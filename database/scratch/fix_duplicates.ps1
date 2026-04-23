$p = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_Vietnam_RawMaterialInputHist_uid.sql'
$c = Get-Content $p -Raw
# Fix the duplicate 'CRYPK0-022', 'CRYPK0-022'
$c = $c -replace "'CRYPK0-022', 'CRYPK0-022'", "'CRYPK0-022'"

# Also check for other duplicates I might have missed
# Just to be safe, I'll do a global cleanup for this specific pattern if it appears multiple times
$c = $c -replace "'CRYPK0-022', 'CRYPK0-022'", "'CRYPK0-022'"

Set-Content $p $c -Encoding UTF8
Write-Host "Fixed duplicate CRYPK0-022 in $p"
