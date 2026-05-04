$content = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\usp_Vietnam_GetBoxIDForLotNo_VVT.sql' -Raw
$alterContent = $content -replace "CREATE PROCEDURE", "ALTER PROCEDURE"
$alterContent | Out-File 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\alter_usp_Vietnam_GetBoxIDForLotNo_VVT.sql' -Encoding utf8

Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -InputFile 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\alter_usp_Vietnam_GetBoxIDForLotNo_VVT.sql'
