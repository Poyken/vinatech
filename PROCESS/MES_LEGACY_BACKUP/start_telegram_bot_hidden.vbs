Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /c chcp 65001 > nul & python tools\mes_telegram_bot.py", 0, False
Set WshShell = Nothing
