$sql = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_GetBoxIDForLotNo_VVT'))"
$def = Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
$def[0] | Select-String -Pattern "tÃ¹y", "chuy?n", "B?c Giang"
