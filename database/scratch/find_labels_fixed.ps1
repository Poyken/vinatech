$modelCode = "ECVT30-357"
$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$pass = "vina1234%6&8"

# 1. Get Label settings for this model
$queryModelLabel = "SELECT ModelCode, LabelType, FormatName FROM STB_ModelLabelInfo WHERE ModelCode = '$modelCode'"
sqlcmd -S $server -d $database -U $user -P $pass -Q $queryModelLabel -W -C

# 2. Get specific details from STB_LabelInfo based on the found LabelType/FormatName
# I'll just select all from STB_LabelInfo to see what's available
$queryAllLabels = "SELECT LabelType, FormatName, LabelRemark FROM SmartFramework.dbo.STB_LabelInfo"
sqlcmd -S $server -d $database -U $user -P $pass -Q $queryAllLabels -W -C
