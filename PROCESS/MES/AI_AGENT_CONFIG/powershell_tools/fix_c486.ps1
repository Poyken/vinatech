$path = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES\MES_MASTER_KNOWLEDGE_BASE\KB_05\KB_05_02_SCREEN_BUGS_QC.md"
$lines = Get-Content $path -Encoding UTF8
$filtered = $lines | Where-Object { $_ -notmatch 'DATALENGTH\(XmlLayout\)' -and $_ -notmatch 'ErrorDataSorting' }
Set-Content $path $filtered -Encoding UTF8
Write-Host "C486 duplicate block removed successfully!"
