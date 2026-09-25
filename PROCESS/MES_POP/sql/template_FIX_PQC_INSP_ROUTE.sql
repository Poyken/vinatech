-- ==============================================================================
-- TEMPLATE: FIX PQC INSPECTION ROUTE (ĐIỀU CHỈNH CÔNG ĐOẠN HẠNG MỤC KIỂM TRA PQC)
-- Reference: POP_KB_03 Case 6 | HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI
-- Author / ChangeUserID: vanduc
-- Created At: {{DATE_CREATED}}
-- Issue Code: {{ISSUE_CODE}}
-- Target: Điều chỉnh RouteCode cho các mã đo kiểm STB_CommInspDocItem bị gắn sai
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Kiểm tra dữ liệu tài liệu kiểm tra hiện tại)
DECLARE @Barcode VARCHAR(50) = '<MÃ_LOT>';       -- VD: 'VVQR163R825713'
DECLARE @TargetRoute VARCHAR(50) = 'V-24_HY';     -- Công đoạn chuẩn cần gắn

SELECT 
    DH.CommInspDocNo, SI.Barcode, DI.CommInspDocItemNo, DI.CommInspItemCode, DI.RouteCode AS CurrentRoute,
    DI.ItemTargetQty, DI.ItemQty
FROM SmartFactoryV2.dbo.STB_CommInspDocHistory DH WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK) ON SI.ControlNo = DH.ProdNo
INNER JOIN SmartFactoryV2.dbo.STB_CommInspDocItem DI WITH(NOLOCK) ON DI.CommInspDocNo = DH.CommInspDocNo
WHERE SI.Barcode = @Barcode
  AND DI.CommInspItemCode IN ('V_H1_HY', 'V_H2_HY', 'V_WA_HY');
GO

-- 2. THỰC THI ĐIỀU CHỈNH CÔNG ĐOẠN
-- Lưu ý: Kỹ sư phải vào màn hình WinForm C141 để cập nhật Master trước khi chạy script này!
BEGIN TRAN;

DECLARE @Barcode VARCHAR(50) = '<MÃ_LOT>';
DECLARE @TargetRoute VARCHAR(50) = 'V-24_HY';

UPDATE DI
SET 
    DI.RouteCode = @TargetRoute
FROM SmartFactoryV2.dbo.STB_CommInspDocItem DI
INNER JOIN SmartFactoryV2.dbo.STB_CommInspDocHistory DH ON DH.CommInspDocNo = DI.CommInspDocNo
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo SI ON SI.ControlNo = DH.ProdNo
WHERE SI.Barcode = @Barcode
  AND DI.CommInspItemCode IN ('V_H1_HY', 'V_H2_HY', 'V_WA_HY');

DECLARE @RowsUpdated INT = @@ROWCOUNT;
PRINT '-> Số hạng mục kiểm tra PQC được cập nhật sang ' + @TargetRoute + ': ' + CAST(@RowsUpdated AS VARCHAR(10));

-- Đổi ROLLBACK thành COMMIT sau khi xác minh
ROLLBACK TRAN;
-- COMMIT TRAN;
PRINT '-> [XÁC MINH] Hãy kiểm tra kỹ trước khi đổi ROLLBACK thành COMMIT TRAN!';
GO
