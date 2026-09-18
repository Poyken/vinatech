@echo off
chcp 65001 > nul
title Vinatech MES Telegram Assistant
cd /d "%~dp0"
echo =================================================================
echo         KHOI DONG VINATECH MES TELEGRAM ASSISTANT BOT
echo =================================================================
python tools\mes_telegram_bot.py
pause
