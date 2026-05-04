$sql = "SELECT Barcode, REPLACE(Barcode, '7156', '715') as Reverted FROM STB_SetInfo WHERE Barcode LIKE 'VVPQ132R7156%'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
