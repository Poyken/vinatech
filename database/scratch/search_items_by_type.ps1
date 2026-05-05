$sql = "SELECT TOP 10 MaterialCode, ProductGroupCode, CommInspTypeCode FROM STB_CommInspItem WHERE CommInspTypeCode IN ('ROUTE_TEST2', 'VE_ROUTE_TEST', 'ROUTE_TEST') AND CompanyCode = 'VVT'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
