# Script: Apply the 2 fresh, verified SQL files directly to DB
# Reads export_fn_VVT_getdatebyVendorLot_MergeCode.sql and export_usp_DoChangeMaterialDocLotInfo.sql

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }

$file1 = Join-Path $scriptPath "export_fn_VVT_getdatebyVendorLot_MergeCode.sql"
$file2 = Join-Path $scriptPath "export_usp_DoChangeMaterialDocLotInfo.sql"

if ((-not (Test-Path $file1)) -or (-not (Test-Path $file2))) {
    Write-Host "ERROR: Missing exported SQL files!" -ForegroundColor Red
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
            Write-Host "SUCCESS! Connected to: $srv" -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "   -> Cannot connect to $srv" -ForegroundColor Gray
    }
}

if (-not $connected) {
    Write-Host "ERROR: Could not connect to any DB Server!" -ForegroundColor Red
    exit
}

try {
    # 1. Apply Function fn_VVT_getdatebyVendorLot_MergeCode
    Write-Host "Applying Function fn_VVT_getdatebyVendorLot_MergeCode (153_SACTRAYHL Fix)..." -ForegroundColor Cyan
    $sqlText1 = [System.IO.File]::ReadAllText($file1, [System.Text.Encoding]::UTF8)
    if ($sqlText1 -match "CREATE\s+FUNCTION") { $sqlText1 = $sqlText1 -replace "CREATE\s+FUNCTION", "ALTER FUNCTION" }
    $cmd1 = $conn.CreateCommand()
    $cmd1.CommandTimeout = 120
    $cmd1.CommandText = $sqlText1
    $cmd1.ExecuteNonQuery()
    Write-Host "[OK] Function fn_VVT_getdatebyVendorLot_MergeCode APPLIED SUCCESSFULLY!" -ForegroundColor Green

    # 2. Apply Stored Procedure usp_DoChangeMaterialDocLotInfo
    Write-Host "Applying Procedure usp_DoChangeMaterialDocLotInfo (153_SACTRAYHL Fix)..." -ForegroundColor Cyan
    $sqlText2 = [System.IO.File]::ReadAllText($file2, [System.Text.Encoding]::UTF8)
    if ($sqlText2 -match "CREATE\s+PROCEDURE") { $sqlText2 = $sqlText2 -replace "CREATE\s+PROCEDURE", "ALTER PROCEDURE" }
    $cmd2 = $conn.CreateCommand()
    $cmd2.CommandTimeout = 120
    $cmd2.CommandText = $sqlText2
    $cmd2.ExecuteNonQuery()
    Write-Host "[OK] Procedure usp_DoChangeMaterialDocLotInfo APPLIED SUCCESSFULLY!" -ForegroundColor Green

    Write-Host "`n======> SUCCESS! ALL FIXES FOR 153_SACTRAYHL APPLIED WITH UTF-8 FONT PRESERVATION! <======" -ForegroundColor Green
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
