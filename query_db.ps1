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
    } catch {
        # Ignore config read errors
    }
}

function Connect-Server([string]$srv, [string]$db, [string]$usr, [string]$pwd) {
    $connStr = "Server=$srv;Database=$db;User Id=$usr;Password=$pwd;Connect Timeout=3;Encrypt=False;"
    $sqlConn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    try {
        $sqlConn.Open()
        if ($sqlConn.State -eq 'Open') {
            return $sqlConn
        }
    } catch {
        if ($sqlConn -ne $null -and $sqlConn.State -eq 'Open') { $sqlConn.Close() }
    }
    return $null
}

$conn = $null
$workingServer = ""

foreach ($srv in $serversToTry) {
    Write-Host "Dang thu ket noi SQL Server: $srv ..." -ForegroundColor Cyan
    $testConn = Connect-Server -srv $srv -db $database -usr $user -pwd $password
    if ($testConn -ne $null) {
        $conn = $testConn
        $workingServer = $srv
        Write-Host "KET NOI THANH CONG TOI SERVER: $srv (DB: $database)!" -ForegroundColor Green
        break
    } else {
        Write-Host "   -> Khong ket noi duoc $srv" -ForegroundColor Gray
    }
}

if ($conn -eq $null) {
    Write-Host "LOI: Khong the ket noi toi bat ky Server Database nao!" -ForegroundColor Red
    exit
}

function Execute-SelectQuery([string]$sqlText) {
    if ([string]::IsNullOrWhiteSpace($sqlText)) { return }

    # Safety check: SELECT-ONLY rule
    $trimmed = $sqlText.Trim()
    if ($trimmed -notmatch "^(?i)\s*(SELECT|WITH|EXEC|EXECUTE|SHOW|DESC|SP_)") {
        Write-Host "CANH BAO: Cong cu nay chi cho phep cau lenh SELECT / TRA CUU du lieu!" -ForegroundColor Yellow
        return
    }

    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 120
        $cmd.CommandText = $sqlText
        
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $null = $adapter.Fill($dt)

        if ($dt.Rows.Count -eq 0) {
            Write-Host "(0 rows returned)" -ForegroundColor Gray
        } else {
            Write-Host "`nKet qua ($($dt.Rows.Count) dong):" -ForegroundColor Green
            $dt | Format-Table -AutoSize | Out-String -Width 4000
        }
    } catch {
        Write-Host "LOI SQL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 1. Chay 1 cau lenh truyen tham so -Query
if ($Query -ne "") {
    Execute-SelectQuery -sqlText $Query
    if ($conn.State -eq 'Open') { $conn.Close() }
    exit
}

# 2. Che do tuong tac lien tuc
Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "CHE DO TRA CUU TUONG TAC (Go 'exit' hoac 'quit' de thoat)" -ForegroundColor Yellow
Write-Host "Vi du: SELECT TOP 5 MaterialCode, MaterialName FROM STB_MaterialMaster" -ForegroundColor Gray
Write-Host "----------------------------------------------------------------------`n" -ForegroundColor Yellow

while ($true) {
    $userSql = Read-Host "SQL"
    if ($userSql -eq "exit" -or $userSql -eq "quit" -or $userSql -eq "q") {
        break
    }
    Execute-SelectQuery -sqlText $userSql
}

if ($conn.State -eq 'Open') {
    $conn.Close()
}
Write-Host "Da ngat ket noi CSDL." -ForegroundColor Cyan
