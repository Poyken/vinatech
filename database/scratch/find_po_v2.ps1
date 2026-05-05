$sql = "SELECT TOP 1 PONo, WorkCenterCode, CompanyCode FROM STB_ProductionOrderInfo WHERE MaterialCode = 'ECVT30-379' AND IsCancel = 0 ORDER BY CreateDateTime DESC"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
