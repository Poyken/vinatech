$sql = "
SELECT Barcode, MaterialCode, CreateDateTime 
FROM STB_SetInfo 
WHERE Barcode LIKE 'VVPQ132R715%04' OR Barcode LIKE 'VVPQ132R71504%' OR Barcode LIKE 'VVPQ132R715%'
ORDER BY CreateDateTime DESC
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
