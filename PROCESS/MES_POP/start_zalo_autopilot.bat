@echo off
chcp 65001 > nul
title Vinatech MES — Zalo Auto-Pilot Control Center
cd /d "%~dp0"
echo =================================================================
echo   KHOI DONG VINATECH MES ZALO AUTO-PILOT CONTROL CENTER (GUI)
echo =================================================================
echo.
echo [1] Che do Giao Dien Trực Quan (GUI Dashboard - Khuyen dung)
echo [2] Che do Chay Ngam Console (Clipboard Sniffer)
echo.
set /p choice="Chon che do (Enter de mo GUI [1]): "
if "%choice%"=="2" (
    python tools\mes_zalo_autopilot.py --clip
) else (
    start pythonw tools\mes_zalo_gui.py
)
