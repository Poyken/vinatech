$sql = "SELECT COUNT(*) as Count FROM STB_CommInspItem WHERE MaterialCode = 'ECVT30-379' AND CommInspTypeCode = 'ROUTE_TEST'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
