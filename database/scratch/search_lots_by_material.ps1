$sql = "SELECT TOP 5 Barcode, MaterialCode, CreateDateTime FROM STB_SetInfo WHERE MaterialCode = 'ECVT30-379' OR MaterialCode = 'WEC3R0256QG-D' ORDER BY CreateDateTime DESC"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
