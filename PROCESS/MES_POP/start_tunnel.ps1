# ======================================================================
#   VINATECH MES - 1-CLICK CLOUDFLARE TUNNEL & API RELAY LAUNCHER
#   Ket noi an toan tu Vercel ve 15 CSDL Noi Bo khong can mo Port
#   Tac gia: Nguyen Van Duc (vanduc - EA Team)
# ======================================================================

$BaseDir = $PSScriptRoot
$RelayScript = Join-Path $BaseDir "tools\api_relay.py"
$CloudflaredExe = Join-Path $BaseDir "tools\cloudflared.exe"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "       VINATECH MES - KHOI DONG HE THONG RELAY & TUNNEL CLOUDFLARE    " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Kiem tra va khoi dong Python Relay Server
Write-Host "[1/2] Dang khoi dong Python API Relay tren cong 5000..." -ForegroundColor Yellow
$RelayProc = Start-Process python -ArgumentList "`"$RelayScript`"" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 2

if ($RelayProc -and !$RelayProc.HasExited) {
    Write-Host "  -> Python Relay dang chay ngam (PID: $($RelayProc.Id))!" -ForegroundColor Green
} else {
    Write-Host "  -> Canh bao: Khong the khoi dong Relay ngam, dang tiep tuc..." -ForegroundColor Yellow
}

# 2. Khoi dong Cloudflare Tunnel
Write-Host "[2/2] Dang mo duong ham ma hoa Cloudflare Tunnel..." -ForegroundColor Yellow
Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "HUONG DAN: Doi 3-5 giay de Cloudflare cap URL (dang https://...trycloudflare.com)" -ForegroundColor White
Write-Host "Copy URL do va dan vao bien MES_RELAY_URL tren Vercel Settings!" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

& $CloudflaredExe tunnel --url http://localhost:5000
