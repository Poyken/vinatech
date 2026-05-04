$sql = "
UPDATE STB_ModelBasicInfo 
SET MBIExtText05 = '156', 
    ChangeDateTime = GETDATE(), 
    ChangeUserID = 'vinaadmin_patch' 
WHERE ModelCode = 'ECVT27-404'
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
