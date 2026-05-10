$lotNo = "VVQL033R07279S"
$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$pass = "vina1234%6&8"

# 1. Search for Screen B767 in SmartFramework
$queryScreen = "SELECT ScreenName, ObjectName, Description FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName LIKE '%B767%'"
sqlcmd -S $server -d $database -U $user -P $pass -Q $queryScreen -W -C

# 2. Search for the MaterialCode and its Label settings
$queryLabel = "
SELECT 
    MLI.MaterialCode, 
    MLI.LotNo, 
    MLI.PackingID,
    MM.MaterialName,
    LBI.LabelName,
    LBI.LabelType,
    LBI.FormatName
FROM STB_MaterialLotInfo MLI
JOIN STB_MaterialMaster MM ON MLI.MaterialCode = MM.MaterialCode
LEFT JOIN STB_LabelInfo LBI ON LBI.MaterialTypeCode = MM.MaterialTypeCode -- This is a guess on join
WHERE MLI.LotNo = '$lotNo'
"
# Actually, join might be different. Let's just get the MaterialCode first and then look for LabelInfo.
