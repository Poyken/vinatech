-- ==============================================================================
-- TEMPLATE HOTFIX: HỦY LẺ 1 PACK / BOX BẤT KỲ TRÊN MES VÀ POP
-- Author: vanduc
-- Reference: POP_KB_04 §2.5 Phương án 4 & HOTFIX_LOG ID_53
-- 
-- HƯỚNG DẪN SỬ DỤNG:
-- 1. Chạy câu lệnh tra cứu để lấy @MaterialDocNo, @PackingID, @CancelQty từ mã tem Box:
--    SELECT MDLI.MaterialDocNo, MDLI.PackingID, MDLI.StockQty, MDLI.LotNo, SI.RouteCode
--    FROM SmartFactoryV2.dbo.STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
--    WHERE MDLI.LotID = '<MÃ_BOX_BARCODE>' OR MDLI.LotNo = '<MÃ_LOT>';
-- 2. Điền các giá trị vào 4 biến bên dưới.
-- 3. Chạy script ở chế độ ROLLBACK để kiểm tra @@ROWCOUNT.
-- 4. Khi đúng, đổi ROLLBACK thành COMMIT.
-- ==============================================================================
USE SmartFactoryV2;
GO

SET NOCOUNT ON;

BEGIN TRANSACTION;
BEGIN TRY
    -- <<< KHAI BÁO CÁC BIẾN CẦN HỦY LẺ >>>
    DECLARE @LotNo VARCHAR(50) = '<MÃ_LOT>';                    -- VD: 'VVQR143R060619'
    DECLARE @PackingID VARCHAR(50) = '<MÃ_PACKING_ID>';         -- VD: 'PKQR2300158'
    DECLARE @CancelQty NUMERIC(20,5) = 0.00000;                 -- VD: 495.00000 (SL của riêng Box cần hủy)
    DECLARE @RouteCode VARCHAR(20) = '<MÃ_CÔNG_ĐOẠN_ĐÓNG_GÓI>'; -- VD: 'V-28_HY', 'V-28', 'VE10'
    DECLARE @UserID VARCHAR(20) = 'vanduc';

    -- 1. Lấy thông tin điều phối ControlNo & PONo
    DECLARE @ControlNo VARCHAR(20), @PONo VARCHAR(20);
    SELECT @ControlNo = ControlNo, @PONo = PONo 
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
    WHERE Barcode = @LotNo;

    IF @ControlNo IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy thông tin Lot trong STB_SetInfo!', 16, 1);
        RETURN;
    END

    -- 2. Tìm chứng từ kho tương ứng của Pack và hủy chứng từ
    DECLARE @MaterialDocNo VARCHAR(20);
    SELECT @MaterialDocNo = MaterialDocNo 
    FROM SmartFactoryV2.dbo.STB_MaterialDocLotInfo WITH(NOLOCK)
    WHERE PackingID = @PackingID AND LotNo = @LotNo;

    IF @MaterialDocNo IS NOT NULL
    BEGIN
        EXEC usp_DoCancelMaterialDoc 
             @pProcessLanguage = 'VIETNAMESE', 
             @pProcessUserID = @UserID, 
             @pMaterialDocNo = @MaterialDocNo;
        PRINT N'>> 1. Đã hủy chứng từ kho: ' + @MaterialDocNo;
    END
    ELSE
    BEGIN
        PRINT N'>> [CẢNH BÁO] Không tìm thấy MaterialDocNo trong STB_MaterialDocLotInfo cho Pack: ' + @PackingID;
    END

    -- 3. Xóa thùng BTP của riêng Box này trong STB_MaterialLotInfo
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo 
    WHERE LotNo = @LotNo AND PackingID = @PackingID;
    PRINT N'>> 2. Đã xóa Box trong STB_MaterialLotInfo: ' + CAST(@@ROWCOUNT AS VARCHAR) + N' bản ghi.';

    -- 4. Giảm trừ sản lượng lũy kế đóng gói trong STB_ProdRouteHist
    UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist
    SET ProdQty = ProdQty - @CancelQty,
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode;
    PRINT N'>> 3. Đã giảm trừ ProdQty trong STB_ProdRouteHist.';

    -- Nếu sau khi trừ mà sản lượng về 0 (đã hủy hết tất cả các Box), xóa dòng chốt
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist
    WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode AND ProdQty <= 0;
    IF @@ROWCOUNT > 0
    BEGIN
        PRINT N'>> [THÔNG BÁO] Toàn bộ Box đã bị hủy, đã dọn sạch dòng chốt STB_ProdRouteHist.';
        DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist 
        WHERE ProdRouteHistNo NOT IN (SELECT ProdRouteHistNo FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK));
    END

    -- 5. Giảm trừ sản lượng hoàn thành PO và Tổng kết công đoạn
    UPDATE SmartFactoryV2.dbo.STB_ProductionOrderInfo
    SET ProdFinishQty = CASE WHEN ProdFinishQty >= @CancelQty THEN ProdFinishQty - @CancelQty ELSE 0 END
    WHERE PONo = @PONo;

    UPDATE SmartFactoryV2.dbo.STB_ProdRouteSummary
    SET OutputQty = CASE WHEN OutputQty >= @CancelQty THEN OutputQty - @CancelQty ELSE 0 END
    WHERE PONo = @PONo AND RouteCode = @RouteCode;
    PRINT N'>> 4. Đã giảm trừ sản lượng PO và RouteSummary.';

    -- 6. Đồng bộ Kiosk POP (MongoToMesPerformance)
    UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
    SET TotalProdQty = CASE WHEN TotalProdQty >= CAST(@CancelQty AS INT) THEN TotalProdQty - CAST(@CancelQty AS INT) ELSE 0 END,
        IsDone = 0,
        IsTransferred = 0,
        InsertDateTime = GETDATE()
    WHERE Barcode = @LotNo AND RouteCode = @RouteCode;
    PRINT N'>> 5. Đã đồng bộ giảm trừ Kiosk POP.';

    -- 7. Khôi phục trạng thái Lot trong STB_SetInfo về WIP (chưa hoàn thành)
    UPDATE SmartFactoryV2.dbo.STB_SetInfo 
    SET IsProdFinish = 0,
        ProdFinishDateTime = NULL,
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @ControlNo;
    PRINT N'>> 6. Đã khôi phục IsProdFinish = 0 trong STB_SetInfo.';

    -- 8. Ghi nhật ký kiểm toán Audit Trail
    INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHistCancelHist (LotNo, CreateUserID, CreateDateTime)
    VALUES (@LotNo, @UserID, GETDATE());
    PRINT N'>> 7. Đã ghi log Audit vào STB_ProdRouteHistCancelHist.';

    -- Đối soát kiểm tra
    PRINT N'--- KẾT QUẢ ĐỐI SOÁT ---';
    SELECT Barcode, IsProdFinish FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @ControlNo;
    SELECT RouteCode, ProdQty FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode;
    SELECT MaterialLotNo, PackingID, CurrentQty FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = @LotNo;

    -- [AN TOÀN]: Mặc định ROLLBACK để rà soát. Đổi sang COMMIT khi xác nhận chính xác
    ROLLBACK TRANSACTION;
    PRINT N'>> [AN TOÀN] Giao dịch đã ROLLBACK để kiểm tra. Đổi sang COMMIT khi xác nhận chính xác.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'>> LỖI PHÁT SINH: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
