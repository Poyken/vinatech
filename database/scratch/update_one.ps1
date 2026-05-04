$sql = "UPDATE STB_SetInfo SET Barcode = 'VVPQ132R71501' WHERE Barcode = 'VVPQ132R715601'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
