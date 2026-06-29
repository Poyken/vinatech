/*
=============================================================
  C585 - Xóa mã phân loại lỗi 05, 06 (trùng với 03, 07)
  
  Vấn đề: 
    - Mã 05 (제품검사(베트남)_kiểm tra sản phẩm VN) trùng mã 03 (제품검사_kiểm tra sản phẩm)
    - Mã 06 (출하검사(베트남)_kiểm tra xuất hàng VN) trùng mã 07 (FOQC)
  
  Thực hiện:
    Bước 1: Cập nhật 5 bản ghi giao dịch: 05 → 03, 06 → 07
    Bước 2: Xóa mã 05, 06 khỏi dropdown (STB_BaseCode)
  
  Ngày: 2026-06-19
  Chạy trên: SSMS → SmartFactoryV2
  ĐỔI ROLLBACK → COMMIT KHI ĐÃ KIỂM TRA OK
=============================================================
*/

-- ===================== BƯỚC 1: Cập nhật bản ghi giao dịch =====================
BEGIN TRAN

-- Kiểm tra TRƯỚC khi sửa
SELECT 'BEFORE UPDATE' AS [Step], DefectDivisionCode, Barcode, DefectCode, DefectQty
FROM STB_QCDefectDetailsRecord WITH(NOLOCK)
WHERE DefectDivisionCode IN ('05','06')

-- Cập nhật mã 05 → 03 (제품검사_kiểm tra sản phẩm)
UPDATE STB_QCDefectDetailsRecord
SET DefectDivisionCode = '03'
WHERE DefectDivisionCode = '05'
-- Dự kiến: 4 rows affected

-- Cập nhật mã 06 → 07 (FOQC)
UPDATE STB_QCDefectDetailsRecord
SET DefectDivisionCode = '07'
WHERE DefectDivisionCode = '06'
-- Dự kiến: 1 row affected

-- Kiểm tra SAU khi sửa (phải trả về 0 rows)
SELECT 'AFTER UPDATE - SHOULD BE EMPTY' AS [Step], DefectDivisionCode, Barcode
FROM STB_QCDefectDetailsRecord WITH(NOLOCK)
WHERE DefectDivisionCode IN ('05','06')

ROLLBACK  -- ĐỔI THÀNH COMMIT SAU KHI KIỂM TRA OK
GO

-- ===================== BƯỚC 2: Xóa mã 05, 06 khỏi dropdown =====================
BEGIN TRAN

-- Kiểm tra trước khi xóa
SELECT 'BEFORE DELETE' AS [Step], *
FROM SmartFramework.dbo.STB_BaseCode WITH(NOLOCK)
WHERE CodeGroup = 'DefectDivisionCode' AND ItemCode IN ('05','06')

-- Xóa mã 05 và 06
DELETE FROM SmartFramework.dbo.STB_BaseCode
WHERE CodeGroup = 'DefectDivisionCode' AND ItemCode IN ('05','06')
-- Dự kiến: 2 rows affected

-- Kiểm tra sau khi xóa (phải trả về 0 rows cho 05, 06)
SELECT 'AFTER DELETE' AS [Step], *
FROM SmartFramework.dbo.STB_BaseCode WITH(NOLOCK)
WHERE CodeGroup = 'DefectDivisionCode'
ORDER BY ItemCode

ROLLBACK  -- ĐỔI THÀNH COMMIT SAU KHI KIỂM TRA OK
