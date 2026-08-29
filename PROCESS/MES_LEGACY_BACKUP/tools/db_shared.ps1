# db_shared.ps1 — Shared Database Functions & Configuration Loader for Vinatech MES
# Multi-DB Profiles | Auto-Failover | Pre-flight Backup | Safe Execution

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$configPath = Join-Path $PSScriptRoot "db_config.json"
if (-not (Test-Path $configPath)) {
    $configPath = Join-Path $PSScriptRoot "..\db_config.json"
}
if (!(Test-Path $configPath)) {
    Write-Error "Configuration file not found at: $configPath"
    exit 1
}

try {
    $global:mesConfig = Get-Content -Raw -Path $configPath -Encoding UTF8 | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse db_config.json: $_"
    exit 1
}

# Resolve DB configuration for a given profile
function Get-DbProfileConfig {
    param (
        [string]$Profile = ""
    )
    
    $cfg = $global:mesConfig
    $server = $cfg.Server
    $db = $cfg.Database
    $user = $cfg.User
    $pwd = $cfg.Password
    $timeout = if ($cfg.Timeout) { $cfg.Timeout } else { 30 }
    
    # Profile mapping aliases
    $aliases = @{
        "MES"        = "SmartFactoryV2"
        "SMARTFACTORY" = "SmartFactoryV2"
        "AUTH"       = "SmartFramework"
        "FRAMEWORK"  = "SmartFramework"
        "GW"         = "Groupware"
        "GROUPWARE"  = "Groupware"
        "ERP"        = "ERP"
        "DOUZONE"    = "ERP"
        "BIZBOX"     = "Bizbox"
        "DZICUBE"    = "Bizbox"
        "POP"        = "POP"
        "ANDON"      = "Andon"
        "SSO"        = "SSO"
        "WEBSOCKET"  = "WebSocket"
        "EXCEL"      = "Spreadsheet"
        "SPREADSHEET" = "Spreadsheet"
        "WCMS"       = "WCMS"
        "INCUBATOR"  = "Incubator"
        "KSOX"       = "KSOX"
        "LEGACY"     = "LegacyERP"
        "STREAMDOCS" = "StreamDocs"
    }

    if (![string]::IsNullOrEmpty($Profile)) {
        $pUpper = $Profile.Trim().ToUpper()
        $matchedKey = $null

        if ($aliases.ContainsKey($pUpper)) {
            $matchedKey = $aliases[$pUpper]
        } else {
            foreach ($key in $cfg.Profiles.PSObject.Properties.Name) {
                if ($key.ToUpper() -eq $pUpper) {
                    $matchedKey = $key
                    break
                }
            }
        }

        if ($matchedKey -and $cfg.Profiles.$matchedKey) {
            $profileObj = $cfg.Profiles.$matchedKey
            $db = $profileObj.Database
            if ($profileObj.Server) { $server = $profileObj.Server }
            if ($profileObj.User) { $user = $profileObj.User }
            if ($profileObj.Password) { $pwd = $profileObj.Password }
            if ($profileObj.Timeout) { $timeout = $profileObj.Timeout }
        } else {
            # Check if profile string matches actual database name
            $db = $Profile
        }
    }

    $failovers = if ($cfg.FailoverServers) { @($cfg.FailoverServers) } else { @($server) }
    if ($failovers -notcontains $server) {
        $failovers = @($server) + $failovers
    }

    return @{
        Server          = $server
        Database        = $db
        User            = $user
        Password        = $pwd
        Timeout         = $timeout
        FailoverServers = $failovers
        ProfileName     = if ($Profile) { $Profile } else { "Default" }
    }
}

# Construct connection string
function Get-ConnectionString {
    param(
        [string]$Profile = "",
        [string]$ServerOverride = ""
    )
    $p = Get-DbProfileConfig -Profile $Profile
    $srv = if ($ServerOverride) { $ServerOverride } else { $p.Server }
    return "Server=$srv;Database=$($p.Database);User Id=$($p.User);Password=$($p.Password);TrustServerCertificate=True;Timeout=$($p.Timeout);Encrypt=False;"
}

# Create and open SQL Connection with Auto-Failover
function Get-DbConnection {
    param(
        [string]$Profile = "",
        [switch]$Silent,
        [int]$ConnectTimeoutSeconds = 15
    )

    $p = Get-DbProfileConfig -Profile $Profile
    $servers = $p.FailoverServers

    foreach ($srv in $servers) {
        if (-not $Silent) {
            Write-Host "Connecting to SQL Server: $srv (DB: $($p.Database))..." -ForegroundColor Cyan
        }
        $connStr = "Server=$srv;Database=$($p.Database);User Id=$($p.User);Password=$($p.Password);Connect Timeout=$ConnectTimeoutSeconds;TrustServerCertificate=True;Encrypt=False;"
        $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
        try {
            $conn.Open()
            if ($conn.State -eq 'Open') {
                if (-not $Silent) {
                    Write-Host "Connected successfully to: $srv ($($p.Database))" -ForegroundColor Green
                }
                return $conn
            }
        } catch {
            if (-not $Silent) {
                Write-Host "  -> Failed on $($srv) : $($_.Exception.Message)" -ForegroundColor DarkGray
            }
            if ($conn -ne $null -and $conn.State -eq 'Open') { $conn.Close() }
        }
    }

    if (-not $Silent) {
        Write-Error "Failed to connect to any SQL Server for DB '$($p.Database)'"
    }
    return $null
}

# Execute Read-Only SQL Query on an open connection and format results
function Execute-SqlQuery {
    param(
        [System.Data.SqlClient.SqlConnection]$Connection,
        [string]$Query
    )
    if ($Connection -eq $null -or [string]::IsNullOrWhiteSpace($Query)) { return }
    try {
        $cmd = $Connection.CreateCommand()
        $cmd.CommandTimeout = 60
        $cmd.CommandText = $Query
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $null = $adapter.Fill($dt)
        if ($dt.Rows.Count -eq 0) {
            Write-Host "  (0 rows returned)" -ForegroundColor Gray
        } else {
            $dt | Format-Table -AutoSize | Out-String -Width 4000 | Write-Host -ForegroundColor White
        }
    } catch {
        Write-Host "  LOI SQL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Pre-flight Data Backup: Export snapshot before data modification
function Export-PreflightSnapshot {
    param(
        [string]$TableName,
        [string]$WhereClause,
        [string]$Profile = "SmartFactoryV2",
        [string]$Reason = "hotfix"
    )

    if ([string]::IsNullOrWhiteSpace($TableName) -or [string]::IsNullOrWhiteSpace($WhereClause)) {
        Write-Warning "Cannot create snapshot without TableName and WhereClause."
        return $null
    }

    $backupDir = Join-Path $PSScriptRoot "backups"
    if (!(Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $cleanTable = $TableName -replace "[\[\]\s\.]", ""
    $snapshotFile = Join-Path $backupDir "preflight_${timestamp}_${cleanTable}_${Reason}.json"

    $conn = Get-DbConnection -Profile $Profile -Silent
    if ($conn -eq $null) { return $null }

    try {
        $sql = "SELECT * FROM $TableName WITH(NOLOCK) WHERE $WhereClause"
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $sql
        $cmd.CommandTimeout = 30

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $null = $adapter.Fill($dt)

        if ($dt.Rows.Count -gt 0) {
            $rowsList = @()
            foreach ($row in $dt.Rows) {
                $rowDict = [ordered]@{}
                foreach ($col in $dt.Columns) {
                    $val = $row[$col.ColumnName]
                    if ($val -is [System.DBNull]) {
                        $rowDict[$col.ColumnName] = $null
                    } else {
                        $rowDict[$col.ColumnName] = $val
                    }
                }
                $rowsList += $rowDict
            }

            $meta = [ordered]@{
                Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                Database  = $conn.Database
                Table     = $TableName
                Where     = $WhereClause
                RowCount  = $dt.Rows.Count
                Data      = $rowsList
            }

            $jsonContent = $meta | ConvertTo-Json -Depth 5
            [System.IO.File]::WriteAllText($snapshotFile, $jsonContent, [System.Text.Encoding]::UTF8)
            Write-Host "(!) [PRE-FLIGHT BACKUP] Saved $($dt.Rows.Count) records to: $snapshotFile" -ForegroundColor Yellow
            return $snapshotFile
        } else {
            Write-Host "(!) [PRE-FLIGHT BACKUP] 0 records matched WHERE clause. No snapshot saved." -ForegroundColor Gray
            return $null
        }
    } catch {
        Write-Warning "Pre-flight snapshot failed: $_"
        return $null
    } finally {
        if ($conn -and $conn.State -eq 'Open') { $conn.Close() }
    }
}

# Validate SQL read-only safety rules (for run_query.ps1 / mes query)
function Test-SqlReadOnlySafety {
    param (
        [string]$SqlText
    )
    
    $restrictedKeywords = @(
        "\bINSERT\b", "\bUPDATE\b", "\bDELETE\b", "\bMERGE\b",
        "\bDROP\b", "\bALTER\b", "\bTRUNCATE\b", "\bCREATE\b"
    )
    
    foreach ($keyword in $restrictedKeywords) {
        if ($SqlText -match "(?mi)$keyword") {
            return @{
                IsValid = $false
                Error = "Safety violation: Modifying command detected ($keyword). Read-only queries only."
            }
        }
    }
    
    return @{ IsValid = $true }
}

# Generate warnings if queries access key transactional tables without NOLOCK
function Get-NoLockWarnings {
    param (
        [string]$SqlText
    )
    
    $warnings = @()
    $transactionTables = @("STB_ProdRouteHist", "STB_MaterialLotInfo", "STB_SetInfo", "STB_MaterialDocDetail", "STB_MaterialStock")
    
    foreach ($table in $transactionTables) {
        if ($SqlText -match "(?mi)\b$table\b" -and $SqlText -notmatch "(?mi)\b$table\b.*\bNOLOCK\b" -and $SqlText -notmatch "(?mi)\bNOLOCK\b.*\b$table\b") {
            $warnings += "Warning: Query accesses transactional table '$table' without WITH(NOLOCK). Please add WITH(NOLOCK) to prevent table locks."
        }
    }
    
    return $warnings
}

# Validate SQL deployment safety rules
function Test-SqlDeploySafety {
    param (
        [string]$SqlText,
        [bool]$AllowDangerous = $false
    )
    
    $isValid = $true
    $errors = @()
    $warnings = @()
    
    $isRoutineDefinition = $SqlText -match "(?mi)\b(CREATE|ALTER)\s+(OR\s+ALTER\s+)?(PROCEDURE|PROC|FUNCTION|VIEW|TRIGGER)\b"
    $hasDML = $SqlText -match "(?mi)\b(INSERT|UPDATE|DELETE|MERGE)\b"
    
    if ($hasDML -and -not $isRoutineDefinition) {
        if ($SqlText -notmatch "(?mi)\bBEGIN\s+(TRAN|TRANSACTION)\b") {
            $errors += "Validation Error: SQL contains DML (INSERT/UPDATE/DELETE) but is missing 'BEGIN TRAN'."
            $isValid = $false
        }
        
        if ($SqlText -notmatch "(?mi)\b(ROLLBACK|COMMIT)\s+(TRAN|TRANSACTION)?\b") {
            $errors += "Validation Error: SQL contains DML but is missing 'ROLLBACK' or 'COMMIT'."
            $isValid = $false
        }
        
        if ($SqlText -match "(?mi)\b(UPDATE|DELETE)\b" -and $SqlText -notmatch "(?mi)\b(WHERE|JOIN)\b") {
            $errors += "Validation Error: SQL contains UPDATE/DELETE without WHERE or JOIN clause! Extremely dangerous."
            $isValid = $false
        }
    }
    
    $dangerousDDLKeywords = @(
        "\bDROP\s+TABLE\s+(?!(?:#|(?:\[?dbo\]?\.)?\[?B(?:K|AK)_))\S+",
        "\bDROP\s+DATABASE\b",
        "\bTRUNCATE\s+TABLE\b",
        "\bALTER\s+TABLE\s+(?!(?:#|(?:\[?dbo\]?\.)?\[?B(?:K|AK)_))\S+"
    )
    
    foreach ($keyword in $dangerousDDLKeywords) {
        if ($SqlText -match "(?mi)$keyword") {
            if ($AllowDangerous) {
                $warnings += "Warning: Dangerous DDL statement detected ($keyword) but allowed via -AllowDangerous."
            } else {
                $errors += "Validation Error: Dangerous DDL statement detected ($keyword)."
                $isValid = $false
            }
        }
    }
    
    return @{
        IsValid  = $isValid
        Errors   = $errors
        Warnings = $warnings
    }
}

# Scan local markdown files for keywords
function Invoke-ProactiveKbSearch {
    param (
        [string]$SqlText
    )

    if ([string]::IsNullOrEmpty($SqlText)) { return }

    $keywords = @()
    $spMatches = [regex]::Matches($SqlText, '\b[uU][sS][pP]_[a-zA-Z0-9_]+\b')
    foreach ($m in $spMatches) { $keywords += $m.Value }
    
    $tblMatches = [regex]::Matches($SqlText, '\b(?:[sS][tT][bB]|[vV][vV][tT])_[a-zA-Z0-9_]+\b')
    foreach ($m in $tblMatches) { $keywords += $m.Value }
    
    $scrMatches = [regex]::Matches($SqlText, '\b(?:HN)?[a-zA-Z][0-9]{3}\b')
    foreach ($m in $scrMatches) { $keywords += $m.Value }
    
    $keywords = $keywords | Select-Object -Unique
    if ($keywords.Count -eq 0) { return }
    
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "(!) [KB SUGGESTION] Detected keywords: $($keywords -join ', ')" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Cyan

    $dirs = @(
        (Join-Path $PSScriptRoot "MES_MASTER_KNOWLEDGE_BASE"),
        (Join-Path $PSScriptRoot "DATABASE_KNOWLEDGE_BASE"),
        (Join-Path $PSScriptRoot "GROUPWARE_KNOWLEDGE_BASE"),
        (Join-Path $PSScriptRoot "AI_AGENT_CONFIG")
    )
    
    $files = @()
    foreach ($d in $dirs) {
        if (Test-Path $d) { $files += Get-ChildItem -Path $d -Filter "*.md" -Recurse }
    }
    
    foreach ($keyword in $keywords) {
        $keywordMatchCount = 0
        Write-Host "--> Keyword: $keyword" -ForegroundColor Yellow
        
        foreach ($file in $files) {
            $relative = $file.FullName.Replace($PSScriptRoot, ".").Replace("\", "/")
            $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
            if (-not $content) { continue }
            
            $lineNum = 1
            $fileMatches = 0
            foreach ($line in $content) {
                if ($line -match [regex]::Escape($keyword)) {
                    $trimmed = $line.Trim()
                    if ($trimmed.Length -gt 5 -and $trimmed -notmatch "^[#\-\s\=\|]+$") {
                        Write-Host ("  [" + $relative + ":" + $lineNum + "] ") -NoNewline -ForegroundColor Gray
                        Write-Host "$trimmed" -ForegroundColor White
                        $fileMatches++
                        $keywordMatchCount++
                    }
                }
                if ($fileMatches -ge 3) { break }
                $lineNum++
            }
            if ($keywordMatchCount -ge 6) { break }
        }
        
        if ($keywordMatchCount -eq 0) {
            Write-Host "  No business rules documented for $keyword." -ForegroundColor Gray
        }
        Write-Host ""
    }
    Write-Host "======================================================================" -ForegroundColor Cyan
}
