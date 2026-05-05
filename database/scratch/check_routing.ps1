$sql = "SELECT RouteCode, RouteIndex FROM STB_ProductionOrderRouting WHERE PONo = '260501000025' ORDER BY RouteIndex"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
