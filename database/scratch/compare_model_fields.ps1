$sql = "SELECT TOP 20 ModelCode, ModelName, MBIExtText02, MBIExtText05 FROM STB_ModelBasicInfo WHERE MBIExtText02 IS NOT NULL AND MBIExtText05 IS NOT NULL"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
