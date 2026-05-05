$txt = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml' -Raw
$txt.Substring(0, 2000) | Out-File 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\xml_peek.txt'
