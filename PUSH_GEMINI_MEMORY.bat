@echo off
chcp 65001 > nul
echo ========================================================
echo   DANG DONG BO TRI NHO ANTIGRAVITY LEN GIT...
echo ========================================================
cd /d "%USERPROFILE%\.gemini"

git add .
git commit -m "update: sync agent memory %date% %time%"
git push origin main

echo.
if %ERRORLEVEL% EQU 0 (
    echo [OK] DA DONG BO TRI NHO LEN GIT THANH CONG!
) else (
    echo [!] CHUA THE PUSH. Neu ban vua tao repo moi, hay xem huong dan ket noi remote!
)
pause
