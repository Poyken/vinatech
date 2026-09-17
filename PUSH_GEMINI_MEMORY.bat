@echo off
chcp 65001 > nul
echo ========================================================
echo   DANG DONG BO TRI NHO ANTIGRAVITY LEN GIT...
echo ========================================================
cd /d "%USERPROFILE%\.gemini"

git remote get-url origin >nul 2>&1
if errorlevel 1 goto :no_remote

git add config/
git add antigravity-ide/knowledge/
git add .gitignore

git diff-index --quiet HEAD --
if errorlevel 1 goto :do_commit
echo [OK] Tri nho da o trang thai moi nhat, khong co thay doi de commit!
goto :do_push

:do_commit
git commit -m "update: sync agent memory %date% %time%"

:do_push
echo.
echo Dang push len Git...
git push origin main
if errorlevel 1 goto :push_error

echo.
echo [OK] DA DONG BO TRI NHO LEN GIT THANH CONG!
goto :done

:push_error
echo.
echo [!] CO LOI KHI PUSH. Kiem tra lai ket noi mang hoac quyen truy cap GitHub!
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
