$sql = "SELECT t.name AS TableName, c.name AS ColumnName FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id WHERE c.name LIKE '%LotNo%' OR c.name LIKE '%Barcode%'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
