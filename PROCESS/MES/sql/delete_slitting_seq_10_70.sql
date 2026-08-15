-- ====================================================================
-- SCRIPT XÓA LỊCH SỬ CẮT ĐIỆN CỰC (STT 10-70) CHO LOT VVQO2020001E36
-- Database: SmartFactoryV2
-- Screen: [B552] Vietnam_Kết quả đo điện cực (Tab Slitting - Cắt điện cực)
-- Target Table: STB_ElectrodeSlittingResult (Seq: 10 -> 70)
-- ====================================================================
USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Đếm và kiểm tra số bản ghi mục tiêu
    DECLARE @TargetCount INT;
    SELECT @TargetCount = COUNT(*) 
    FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
    WHERE ElectrodeLotNumber = 'VVQO2020001E36'
      AND Seq BETWEEN 10 AND 70;

    PRINT N'Số bản ghi xác nhận cần xóa trong STB_ElectrodeSlittingResult (STT 10 - 70): ' + CAST(@TargetCount AS VARCHAR(10));

    -- 2. Thực hiện xóa an toàn trong Transaction
    DELETE FROM STB_ElectrodeSlittingResult
    WHERE ElectrodeLotNumber = 'VVQO2020001E36'
      AND Seq BETWEEN 10 AND 70;

    -- 3. Xác nhận Hoàn tất
    COMMIT TRANSACTION;
    PRINT N'SUCCESS: Đã xóa thành công ' + CAST(@TargetCount AS VARCHAR(10)) + N' bản ghi (STT 10 đến 70) của Lot VVQO2020001E36 khỏi B552!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'LỖI: ' + ERROR_MESSAGE();
END CATCH;
GO
