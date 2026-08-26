@echo off
chcp 65001 > nul
echo ========================================================
echo   DANG CAP NHAT TRI NHO ANTIGRAVITY TU GIT VE MAY...
echo ========================================================
cd /d "%USERPROFILE%\.gemini"

git pull origin main

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] DA CAP NHAT TRI NHO MOI NHAT THANH CONG!
) else (
    echo [!] CO LOI KHI PULL. Kiem tra lai ket noi mang hoac remote Git.
)
pause
