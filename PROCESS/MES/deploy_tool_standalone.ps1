# ==============================================================================
# SCRIPT DEPLOY DATABASE STANDALONE (MANG SANG MÁY KHÁC NẠP VÀO DB)
# TỰ ĐỘNG HÓA 100% - CHẠY TRÊN MỌI PHIÊN BẢN POWERSHELL - BẢO TOÀN FONT UNICODE
# Usage: .\deploy_tool_standalone.ps1
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }

$sqlFile = Join-Path $scriptPath "DEPLOY_TO_DATABASE.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Host "Khong tim thay file DEPLOY_TO_DATABASE.sql tai: $sqlFile" -ForegroundColor Red
    exit
}

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

$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

$cfgPath = Join-Path $scriptPath "db_config.json"
if (Test-Path $cfgPath) {
    try {
        $cfg = Get-Content -Raw -Path $cfgPath | ConvertFrom-Json
        if ($cfg.Server) { $serversToTry = @($cfg.Server) + $serversToTry }
        if ($cfg.Database) { $database = $cfg.Database }
        if ($cfg.User) { $user = $cfg.User }
        if ($cfg.Password) { $password = $cfg.Password }
    } catch {
        # ignore config parse error
    }
}

$connected = $false
$workingServer = ""
$conn = $null

foreach ($srv in $serversToTry) {
    Write-Host "Dang thu ket noi SQL Server: $srv ..." -ForegroundColor Cyan
    $connStr = "Server=$srv;Database=$database;User Id=$user;Password=$password;Connect Timeout=5;Encrypt=False;"
    $testConn = New-Object System.Data.SqlClient.SqlConnection
    $testConn.ConnectionString = $connStr
    
    $success = $false
    try {
        $testConn.Open()
        if ($testConn.State -eq 'Open') {
            $success = $true
        }
    } catch {
        $success = $false
    }

    if ($success) {
        $connected = $true
        $workingServer = $srv
        $conn = $testConn
        Write-Host "KET NOI THANH CONG TOI SERVER: $srv !" -ForegroundColor Green
        break
    } else {
        if ($testConn.State -eq 'Open') { $testConn.Close() }
        Write-Host "   -> Khong ket noi duoc $srv" -ForegroundColor Gray
    }
}

if (-not $connected) {
    Write-Host "LOI: Khong the ket noi toi bat ky Server Database nao!" -ForegroundColor Red
    exit
}

try {
    Write-Host "Dang nap file SQL: $sqlFile ..." -ForegroundColor Cyan
    $sqlText = [System.IO.File]::ReadAllText($sqlFile, [System.Text.Encoding]::UTF8)

    $batches = $sqlText -split "(?m)^\s*GO\s*$"

    foreach ($batch in $batches) {
        $cleanBatch = $batch.Trim()
        if ($cleanBatch.Length -gt 0) {
            $cmd = $conn.CreateCommand()
            $cmd.CommandTimeout = 180
            $cmd.CommandText = $cleanBatch
            $null = $cmd.ExecuteNonQuery()
        }
    }

    Write-Host "`n======> THANH CONG! DA NAP THANH CONG BAN FIX MOI NAT LEN DATABASE! <======" -ForegroundColor Green
} catch {
    Write-Host "LOI KHI NAP DATABASE: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($conn -ne $null) {
        if ($conn.State -eq 'Open') {
            $conn.Close()
        }
    }
}
