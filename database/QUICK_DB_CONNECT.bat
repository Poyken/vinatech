@echo off
echo ========================================
echo MES DATABASE QUICK CONNECTION
echo ========================================
echo.

echo [1] Connect to Production DB
echo [2] Connect to Test DB (if available)
echo [3] Run Debug Script
echo [4] Exit
echo.

set /p choice="Choose option (1-4): "

if "%choice%"=="1" goto prod
if "%choice%"=="2" goto test
if "%choice%"=="3" goto debug
if "%choice%"=="4" goto end

:prod
echo Connecting to Production Database...
sqlcmd -S "dbserver.hycap.co.kr,5398" -d "SmartFactoryV2" -U "vinaadmin" -P "vina1234%6&8" -C
pause
goto menu

:test
echo Connecting to Test Database...
rem sqlcmd -S "testserver" -d "SmartFactoryV2_Test" -U "vinaadmin" -P "password" -C
echo Test DB not configured yet!
pause
goto menu

:debug
echo Running Debug Script...
set /p barcode="Enter Barcode to debug: "
sqlcmd -S "dbserver.hycap.co.kr,5398" -d "SmartFactoryV2" -U "vinaadmin" -P "vina1234%6&8" -C -Q "DECLARE @Barcode VARCHAR(50) = '%barcode%'; PRINT 'Checking barcode: ' + @Barcode; SELECT * FROM STB_SetInfo WHERE ControlNo = @Barcode OR Barcode = @Barcode; SELECT * FROM STB_ProdRouteHist WHERE ControlNo = (SELECT SetInfoNo FROM STB_SetInfo WHERE ControlNo = @Barcode OR Barcode = @Barcode) ORDER BY RouteCode;"
pause
goto menu

:menu
cls
goto :eof

:end
echo Goodbye!
pause
