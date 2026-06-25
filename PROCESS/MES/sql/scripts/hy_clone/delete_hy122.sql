-- Xóa sạch HY122 để tạo lại từ đầu trong Designer
-- Author: vanduc | Date: 2026-06-25
USE SmartFramework;
GO
BEGIN TRAN;

-- Xóa tất cả references
DELETE FROM STB_ScreenObjects              WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial';  -- 0 rows
DELETE FROM STB_ScreenStringResources      WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial';  -- 130 rows
DELETE FROM STB_UserTypeBasicPermission    WHERE Name = 'HYMaterialQcInspectionItemByMaterial';        -- 1 row
DELETE FROM STB_UserTypeViewPermission     WHERE Name = 'HYMaterialQcInspectionItemByMaterial';        -- 1 row
DELETE FROM STB_ScreenLayoutInfo           WHERE Name = 'HYMaterialQcInspectionItemByMaterial';        -- 1 row
DELETE FROM STB_ScreenInfo                 WHERE Name = 'HYMaterialQcInspectionItemByMaterial';        -- 1 row

-- Verify: tất cả phải = 0
SELECT 'ScreenInfo' AS Tbl, COUNT(*) AS Cnt FROM STB_ScreenInfo WITH(NOLOCK) WHERE Name = 'HYMaterialQcInspectionItemByMaterial'
UNION ALL SELECT 'Layout', COUNT(*) FROM STB_ScreenLayoutInfo WITH(NOLOCK) WHERE Name = 'HYMaterialQcInspectionItemByMaterial'
UNION ALL SELECT 'Objects', COUNT(*) FROM STB_ScreenObjects WITH(NOLOCK) WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial'
UNION ALL SELECT 'StringRes', COUNT(*) FROM STB_ScreenStringResources WITH(NOLOCK) WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial'
UNION ALL SELECT 'Permission', COUNT(*) FROM STB_UserTypeBasicPermission WITH(NOLOCK) WHERE Name = 'HYMaterialQcInspectionItemByMaterial'
UNION ALL SELECT 'ViewPerm', COUNT(*) FROM STB_UserTypeViewPermission WITH(NOLOCK) WHERE Name = 'HYMaterialQcInspectionItemByMaterial';

-- ROLLBACK → COMMIT khi OK
ROLLBACK;
-- COMMIT;
