$sql = "SELECT TOP 1 * FROM STB_CommInspDocHistory WHERE MaterialCode = 'ECVT30-379' AND CommInspTypeCode LIKE '%QUALITY%' ORDER BY CreateDateTime DESC"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
