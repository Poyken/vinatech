param (
    [string]$SqlPath,
    [string]$Profile = "SmartFactoryV2",
    [switch]$Force,
    [switch]$SkipBackup
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if ([string]::IsNullOrEmpty($SqlPath)) {
    Write-Host "Usage: .\deploy_tool.ps1 -SqlPath <path_to_sql_file> [-Profile <DbProfile>] [-Force] [-SkipBackup]" -ForegroundColor Yellow
    exit 1
}

if (!(Test-Path $SqlPath)) {
    Write-Host "File not found: $SqlPath" -ForegroundColor Red
    exit 1
}

# Run safety validation
$validateScript = Join-Path $PSScriptRoot "validate_sql.ps1"
if (Test-Path $validateScript) {
    if ($Force) {
        & $validateScript -SqlPath $SqlPath -AllowDangerous
    } else {
        & $validateScript -SqlPath $SqlPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Deployment aborted due to safety validation failure. Use -Force to override." -ForegroundColor Red
            exit 1
        }
    }
}

# Load shared database utilities
. (Join-Path $PSScriptRoot "db_shared.ps1")

$sqlText = [System.IO.File]::ReadAllText($SqlPath, [System.Text.Encoding]::UTF8)

# Automatic Pre-flight Snapshot for DML changes
if (-not $SkipBackup) {
    $updateMatches = [regex]::Matches($sqlText, "(?mi)\bUPDATE\s+([a-zA-Z0-9_\[\]\.]+)\s+SET\s+.*?\bWHERE\s+(.+?)(?:;|\bGO\b|\bBEGIN\b|\bCOMMIT\b|\bROLLBACK\b|$)")
    foreach ($m in $updateMatches) {
        $tbl = $m.Groups[1].Value.Trim()
        $where = $m.Groups[2].Value.Trim()
        if ($tbl -and $where) {
            Export-PreflightSnapshot -TableName $tbl -WhereClause $where -Profile $Profile -Reason "deploy_preflight"
        }
    }

    $deleteMatches = [regex]::Matches($sqlText, "(?mi)\bDELETE\s+(?:FROM\s+)?([a-zA-Z0-9_\[\]\.]+)\s+\bWHERE\s+(.+?)(?:;|\bGO\b|\bBEGIN\b|\bCOMMIT\b|\bROLLBACK\b|$)")
    foreach ($m in $deleteMatches) {
        $tbl = $m.Groups[1].Value.Trim()
        $where = $m.Groups[2].Value.Trim()
        if ($tbl -and $where) {
            Export-PreflightSnapshot -TableName $tbl -WhereClause $where -Profile $Profile -Reason "deploy_preflight"
        }
    }
}

$connection = Get-DbConnection -Profile $Profile
if ($connection -eq $null) {
    Write-Error "Cannot connect to database for deployment."
    exit 1
}

try {
    # Clean SQL text for ADO.NET execution (strip USE statements)
    $cleanSql = $sqlText -replace "(?mi)^\s*USE\s+\[?\w+\]?\s*(\r?\n|$)", ""
    
    # Split by GO and run each batch
    $batches = [System.Text.RegularExpressions.Regex]::Split($cleanSql, "(?mi)^\s*GO\s*(\r?\n|$)")
    
    foreach ($batch in $batches) {
        $cleanBatch = $batch.Trim()
        if ($cleanBatch.Length -gt 0) {
            $command = New-Object System.Data.SqlClient.SqlCommand($cleanBatch, $connection)
            $command.CommandTimeout = 120
            $command.ExecuteNonQuery() | Out-Null
        }
    }
    
    Write-Host "Deployed successfully: $SqlPath to DB: $($connection.Database)" -ForegroundColor Green

    # ==========================================================================
    # AUTO-LEARN & AUDIT TRAIL HOOK (Tự động học tri thức từ Hotfix thành công)
    # ==========================================================================
    $logDir = Join-Path (Split-Path -Parent $PSScriptRoot) "AI_AGENT_CONFIG"
    $jsonlPath = Join-Path $logDir "HOTFIX_LOG.jsonl"
    
    $titleMatch = [regex]::Match($sqlText, "(?mi)^\s*--\s*(?:HOTFIX|ISSUE|TITLE)\s*:\s*(.+)$")
    $issueTitle = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { (Split-Path -Leaf $SqlPath) }
    
    $authorMatch = [regex]::Match($sqlText, "(?mi)^\s*--\s*Author.*?:\s*(.+)$")
    $author = if ($authorMatch.Success) { $authorMatch.Groups[1].Value.Trim() } else { "vanduc" }
    
    $targetTables = @()
    if ($updateMatches) { $targetTables += ($updateMatches | ForEach-Object { $_.Groups[1].Value.Trim() }) }
    if ($deleteMatches) { $targetTables += ($deleteMatches | ForEach-Object { $_.Groups[1].Value.Trim() }) }
    $targetTables = $targetTables | Select-Object -Unique
    
    $record = @{
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        file = (Split-Path -Leaf $SqlPath)
        db = $connection.Database
        author = $author
        title = $issueTitle
        tables = $targetTables
    }
    
    $recordJson = ($record | ConvertTo-Json -Compress)
    [System.IO.File]::AppendAllText($jsonlPath, "$recordJson`n", [System.Text.Encoding]::UTF8)
    Write-Host "-> [AUTO-LEARN] Da tu dong cap nhat nhat ky tri thuc: $jsonlPath" -ForegroundColor Cyan
} catch {
    Write-Error "Deployment failed for $SqlPath : $_"
    exit 1
} finally {
    if ($connection.State -eq 'Open') {
        $connection.Close()
    }
}
