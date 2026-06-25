-- ============================================================================
-- Script 04: Grant Permissions for 7 HY Screens
-- Target DB: SmartFramework
-- Author: vanduc
-- Date: 2026-06-23
--
-- PHẢI chạy SAU script 01 + 02 + 03
-- Cấp quyền Admin cho 7 screens mới (giống pattern existing HY screens)
--
-- ⚠️ Script mặc định ROLLBACK → xem preview → đổi COMMIT
-- ============================================================================

USE SmartFramework;
GO

BEGIN TRAN;

-- ============================================================================
-- Grant Admin permissions (AllowView, AllowAdd, AllowModify, AllowDelete = True)
-- Pattern: Giống các HY screens đã có (QCInspectionGroupCode_HY, PO_Electrode_HY, etc.)
-- ============================================================================

DECLARE @screens TABLE (Name VARCHAR(100));
INSERT INTO @screens VALUES 
    ('MaterialIqcInfoSampleManagement_HY'),      -- HY220
    ('ProductionOrderInfo_HY'),                   -- HY310
    ('ElectrodePlan_HY'),                         -- HY442
    ('ElectrodePrcsCard_HY'),                     -- HY470
    ('ElectrodeMeasureResult_HY'),                -- HY552
    ('ElectrodeProdRouteHist_HY'),                -- HY802
    ('ElectrodeInspectionHistoryForBarcode_HY');  -- HY460

-- Insert Admin permissions for each screen
INSERT INTO dbo.STB_UserTypeBasicPermission (UserType, Name, AllowView, AllowAdd, AllowModify, AllowDelete)
SELECT 
    'Admin' AS UserType,
    s.Name,
    1 AS AllowView,
    1 AS AllowAdd,
    1 AS AllowModify,
    1 AS AllowDelete
FROM @screens s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.STB_UserTypeBasicPermission p 
    WHERE p.UserType = 'Admin' AND p.Name = s.Name
);

PRINT 'Admin permissions granted for ' + CAST(@@ROWCOUNT AS VARCHAR) + ' screens.';

-- ============================================================================
-- Verify
-- ============================================================================
SELECT UserType, Name, AllowView, AllowAdd, AllowModify, AllowDelete
FROM dbo.STB_UserTypeBasicPermission
WHERE Name IN (SELECT Name FROM @screens)
ORDER BY UserType, Name;

-- ============================================================================
-- OPTIONAL: Cấp quyền cho các user types khác (uncomment nếu cần)
-- ============================================================================
/*
-- Ví dụ: Cấp quyền cho ESProdManagement (Electrode SP Production)
INSERT INTO dbo.STB_UserTypeBasicPermission (UserType, Name, AllowView, AllowAdd, AllowModify, AllowDelete)
SELECT 
    'ESProdManagement' AS UserType,
    s.Name,
    1, 1, 1, 0  -- View/Add/Modify nhưng không Delete
FROM @screens s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.STB_UserTypeBasicPermission p 
    WHERE p.UserType = 'ESProdManagement' AND p.Name = s.Name
);
*/

PRINT '=== Permissions granted. Review above, then change ROLLBACK to COMMIT ===';

ROLLBACK; -- ← Đổi thành COMMIT khi đã xác nhận OK
-- COMMIT;
GO
