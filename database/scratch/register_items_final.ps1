$sql = @"
INSERT INTO STB_CommInspItem (
    CommInspItemCode, CommInspTypeCode, CompanyCode, WorkCenterCode, 
    MaterialCode, CommInspItemName, CommInspUnit, CommInspInputType, 
    DisplayIndex, CreateDateTime, CreateUserID
)
SELECT 
    'ITM' + LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 12), 
    'ROUTE_TEST', 
    'VVT', 
    'VVT_F1', 
    'ECVT30-379', 
    CommInspItemName, 
    CommInspUnit, 
    CommInspInputType, 
    DisplayIndex, 
    GETDATE(), 
    'vinaadmin'
FROM STB_CommInspItem
WHERE CommInspTypeCode = 'ROUTE_TEST2' AND CompanyCode = 'VVT' AND MaterialCode = ''
"@
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
