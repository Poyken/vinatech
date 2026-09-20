-- ==============================================================================
-- HOTFIX: XÓA DỮ LIỆU KẾT QUẢ CẮT ĐIỆN CỰC CHO MODEL 35105-720F
-- Màn hình liên quan: [B552] Vietnam_Kết quả đo điện cực (Tab Slitting)
-- Mã Lot điện cực: VVQQ2720001E42 (Seq 1 -> Seq 31, Width = 90.0)
-- Căn cứ KB: KB_09_SCREEN_BUG_FIXBOOK.md ([B552] Mục 2) & HOTFIX_LOG.md (ID_29)
-- DB Target: SmartFactoryV2
-- ==============================================================================

BEGIN TRANSACTION;

-- 1. Ghi nhận lịch sử xóa vào STB_ElectrodeSlittingResultHist (theo chuẩn SP usp_ElectrodeSlittingResult_iud)
INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID)
SELECT 
    ElectrodeLotNumber, 
    Seq, 
    'DELETE' AS Flag, 
    GETDATE() AS CreateDateTime, 
    N'SYSTEM_AI_FIX' AS CreateUserID
FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
WHERE ElectrodeLotNumber = 'VVQQ2720001E42'
  AND Seq BETWEEN 1 AND 31
  AND SlittingWidth = 90.00;

-- 2. Xóa các bản ghi chia cuộn cho model 35105-720F (Seq 1 đến 31)
DELETE FROM STB_ElectrodeSlittingResult
WHERE ElectrodeLotNumber = 'VVQQ2720001E42'
  AND Seq BETWEEN 1 AND 31
  AND SlittingWidth = 90.00;

-- 3. Kiểm tra số lượng bản ghi bị tác động
DECLARE @DeletedRows INT = @@ROWCOUNT;
PRINT N'Đã xóa thành công ' + CAST(@DeletedRows AS NVARCHAR(10)) + N' bản ghi Slitting cho Model 35105-720F của Lot VVQQ2720001E42.';

-- KIỂM TRA TRƯỚC KHI COMMIT (Chạy thử nghiệm an toàn)
-- NẾU CHẠY THỦ CÔNG QUA SSMS:
-- ROLLBACK TRANSACTION; -- Hủy nếu kiểm tra chưa ưng ý
COMMIT TRANSACTION; -- Kích hoạt commit khi xác nhận chính xác
