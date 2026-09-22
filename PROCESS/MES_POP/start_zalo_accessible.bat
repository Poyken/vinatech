@echo off
chcp 65001 > nul
title Vinatech MES — Khoi Dong Zalo Co Ho Tro Tro Nang (Accessibility)
cd /d "%~dp0"

echo =================================================================
echo   KHOI DONG ZALO PC VOI CO TRO NANG (--force-renderer-accessibility)
echo =================================================================
echo.
echo Cờ này cho phép AI tu dong doc tin nhan trong khung chat Zalo
echo ma ban KHONG CAN phai bam Copy (Ctrl+C).
echo.

set ZALO_EXE="%LOCALAPPDATA%\Programs\Zalo\Zalo.exe"
if not exist %ZALO_EXE% (
    echo [LOI] Khong tim thay Zalo.exe tai %ZALO_EXE%
    pause
    exit /b 1
)

echo Dang khoi dong Zalo...
start "" %ZALO_EXE% --force-renderer-accessibility
echo [OK] Zalo da duoc khoi dong voi co Tro Nang.
echo.
timeout /t 3 > nul
