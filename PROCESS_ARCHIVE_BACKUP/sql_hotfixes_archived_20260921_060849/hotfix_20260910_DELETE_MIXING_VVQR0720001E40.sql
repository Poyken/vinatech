USE SmartFactoryV2;
GO

-- ======================================================================
-- HOTFIX: XÓA MẺ TRỘN ĐIỆN CỰC THỪA (ELECTRODE MIXING CANCELLATION SOP)
-- Target Lot : VVQR0720001E40 (CRECO85-03 - Coating-Roll Etching-CY 85 200 1.5 batch (+))
-- Screen     : [B552] Slitting Configurations & Electrode Measure Result (Tab: Mixing)
-- Reference  : KB_09_SCREEN_BUG_FIXBOOK.md L220-L243 | KB_05_01 §8.10
-- Author     : Trường (MES Support Agent)
-- Created    : 2026-09-10 07:53:40
-- ======================================================================

SET NOCOUNT ON;

DECLARE @LotNumber NVARCHAR(50) = N'VVQR0720001E40';

-- [BƯỚC 1] PRE-FLIGHT GATE CHECK
DECLARE @CoatingCount INT = 0;
SELECT @CoatingCount = COUNT(*) FROM STB_ElectrodeCoatingInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = @LotNumber;

IF @CoatingCount > 0
BEGIN
    RAISERROR(N'⛔ [ABORT] Lot điện cực đã phát sinh công đoạn Coating (STB_ElectrodeCoatingInfo > 0). CẤM XÓA!', 16, 1);
    RETURN;
END;

PRINT N'==> [PRE-FLIGHT GATE PASSED] Chưa phát sinh Coating. Bắt đầu giao dịch xóa an toàn...';

-- [BƯỚC 2] THỰC HIỆN XÓA AN TOÀN TRONG GIAO DỊCH
BEGIN TRANSACTION;
BEGIN TRY
    -- 2.1 Snapshot backup dữ liệu trước khi xóa
    IF OBJECT_ID('tempdb..#BAK_ElectrodeMixStepInfo_VVQR0720001E40') IS NOT NULL 
        DROP TABLE #BAK_ElectrodeMixStepInfo_VVQR0720001E40;
    SELECT * INTO #BAK_ElectrodeMixStepInfo_VVQR0720001E40 
    FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = @LotNumber;

    IF OBJECT_ID('tempdb..#BAK_ElectrodeMixInfo_VVQR0720001E40') IS NOT NULL 
        DROP TABLE #BAK_ElectrodeMixInfo_VVQR0720001E40;
    SELECT * INTO #BAK_ElectrodeMixInfo_VVQR0720001E40 
    FROM STB_ElectrodeMixInfo WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = @LotNumber;


    -- 2.2 Xóa chi tiết các bước cân (STB_ElectrodeMixStepInfo)
    DELETE FROM STB_ElectrodeMixStepInfo 
    WHERE ElectrodeLotNumber = 'VVQR0720001E40';
    PRINT N'  -> Đã xóa 8 bước cân trong STB_ElectrodeMixStepInfo (SUM InputQty1 -> 0)';

    -- 2.3 Cập nhật thông tin mẻ trộn STB_ElectrodeMixInfo về 0 (Set Số lượng sản xuất = 0)
    -- Lưu ý: ViscosityResult là computed column tự động tính theo ViscosityValue, không update trực tiếp
    IF EXISTS (SELECT 1 FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = 'VVQR0720001E40')
    BEGIN
        UPDATE STB_ElectrodeMixInfo 
        SET ProductionQty = 0,
            MachineCode = '',
            WorkerCode = '',
            ViscosityValue = NULL,
            ChangeDateTime = GETDATE(),
            ChangeUserID = N'RESET_FIX'
        WHERE ElectrodeLotNumber = 'VVQR0720001E40';
        PRINT N'  -> Đã UPDATE STB_ElectrodeMixInfo: ProductionQty = 0, Reset thông số mẻ trộn';
    END
    ELSE
    BEGIN
        INSERT INTO STB_ElectrodeMixInfo (ElectrodeLotNumber, ProductionQty, CreateDateTime, CreateUserID)
        VALUES ('VVQR0720001E40', 0, GETDATE(), N'RESET_FIX');
        PRINT N'  -> Đã INSERT STB_ElectrodeMixInfo: ProductionQty = 0';
    END

    -- 2.4 GIỮ NGUYÊN STB_SetInfo (Barcode gốc được bảo lưu để chạy tiếp công đoạn Coating/Rollpress/Slitting hoặc cân lại)
    PRINT N'  -> [BẢO LƯU] STB_SetInfo được giữ nguyên để mã Lot tiếp tục sử dụng ở các công đoạn sau.';

    -- 2.5 POST-FLIGHT VERIFICATION
    DECLARE @RemainStepCount INT = 0;
    DECLARE @CurrProdQty NUMERIC(20,5) = -1;

    SELECT @RemainStepCount = COUNT(*) FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = @LotNumber;
    SELECT @CurrProdQty = ISNULL(ProductionQty, 0) FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = @LotNumber;

    IF @RemainStepCount = 0 AND @CurrProdQty = 0
    BEGIN
        COMMIT TRANSACTION;
        PRINT N'==> [SUCCESS] ĐÃ XÓA SẠCH BƯỚC CÂN VÀ UPDATE SỐ LƯỢNG SẢN XUẤT = 0 CHO LOT VVQR0720001E40.';
        PRINT N'==> Ô "Số lượng sản xuất" trên màn hình B552 sẽ hiển thị là 0, SetInfo được bảo lưu an toàn.';
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR(N'⛔ [VERIFY FAILED] Dữ liệu chưa về 0 sau khi cập nhật. Đã ROLLBACK toàn bộ giao dịch!', 16, 1);
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(N'⛔ [ERROR] Lỗi thực thi: %s', 16, 1, @ErrMsg);
END CATCH;
GO
