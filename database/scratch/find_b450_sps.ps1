$sql = "SELECT ScreenName, ObjectName, ObjectType, Description FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'B450'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
