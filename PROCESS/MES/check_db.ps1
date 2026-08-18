# check_db.ps1 — 1-Click Database Connection Tester for Vinatech MES

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " VINATECH MES -- DATABASE CONNECTION DIAGNOSTIC TOOL" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

$serverHost = "dbserver.hycap.co.kr"
$serverPort = 5398

$configPath = Join-Path $PSScriptRoot "db_config.json"
if (Test-Path $configPath) {
    try {
        $config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
        if ($config.Server -match "^([^,]+)(?:,(\d+))?$") {
            $serverHost = $matches[1]
            if ($matches[2]) { $serverPort = [int]$matches[2] }
        }
    } catch {}
}

Write-Host "1. Testing TCP Connection to DB Server (${serverHost}:${serverPort})..." -NoNewline
$tcpTest = Test-NetConnection -ComputerName $serverHost -Port $serverPort -WarningAction SilentlyContinue

if ($tcpTest.TcpTestSucceeded) {
    Write-Host " [OK - SUCCESS]" -ForegroundColor Green
} else {
    Write-Host " [FAILED]" -ForegroundColor Red
    Write-Host ""
    Write-Host "KHONG THE KET NOI MANG TOI DB SERVER (${serverHost}:${serverPort})!" -ForegroundColor Yellow
    Write-Host "Nguyen nhan: Chua bat VPN Vinatech hoac Wi-Fi rot ket noi." -ForegroundColor Yellow
    Write-Host "Xu ly: Vui long kiem tra ung dung VPN (FortiClient/SSL-VPN) va bam Connect lai." -ForegroundColor Yellow
    exit 1
}

Write-Host "2. Running SQL Query Test..." -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File .\run_query.ps1 -Query "SELECT @@SERVERNAME AS ServerName, DB_NAME() AS DatabaseName, GETDATE() AS CurrentTime"

Write-Host "======================================================================" -ForegroundColor Green
Write-Host " KET NOI DATABASE DA SAN SANG!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
