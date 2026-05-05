$sql = "SELECT DISTINCT WorkCenterCode, CompanyCode, CommInspTypeCode FROM STB_CommInspItem WHERE CommInspTypeCode = 'ROUTE_TEST2'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
