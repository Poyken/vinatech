$sql = "SELECT TOP 1 CommInspDocNo FROM STB_CommInspDocHistory WHERE ProdNo = '20260505000501' ORDER BY CreateDateTime DESC"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
