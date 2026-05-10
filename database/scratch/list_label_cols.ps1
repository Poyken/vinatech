$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$pass = "vina1234%6&8"

$queryCols1 = "SELECT TOP 0 * FROM STB_ModelLabelInfo"
sqlcmd -S $server -d $database -U $user -P $pass -Q "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'STB_ModelLabelInfo'" -W -C

$queryCols2 = "SELECT TOP 0 * FROM SmartFramework.dbo.STB_LabelInfo"
sqlcmd -S $server -d $database -U $user -P $pass -Q "SELECT COLUMN_NAME FROM SmartFramework.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'STB_LabelInfo'" -W -C
