$lotNo = "VVQL033R07279S"
$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$pass = "vina1234%6&8" # Từ system_environment.md

# Query STB_SetInfo
$querySetInfo = "SELECT Barcode, MaterialCode, PONo, DayPlanNo FROM STB_SetInfo WHERE Barcode = '$lotNo'"
sqlcmd -S $server -d $database -U $user -P $pass -Q $querySetInfo -W -C

# Query STB_MaterialLotInfo
$queryMatLot = "SELECT LotNo, MaterialCode, MaterialLotNo, PackingID FROM STB_MaterialLotInfo WHERE LotNo = '$lotNo' OR LotID = '$lotNo'"
sqlcmd -S $server -d $database -U $user -P $pass -Q $queryMatLot -W -C
