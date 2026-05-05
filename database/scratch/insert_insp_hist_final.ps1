$sql = @"
DECLARE @DocNo VARCHAR(20) = 'INS' + LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 12)

IF NOT EXISTS (SELECT 1 FROM STB_CommInspDocHistory WHERE ProdNo = '20260505000501')
BEGIN
    INSERT INTO STB_CommInspDocHistory (
        CommInspDocNo, CommInspTypeCode, CompanyCode, WorkCenterCode, 
        MaterialCode, ProdNo, JobDate, ShiftCode, InspTimeCode, 
        IsFinished, CreateDateTime, CreateUserID, ProductGroupCode
    ) VALUES (
        @DocNo, 
        'ROUTE_QUALITY2_BG', 
        'VVT', 
        'VVT_F2', 
        'ECVT30-379', 
        '20260505000501', 
        GETDATE(), 
        '1', 
        '*', 
        1, 
        GETDATE(), 
        'vinaadmin',
        'HC-EDLC'
    )
END
"@
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
