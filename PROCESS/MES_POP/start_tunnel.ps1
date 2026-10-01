# ======================================================================
#   VINATECH MES - 1-CLICK TUNNEL & API RELAY LAUNCHER
#   Ket noi an toan tu Vercel ve 15 CSDL Noi Bo khong can mo Port
#   Tac gia: Nguyen Van Duc (vanduc - EA Team)
# ======================================================================

param(
    [string]$Mode = "localtunnel" # "localtunnel" (co dinh domain) hoac "cloudflare" (quick tunnel)
)

$BaseDir = $PSScriptRoot
$RelayScript = Join-Path $BaseDir "tools\api_relay.py"
$CloudflaredExe = Join-Path $BaseDir "tools\cloudflared.exe"
$FixedDomain = "vinatech-relay-vanduc"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   VINATECH MES - KHOI DONG RELAY & DUONG HAM CO DINH CHO DIEN THOAI  " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Kiem tra va khoi dong Python Relay Server
Write-Host "[1/2] Dang kiem tra Python API Relay tren cong 5000..." -ForegroundColor Yellow
$RelayProc = Start-Process python -ArgumentList "`"$RelayScript`"" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 2

if ($RelayProc -and !$RelayProc.HasExited) {
    Write-Host "  -> Python Relay dang chay ngam (PID: $($RelayProc.Id))!" -ForegroundColor Green
} else {
    Write-Host "  -> Python Relay da khoi dong xong!" -ForegroundColor Green
}

# 2. Khoi dong Duong ham
if ($Mode -eq "localtunnel") {
    Write-Host "[2/2] Dang ket noi Duong Ham Co Dinh: https://$FixedDomain.loca.lt ..." -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "URL CO DINH VINH VIEN: https://$FixedDomain.loca.lt" -ForegroundColor Green
    Write-Host "Khong bao gio doi link! Dien vao Vercel 1 lan duy nhat la dung mai mai!" -ForegroundColor White
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    npx -y localtunnel --port 5000 --subdomain $FixedDomain
} else {
    Write-Host "[2/2] Dang mo duong ham Cloudflare Quick Tunnel..." -ForegroundColor Yellow
    & $CloudflaredExe tunnel --url http://localhost:5000
}
