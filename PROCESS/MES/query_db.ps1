# ==============================================================================
# SCRIPT QUERY DATABASE MES VINATECH CHẠY TRỰC TIẾP TRÊN POWERSHELL
# TỰ ĐỘNG DÒ SERVER - CHỈ CHO PHÉP SELECT - CHỐNG BỊ CẮT CỘT - UTF-8 UNICODE
#
# Cách dùng 1 (Truyền SQL trực tiếp):
#   .\query_db.ps1 -Query "SELECT TOP 5 MaterialCode, MaterialName FROM STB_MaterialMaster"
#
# Cách dùng 2 (Chạy tương tác):
#   .\query_db.ps1
# ==============================================================================

param(
    [string]$Query = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

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

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }

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
        Write-Host "KẾT NỐI THÀNH CÔNG TỚI SERVER: $srv (DB: $database)" -ForegroundColor Green
        break
    } else {
        if ($testConn.State -eq 'Open') { $testConn.Close() }
    }
}

if (-not $connected) {
    Write-Host "LỖI: Không thể kết nối tới bất kỳ Server Database nào!" -ForegroundColor Red
    exit
}

function Execute-SelectQuery([string]$sql) {
    if ([string]::IsNullOrWhiteSpace($sql)) { return }

    # Safety check: SELECT-ONLY rule
    $trimmed = $sql.Trim()
    if ($trimmed -notmatch "^(?i)\s*(SELECT|WITH|EXEC|EXECUTE|SHOW|DESC|SP_)") {
        Write-Host "CẢNH BÁO: Công cụ này chỉ cho phép câu lệnh SELECT / TRA CỨU dữ liệu!" -ForegroundColor Yellow
        return
    }

    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 120
        $cmd.CommandText = $sql
        
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $null = $adapter.Fill($dt)

        if ($dt.Rows.Count -eq 0) {
            Write-Host "(0 rows returned)" -ForegroundColor Gray
        } else {
            Write-Host "`nKết quả ($($dt.Rows.Count) dòng):" -ForegroundColor Green
            # Format-Table width 4000 to prevent column truncation
            $dt | Format-Table -AutoSize | Out-String -Width 4000
        }
    } catch {
        Write-Host "LỖI SQL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 1. Chạy 1 câu lệnh truyền tham số -Query
if ($Query -ne "") {
    Execute-SelectQuery $Query
    if ($conn.State -eq 'Open') { $conn.Close() }
    exit
}

# 2. Chế độ tương tác liên tục
Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "CHẾ ĐỘ TRA CỨU TƯƠNG TÁC (Gõ 'exit' hoặc 'quit' để thoát)" -ForegroundColor Yellow
Write-Host "Ví dụ: SELECT TOP 5 MaterialCode, MaterialName FROM STB_MaterialMaster" -ForegroundColor Gray
Write-Host "----------------------------------------------------------------------`n" -ForegroundColor Yellow

while ($true) {
    $userSql = Read-Host "SQL"
    if ($userSql -eq "exit" -or $userSql -eq "quit" -or $userSql -eq "q") {
        break
    }
    Execute-SelectQuery $userSql
}

if ($conn.State -eq 'Open') {
    $conn.Close()
}
Write-Host "Đã ngắt kết nối CSDL." -ForegroundColor Cyan
