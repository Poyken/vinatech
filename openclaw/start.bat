@echo off
echo ========================================
echo  ZALO AI TASK SYSTEM - LAUNCHER
echo ========================================

echo.
echo [1] Kiem tra Chrome co mo debug port khong...
curl -s http://localhost:9222/json/version > nul 2>&1
if %errorlevel% == 0 (
    echo  Chrome debug port: OK
) else (
    echo  CANH BAO: Chrome chua mo debug port!
    echo  Se mo Chrome voi debug port...
    start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%APPDATA%\ChromeDebug"
    echo  Doi Chrome khoi dong...
    timeout /t 3 /nobreak > nul
)

echo.
echo [2] Cai dat dependencies...
call npm install
if %errorlevel% neq 0 (
    echo LOI: npm install that bai
    pause
    exit /b 1
)

echo.
echo [3] Cai dat Playwright browsers...
call npx playwright install chromium
if %errorlevel% neq 0 (
    echo CANH BAO: Playwright install that bai, tiep tuc...
)

echo.
echo [4] Tao workspace directories...
if not exist "workspace\notes" mkdir "workspace\notes"
if not exist "workspace\tasks" mkdir "workspace\tasks"
if not exist "workspace\reports" mkdir "workspace\reports"
if not exist "workspace\.state" mkdir "workspace\.state"

echo.
echo ========================================
echo  KHOI DONG HE THONG...
echo ========================================
node src/main.js

pause
