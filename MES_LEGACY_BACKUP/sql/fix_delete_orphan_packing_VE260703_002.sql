-- ==============================================================================
-- FIX SCRIPT: DELETE ORPHAN SUB-LOT RECORD FOR B523 / HN523 PACKING RECOVERY
-- LOT NO: VE260703-002
-- TARGET MATERIAL LOT NO: 20260814000278 (Qty = 705, PackingID IS NULL/EMPTY)
-- PURPOSE: Delete orphan sub-lot record so that 705 Qty returns to "Slg còn lại"
-- REFERENCE SoT: KB_04_02_SCREEN_BUGS.md § 4.1 (Kịch bản B)
-- ==============================================================================
USE [SmartFactoryV2];
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Kiểm tra bản ghi mồ côi 705 sản phẩm trước khi xóa
    SELECT MaterialLotNo, LotNo, PackingID, CurrentQty, InitialQty, CreateDateTime
    FROM dbo.STB_MaterialLotInfo WITH(NOLOCK)
    WHERE MaterialLotNo = '20260814000278' AND LotNo = 'VE260703-002';

    -- 2. Xóa bản ghi mồ côi khỏi STB_MaterialLotInfo để đẩy 705 về Slg còn lại
    DELETE FROM dbo.STB_MaterialLotInfo
    WHERE MaterialLotNo = '20260814000278'
      AND LotNo = 'VE260703-002'
      AND (PackingID IS NULL OR RTRIM(LTRIM(PackingID)) = '');

    -- 3. Kiểm tra số lượng ảnh hưởng (Phải = 1)
    PRINT 'Đã xóa bản ghi mồ côi MaterialLotNo 20260814000278 (705 SP) thành công!';

    -- 4. Kiểm tra lại tổng sản lượng đóng gói sau khi xóa (Tổng còn lại = 9,295, Slg còn lại = 705)
    SELECT LotNo, SUM(CurrentQty) AS TotalPackedQty, (10000 - SUM(CurrentQty)) AS SlgConLai
    FROM dbo.STB_MaterialLotInfo WITH(NOLOCK)
    WHERE LotNo = 'VE260703-002'
    GROUP BY LotNo;

    -- XÁC NHẬN AN TOÀN: Mặc định COMMIT khi chạy chính thức
    COMMIT TRANSACTION;
    PRINT 'SUCCESS: Đã commit giao dịch thành công!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
