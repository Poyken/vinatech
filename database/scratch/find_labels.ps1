$modelCode = "ECVT30-357"
$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$pass = "vina1234%6&8"

# 1. Get Label settings for this model
$queryModelLabel = "SELECT * FROM STB_ModelLabelInfo WHERE MaterialCode = '$modelCode'"
sqlcmd -S $server -d $database -U $user -P $pass -Q $queryModelLabel -W -C

# 2. Get all templates from SmartFramework
$queryAllLabels = "SELECT LabelName, LabelType, FormatName, Description FROM SmartFramework.dbo.STB_LabelInfo"
sqlcmd -S $server -d $database -U $user -P $pass -Q $queryAllLabels -W -C
