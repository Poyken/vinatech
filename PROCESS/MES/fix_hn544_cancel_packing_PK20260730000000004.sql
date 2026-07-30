-- ==============================================================================
-- FIX SCRIPT: HỦY PACKING GỘP (RÃ BOX) CHO MÀN HÌNH HN544
-- Target PackingID: PK20260730000000004
-- Target Database: SmartFactoryV2
-- Created Date: 2026-07-30
-- Quy tắc an toàn: Đã bọc BEGIN TRANSACTION ... ROLLBACK
-- ==============================================================================

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Kiểm tra trạng thái dữ liệu trước khi rã Box
    SELECT MaterialLotNo, LotNo, PackingID, CurrentQty, InitialQty 
    FROM STB_MaterialLotInfo WITH(NOLOCK)
    WHERE PackingID = 'PK20260730000000004';

    -- 2. Giải phóng liên kết PackingID khỏi 4 Lot con trong STB_MaterialLotInfo
    UPDATE STB_MaterialLotInfo 
    SET PackingID = NULL 
    WHERE PackingID = 'PK20260730000000004';

    PRINT CONCAT('-> Đã giải phóng ', @@ROWCOUNT, ' Lot con khỏi PackingID PK20260730000000004.');

    -- 3. Xóa 4 bản ghi gộp box trong STB_DividePackaging (DivideID: 29928, 29929, 29930, 29931)
    DELETE FROM STB_DividePackaging 
    WHERE PackingID = 'PK20260730000000004';

    PRINT CONCAT('-> Đã xóa ', @@ROWCOUNT, ' bản ghi trong STB_DividePackaging.');

    -- MẶC ĐỊNH ROLLBACK ĐỂ KIỂM TRA. ĐỔI THÀNH COMMIT TRANSACTION ĐỂ THỰC THI THẬT.
    ROLLBACK TRANSACTION;
    -- COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Lỗi thực thi rã Box: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
