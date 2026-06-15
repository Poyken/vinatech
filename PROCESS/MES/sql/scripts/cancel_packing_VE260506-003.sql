-- =================================================================================
-- Author: Antigravity
-- Date: 2026-06-15
-- Description: Hủy 2 packing (PKQN2500089, PKQN2500091) của Lot VE260506-003 ở trạm B523.
--              Do 2 packing này đã được nhập kho thành phẩm (mã phiếu VNEPD04-260525-01),
--              hệ thống chặn không cho hủy trên giao diện UI.
--              Script này sẽ xóa khỏi kho thành phẩm, hủy Material Doc và trừ sản lượng chốt.
-- Safety Warning: Bọc trong Transaction. Chuyển ROLLBACK sang COMMIT sau khi test OK.
-- =================================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY

    -- 1. Xóa bản ghi trong kho thành phẩm Hà Nam (STB_VN_FINISHGOODS_HN_New) để mở khóa
    PRINT '1. Deleting finished goods records for PKQN2500089 and PKQN2500091...';
    DELETE FROM STB_VN_FINISHGOODS_HN_New 
    WHERE PackingID IN ('pkqn2500089', 'pkqn2500091') AND LotNo = 'VE260506-003';

    -- 2. Gọi procedure hệ thống hủy tài liệu nhập kho vật tư (giải phóng STB_MaterialLotInfo)
    PRINT '2. Canceling material documents...';
    -- Hủy packing PKQN2500089
    EXEC usp_DoCancelMaterialDoc 
        @pProcessLanguage = 'vn',
        @pProcessUserID = 'doanthao',
        @pMaterialDocNo = '260525000095';

    -- Hủy packing PKQN2500091
    EXEC usp_DoCancelMaterialDoc 
        @pProcessLanguage = 'vn',
        @pProcessUserID = 'doanthao',
        @pMaterialDocNo = '260525000097';

    -- 3. Cập nhật giảm sản lượng chốt công đoạn cuối (VE10) đi 1200 (600 x 2) trong STB_ProdRouteHist
    PRINT '3. Updating production routing history (Route VE10)...';
    UPDATE STB_ProdRouteHist
    SET ProdQty = ProdQty - 1200
    WHERE ControlNo = '20260428000416' AND RouteCode = 'VE10';

    -- 4. Cập nhật giảm sản lượng trong bảng tổng hợp công đoạn STB_ProdRouteSummary đi 1200
    PRINT '4. Updating routing summary...';
    UPDATE STB_ProdRouteSummary
    SET OutputQty = OutputQty - 1200
    WHERE ProductSummaryID = '20260525000326';

    -- 5. Cập nhật giảm sản lượng hoàn thành của PO đi 1200
    PRINT '5. Updating production order finish qty...';
    UPDATE STB_ProductionOrderInfo
    SET ProdFinishQty = ProdFinishQty - 1200
    WHERE PONo = '260428000013';

    -- 6. Xác minh kết quả sau khi xử lý
    PRINT 'Verification:';
    SELECT MaterialLotNo, LotNo, PackingID, CurrentQty, InitialQty 
    FROM STB_MaterialLotInfo WITH(NOLOCK) 
    WHERE LotNo = 'VE260506-003';

    -- Mặc định ROLLBACK để an toàn. Thay bằng COMMIT TRANSACTION khi muốn thực thi thật.
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back successfully. (Change to COMMIT TRANSACTION to persist changes)';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error occurred: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
