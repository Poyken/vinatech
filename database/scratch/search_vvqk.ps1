$sql = "SELECT TOP 5 Barcode, MaterialCode FROM STB_SetInfo WHERE Barcode LIKE 'VVQK273%' ORDER BY CreateDateTime DESC"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
