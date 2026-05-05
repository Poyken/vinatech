$sql = @"
IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = 'VVQK273R025601')
BEGIN
    INSERT INTO STB_SetInfo (
        ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, ProdQty, 
        GradeCode, CreateDateTime, CreateUserID
    ) VALUES (
        '20260505000501', 
        '260501000025',   
        '2026050100206',
        'ECVT30-379',     
        'VVQK273R025601', 
        800,              
        'A',              
        GETDATE(), 
        'vinaadmin'
    )
END
"@
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
