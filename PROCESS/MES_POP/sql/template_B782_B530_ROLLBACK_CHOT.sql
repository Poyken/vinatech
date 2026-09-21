-- ==============================================================================
-- TEMPLATE 3: ROLLBACK CHỐT NHẦM SẢN LƯỢNG (B782 / B530 / POP KIOSK)
-- Mục đích: Hủy lượt chốt sản lượng sai/kẹt sớm để công nhân nhập lại trên MES/POP
-- Thay thế: 
--   {{BARCODE}}          : Barcode của Lot (VD: 'VVQR013R072727')
--   {{CONTROL_NO}}       : ControlNo của Lot (VD: '20260901000137')
--   {{ROUTE_CODE}}       : Công đoạn cần rollback (VD: 'V-28_HY', 'V-26_HY', 'VE07')
--   {{PROD_ROUTE_HIST_NO}}: Mã lịch sử chốt cần xóa (nếu biết cụ thể)
--   {{DATE_TAG}}         : Nhãn ngày YYYYMMDD (VD: '20260921')
--
-- TUÂN THỦ QUY TẮC AN TOÀN MES:
--   [RULE 1]  : Thử nghiệm SELECT trước, chạy trong TRANSACTION
--   [RULE 11] : CẤM DELETE/MODIFY STB_SetInfo hoặc STB_LotSetInfo để bảo toàn identity Lot!
--   [RULE 13] : Dual-sync MES & POP (xóa cả trên MongoToMesPerformance / PACKING_REMAIN)
-- ==============================================================================

USE SmartFactoryV2;
GO

-- ------------------------------------------------------------------------------
-- BƯỚC 0: KIỂM TRA DỮ LIỆU HIỆN TẠI (PRE-CHECK)
-- ------------------------------------------------------------------------------
SELECT 
    SI.ControlNo, SI.Barcode, SI.CurrentRouteCode, SI.MaterialCode, SI.LotQty
FROM STB_SetInfo SI WITH(NOLOCK)
WHERE SI.Barcode = '{{BARCODE}}' OR SI.ControlNo = '{{CONTROL_NO}}';

SELECT 
    ProdRouteHistNo, ControlNo, RouteCode, InQty, OutQty, JobDate, ProdDateTime, CreateUserID
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo = '{{CONTROL_NO}}' AND RouteCode = '{{ROUTE_CODE}}'
ORDER BY ProdRouteHistNo DESC;

SELECT 
    Barcode, RouteCode, MachineCode, TotalProdQty, IsDone, CompletedDate
FROM MongoToMesPerformance WITH(NOLOCK)
WHERE Barcode = '{{BARCODE}}' AND RouteCode = '{{ROUTE_CODE}}';
GO

-- ------------------------------------------------------------------------------
-- BƯỚC 1: TẠO SNAPSHOT BACKUP BẢO VỆ DỮ LIỆU GỐC
-- ------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BAK_STB_ProdRouteHist_{{DATE_TAG}}_{{BARCODE}}')
BEGIN
    SELECT * INTO BAK_STB_ProdRouteHist_{{DATE_TAG}}_{{BARCODE}}
    FROM STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = '{{CONTROL_NO}}' AND RouteCode = '{{ROUTE_CODE}}';
    PRINT '>> [BACKUP] Da tao: BAK_STB_ProdRouteHist_{{DATE_TAG}}_{{BARCODE}}';
END;

-- Backup thêm bảng phụ nếu có dữ liệu
IF EXISTS (SELECT 1 FROM STB_ProdRouteWorkerHist WITH(NOLOCK) 
           WHERE ProdRouteHistNo IN (SELECT ProdRouteHistNo FROM STB_ProdRouteHist WHERE ControlNo = '{{CONTROL_NO}}' AND RouteCode = '{{ROUTE_CODE}}'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BAK_STB_ProdRouteWorkerHist_{{DATE_TAG}}_{{BARCODE}}')
    BEGIN
        SELECT * INTO BAK_STB_ProdRouteWorkerHist_{{DATE_TAG}}_{{BARCODE}}
        FROM STB_ProdRouteWorkerHist WITH(NOLOCK)
        WHERE ProdRouteHistNo IN (SELECT ProdRouteHistNo FROM STB_ProdRouteHist WHERE ControlNo = '{{CONTROL_NO}}' AND RouteCode = '{{ROUTE_CODE}}');
        PRINT '>> [BACKUP] Da tao: BAK_STB_ProdRouteWorkerHist_{{DATE_TAG}}_{{BARCODE}}';
    END;
END;
GO

-- ------------------------------------------------------------------------------
-- BƯỚC 2: THỰC THI ROLLBACK TRONG TRANSACTION AN TOÀN
-- ------------------------------------------------------------------------------
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @AffectedRows INT = 0;

    -- 1. Xóa chi tiết công nhân nếu có
    DELETE FROM STB_ProdRouteWorkerHist
    WHERE ProdRouteHistNo IN (
        SELECT ProdRouteHistNo FROM STB_ProdRouteHist 
        WHERE ControlNo = '{{CONTROL_NO}}' AND RouteCode = '{{ROUTE_CODE}}'
    );
    SET @AffectedRows = @@ROWCOUNT;
    PRINT '>> [EXEC 1] Xoa STB_ProdRouteWorkerHist: ' + CAST(@AffectedRows AS VARCHAR) + ' rows.';

    -- 2. Xóa lượt chốt công đoạn trong STB_ProdRouteHist
    DELETE FROM STB_ProdRouteHist
    WHERE ControlNo = '{{CONTROL_NO}}' 
      AND RouteCode = '{{ROUTE_CODE}}'
      -- AND ProdRouteHistNo = '{{PROD_ROUTE_HIST_NO}}' -- Bỏ comment nếu muốn xóa đích danh 1 lượt chốt
    ;
    SET @AffectedRows = @@ROWCOUNT;
    PRINT '>> [EXEC 2] Xoa STB_ProdRouteHist: ' + CAST(@AffectedRows AS VARCHAR) + ' rows.';

    -- 4. Trả lại công đoạn hiện tại trên STB_SetInfo (RULE 11: CHỈ UPDATE RouteCode, CẤM XÓA SetInfo)
    UPDATE STB_SetInfo
    SET CurrentRouteCode = '{{ROUTE_CODE}}',
        ChangeDateTime = GETDATE(),
        ChangeUserID = 'it_rollback'
    WHERE ControlNo = '{{CONTROL_NO}}';
    PRINT '>> [EXEC 4] Update CurrentRouteCode tren STB_SetInfo ve: {{ROUTE_CODE}}.';

    -- 5. Đồng bộ POP Kiosk nếu công đoạn này chạy qua POP (RULE 13)
    IF EXISTS (SELECT 1 FROM MongoToMesPerformance WHERE Barcode = '{{BARCODE}}' AND RouteCode = '{{ROUTE_CODE}}')
    BEGIN
        DELETE FROM MongoToMesPerformance
        WHERE Barcode = '{{BARCODE}}' AND RouteCode = '{{ROUTE_CODE}}';
        PRINT '>> [EXEC 5] Xoa ban ghi ket trong MongoToMesPerformance.';
    END;

    -- 6. Dọn bản ghi đóng gói dở dang POP nếu là công đoạn đóng gói V-28
    IF '{{ROUTE_CODE}}' LIKE '%V-28%' OR '{{ROUTE_CODE}}' LIKE '%V-29%'
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'VINATECH_POP')
        BEGIN
            EXEC('DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY WHERE BARCODE = ''{{BARCODE}}'' AND ROUTE_CODE = ''{{ROUTE_CODE}}'';');
            PRINT '>> [EXEC 6] Xoa VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY.';
        END;
    END;

    -- XÁC THỰC MẶC ĐỊNH AN TOÀN: Đổi thành COMMIT TRANSACTION khi chắc chắn
    ROLLBACK TRANSACTION;
    PRINT '>> [TEST PASS] Da mo phong thanh cong! Doi ROLLBACK thanh COMMIT TRANSACTION de thuc thi.';

    -- COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '>> [ERROR] Rollback that bai, da khoi phuc transaction: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

-- ------------------------------------------------------------------------------
-- BƯỚC 3: HƯỚNG DẪN HOÀN TẤT VÀ KIỂM TRA LẠI
-- ------------------------------------------------------------------------------
-- 1. Chạy lại câu SELECT ở Bước 0 để đảm bảo RouteCode đã về {{ROUTE_CODE}}
-- 2. Yêu cầu OP/Kiosk tải lại màn hình và chốt sản lượng bình thường
-- 3. Xóa bảng backup sau 3-7 ngày: DROP TABLE BAK_STB_ProdRouteHist_{{DATE_TAG}}_{{BARCODE}};
