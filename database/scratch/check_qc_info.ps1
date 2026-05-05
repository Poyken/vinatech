$sql = "SELECT TOP 1 * FROM STB_MaterialQcInfo WHERE LotNo = 'VVQN053R025609'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
