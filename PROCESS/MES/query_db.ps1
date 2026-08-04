# ==============================================================================
# SCRIPT QUERY DATABASE MES VINATECH CHẠY TRỰC TIẾP TRÊN POWERSHELL
# Kết nối: dbserver.hycap.co.kr,5398
# DB Chính: SmartFactoryV2
# BẢO TOÀN 100% FONT CHỮ UNICODE TIẾNG HÀN & TIẾNG VIỆT
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

$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Get-Location }

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

Write-Host "Connecting to SQL Server: $server (Database: $database)..." -ForegroundColor Cyan

$connStr = "Server=$server;Database=$database;User Id=$user;Password=$password;Connect Timeout=15;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)

try {
    $conn.Open()
    Write-Host "CONNECTED SUCCESSFULLY TO DATABASE!" -ForegroundColor Green
} catch {
    Write-Host "ERROR CONNECTING TO DATABASE: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

function Execute-SelectQuery([string]$sql) {
    if ([string]::IsNullOrWhiteSpace($sql)) { return }

    # Safety check: SELECT-ONLY rule
    $trimmed = $sql.Trim()
    if ($trimmed -notmatch "^(?i)\s*(SELECT|WITH|EXEC|EXECUTE|SHOW|DESC|SP_)") {
        Write-Host "WARNING: Only SELECT / READ-ONLY queries are allowed via this tool!" -ForegroundColor Yellow
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
            Write-Host "`nResults ($($dt.Rows.Count) rows):" -ForegroundColor Green
            $dt | Format-Table -AutoSize
        }
    } catch {
        Write-Host "SQL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 1. Nếu có truyền tham số -Query
if ($Query -ne "") {
    Execute-SelectQuery $Query
    if ($conn.State -eq 'Open') { $conn.Close() }
    exit
}

# 2. Chế độ tương tác nhập câu lệnh SQL
Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "CHẾ ĐỘ QUERY TƯƠNG TÁC (Gõ 'exit' hoặc 'quit' để thoát)" -ForegroundColor Yellow
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
Write-Host "Disconnected." -ForegroundColor Cyan
