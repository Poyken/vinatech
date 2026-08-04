# Script: Export SP & Function definitions to UTF-8 files
# Pure ASCII script structure to prevent any PowerShell encoding parser issues

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }

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
    # 1. Export Function fn_VVT_getdatebyVendorLot_MergeCode
    $file1 = Join-Path $scriptPath "export_fn_VVT_getdatebyVendorLot_MergeCode.sql"
    $cmd1 = $conn.CreateCommand()
    $cmd1.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.fn_VVT_getdatebyVendorLot_MergeCode'))"
    $def1 = $cmd1.ExecuteScalar()
    if ($def1) {
        [System.IO.File]::WriteAllText($file1, $def1, [System.Text.Encoding]::UTF8)
        Write-Host "EXPORT SUCCESS: $file1 (UTF-8)" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Function dbo.fn_VVT_getdatebyVendorLot_MergeCode not found!" -ForegroundColor Red
    }

    # 2. Export Stored Procedure usp_DoChangeMaterialDocLotInfo
    $file2 = Join-Path $scriptPath "export_usp_DoChangeMaterialDocLotInfo.sql"
    $cmd2 = $conn.CreateCommand()
    $cmd2.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.usp_DoChangeMaterialDocLotInfo'))"
    $def2 = $cmd2.ExecuteScalar()
    if ($def2) {
        [System.IO.File]::WriteAllText($file2, $def2, [System.Text.Encoding]::UTF8)
        Write-Host "EXPORT SUCCESS: $file2 (UTF-8)" -ForegroundColor Green
    } else {
        Write-Host "ERROR: SP dbo.usp_DoChangeMaterialDocLotInfo not found!" -ForegroundColor Red
    }
}
catch {
    Write-Host "ERROR EXPORTING: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($null -ne $conn) {
        if ($conn.State -eq [System.Data.ConnectionState]::Open) {
            $conn.Close()
        }
    }
}
