@echo off
title VINATECH MES - ZALO AUTO-PILOT LAUNCHER
echo ==============================================================================
echo   VINATECH MES - KHOI DONG HE THONG ZALO AUTO-PILOT (1-CLICK)
echo   Ky su IT: Nguyen Van Duc (EA Team) - Author: vanduc
echo ==============================================================================

:: 1. Kiem tra tien trinh Zalo PC
tasklist /fi "imagename eq Zalo.exe" 2>nul | find /i "Zalo.exe" >nul
if "%ERRORLEVEL%"=="0" (
    echo [1/2] Zalo PC dang mo.
) else (
    echo [1/2] Dang khoi dong Zalo PC voi co tro nang --force-renderer-accessibility...
    start "" "%LOCALAPPDATA%\Programs\Zalo\Zalo.exe" --force-renderer-accessibility
    ping 127.0.0.1 -n 4 >nul
)

:: 2. Khoi dong Bang Dieu Khien GUI Control Center
echo [2/2] Dang mo Bang Dieu Khien Truc Quan (Control Center GUI)...
cd /d "%~dp0"
if exist "%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe" (
    start "" "%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe" "%~dp0tools\mes_zalo_gui.py"
) else (
    start "" pythonw "%~dp0tools\mes_zalo_gui.py"
)

echo.
echo -^> DA KHOI DONG XONG! Giao dien dang chay tren man hinh.
ping 127.0.0.1 -n 3 >nul
exit
