$p = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_Vietnam_RawMaterialInputHist_uid.sql'
$c = Get-Content $p -Raw
# Add CRYPK0-022 where missing in typical lists
$c = $c -replace "'CRCEK0-268', 'CRCEK0-266', 'CRYPK0-011'", "'CRCEK0-268', 'CRCEK0-266', 'CRYPK0-011', 'CRYPK0-022'"
# Handle the longer lists with duplicates (Vinatech specialty)
$c = $c -replace "'CRCEK0-268', 'CRYPK0-011'\)", "'CRCEK0-268', 'CRYPK0-011', 'CRYPK0-022')"
Set-Content $p $c -Encoding UTF8
Write-Host "Updated material exceptions in $p"
