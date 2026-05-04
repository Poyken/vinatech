$sql = "Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\usp_Vietnam_GetBoxIDForLotNo_VVT.sql' | Out-String"
$spContent = powershell -Command $sql

$target = "				else
					(case when @allowVJ=1"

$replacement = "				 when @LotNo like 'VVPQ132R715%' then REPLACE(@LotNo, 'R715', 'R7156')
				else
					(case when @allowVJ=1"

$newContent = $spContent.Replace($target, $replacement)

# Use a temporary file to save the ALTER script
$alterScript = $newContent -replace "CREATE PROCEDURE", "ALTER PROCEDURE"
$alterScript | Out-File 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\alter_usp_Vietnam_GetBoxIDForLotNo_VVT.sql' -Encoding utf8

Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -InputFile 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\alter_usp_Vietnam_GetBoxIDForLotNo_VVT.sql'
