# ==============================================================================
# PROCESS/tools/shared/db_shared.ps1 — VINATECH UNIFIED DATABASE CORE ENGINE (v4.0)
# Multi-DB Profiles (15 CSDL) | Failover | Safe Execution | Pre-flight Snapshots
# Single Source of Truth for MES_POP, GROUPWARE, DATABASE, FINAL (K-System)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Universal Root Detection
$script:processRoot = $null
$candidateDirs = @(
    $PSScriptRoot,
    (Split-Path $PSScriptRoot -Parent),
    (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
    "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS"
)

foreach ($d in $candidateDirs) {
    if ($d -and (Test-Path (Join-Path $d "README.md")) -and (Test-Path (Join-Path $d "MES_POP"))) {
        $script:processRoot = $d
        break
    }
}
if (-not $script:processRoot) {
    $script:processRoot = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS"
}

# Resolve Configuration: .local.json (private) -> db_config.json
$configCandidates = @(
    (Join-Path $script:processRoot "db_config.local.json"),
    (Join-Path $script:processRoot "MES_POP\db_config.local.json"),
    (Join-Path $script:processRoot "db_config.json"),
    (Join-Path $script:processRoot "MES_POP\db_config.json"),
    (Join-Path $script:processRoot "DATABASE\db_config.json")
)

$script:configFile = $null
foreach ($f in $configCandidates) {
    if (Test-Path $f) {
        $script:configFile = $f
        break
    }
}

if (-not $script:configFile) {
    Write-Error "CRITICAL: Cannot find db_config.json across PROCESS workspace roots!"
    exit 1
}

try {
    $global:vinaMasterDbConfig = Get-Content -Raw -Path $script:configFile -Encoding UTF8 | ConvertFrom-Json
    $global:mesConfig = $global:vinaMasterDbConfig
} catch {
    Write-Error "Failed to parse database configuration ($script:configFile): $_"
    exit 1
}

# 15 Database Profiles & Canonical Mapping
function Get-DbProfileConfig {
    param (
        [string]$Profile = ""
    )
    
    $cfg = $global:vinaMasterDbConfig
    $server = $cfg.Server
    $db = $cfg.Database
    $user = $cfg.User
    $pwd = $cfg.Password
    $timeout = if ($cfg.Timeout) { $cfg.Timeout } else { 30 }
    
    $aliases = @{
        "MES"           = "SmartFactoryV2"
        "SMARTFACTORY"  = "SmartFactoryV2"
        "AUTH"          = "SmartFramework"
        "FRAMEWORK"     = "SmartFramework"
        "GW"            = "Groupware"
        "GROUPWARE"     = "Groupware"
        "ERP"           = "ERP"
        "DOUZONE"       = "ERP"
        "BIZBOX"        = "Bizbox"
        "DZICUBE"       = "Bizbox"
        "POP"           = "POP"
        "ANDON"         = "Andon"
        "SSO"           = "SSO"
        "WEBSOCKET"     = "WebSocket"
        "EXCEL"         = "Spreadsheet"
        "SPREADSHEET"   = "Spreadsheet"
        "WCMS"          = "WCMS"
        "INCUBATOR"     = "Incubator"
        "KSOX"          = "KSOX"
        "LEGACY"        = "LegacyERP"
        "STREAMDOCS"    = "StreamDocs"
        "KSYS"          = "VINATECVN"
        "KSYSTEM"       = "VINATECVN"
        "KSYSCOMMON"    = "VINATECVNCommon"
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

# Compatibility for DATABASE/db.ps1
function Get-DBConfig {
    return $global:vinaMasterDbConfig
}

function Get-ConnectionString {
    param(
        [string]$Profile = "",
        [string]$ServerOverride = ""
    )
    $p = Get-DbProfileConfig -Profile $Profile
    $targetServer = if ($ServerOverride) { $ServerOverride } else { $p.Server }
    return "Server=$targetServer;Database=$($p.Database);User Id=$($p.User);Password=$($p.Password);TrustServerCertificate=True;Connect Timeout=$($p.Timeout);Application Name=Vinatech_Master_Ops"
}

# Unified Get-DbConnection (Supports both $conn directly and $dbObj.Connection / $dbObj.Server)
function Get-DbConnection {
    param (
        [string]$Profile = "SmartFactoryV2",
        [string]$CustomDB = $null,
        [switch]$Silent,
        [int]$ConnectTimeoutSeconds = 15
    )
    $p = Get-DbProfileConfig -Profile $Profile
    if ($CustomDB) { $p.Database = $CustomDB }
    $timeout = if ($ConnectTimeoutSeconds) { $ConnectTimeoutSeconds } else { $p.Timeout }
    
    foreach ($srv in $p.FailoverServers) {
        $connStr = "Server=$srv;Database=$($p.Database);User Id=$($p.User);Password=$($p.Password);TrustServerCertificate=True;Connect Timeout=$timeout;Application Name=Vinatech_Master_Ops"
        try {
            $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
            $conn.Open()
            if ($conn.State -eq 'Open') {
                # Attach properties so caller can use both $conn directly OR $dbObj.Connection / $dbObj.Server / $dbObj.Database
                $conn | Add-Member -NotePropertyName "Connection" -NotePropertyValue $conn -Force
                $conn | Add-Member -NotePropertyName "Server" -NotePropertyValue $srv -Force
                $conn | Add-Member -NotePropertyName "Database" -NotePropertyValue $p.Database -Force
                $conn | Add-Member -NotePropertyName "Profile" -NotePropertyValue $Profile -Force
                return $conn
            }
        } catch {
            if (-not $Silent) {
                Write-Verbose "Connection failed to $srv ($($p.Database)): $($_.Exception.Message)"
            }
            if ($conn -ne $null -and $conn.State -eq 'Open') { $conn.Close() }
        }
    }
    throw "Cannot connect to database profile: $Profile across all failovers."
}

# Compatibility for GROUPWARE/tools/gw_trace.ps1
function Invoke-DbQuery {
    param(
        [string]$Profile = "Groupware",
        [string]$Query = ""
    )
    if ([string]::IsNullOrWhiteSpace($Query)) { return $null }
    $conn = Get-DbConnection -Profile $Profile -Silent
    if ($conn -eq $null) { return $null }
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 60
        $cmd.CommandText = $Query
        $reader = $cmd.ExecuteReader()
        $dt = New-Object System.Data.DataTable
        $dt.Load($reader)
        $reader.Close()
        return ,$dt
    } catch {
        Write-Host "Invoke-DbQuery ERROR: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    } finally {
        if ($conn.State -eq 'Open') { $conn.Close() }
    }
}

# Safe SQL Query Execution
function Invoke-SafeSqlQuery {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Query,
        
        [string]$Profile = "",
        [hashtable]$Parameters = @{},
        [int]$TimeoutSeconds = 0,
        [switch]$AsDataTable
    )

    $p = Get-DbProfileConfig -Profile $Profile
    $lastError = $null

    foreach ($server in $p.FailoverServers) {
        $connStr = Get-ConnectionString -Profile $Profile -ServerOverride $server
        $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)

        try {
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $Query
            $cmd.CommandTimeout = if ($TimeoutSeconds -gt 0) { $TimeoutSeconds } else { $p.Timeout }

            if ($Parameters) {
                foreach ($key in $Parameters.Keys) {
                    $paramName = if ($key.StartsWith("@")) { $key } else { "@$key" }
                    $cmd.Parameters.AddWithValue($paramName, $Parameters[$key]) | Out-Null
                }
            }

            $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
            $dataSet = New-Object System.Data.DataSet
            $adapter.Fill($dataSet) | Out-Null
            $conn.Close()

            if ($dataSet.Tables.Count -eq 0) {
                return @()
            }

            if ($AsDataTable) {
                return $dataSet.Tables[0]
            }

            $table = $dataSet.Tables[0]
            $results = @()
            foreach ($row in $table.Rows) {
                $obj = New-Object PSObject
                foreach ($col in $table.Columns) {
                    $val = $row[$col.ColumnName]
                    if ($val -is [System.DBNull]) { $val = $null }
                    $obj | Add-Member -MemberType NoteProperty -Name $col.ColumnName -Value $val
                }
                $results += $obj
            }
            return $results

        } catch {
            $lastError = $_
            if ($conn.State -eq [System.Data.ConnectionState]::Open) {
                $conn.Close()
            }
        }
    }

    throw "Safe SQL Query execution failed across all failover servers: $lastError"
}

function Invoke-SafeSqlScalar {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Query,
        [string]$Profile = "",
        [hashtable]$Parameters = @{}
    )
    $results = Invoke-SafeSqlQuery -Query $Query -Profile $Profile -Parameters $Parameters
    if ($results -and $results.Count -gt 0) {
        $firstRow = $results[0]
        $firstProp = ($firstRow.PSObject.Properties | Select-Object -First 1).Name
        return $firstRow.$firstProp
    }
    return $null
}

# Safe Snapshot & Auto-Undo File Generator
function Create-SafePreflightSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetTable,
        [Parameter(Mandatory = $true)]
        [string]$WhereClause,
        [string]$Profile = "SmartFactoryV2",
        [string]$TargetId = "HOTFIX"
    )

    $snapshotDir = Join-Path $script:processRoot "backups\snapshots"
    $undoDir = Join-Path $script:processRoot "backups\undo"
    if (-not (Test-Path $snapshotDir)) { New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null }
    if (-not (Test-Path $undoDir)) { New-Item -ItemType Directory -Path $undoDir -Force | Out-Null }

    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $cleanWhere = $WhereClause.Trim()
    if ($cleanWhere.ToUpper().StartsWith("WHERE ")) {
        $cleanWhere = $cleanWhere.Substring(6)
    }

    $selectQuery = "SELECT * FROM $TargetTable WITH (NOLOCK) WHERE $cleanWhere"
    $rows = Invoke-SafeSqlQuery -Query $selectQuery -Profile $Profile

    if (-not $rows -or $rows.Count -eq 0) {
        Write-Warning "Pre-flight snapshot: No rows matched for [$TargetTable] WHERE $cleanWhere"
        return $null
    }

    # Save JSON Snapshot
    $snapFile = Join-Path $snapshotDir "snap_${TargetId}_${timestamp}.json"
    $jsonText = $rows | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($snapFile, $jsonText, (New-Object System.Text.UTF8Encoding($true)))

    # Generate Undo SQL
    $undoFile = Join-Path $undoDir "undo_${TargetId}_${timestamp}.sql"
    $undoSql = New-Object System.Text.StringBuilder
    $undoSql.AppendLine("-- ==============================================================================") | Out-Null
    $undoSql.AppendLine("-- AUTOMATIC REVERSIBLE UNDO SCRIPT") | Out-Null
    $undoSql.AppendLine("-- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Target: $TargetId") | Out-Null
    $undoSql.AppendLine("-- Profile: $Profile | TargetTable: $TargetTable") | Out-Null
    $undoSql.AppendLine("-- Author: vanduc | ChangeUserID: vanduc") | Out-Null
    $undoSql.AppendLine("-- ==============================================================================") | Out-Null
    $undoSql.AppendLine("BEGIN TRANSACTION;") | Out-Null
    $undoSql.AppendLine("BEGIN TRY") | Out-Null

    foreach ($r in $rows) {
        $setClauses = @()
        $pkWhere = @()
        foreach ($prop in $r.PSObject.Properties) {
            $colName = $prop.Name
            $val = $prop.Value
            if ($colName -in @("LotID", "LOTNO", "WO_NO", "DayPlanNo", "RouteSeq", "Barcode", "OrderNo", "PlanNo")) {
                if ($val -ne $null) {
                    $pkWhere += "[$colName] = '$($val.ToString().Replace("'", "''"))'"
                }
            } else {
                if ($val -eq $null) {
                    $setClauses += "[$colName] = NULL"
                } elseif ($val -is [DateTime]) {
                    $setClauses += "[$colName] = '$($val.ToString('yyyy-MM-dd HH:mm:ss.fff'))'"
                } elseif ($val -is [bool]) {
                    $setClauses += "[$colName] = $(if ($val) { 1 } else { 0 })"
                } elseif ($val -is [int] -or $val -is [double] -or $val -is [decimal]) {
                    $setClauses += "[$colName] = $val"
                } else {
                    $setClauses += "[$colName] = N'$($val.ToString().Replace("'", "''"))'"
                }
            }
        }
        
        $whereCond = if ($pkWhere.Count -gt 0) { $pkWhere -join " AND " } else { $cleanWhere }
        $undoSql.AppendLine("    UPDATE $TargetTable SET $($setClauses -join ', ') WHERE $whereCond;") | Out-Null
    }

    $undoSql.AppendLine("    COMMIT TRANSACTION;") | Out-Null
    $undoSql.AppendLine("    PRINT '[SUCCESS] Reversible Undo executed cleanly.';") | Out-Null
    $undoSql.AppendLine("END TRY") | Out-Null
    $undoSql.AppendLine("BEGIN CATCH") | Out-Null
    $undoSql.AppendLine("    ROLLBACK TRANSACTION;") | Out-Null
    $undoSql.AppendLine("    PRINT '[ERROR] Reversible Undo failed: ' + ERROR_MESSAGE();") | Out-Null
    $undoSql.AppendLine("END CATCH;") | Out-Null

    [System.IO.File]::WriteAllText($undoFile, $undoSql.ToString(), (New-Object System.Text.UTF8Encoding($true)))

    Write-Host "[OK] Pre-flight Snapshot: $snapFile ($($rows.Count) rows)" -ForegroundColor Green
    Write-Host "[OK] Auto-Undo Script: $undoFile (Profile: $Profile)" -ForegroundColor Cyan


    return @{
        SnapshotFile = $snapFile
        UndoFile     = $undoFile
        RowCount     = $rows.Count
    }
}

# Centralized Hotfix Audit Logger
function Write-HotfixAuditLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$System, # 'POP' or 'MES' or 'GW' or 'DB' or 'KSYS'
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [Parameter(Mandatory = $true)]
        [string]$Action,
        [string]$ScriptFile = "",
        [string]$UndoFile = "",
        [string]$Status = "COMMITTED",
        [string]$Remark = ""
    )

    $logDir = Join-Path $script:processRoot "logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    $logFile = Join-Path $logDir "hotfix_audit.jsonl"

    $entry = @{
        Timestamp  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Author     = "vanduc"
        System     = $System.ToUpper()
        Target     = $Target
        Action     = $Action
        ScriptFile = $ScriptFile
        UndoFile   = $UndoFile
        Status     = $Status
        Remark     = $Remark
    }

    $jsonLine = $entry | ConvertTo-Json -Compress
    Add-Content -Path $logFile -Value $jsonLine -Encoding UTF8
    Write-Host "[AUDIT] Logged $System intervention on $Target to $logFile" -ForegroundColor DarkCyan
}

# Proactive KB Keyword Search Across All 5 Pillars
function Invoke-ProactiveKbSearch {
    param (
        [string]$SqlText
    )

    if ([string]::IsNullOrEmpty($SqlText)) { return }

    $keywords = @()
    $spMatches = [regex]::Matches($SqlText, '\b[uU][sS][pP]_[a-zA-Z0-9_]+\b')
    foreach ($m in $spMatches) { $keywords += $m.Value }
    
    $tblMatches = [regex]::Matches($SqlText, '\b(?:[sS][tT][bB]|[vV][vV][tT]|_TPR|_TMA|_TAC)_[a-zA-Z0-9_]+\b')
    foreach ($m in $tblMatches) { $keywords += $m.Value }
    
    $scrMatches = [regex]::Matches($SqlText, '\b(?:HN)?[a-zA-Z][0-9]{3}\b')
    foreach ($m in $scrMatches) { $keywords += $m.Value }
    
    $keywords = $keywords | Select-Object -Unique
    if ($keywords.Count -eq 0) { return }
    
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "(!) [KB PROACTIVE SEARCH] Detected entities: $($keywords -join ', ')" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Cyan

    $dirs = @(
        (Join-Path $script:processRoot "MES_POP\MES_MASTER_KNOWLEDGE_BASE"),
        (Join-Path $script:processRoot "MES_POP\POP_KNOWLEDGE_BASE"),
        (Join-Path $script:processRoot "MES_POP\AI_AGENT_CONFIG"),
        (Join-Path $script:processRoot "DATABASE\DATABASE_KNOWLEDGE_BASE"),
        (Join-Path $script:processRoot "GROUPWARE\GROUPWARE_KNOWLEDGE_BASE"),
        (Join-Path $script:processRoot "FINAL\ARCHITECTURE"),
        (Join-Path $script:processRoot "FINAL\AI_AGENT_CONFIG")
    )
    
    $files = @()
    foreach ($d in $dirs) {
        if (Test-Path $d) { $files += Get-ChildItem -Path $d -Filter "*.md" -Recurse }
    }
    
    foreach ($keyword in $keywords) {
        $keywordMatchCount = 0
        Write-Host "--> Entity: $keyword" -ForegroundColor Yellow
        
        foreach ($file in $files) {
            $relative = $file.FullName.Replace($script:processRoot, ".").Replace("\", "/")
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
            Write-Host "  No business rules explicitly documented for $keyword." -ForegroundColor Gray
        }
        Write-Host ""
    }
    Write-Host "======================================================================" -ForegroundColor Cyan
}

function Export-PreflightSnapshot {
    param(
        [Parameter(Mandatory=$true)]
        [string]$TableName,
        [Parameter(Mandatory=$true)]
        [string]$WhereClause,
        [string]$Profile = "SmartFactoryV2",
        [string]$Reason = "preflight"
    )
    return Create-SafePreflightSnapshot -TargetTable $TableName -WhereClause $WhereClause -Profile $Profile -TargetId $Reason
}

# Backward compatibility aliases for DATABASE & GROUPWARE pillars
function Invoke-SafeSelect {
    param(
        [Parameter(Mandatory=$true)][string]$Query,
        [string]$Profile = "SmartFactoryV2",
        [int]$MaxRows = 50,
        [int]$TimeoutSeconds = 15
    )
    return Invoke-SafeSqlQuery -Query $Query -Profile $Profile
}

function Get-DBConfig {
    param([string]$ConfigPath = "")
    return $global:mesConfig
}
