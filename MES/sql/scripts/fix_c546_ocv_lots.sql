-- ==========================================================================================
-- FIX SCRIPT: C546 (FOQC) OCV/ESR lỗi hiển thị cho Lot FVVQK113R825702 và Lot FVVQK283R825705
-- Ngày: 2026-06-04
-- Người tạo: vanduc 2026-06-04 (theo yêu cầu IT Vinatech)
-- ==========================================================================================
-- ⚠️ PHÂN TÍCH LỖI GỐC (ROOT CAUSE) MÀN HÌNH C546:
-- 1. SP get kết quả mẫu [usp_MaterialQcSampleResult_get] bị thiếu pattern 'FOQC_V01_07/08' (Đã sửa).
-- 2. SP get chi tiết màn hình [usp_Vietnam_MaterialFOQcDetail_get] BỊ THIẾU BLOCK KHỞI TẠO của 
--    hạng mục OCV (DetailNo = 2). Trong khi ESR (DetailNo = 3) và các mục khác đều có block khởi tạo 
--    để tạo đủ 50 dòng trống.
--    => Khiến lưới OCV chỉ hiển thị tối đa số dòng đo thực tế từ máy (20 dòng) thay vì 50 dòng trống.
-- ==========================================================================================
-- BƯỚC 1: CẬP NHẬT STORED PROCEDURE [usp_Vietnam_MaterialFOQcDetail_get]
-- -> Vui lòng mở file sql\procedures\usp_Vietnam_MaterialFOQcDetail_get.sql và chạy ALTER để deploy.
-- ==========================================================================================

USE SmartFactoryV2;
GO

-- ==========================================================================================
-- BƯỚC 2: FIX DỮ LIỆU CHO LOT 1 - FVVQK113R825702 (Không hiển thị giá trị OCV nào trên FOQC)
-- ==========================================================================================

-- 2.1. BACKUP / KIỂM TRA TRƯỚC KHI SỬA
-- Xem các sample kết quả OCV của lot này (hiện tại có 0 dòng cho FVVQK113R825702)
SELECT * FROM STB_MaterialQcSampleResult 
WHERE MaterialQcNo = 'FVVQK113R825702' AND MaterialQcDetailNo = 2;

-- Xem trạng thái upload OCV trong monitor (hiện tại có 21 rows UploadOCVToMess = NULL hoặc '')
SELECT ID, lotno, valueocv, UploadOCVToMess 
FROM Stb_ESRValueMonitor 
WHERE lotno = 'VVQK113R825702';

-- 2.2. THỰC THI SỬA ĐỔI LOT 1
-- Bước A: Reset trạng thái OCV trong monitor về NULL để SP có thể chạy lại
BEGIN TRANSACTION;
UPDATE Stb_ESRValueMonitor 
SET UploadOCVToMess = NULL 
WHERE lotno = 'VVQK113R825702';
-- ⚠️ KIỂM TRA: Phải ảnh hưởng đúng 21 dòng (21 rows affected)
-- Nếu ĐÚNG chạy: COMMIT TRANSACTION;
-- Nếu SAI chạy:  ROLLBACK TRANSACTION;

-- Bước B: Reset trạng thái đã Pass trong bảng Detail nếu cần QC đánh giá lại
BEGIN TRANSACTION;
UPDATE STB_MaterialQcDetail
SET DecisionResult = NULL, PassedSampleQty = 0
WHERE MaterialQcNo = 'FVVQK113R825702' AND MaterialQcDetailNo = 2;
-- ⚠️ KIỂM TRA: Phải ảnh hưởng đúng 1 dòng (1 row affected)
-- Nếu ĐÚNG chạy: COMMIT TRANSACTION;
-- Nếu SAI chạy:  ROLLBACK TRANSACTION;


-- ==========================================================================================
-- BƯỚC 3: FIX DỮ LIỆU CHO LOT 2 - FVVQK283R825705 (Chỉ hiển thị 20/50ea do load nhầm PQC barcode)
-- ==========================================================================================

-- 3.1. BACKUP / KIỂM TRA TRƯỚC KHI SỬA
-- Xem sample OCV/ESR hiện tại của lot FOQC (ESR đang bị 54 dòng NULL, OCV bị 0 dòng)
SELECT MaterialQcDetailNo, COUNT(*), MIN(TestValue), MAX(TestValue)
FROM STB_MaterialQcSampleResult 
WHERE MaterialQcNo = 'FVVQK283R825705'
GROUP BY MaterialQcDetailNo;

-- Xem chi tiết 54 dòng ESR bị NULL giá trị
SELECT * FROM STB_MaterialQcSampleResult 
WHERE MaterialQcNo = 'FVVQK283R825705' AND MaterialQcDetailNo = 3;

-- Xem trạng thái upload trong monitor
SELECT ID, lotno, value, valueocv, UploadToMes, UploadOCVToMess 
FROM Stb_ESRValueMonitor 
WHERE lotno = 'VVQK283R825705';

-- 3.2. THỰC THI SỬA ĐỔI LOT 2
-- Bước A: Xóa 54 dòng ESR bị NULL giá trị trong bảng kết quả mẫu
BEGIN TRANSACTION;
DELETE FROM STB_MaterialQcSampleResult 
WHERE MaterialQcNo = 'FVVQK283R825705' AND MaterialQcDetailNo = 3;
-- ⚠️ KIỂM TRA: Phải ảnh hưởng đúng 54 dòng (54 rows affected)
-- Nếu ĐÚNG chạy: COMMIT TRANSACTION;
-- Nếu SAI chạy:  ROLLBACK TRANSACTION;

-- Bước B: Reset trạng thái upload ESR và OCV trong monitor về NULL để SP có thể chạy lại cho FOQC
BEGIN TRANSACTION;
UPDATE Stb_ESRValueMonitor 
SET UploadToMes = NULL, UploadOCVToMess = NULL 
WHERE lotno = 'VVQK283R825705';
-- ⚠️ KIỂM TRA: Phải ảnh hưởng đúng 22 dòng (22 rows affected)
-- Nếu ĐÚNG chạy: COMMIT TRANSACTION;
-- Nếu SAI chạy:  ROLLBACK TRANSACTION;

-- Bước C: Reset trạng thái đánh giá trong bảng Detail để QC load lại từ đầu
BEGIN TRANSACTION;
UPDATE STB_MaterialQcDetail
SET DecisionResult = NULL, PassedSampleQty = 0
WHERE MaterialQcNo = 'FVVQK283R825705' AND MaterialQcDetailNo IN (2, 3);
-- ⚠️ KIỂM TRA: Phải ảnh hưởng đúng 2 dòng (2 rows affected)
-- Nếu ĐÚNG chạy: COMMIT TRANSACTION;
-- Nếu SAI chạy:  ROLLBACK TRANSACTION;


-- ==========================================================================================
-- BƯỚC 4: XÁC NHẬN SAU KHI SỬA
-- ==========================================================================================
-- 1. QC tắt màn hình C546 và mở lại.
-- 2. Nhập barcode cần kiểm tra (Ví dụ: FVVQK113R825702 hoặc FVVQK283R825705).
-- 3. Chọn OCV và ESR. Lúc này, nhờ có SP [usp_Vietnam_MaterialFOQcDetail_get] mới, 
--    hệ thống sẽ tự động tạo đủ 50 dòng kết quả (được điền giá trị đo thực tế và lặp lại cho đủ 50).
-- ==========================================================================================
