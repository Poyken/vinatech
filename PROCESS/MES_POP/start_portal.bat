@echo off
title Vinatech MES Operations Portal Launcher
color 0b

echo ======================================================================
echo    VINATECH MES OPERATIONS PORTAL - KHOI DONG HE THONG 1-CLICK
echo    Tac gia: Nguyen Van Duc (vanduc - EA Team)
echo ======================================================================
echo.

cd /d "%~dp0"

echo [1/3] Kiem tra va khoi dong API Relay Server (Port 5000)...
netstat -ano | findstr 127.0.0.1:5000 >nul
if %errorlevel% neq 0 (
    start "Vinatech-API-Relay" /min python tools\api_relay.py
    echo    -> Da bat API Relay Server tren cong 5000.
) else (
    echo    -> API Relay Server da dang chay tren cong 5000.
)

echo.
echo [2/3] Kiem tra va khoi dong Web Portal Next.js (Port 3000)...
netstat -ano | findstr 127.0.0.1:3000 >nul
if %errorlevel% neq 0 (
    start "Vinatech-Web-Portal" /min cmd /c "cd /d "%~dp0web" && npm run dev"
    echo    -> Da bat Web Portal Next.js tren cong 3000.
) else (
    echo    -> Web Portal da dang chay tren cong 3000.
)

echo.
echo [3/3] Dang mo trinh duyet den Vinatech Operations Portal...
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo ======================================================================
echo    HE THONG DA SAN SANG!
echo    - Web UI: http://localhost:3000
echo    - API Relay: http://localhost:5000
echo    - Nhan phim bat ky de dong cua so console nay...
echo ======================================================================
pause >nul
