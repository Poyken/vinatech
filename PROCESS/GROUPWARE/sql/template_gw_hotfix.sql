-- ==============================================================================
-- TEMPLATE HOTFIX CHUẨN CSDL VINATECH_GROUP (UTF-8 WITH BOM)
-- LƯU Ý AN TOÀN: Luôn chạy với ROLLBACK trước để kiểm tra số dòng bị ảnh hưởng!
-- ==============================================================================

USE [VINATECH_GROUP];
GO

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Ghi nhận thời điểm và mục tiêu can thiệp
    PRINT '>>> BAT DAU THUC THI HOTFIX TREN VINATECH_GROUP...';

    -- 2. Đặt câu lệnh can thiệp dữ liệu tại đây (Ví dụ điều chỉnh cờ)
    -- UPDATE dbo.VINA_DOCUMENT_SAVE
    -- SET DOCUMENT_SAVE_MODIFY_DATE = GETDATE()
    -- WHERE DOCUMENT_SAVE_CODE = 'TEST';

    -- 3. Kiểm tra số dòng bị ảnh hưởng
    -- IF @@ROWCOUNT = 0
    -- BEGIN
    --     RAISERROR('Khong tim thay ban ghi can xu ly!', 16, 1);
    -- END

    PRINT '>>> THUC THI THANH CONG. KIEM TRA DU LIEU TRUOC KHI COMMIT.';

    -- MAC DINH: ROLLBACK DE KIEM TRA AN TOAN. 
    -- Chi thay bang COMMIT TRANSACTION khi da kiem tra ket qua chinh xac 100%!
    ROLLBACK TRANSACTION;
    PRINT '>>> DA ROLLBACK AN TOAN (TEST RUN).';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    PRINT '>>> CO LOI XAY RA: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
