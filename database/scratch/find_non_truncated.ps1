$sql = "SELECT TOP 20 ModelCode, MBIExtText02, MBIExtText05 FROM STB_ModelBasicInfo WHERE MBIExtText05 <> SUBSTRING(MBIExtText02, 1, 2) AND LEN(MBIExtText02) >= 2"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
