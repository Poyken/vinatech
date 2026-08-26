param (
    [string]$SqlPath,
    [switch]$Force
)

if ([string]::IsNullOrEmpty($SqlPath)) {
    Write-Host "Usage: .\deploy_tool.ps1 -SqlPath <path_to_sql_file> [-Force]" -ForegroundColor Yellow
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

$connection = Get-DbConnection
$connection.Open()

try {
    $sqlText = [System.IO.File]::ReadAllText($SqlPath, [System.Text.Encoding]::UTF8)
    
    # Clean SQL text for ADO.NET execution (strip USE statements)
    $sqlText = $sqlText -replace "(?mi)^\s*USE\s+\[?\w+\]?\s*(\r?\n|$)", ""
    
    # Split by GO and run each batch
    $batches = [System.Text.RegularExpressions.Regex]::Split($sqlText, "(?mi)^\s*GO\s*(\r?\n|$)")
    
    foreach ($batch in $batches) {
        $cleanBatch = $batch.Trim()
        if ($cleanBatch.Length -gt 0) {
            $command = New-Object System.Data.SqlClient.SqlCommand($cleanBatch, $connection)
            $command.ExecuteNonQuery() | Out-Null
        }
    }
    
    Write-Host "Deployed successfully: $SqlPath" -ForegroundColor Green
} catch {
    Write-Error "Deployment failed for $SqlPath : $_"
} finally {
    $connection.Close()
}
