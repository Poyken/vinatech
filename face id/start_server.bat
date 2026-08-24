@echo off
title VINATECH FACE ID & HIKCENTRAL WEB PORTAL
echo ===============================================================
echo   VINATECH FACE ID & HIKCENTRAL ACCESS CONTROL PORTAL
echo   Server URL: http://localhost:8090/
echo   Database: HCP_DATA @ 192.168.184.250
echo ===============================================================
echo Dang khoi dong Web Server...

start http://localhost:8090/
python server.py
pause
