USE SmartFactoryV2;
GO

SET NOCOUNT ON;

-- ==============================================================================
-- HOTFIX: Reset công đoạn cho Lot điện cực VVQQ2520001E34 thành Lot mới tinh 100%
-- Mục đích: Phục vụ người dùng thực hành toàn diện quy trình Điện cực trên POP Kiosk
-- An toàn: Có Pre-flight kiểm tra, Transaction tự bảo vệ và kiểm tra hậu kiểm
-- ==============================================================================

DECLARE @cnt INT = (SELECT COUNT(*) FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = 'VVQQ2520001E34');
IF @cnt = 0
BEGIN
    PRINT N'==> [INFO] Khong tim thay ban ghi STB_ElectrodeMixInfo cho lot VVQQ2520001E34. Lot da o trang thai sach!';
    RETURN;
END;

BEGIN TRANSACTION;
BEGIN TRY
    -- Xóa dòng ghi nhận mẻ trộn dở dang
    DELETE FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQQ2520001E34';

    DECLARE @remain INT = (SELECT COUNT(*) FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQQ2520001E34');
    IF @remain = 0
    BEGIN
        COMMIT TRANSACTION;
        PRINT N'==> [SUCCESS] Da reset thanh cong cong doan cho lot VVQQ2520001E34 ve trang thai moi tinh 100%!';
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR(N'==> [ERROR] Con du lieu ton dong, da rollback an toan!', 16, 1);
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@msg, 16, 1);
END CATCH;
GO
