$sql = "SELECT ModelCode, ModelName, MBIExtText01, MBIExtText02, MBIExtText03 FROM STB_ModelBasicInfo WHERE ModelCode = 'ECVT27-404'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
