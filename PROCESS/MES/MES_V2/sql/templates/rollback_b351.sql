-- ==============================================================================
-- TEMPLATE: Rollback B351 Lot Conversion (Đồng bộ 4 bảng an toàn)
-- ==============================================================================

DECLARE @ControlNo NVARCHAR(50) = 'CN_SAMPLE';
DECLARE @BarcodeGoc NVARCHAR(50) = 'BC_OLD_SAMPLE';
DECLARE @MaterialCodeGoc NVARCHAR(50) = 'MAT_OLD_SAMPLE';
DECLARE @DayPlanNoGoc NVARCHAR(50) = 'DP_OLD_SAMPLE';
DECLARE @BarcodeB351 NVARCHAR(50) = 'BC_NEW_SAMPLE';
DECLARE @CPHNo NVARCHAR(50) = 'CPH_SAMPLE';

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Cập nhật STB_SetInfo
    UPDATE STB_SetInfo
    SET Barcode = @BarcodeGoc, MaterialCode = @MaterialCodeGoc, DayPlanNo = @DayPlanNoGoc
    WHERE ControlNo = @ControlNo;

    -- 2. Cập nhật STB_MaterialLotInfo
    UPDATE STB_MaterialLotInfo
    SET MaterialCode = @MaterialCodeGoc, MaterialLotNo = @BarcodeGoc, LotNo = @BarcodeGoc
    WHERE LotNo IN (@BarcodeB351, @BarcodeGoc) OR MaterialLotNo IN (@BarcodeB351, @BarcodeGoc);

    -- 3. Cập nhật STB_ProdRouteHist
    UPDATE STB_ProdRouteHist
    SET DayPlanNo = @DayPlanNoGoc, MaterialCode = @MaterialCodeGoc
    WHERE ControlNo = @ControlNo;

    -- 4. Xóa nhật ký B351
    DELETE FROM STB_LotChangeMaterialHistory WHERE CPHNo = @CPHNo;

    -- ROLLBACK TRANSACTION; -- Mặc định an toàn
    COMMIT TRANSACTION;
    PRINT 'SUCCESS: Rollback B351 thanh cong!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH;
