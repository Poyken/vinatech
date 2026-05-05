$password = 'MK vina1234%6&8'
$query = "SELECT TOP 5 Barcode, CreateDateTime FROM STB_SetInfo ORDER BY CreateDateTime DESC"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vanduc' -Password $password -Query $query | ConvertTo-Json
