Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
WshShell.CurrentDirectory = scriptDir
WshShell.Run "cmd /c chcp 65001 > nul & python -u tools\mes_telegram_bot.py", 0, False
Set WshShell = Nothing
Set fso = Nothing

