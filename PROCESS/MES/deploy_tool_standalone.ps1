# ==============================================================================
# SCRIPT DEPLOY DATABASE STANDALONE (MANG SANG MÁY KHÁC NẠP VÀO DB)
# Bảo toàn 100% Font chữ tiếng Việt/tiếng Hàn
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

$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

$cfgPath = Join-Path $scriptPath "db_config.json"
if (Test-Path $cfgPath) {
    try {
        $cfg = Get-Content -Raw -Path $cfgPath | ConvertFrom-Json
        if ($cfg.Server) { $server = $cfg.Server }
        if ($cfg.Database) { $database = $cfg.Database }
        if ($cfg.User) { $user = $cfg.User }
        if ($cfg.Password) { $password = $cfg.Password }
    } catch {}
}

$inputServer = Read-Host "Nhập Server DB (Bấm Enter để dùng mặc định: $server)"
if ($inputServer -ne "") { $server = $inputServer }

Write-Host "Đang kết nối tới SQL Server: $server - Database: $database ..." -ForegroundColor Cyan

$connStr = "Server=$server;Database=$database;User Id=$user;Password=$password;Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)

try {
    $conn.Open()
    Write-Host "KẾT NỐI THÀNH CÔNG!" -ForegroundColor Green
    
    # Đọc file SQL mã hóa UTF-8
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
    
    Write-Host "`n======> APPLY THÀNH CÔNG BẢN FIX MỚI NẤT LÊN DATABASE (PRESERVED UTF-8 FONT)! <======" -ForegroundColor Green
}
catch {
    Write-Host "LỖI KHI NẠP DATABASE:" $_.Exception.Message -ForegroundColor Red
}
finally {
    if ($null -ne $conn -and $conn.State -eq [System.Data.ConnectionState]::Open) {
        $conn.Close()
    }
}
