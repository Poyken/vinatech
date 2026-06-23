-- ================================================
-- XÓA C121_HY và C122_HY (screens cũ)
-- Chạy trên SSMS, đổi ROLLBACK → COMMIT khi OK
-- ================================================
USE SmartFramework;
GO

BEGIN TRAN;

-- 1. Xóa ScreenObjects
DELETE FROM STB_ScreenObjects WHERE ScreenName = 'QcInspectionGroupItem_HY';
DELETE FROM STB_ScreenObjects WHERE ScreenName = 'MaterialInspectionCriteria_HY';
PRINT 'Deleted ScreenObjects: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- 2. Xóa Layout
DELETE FROM STB_ScreenLayoutInfo WHERE Name = 'QcInspectionGroupItem_HY';
DELETE FROM STB_ScreenLayoutInfo WHERE Name = 'MaterialInspectionCriteria_HY';
PRINT 'Deleted Layouts';

-- 3. Xóa Permission
DELETE FROM STB_UserTypeBasicPermission WHERE Name = 'QcInspectionGroupItem_HY';
DELETE FROM STB_UserTypeBasicPermission WHERE Name = 'MaterialInspectionCriteria_HY';
PRINT 'Deleted Permissions';

-- 4. Xóa ScreenInfo
DELETE FROM STB_ScreenInfo WHERE Name = 'QcInspectionGroupItem_HY';
DELETE FROM STB_ScreenInfo WHERE Name = 'MaterialInspectionCriteria_HY';
PRINT 'Deleted ScreenInfo';

-- Verify
SELECT 'REMAINING' as Check_, COUNT(*) as Cnt 
FROM STB_ScreenInfo 
WHERE Name IN ('QcInspectionGroupItem_HY','MaterialInspectionCriteria_HY');

-- Đổi ROLLBACK → COMMIT khi OK
ROLLBACK;
