$sql = "SELECT CAST(OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_GetBoxIDForLotNo_VVT')) AS NVARCHAR(MAX))"
$def = Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
$content = $def[0].ToString()
$index = $content.IndexOf("LotNoFirst")
$content.Substring($index, 500)
