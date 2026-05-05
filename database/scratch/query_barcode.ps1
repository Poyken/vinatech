$query = "SELECT TOP 1 * FROM STB_SetInfo WHERE Barcode = 'VVPM082R750609'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vanduc' -Password 'MK vina1234%6&8' -Query $query | ConvertTo-Json
