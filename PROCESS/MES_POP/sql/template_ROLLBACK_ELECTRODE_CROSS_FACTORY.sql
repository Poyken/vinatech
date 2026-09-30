-- ==============================================================================
-- TEMPLATE: ROLLBACK XẺ / ĐÓNG GÓI CHIA CUỘN MẸ ĐIỆN CỰC NHẦM NHÀ MÁY (BN -> HY)
-- Màn hình liên quan: POP Web Kiosk (/pop/screen) - Tab Đóng gói chia / Slitting Line
-- Thay thế: {{LOT_NUMBER}}, {{CONTROL_NO}}
-- Tham chiếu: POP_KB_03 § Case 18, HOTFIX_LOG § ID_63, POP_MATRIX § POP-CASE-18
-- Author / ChangeUserID: vanduc
-- ==============================================================================
-- HUONG DAN:
--   1. Thay thế {{LOT_NUMBER}} bằng mã Lot cuộn mẹ (VD: VWQQ0720001E16)
--   2. Thay thế {{CONTROL_NO}} bằng mã ControlNo trong STB_SetInfo (VD: 20260806000241)
--   3. Mặc định chạy trong Transaction an toàn, chỉ COMMIT khi đã xác nhận chính xác
-- ==============================================================================

USE SmartFactoryV2;
GO

SET NOCOUNT ON;

-- 1. [BEFORE] KHẢO SÁT HIỆN TRẠNG TRƯỚC KHI CAN THIỆP
SELECT Barcode, ControlNo, CompleteRoute, IsLineInput, ModifyDateTime, ChangeUserID
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE Barcode = '{{LOT_NUMBER}}';

SELECT MaterialLotNo, LotNo, MaterialCode, CurrentQty, InitialQty, CreateDateTime
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotNo = '{{LOT_NUMBER}}';

SELECT Barcode, RouteCode, TotalProdQty, IsDone, IsTransferred, InsertDateTime
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
WHERE Barcode = '{{LOT_NUMBER}}';

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @LotNo VARCHAR(50) = '{{LOT_NUMBER}}';
    DECLARE @ControlNo VARCHAR(20) = '{{CONTROL_NO}}';
    DECLARE @ChangeUser VARCHAR(20) = 'vanduc';

    -- 2. THU HỒI CÁC CUỘN BTP CON ĐÃ SINH NHẦM TRÊN POP BẮC NINH
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo
    WHERE LotNo = @LotNo;
    PRINT '>> 1. Da thu hoi cac cuon BTP trong STB_MaterialLotInfo: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dong.';

    -- 3. XÓA BẢN GHI KẾT QUẢ CẮT XẺ ĐIỆN CỰC (NẾU CÓ)
    DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeSlittingResult WHERE ElectrodeLotNumber = @LotNo;
    DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeSlittingInfo WHERE ElectrodeLotNumber = @LotNo;
    PRINT '>> 2. Da don dep STB_ElectrodeSlittingResult & STB_ElectrodeSlittingInfo.';

    -- 4. HỦY PHIẾU ĐO KIỂM PQC ĐÃ TẠO THEO LƯỢT XẺ CŨ
    DELETE FROM SmartFactoryV2.dbo.STB_CommInspDocHistory
    WHERE DocNo IN (SELECT MaterialLotNo FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = @LotNo)
       OR (MaterialCode LIKE 'SRE%' AND MaterialLotNo = @LotNo);
    PRINT '>> 3. Da huy phieu PQC do kiem cu trong STB_CommInspDocHistory.';

    -- 5. RESET CÔNG ĐOẠN XẺ W-04 TRÊN BẢNG ĐỒNG BỘ POP KIOSK
    UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
    SET TotalProdQty = 0,
        TotalDefectQty = 0,
        IsDone = 0,
        IsTransferred = 0,
        ChangeDateTime = GETDATE()
    WHERE Barcode = @LotNo AND RouteCode = 'W-04';
    PRINT '>> 4. Da reset cong doan W-04 tren MongoToMesPerformance: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' dong.';

    -- 6. XÓA DỮ LIỆU ĐỆM ĐÓNG GÓI TRÊN CSDL POP
    DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY 
    WHERE BARCODE = @LotNo;
    PRINT '>> 5. Da don dep bang dem VINA_PACKING_REMAIN_QTY.';

    -- 7. GHI NHẬT KÝ KIỂM TOÁN AUDIT TRAIL THEO CHUẨN IT VINATECH
    INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHistCancelHist (LotNo, CreateUserID, CreateDateTime)
    VALUES (@LotNo, @ChangeUser, GETDATE());
    PRINT '>> 6. Da ghi log kiem toan vao STB_ProdRouteHistCancelHist.';

    -- 8. KHÔI PHỤC CUỘN MẸ VÀ KÍCH HOẠT LẠI CỜ NẠP CHUYỀN ĐỂ KIOSK HY NHẬN DIỆN
    UPDATE SmartFactoryV2.dbo.STB_SetInfo
    SET CompleteRoute = 0,
        IsLineInput = 1,
        ModifyDateTime = GETDATE(),
        ChangeUserID = @ChangeUser
    WHERE ControlNo = @ControlNo;
    PRINT '>> 7. Da khoi phuc cuon me va set IsLineInput = 1 tren STB_SetInfo.';

    -- [BẢO VỆ AN TOÀN]: Mặc định để ROLLBACK khi chạy thử nghiệm
    ROLLBACK TRANSACTION;
    PRINT '>> [AN TOAN] Giao dich da duoc ROLLBACK de kiem tra. Doi sang COMMIT TRANSACTION khi xac nhan chinh xac!';
    -- COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '>> [LOI] ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
