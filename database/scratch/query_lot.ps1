$sql = "
SELECT TOP 1 * FROM STB_MaterialLotInfo WHERE LotNo = 'VVPQ132R71504' OR MaterialLotNo = 'VVPQ132R71504' OR LotID = 'VVPQ132R71504'
SELECT TOP 1 * FROM STB_DividePackaging WHERE PackingID = 'VVPQ132R71504' OR ParentPackingID = 'VVPQ132R71504'
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
