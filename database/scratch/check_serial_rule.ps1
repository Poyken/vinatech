$sql = "SELECT * FROM SmartFramework.dbo.STB_SerialRule WHERE TableName = 'STB_SetInfo'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
