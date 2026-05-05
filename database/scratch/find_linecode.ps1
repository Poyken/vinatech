$sql = "SELECT TOP 1 LineCode FROM STB_ProdRouteHist WHERE PONo = '260501000025' AND LineCode IS NOT NULL"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
