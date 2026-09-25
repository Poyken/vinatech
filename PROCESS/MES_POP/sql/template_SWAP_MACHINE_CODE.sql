-- ==============================================================================
-- TEMPLATE: SWAP MACHINE CODE (ĐỔI MÃ MÁY NHẦM KIOSK POP & MES)
-- Reference: POP_KB_03 Case 16 | RULE 20 (POP BẤT BIẾN - EA PLAYBOOK)
-- Author / ChangeUserID: vanduc
-- Created At: {{DATE_CREATED}}
-- Issue Code: {{ISSUE_CODE}}
-- Target: Cập nhật đồng thời cả 2 bảng STB_ProdRouteHist và MongoToMesPerformance
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Tra cứu mã máy hiện tại và mã máy mới)
-- Gợi ý: Tra cứu MachineCode theo MachineName tại màn hình WinForm B270
DECLARE @Barcode VARCHAR(50) = '<MÃ_LOT_HOẶC_BARCODE>'; -- VD: 'VVQR193R072730'
DECLARE @RouteCode VARCHAR(50) = '<MÃ_CÔNG_ĐOẠN>';      -- VD: 'V-22_HY'
DECLARE @NewMachineCode VARCHAR(50) = '<MÃ_MÁY_MỚI>';   -- VD: 'VVMHY130'

SELECT 
    H.ProdRouteHistNo, S.Barcode, H.RouteCode, H.MachineCode AS CurrentMesMachine, H.ProdQty, H.JobDate
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON H.ControlNo = S.ControlNo
WHERE S.Barcode = @Barcode AND H.RouteCode = @RouteCode;

SELECT 
    PerformanceId, Barcode, RouteCode, MachineCode AS CurrentPopMachine, IsTransferred, IsDone, CreateDate
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
WHERE Barcode = @Barcode AND RouteCode = @RouteCode;
GO

-- 2. THỰC THI HOTFIX AN TOÀN (BẮT BUỘC ĐỒNG BỘ CẢ 2 BẢNG)
BEGIN TRAN;

DECLARE @Barcode VARCHAR(50) = '<MÃ_LOT_HOẶC_BARCODE>';
DECLARE @RouteCode VARCHAR(50) = '<MÃ_CÔNG_ĐOẠN>';
DECLARE @NewMachineCode VARCHAR(50) = '<MÃ_MÁY_MỚI>';

-- 2.1 Cập nhật trên MES Lõi
UPDATE H
SET 
    H.MachineCode    = @NewMachineCode,
    H.ChangeDateTime = GETDATE(),
    H.ChangeUserID   = 'vanduc'
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode = @Barcode AND H.RouteCode = @RouteCode;

DECLARE @RowsMes INT = @@ROWCOUNT;

-- 2.2 Cập nhật trên bảng trung gian POP (Chống Background Worker ghi đè)
UPDATE MongoToMesPerformance
SET 
    MachineCode = @NewMachineCode
WHERE Barcode = @Barcode AND RouteCode = @RouteCode;

DECLARE @RowsPop INT = @@ROWCOUNT;

PRINT '-> Số dòng STB_ProdRouteHist cập nhật: ' + CAST(@RowsMes AS VARCHAR(10));
PRINT '-> Số dòng MongoToMesPerformance cập nhật: ' + CAST(@RowsPop AS VARCHAR(10));

-- 2.3 Kiểm tra an toàn
IF @RowsMes = 0 AND @RowsPop = 0
BEGIN
    PRINT '-> [CẢNH BÁO] Không tìm thấy bản ghi cần sửa! Đang ROLLBACK...';
    ROLLBACK TRAN;
END
ELSE
BEGIN
    -- Đổi ROLLBACK thành COMMIT sau khi kiểm tra số dòng khớp
    ROLLBACK TRAN;
    -- COMMIT TRAN;
    PRINT '-> [XÁC MINH] Hãy kiểm tra kỹ trước khi đổi ROLLBACK thành COMMIT TRAN!';
END
GO
