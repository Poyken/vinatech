-- ============================================================================
-- Script 01: Register 7 New HY Screens in SmartFramework.dbo.STB_ScreenInfo
-- Target DB: SmartFramework
-- Author: vanduc
-- Date: 2026-06-23
-- 
-- INSTRUCTIONS:
--   1. Chạy script này trên SSMS, kết nối đến SmartFramework DB
--   2. Script mặc định ROLLBACK → xem preview kết quả
--   3. Khi confirm OK → đổi ROLLBACK thành COMMIT
--   4. SAU KHI COMMIT → phải chạy tiếp script 02 (clone layouts) NGAY LẬP TỨC
--      để tránh lỗi "Menu initialization failed"
-- ============================================================================

USE SmartFramework;
GO

BEGIN TRAN;

-- ============================================================================
-- 7 Screens mới cho Hưng Yên (VVT_F5)
-- C121/C122 đã có sẵn (C121_HY, C122_HY) → bỏ qua
-- ============================================================================

-- 1. HY220 — IQC Confirmation (clone C220)
INSERT INTO dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
VALUES ('MaterialIqcInfoSampleManagement_HY', 'HY220', 0, '', 0, 'QC_HY', N'^HY_IQC_Confirmation^', 0, 1, 1);

-- 2. HY310 — Create PO (clone B310)
INSERT INTO dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
VALUES ('ProductionOrderInfo_HY', 'HY310', 0, '', 0, 'Production_HY', N'^HY_ProductionOrderInfo^', 0, 1, 1);

-- 3. HY442 — Daily Plan Electrode (clone B442)
INSERT INTO dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
VALUES ('ElectrodePlan_HY', 'HY442', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodePlan^', 0, 1, 1);

-- 4. HY470 — Electrode Process Steps (clone B470)
INSERT INTO dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
VALUES ('ElectrodePrcsCard_HY', 'HY470', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodePrcsCard^', 0, 1, 1);

-- 5. HY552 — Electrode Measure Result (clone B552)
INSERT INTO dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
VALUES ('ElectrodeMeasureResult_HY', 'HY552', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodeMeasureResult^', 0, 1, 1);

-- 6. HY802 — Electrode Report (clone B802)
INSERT INTO dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
VALUES ('ElectrodeProdRouteHist_HY', 'HY802', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodeProdRouteHist^', 0, 1, 1);

-- 7. HY460 — Electrode QC Inspection (clone C460)
INSERT INTO dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
VALUES ('ElectrodeInspectionHistoryForBarcode_HY', 'HY460', 0, '', 0, 'QC_HY', N'^HY_ElectrodeInspection^', 0, 1, 1);

-- ============================================================================
-- Verify
-- ============================================================================
SELECT TCode, Name, ParentName, Caption, ShowInMenu
FROM dbo.STB_ScreenInfo 
WHERE TCode IN ('HY220','HY310','HY442','HY470','HY552','HY802','HY460')
ORDER BY TCode;

PRINT '=== 7 screens registered. Review above, then change ROLLBACK to COMMIT ===';

ROLLBACK; -- ← Đổi thành COMMIT khi đã xác nhận OK
-- COMMIT;
GO
