$sql = "
SELECT ControlNo, Barcode FROM STB_SetInfo WHERE Barcode LIKE 'VVPQ132R7150%' OR Barcode LIKE 'VVPQ132R7151%'
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
