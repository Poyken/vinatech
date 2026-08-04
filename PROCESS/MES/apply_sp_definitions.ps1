# Script: Apply SQL file to DB (UTF-8 Font preservation)
# Usage: .\apply_sp_definitions.ps1 -SqlFile "export_fn_VVT_getdatebyVendorLot_MergeCode.sql"

param (
    [Parameter(Mandatory=$true)]
    [string]$SqlFile,
    [string]$Server = ""
)

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }

$targetFilePath = Join-Path $scriptPath $SqlFile
if (-not (Test-Path $targetFilePath)) {
    $targetFilePath = $SqlFile
}

if (-not (Test-Path $targetFilePath)) {
    Write-Host "ERROR: File not found: $targetFilePath" -ForegroundColor Red
    exit
}

$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

$serversToTry = @(
    "dbserver.hycap.co.kr,5398",
    "175.201.218.156,5398",
    "192.168.112.254,5398",
    "192.168.1.234,5398",
    "192.168.1.200,5398",
    "192.168.1.100,5398",
    "localhost",
    "127.0.0.1"
)

if ($Server -ne "") {
    $serversToTry = @($Server) + $serversToTry
}

$cfgPath = Join-Path $scriptPath "db_config.json"
if (Test-Path $cfgPath) {
    try {
        $cfg = Get-Content -Raw -Path $cfgPath | ConvertFrom-Json
        if ($cfg.Server) { $serversToTry = @($cfg.Server) + $serversToTry }
        if ($cfg.Database) { $database = $cfg.Database }
        if ($cfg.User) { $user = $cfg.User }
        if ($cfg.Password) { $password = $cfg.Password }
    } catch {}
}

$serversToTry = $serversToTry | Select-Object -Unique

# Read SQL content with UTF-8 encoding
$sqlText = [System.IO.File]::ReadAllText($targetFilePath, [System.Text.Encoding]::UTF8)

# Convert CREATE to ALTER if needed
if ($sqlText -match "CREATE\s+FUNCTION") {
    $sqlText = $sqlText -replace "CREATE\s+FUNCTION", "ALTER FUNCTION"
}
if ($sqlText -match "CREATE\s+PROCEDURE") {
    $sqlText = $sqlText -replace "CREATE\s+PROCEDURE", "ALTER PROCEDURE"
}
if ($sqlText -match "CREATE\s+PROC\s") {
    $sqlText = $sqlText -replace "CREATE\s+PROC\s", "ALTER PROC "
}

$connected = $false
$workingServer = ""
$conn = $null

foreach ($srv in $serversToTry) {
    Write-Host "Trying to connect Server: $srv ..." -ForegroundColor Cyan
    $connStr = "Server=$srv;Database=$database;User Id=$user;Password=$password;Connect Timeout=5;Encrypt=False;"
    $testConn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    try {
        $testConn.Open()
        if ($testConn.State -eq [System.Data.ConnectionState]::Open) {
            $connected = $true
            $workingServer = $srv
            $conn = $testConn
            Write-Host "SUCCESS! Connected to Server: $srv" -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "   -> Cannot connect to $srv" -ForegroundColor Gray
    }
}

if (-not $connected) {
    Write-Host "ERROR: Could not connect to any DB server!" -ForegroundColor Red
    exit
}

try {
    Write-Host "Applying SQL File: $targetFilePath to $workingServer ..." -ForegroundColor Cyan
    $cmd = $conn.CreateCommand()
    $cmd.CommandTimeout = 120
    $cmd.CommandText = $sqlText
    $cmd.ExecuteNonQuery()
    Write-Host "APPLY SUCCESSFUL!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR APPLYING SQL: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($null -ne $conn) {
        if ($conn.State -eq [System.Data.ConnectionState]::Open) {
            $conn.Close()
        }
    }
}
