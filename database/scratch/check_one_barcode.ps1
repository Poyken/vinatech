$sql = "SELECT Barcode, LotNumber FROM STB_SetInfo WHERE ControlNo = '20250813000486'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
