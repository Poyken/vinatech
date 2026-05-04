$sql = "SELECT CAST(OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_GetBoxIDForLotNo_VVT')) AS NVARCHAR(MAX))"
$def = Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
$content = $def.Column1
$index = $content.IndexOf("tÃ¹y")
if ($index -ge 0) {
    "Broken found at $index"
    $content.Substring($index, 100)
} else {
    "Broken NOT found"
}
$index2 = $content.IndexOf("tùy")
if ($index2 -ge 0) {
    "Correct found at $index2"
    $content.Substring($index2, 100)
} else {
    "Correct NOT found"
}
