$sql = "SELECT TOP 1 DayPlanNo FROM STB_SetInfo WHERE PONo = '260501000025' AND DayPlanNo IS NOT NULL"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | ConvertTo-Json
