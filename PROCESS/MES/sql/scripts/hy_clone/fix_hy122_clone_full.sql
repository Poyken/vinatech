-- =============================================
-- Fix HY122: Clone layout + objects từ C122 gốc
-- Author: vanduc  |  Date: 2026-06-25
-- KHÔNG ĐỘNG VÀO C122 GỐC
-- =============================================
USE SmartFramework;
GO
BEGIN TRAN;

-- 1) Xóa layout + objects cũ của HY122
DELETE FROM STB_ScreenLayoutInfo WHERE Name = 'HYMaterialQcInspectionItemByMaterial';
DELETE FROM STB_ScreenObjects WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial';

-- 2) Clone layout từ C122 + replace 2 SP names
INSERT INTO STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout)
SELECT 
    'HYMaterialQcInspectionItemByMaterial',
    Version, DeveloperVersion,
    CAST(REPLACE(REPLACE(CAST(Layout AS VARCHAR(MAX)),
        'usp_MaterialQcInspectionItem_ByMaterial_get',
        'usp_MaterialQcInspectionItem_ByMaterial_HY_get'),
        'usp_MaterialQcInspectionItem_iud',
        'usp_MaterialQcInspectionItem_HY_iud'
    ) AS VARBINARY(MAX)),
    XmlLayout
FROM STB_ScreenLayoutInfo WITH(NOLOCK)
WHERE Name = 'MaterialQcInspectionItemByMaterial';

-- 3) Clone 9 objects từ C122 (replace 3 tên _HY)
INSERT INTO STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
SELECT 
    'HYMaterialQcInspectionItemByMaterial',
    ObjectType,
    CASE ObjectName
        WHEN 'usp_MaterialQcInspectionItem_ByMaterial_get' THEN 'usp_MaterialQcInspectionItem_ByMaterial_HY_get'
        WHEN 'usp_MaterialQcInspectionItem_iud'            THEN 'usp_MaterialQcInspectionItem_HY_iud'
        WHEN 'MaterialQcInspectionItem_ByMaterial'         THEN 'MaterialQcInspectionItem_ByMaterial_HY'
        ELSE ObjectName
    END,
    Caption, Description
FROM STB_ScreenObjects WITH(NOLOCK)
WHERE ScreenName = 'MaterialQcInspectionItemByMaterial';

-- 4) Verify
SELECT 'Objects:' AS Info, COUNT(*) AS Cnt FROM STB_ScreenObjects WITH(NOLOCK) WHERE ScreenName = 'HYMaterialQcInspectionItemByMaterial';
SELECT 'Layout:' AS Info, LEN(CAST(Layout AS VARCHAR(MAX))) AS Len FROM STB_ScreenLayoutInfo WITH(NOLOCK) WHERE Name = 'HYMaterialQcInspectionItemByMaterial';
-- Mong đợi: 9 objects, ~664K layout

-- !! ĐỔI THÀNH COMMIT KHI OK !!
ROLLBACK;
-- COMMIT;
