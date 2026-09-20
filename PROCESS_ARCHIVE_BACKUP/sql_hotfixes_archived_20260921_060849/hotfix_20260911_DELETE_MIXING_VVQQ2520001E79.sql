USE SmartFactoryV2;
GO

-- ======================================================================
-- HOTFIX: RESET / XÓA DỮ LIỆU MIXING CHO LOT ĐIỆN CỰC VVQQ2520001E79
-- Target Lot : VVQQ2520001E79 (CREHCO85 - Coatingroll- HCE 200 (SuperP 6%) (-))
-- Screen     : [B552] Slitting Configurations & Electrode Measure Result (Tab: Mixing)
-- Chuẩn IT   : Theo chỉ đạo quản trị viên & chuẩn tiền bối (hotfix_20260910_DELETE_MIXING_VVQR0720001E40.sql)
-- QUY TẮC CỐT LÕI:
--   1. CẤM XÓA / ĐỘNG BẢNG STB_SetInfo (Bảo lưu nguyên vẹn để mã Lot tiếp tục vận hành)
--   2. XÓA bản ghi các bước cân trong STB_ElectrodeMixStepInfo (SUM InputQty1 -> 0)
--   3. UPDATE các cột thông số mẻ trộn trong STB_ElectrodeMixInfo về NULL / 0
--   4. ChangeUserID = 'vanduc'
-- ======================================================================

SET NOCOUNT ON;

DECLARE @LotNumber NVARCHAR(50) = N'VVQQ2520001E79';

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Snapshot backup vào tempdb trong phiên làm việc
    IF OBJECT_ID('tempdb..#BAK_ElectrodeMixStepInfo') IS NOT NULL DROP TABLE #BAK_ElectrodeMixStepInfo;
    SELECT * INTO #BAK_ElectrodeMixStepInfo 
    FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = @LotNumber;

    IF OBJECT_ID('tempdb..#BAK_ElectrodeMixInfo') IS NOT NULL DROP TABLE #BAK_ElectrodeMixInfo;
    SELECT * INTO #BAK_ElectrodeMixInfo 
    FROM STB_ElectrodeMixInfo WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = @LotNumber;

    -- 2. Xóa chi tiết các bước cân (STB_ElectrodeMixStepInfo)
    DELETE FROM STB_ElectrodeMixStepInfo 
    WHERE ElectrodeLotNumber = @LotNumber;
    PRINT N'  -> [1/3] Đã xóa toàn bộ 13 bước cân trong STB_ElectrodeMixStepInfo.';

    -- 3. Cập nhật bảng thông tin mẻ trộn (STB_ElectrodeMixInfo) về NULL và ProductionQty = 0
    UPDATE STB_ElectrodeMixInfo 
    SET ProductionQty        = 0,
        MachineCode          = '',
        WorkerCode           = '',
        WorkDate             = NULL,
        Temperature          = NULL,
        Humidity             = NULL,
        TankInsideTemp       = NULL,
        ViscosityValue       = NULL,
        SpecificGravityValue = NULL,
        MixingTemperature    = NULL,
        CoolantTemperature   = NULL,
        SpecificComment      = NULL,
        ChangeDateTime       = GETDATE(),
        ChangeUserID         = N'vanduc'
    WHERE ElectrodeLotNumber = @LotNumber;
    PRINT N'  -> [2/3] Đã UPDATE STB_ElectrodeMixInfo: ProductionQty = 0 và reset toàn bộ thông số về NULL.';

    -- 4. BẢO LƯU NGUYÊN VẸN STB_SetInfo (TUYỆT ĐỐI KHÔNG ĐỘNG)
    PRINT N'  -> [3/3] BẢO LƯU NGUYÊN VẸN bảng STB_SetInfo theo đúng chỉ đạo.';

    -- 5. Hậu kiểm (Post-flight Verification)
    DECLARE @RemainStepCount INT = 0;
    DECLARE @CurrProdQty NUMERIC(20,5) = -1;
    DECLARE @SetInfoCount INT = 0;

    SELECT @RemainStepCount = COUNT(*) FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = @LotNumber;
    SELECT @CurrProdQty = ISNULL(ProductionQty, -1) FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = @LotNumber;
    SELECT @SetInfoCount = COUNT(*) FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = @LotNumber;

    IF @RemainStepCount = 0 AND @CurrProdQty = 0 AND @SetInfoCount > 0
    BEGIN
        COMMIT TRANSACTION;
        PRINT N'==> [SUCCESS] ĐÃ XÓA SẠCH BƯỚC CÂN VÀ RESET THÔNG TIN MẺ TRỘN THÀNH CÔNG CHO LOT ' + @LotNumber;
        PRINT N'==> STB_SetInfo được bảo toàn nguyên vẹn (' + CAST(@SetInfoCount AS NVARCHAR(10)) + N' bản ghi).';
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR(N'⛔ [VERIFY FAILED] Điều kiện hậu kiểm không thỏa mãn. Đã ROLLBACK toàn bộ giao dịch!', 16, 1);
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(N'⛔ [ERROR] Lỗi thực thi: %s', 16, 1, @ErrMsg);
END CATCH;
GO
