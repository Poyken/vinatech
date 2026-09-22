$WshShell = New-Object -ComObject WScript.Shell
$desktop = [System.Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path $desktop "Zalo (MES Auto-Pilot).lnk"
$zaloExe = Join-Path $env:LOCALAPPDATA "Programs\Zalo\Zalo.exe"

$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $zaloExe
$shortcut.Arguments = "--force-renderer-accessibility"
$shortcut.Description = "Zalo mở với cờ trợ năng để AI tự động đọc tin nhắn xưởng"
$shortcut.WorkingDirectory = Join-Path $env:LOCALAPPDATA "Programs\Zalo"
$shortcut.Save()

Write-Host "-> Đã tạo Shortcut thành công tại: $shortcutPath" -ForegroundColor Green
