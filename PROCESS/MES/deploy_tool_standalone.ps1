# ==============================================================================
# SCRIPT DEPLOY DATABASE STANDALONE (MANG SANG MÁY KHÁC NẠP VÀO DB)
# TỰ ĐỘNG HÓA 100% - KHÔNG CẦN NHẬP PHÍM - BẢO TOÀN FONT UNICODE UTF-8
# Usage: .\deploy_tool_standalone.ps1
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }

$sqlFile = Join-Path $scriptPath "DEPLOY_TO_DATABASE.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Host "Không tìm thấy file DEPLOY_TO_DATABASE.sql tại: $sqlFile" -ForegroundColor Red
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
    } catch {}
}

$serversToTry = $serversToTry | Select-Object -Unique

$connected = $false
$workingServer = ""
$conn = $null

foreach ($srv in $serversToTry) {
    Write-Host "Đang thử kết nối SQL Server: $srv ..." -ForegroundColor Cyan
    $connStr = "Server=$srv;Database=$database;User Id=$user;Password=$password;Connect Timeout=5;Encrypt=False;"
    $testConn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    try {
        $testConn.Open()
        if ($testConn.State -eq [System.Data.ConnectionState]::Open) {
            $connected = $true
            $workingServer = $srv
            $conn = $testConn
            Write-Host "KẾT NỐI THÀNH CÔNG TỚI SERVER: $srv !" -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "   -> Không kết nối được $srv" -ForegroundColor Gray
    }
}

if (-not $connected) {
    Write-Host "LỖI: Không thể kết nối tới bất kỳ Server Database nào!" -ForegroundColor Red
    exit
}

try {
    Write-Host "Đang nạp file SQL: $sqlFile ..." -ForegroundColor Cyan
    
    # Đọc file SQL mã hóa UTF-8 với BOM
    $sqlText = [System.IO.File]::ReadAllText($sqlFile, [System.Text.Encoding]::UTF8)

    # Cắt các khối lệnh theo từ khóa GO
    $batches = $sqlText -split "(?m)^\s*GO\s*$"

    foreach ($batch in $batches) {
        $cleanBatch = $batch.Trim()
        if ($cleanBatch -ne "") {
            $cmd = $conn.CreateCommand()
            $cmd.CommandTimeout = 180
            $cmd.CommandText = $cleanBatch
            $cmd.ExecuteNonQuery()
        }
    }
    
    Write-Host "`n======> THÀNH CÔNG! ĐÃ NẠP THÀNH CÔNG BẢN FIX MỚI NẤT LÊN DATABASE (FONT UTF-8 CHUẨN)! <======" -ForegroundColor Green
}
catch {
    Write-Host "LỖI KHI NẠP DATABASE: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($null -ne $conn -and $conn.State -eq [System.Data.ConnectionState]::Open) {
        $conn.Close()
    }
}
