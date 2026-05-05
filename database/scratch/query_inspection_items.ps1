$password = 'MK vina1234%6&8'
$query = "SELECT TOP 10 * FROM STB_CommInspItem WHERE MaterialCode LIKE 'WEC3R0256QG%'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vanduc' -Password $password -Query $query | ConvertTo-Json
