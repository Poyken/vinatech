-- ==========================================================================================
-- Author:       Antigravity (AI Coding Assistant)
-- Create date:  2026-06-29
-- Description: Check và cập nhật ngày xuất kho cho Lot ML20260416001525 trong bảng STB_MaterialWarehouseInOutHist.
--               Kịch bản cung cấp các tùy chọn cập nhật ngày khác nhau dưới dạng Transaction an toàn.
--               Thủ kho/DBA vui lòng chọn một phương án ngày thích hợp dưới đây để thực thi.
-- ==========================================================================================

-- PHẦN CHUNG: XEM DỮ LIỆU HIỆN TẠI TRƯỚC KHI THỰC HIỆN
SELECT 
    MaterialWarehouseInOutHistNo, 
    LotID, 
    WarehouseInOutCode, 
    CreateDateTime AS [Ngay_Xuat_Hien_Tai], 
    CreateUserID,
    SourceMaterialWarehouseCode,
    TargetMaterialWarehouseCode
FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK)
WHERE LotID = 'ML20260416001525' AND WarehouseInOutCode = 'O';

GO

-- ==========================================================================================
-- PHƯƠNG ÁN 1: Chuyển ngày xuất về 18/05/2026 (KHUYÊN DÙNG - Trùng ngày tạo Lot & ngày SX)
-- ==========================================================================================
/*
BEGIN TRAN;

-- 1. Thực hiện cập nhật (chuyển ngày về 18/05/2026, giữ nguyên giờ phút giây của bản ghi gốc)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2026-05-18' AS DATETIME) + CAST(CreateDateTime AS TIME),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin_fix'
WHERE LotID = 'ML20260416001525' AND WarehouseInOutCode = 'O';

-- 2. Đối chiếu dữ liệu sau khi cập nhật
SELECT 
    MaterialWarehouseInOutHistNo, 
    LotID, 
    CreateDateTime AS [Ngay_Xuat_Sau_Sua], 
    ChangeDateTime,
    ChangeUserID
FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK)
WHERE LotID = 'ML20260416001525' AND WarehouseInOutCode = 'O';

-- NẾU DỮ LIỆU ĐÚNG:
-- COMMIT TRAN;

-- NẾU DỮ LIỆU SAI HOẶC CÓ LỖI:
-- ROLLBACK TRAN;
*/

GO

-- ==========================================================================================
-- PHƯƠNG ÁN 2: Chuyển ngày xuất về 18/06/2026 (Tháng 6)
-- ==========================================================================================
/*
BEGIN TRAN;

-- 1. Thực hiện cập nhật (chuyển ngày về 18/06/2026, giữ nguyên giờ phút giây của bản ghi gốc)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2026-06-18' AS DATETIME) + CAST(CreateDateTime AS TIME),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin_fix'
WHERE LotID = 'ML20260416001525' AND WarehouseInOutCode = 'O';

-- 2. Đối chiếu dữ liệu sau khi cập nhật
SELECT 
    MaterialWarehouseInOutHistNo, 
    LotID, 
    CreateDateTime AS [Ngay_Xuat_Sau_Sua], 
    ChangeDateTime,
    ChangeUserID
FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK)
WHERE LotID = 'ML20260416001525' AND WarehouseInOutCode = 'O';

-- NẾU DỮ LIỆU ĐÚNG:
-- COMMIT TRAN;

-- NẾU DỮ LIỆU SAI HOẶC CÓ LỖI:
-- ROLLBACK TRAN;
*/

GO

-- ==========================================================================================
-- PHƯƠNG ÁN 3: Chuyển ngày xuất về 18/03/2026 (Theo yêu cầu gốc của người dùng - Lưu ý mâu thuẫn)
-- LƯU Ý: Ngày này đi trước ngày nhập kho thực tế (15/04/2026) của Lot, có thể gây sai lệch số liệu kho.
-- ==========================================================================================
/*
BEGIN TRAN;

-- 1. Thực hiện cập nhật (chuyển ngày về 18/03/2026, giữ nguyên giờ phút giây của bản ghi gốc)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2026-03-18' AS DATETIME) + CAST(CreateDateTime AS TIME),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin_fix'
WHERE LotID = 'ML20260416001525' AND WarehouseInOutCode = 'O';

-- 2. Đối chiếu dữ liệu sau khi cập nhật
SELECT 
    MaterialWarehouseInOutHistNo, 
    LotID, 
    CreateDateTime AS [Ngay_Xuat_Sau_Sua], 
    ChangeDateTime,
    ChangeUserID
FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK)
WHERE LotID = 'ML20260416001525' AND WarehouseInOutCode = 'O';

-- NẾU DỮ LIỆU ĐÚNG:
-- COMMIT TRAN;

-- NẾU DỮ LIỆU SAI HOẶC CÓ LỖI:
-- ROLLBACK TRAN;
*/
