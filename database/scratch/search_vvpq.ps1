$sql = "SELECT OBJECT_NAME(object_id) AS SPName FROM sys.sql_modules WHERE definition LIKE '%VVPQ%'"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
