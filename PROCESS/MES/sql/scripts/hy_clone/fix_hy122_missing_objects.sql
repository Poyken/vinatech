-- =============================================
-- Fix: HY122 thiếu 6 objects so với C122 gốc
-- Author: vanduc
-- Date: 2026-06-25
-- Mô tả: Clone 6 objects còn thiếu từ C122 (MaterialQcInspectionItemByMaterial)
--         sang HY122 (HYMaterialQcInspectionItemByMaterial)
-- Objects thiếu: 5 Action + 1 View (MaterialInformation)
-- =============================================

USE SmartFramework;
GO

BEGIN TRAN;

-- Kiểm tra HY122 screen tồn tại
IF NOT EXISTS (
    SELECT 1 FROM STB_ScreenInfo WITH(NOLOCK) 
    WHERE Name = 'HYMaterialQcInspectionItemByMaterial'
)
BEGIN
    RAISERROR('Screen HYMaterialQcInspectionItemByMaterial không tồn tại! Dừng lại.', 16, 1);
    ROLLBACK;
    RETURN;
END

-- Kiểm tra objects hiện có của HY122
SELECT 'BEFORE - HY122 objects:' AS Info;
SELECT ObjectName, ObjectType 
FROM STB_ScreenObjects WITH(NOLOCK) 
WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial' 
ORDER BY ObjectType, ObjectName;

-- Clone 6 objects thiếu từ C122 gốc
-- Chỉ INSERT những object chưa có trong HY122
INSERT INTO STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
SELECT 
    'HYMaterialQcInspectionItemByMaterial' AS ScreenName,
    ObjectType,
    ObjectName,
    Caption,
    Description
FROM STB_ScreenObjects WITH(NOLOCK)
WHERE ScreenName = 'MaterialQcInspectionItemByMaterial'
  AND ObjectName IN (
      'ImportFromInspectionItem',        -- Action: Select From Group/Item Inspection
      'ImportFromMaterialInspectionItem', -- Action: Select from other items
      'SetAql',                           -- Action: AQL Settings
      'SetInspectionType',                -- Action: Set the inspection type
      'SetLevel',                         -- Action: Set the inspection level
      'MaterialInformation'               -- View: Material Information (grid trên)
  )
  AND ObjectName NOT IN (
      SELECT ObjectName FROM STB_ScreenObjects WITH(NOLOCK) 
      WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial'
  );

-- Verify kết quả
SELECT 'AFTER - HY122 objects:' AS Info;
SELECT ObjectName, ObjectType 
FROM STB_ScreenObjects WITH(NOLOCK) 
WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial' 
ORDER BY ObjectType, ObjectName;

-- Đếm: phải có 9 objects (giống C122 gốc)
SELECT COUNT(*) AS TotalObjects,
       CASE WHEN COUNT(*) = 9 THEN 'OK - Đủ 9 objects' 
            ELSE 'WARNING - Không đủ 9 objects!' END AS Status
FROM STB_ScreenObjects WITH(NOLOCK) 
WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial';

-- Mặc định ROLLBACK — đổi thành COMMIT khi OK
ROLLBACK;
-- COMMIT;
