$sql = @"
IF NOT EXISTS (SELECT 1 FROM STB_ProdRouteHist WHERE ControlNo = '20260505000501' AND RouteCode = 'V-27_BG')
BEGIN
    INSERT INTO STB_ProdRouteHist (
        ProdRouteHistNo, CompanyCode, WorkCenterCode, PONo, DayPlanNo, 
        ControlNo, MaterialCode, BomVersion, JobDate, ShiftCode, 
        TimeCode, LineCode, RouteCode, ProdQty, ProdDateTime, 
        CreateDateTime, CreateUserID
    ) VALUES (
        'PR' + LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 12),
        'VVT', 
        'VVT_F2', 
        '260501000025', 
        '2026050100206', 
        '20260505000501', 
        'ECVT30-379', 
        '1', 
        GETDATE(), 
        '1', 
        '*', 
        'VVBGC-04', 
        'V-27_BG', 
        800, 
        GETDATE(), 
        GETDATE(), 
        'vinaadmin'
    )
END
"@
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
