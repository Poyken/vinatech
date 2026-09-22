$WshShell = New-Object -ComObject WScript.Shell
$desktop = [System.Environment]::GetFolderPath('Desktop')
Get-ChildItem $desktop -Filter '*AUTO-PILOT*.lnk' | Remove-Item -Force -ErrorAction SilentlyContinue
$shortcutPath = Join-Path $desktop "MES Zalo Auto-Pilot.lnk"
$batPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES_POP\start_mes_autopilot.bat"

$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $batPath
$shortcut.WorkingDirectory = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES_POP"
$shortcut.Description = "Khoi dong 1-Click: Zalo Tro Nang + Bang Dieu Khien MES Auto-Pilot"
$shortcut.Save()

Write-Host "-> Da tao thanh cong Shortcut tai: $shortcutPath" -ForegroundColor Green
