@echo off
title Vinatech MES Operations Portal Terminator
color 0c

echo ======================================================================
echo    VINATECH MES OPERATIONS PORTAL - DUNG HE THONG
echo    Tac gia: Nguyen Van Duc (vanduc - EA Team)
echo ======================================================================
echo.

echo Dang giai phong cac tien trinh tren cong 3000 va 5000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr 127.0.0.1:3000') do (
    taskkill /F /PID %%a 2>nul
)

for /f "tokens=5" %%a in ('netstat -ano ^| findstr 127.0.0.1:5000') do (
    taskkill /F /PID %%a 2>nul
)

echo.
echo -> Da dung thanh cong Web Portal (Port 3000) va API Relay (Port 5000).
echo.
timeout /t 2 /nobreak >nul
