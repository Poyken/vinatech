$sql = "SELECT CAST(OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_GetBoxIDForLotNo_VVT')) AS NVARCHAR(MAX)) as Definition"
$def = Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
$content = $def.Definition
if ($content.Contains("tùy chọn")) {
    "Font is CORRECT (tùy chọn found)"
} else {
    "Font might be BROKEN (tùy chọn NOT found)"
}
if ($content.Contains("VVPQ132R7156")) {
    "Logic is CORRECT (VVPQ132R7156 found)"
} else {
    "Logic is BROKEN (VVPQ132R7156 NOT found)"
}
