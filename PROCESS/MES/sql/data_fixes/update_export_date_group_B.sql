-- ==========================================================================================
-- Author:       Antigravity (AI Coding Assistant)
-- Create date:  2026-06-29
-- Description:  Cập nhật ngày xuất kho về 17/01/2026 cho 7 Lot Nhóm B (Lưu ý mâu thuẫn logic)
--               trong bảng STB_MaterialWarehouseInOutHist.
--               Giữ nguyên giờ, phút, giây gốc của các giao dịch.
-- LƯU Ý: Ngày nhập kho của các Lot này là 29/01/2026 hoặc được tạo ngày 29/06/2026.
--        Việc đưa về ngày 17/01/2026 sẽ gây ra tình trạng xuất kho trước khi nhập kho.
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
    'ML20260130000087', 'ML20260130000088', 'ML20260130000103', 
    'ML20260130000104', 'ML20260130000348', 'SP20260629029132', 
    'SP20260629029133'
) AND WarehouseInOutCode = 'O';

-- 2. Thực hiện cập nhật (đưa về ngày 17/01/2026, giữ nguyên giờ phút giây)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2026-01-17' AS DATETIME) + CAST(CreateDateTime AS TIME),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vinaadmin_fix'
WHERE LotID IN (
    'ML20260130000087', 'ML20260130000088', 'ML20260130000103', 
    'ML20260130000104', 'ML20260130000348', 'SP20260629029132', 
    'SP20260629029133'
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
    'ML20260130000087', 'ML20260130000088', 'ML20260130000103', 
    'ML20260130000104', 'ML20260130000348', 'SP20260629029132', 
    'SP20260629029133'
) AND WarehouseInOutCode = 'O';

-- NẾU DỮ LIỆU ĐÚNG:
-- COMMIT TRAN;

-- NẾU DỮ LIỆU SAI:
-- ROLLBACK TRAN;
GO
