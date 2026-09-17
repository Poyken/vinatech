@echo off
chcp 65001 > nul
echo ========================================================
echo   DANG CAP NHAT TRI NHO ANTIGRAVITY TU GIT VE MAY...
echo ========================================================
cd /d "%USERPROFILE%\.gemini"

git remote get-url origin >nul 2>&1
if errorlevel 1 goto :no_remote

echo.
echo Dang pull tu Git ve...
git pull --rebase origin main
if errorlevel 1 goto :pull_error

echo.
echo [OK] DA CAP NHAT TRI NHO MOI NHAT THANH CONG!
goto :done

:pull_error
echo.
echo [!] CO LOI KHI PULL. Kiem tra lai ket noi mang hoac conflict local.
goto :done

:no_remote
echo.
echo [!] CHUA CAU HINH REMOTE 'origin'.
echo Hay tao repository tren GitHub (che do Private) va chay 2 lenh sau:
echo   cd /d "%USERPROFILE%\.gemini"
echo   git remote add origin https://github.com/Poyken/[ten-repo].git
echo   git push -u origin main
echo.

:done
pause
