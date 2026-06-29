-- ==========================================================================================
-- Author:       Antigravity (AI Coding Assistant)
-- Create date:  2026-06-29
-- Description:  Cập nhật ngày xuất kho về 17/01/2026 cho 9 Lot Nhóm A (Hợp lệ)
--               trong bảng STB_MaterialWarehouseInOutHist.
--               Giữ nguyên giờ, phút, giây gốc của các giao dịch.
-- ==========================================================================================

USE SmartFactoryV2;
GO

BEGIN TRAN;

-- 1. Xem dữ liệu trước khi sửa
SELECT 
    MaterialWarehouseInOutHistNo, 
    LotID, 
    WarehouseInOutCode, 
    CreateDateTime AS [Ngay_Xuat_Cu], 
    SourceMaterialWarehouseCode, 
    TargetMaterialWarehouseCode
FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK)
WHERE LotID IN (
    'ML20251227000075', 'ML20251227000076', 'ML20251227000081', 
    'ML20251227000142', 'ML20251227000149', 'ML20251227000150', 
    'ML20251227000151', 'ML20251227000152', 'ML20251227000153'
) AND WarehouseInOutCode = 'O';

-- 2. Thực hiện cập nhật (đưa về ngày 17/01/2026, giữ nguyên giờ phút giây)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2026-01-17' AS DATETIME) + CAST(CreateDateTime AS TIME),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin_fix'
WHERE LotID IN (
    'ML20251227000075', 'ML20251227000076', 'ML20251227000081', 
    'ML20251227000142', 'ML20251227000149', 'ML20251227000150', 
    'ML20251227000151', 'ML20251227000152', 'ML20251227000153'
) AND WarehouseInOutCode = 'O';

-- 3. Xem dữ liệu sau khi sửa để đối chiếu
SELECT 
    MaterialWarehouseInOutHistNo, 
    LotID, 
    WarehouseInOutCode, 
    CreateDateTime AS [Ngay_Xuat_Moi], 
    SourceMaterialWarehouseCode, 
    TargetMaterialWarehouseCode
FROM STB_MaterialWarehouseInOutHist WITH(NOLOCK)
WHERE LotID IN (
    'ML20251227000075', 'ML20251227000076', 'ML20251227000081', 
    'ML20251227000142', 'ML20251227000149', 'ML20251227000150', 
    'ML20251227000151', 'ML20251227000152', 'ML20251227000153'
) AND WarehouseInOutCode = 'O';

-- NẾU DỮ LIỆU ĐÚNG:
-- COMMIT TRAN;

-- NẾU DỮ LIỆU SAI:
-- ROLLBACK TRAN;
GO
