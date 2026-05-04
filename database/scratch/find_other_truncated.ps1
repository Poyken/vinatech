$sql = "SELECT ModelCode, ModelName, MBIExtText02, MBIExtText05 FROM STB_ModelBasicInfo WHERE LEN(MBIExtText02) = 3 AND MBIExtText05 = SUBSTRING(MBIExtText02, 1, 2)"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
