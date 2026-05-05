$sql = @"
IF NOT EXISTS (SELECT 1 FROM STB_MaterialLotInfo WHERE LotNo = 'VVQK273R025601')
BEGIN
    DECLARE @NewLotID VARCHAR(50) = 'ML' + LEFT(REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', ''), 15)
    INSERT INTO STB_MaterialLotInfo (
        MaterialLotNo, LotID, CompanyCode, WorkCenterCode, 
        MaterialWarehouseCode, MaterialLocationCode, MaterialCode, 
        MaterialStockAttribute, InitialQty, CurrentQty, LotNo, 
        CreateDateTime, CreateUserID
    ) VALUES (
        '20260505000501', 
        @NewLotID,
        'VVT', 
        'VVT_F2', 
        'PROD_STBY_BG_WH', 
        'PROD_STBY_BG_WH_01', 
        'ECVT30-379', 
        'NORMAL', 
        800, 
        800, 
        'VVQK273R025601', 
        GETDATE(), 
        'vinaadmin'
    )
END
"@
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
