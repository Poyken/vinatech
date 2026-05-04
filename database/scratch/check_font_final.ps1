$sql = "SELECT CAST(OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_GetBoxIDForLotNo_VVT')) AS NVARCHAR(MAX))"
$def = Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
$content = $def[0].ToString()
$index = $content.IndexOf("tùy chọn")
if ($index -ge 0) {
    "Font CORRECT"
    $content.Substring($index, 100)
} else {
    "Font BROKEN"
    # Show what's there
    $index2 = $content.IndexOf("LotNoFirst")
    if ($index2 -ge 0) { $content.Substring($index2, 300) }
}
