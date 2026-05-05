$query = "SELECT TOP 10 Barcode, CreateDateTime FROM STB_SetInfo ORDER BY CreateDateTime DESC"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vanduc' -Password 'MK vina1234%6&8' -Query $query | ConvertTo-Json
