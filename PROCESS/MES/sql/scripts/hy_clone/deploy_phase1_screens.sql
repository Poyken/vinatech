-- ============================================================================
-- DEPLOY Script: Register 7 HY Screens + Clone Layouts + Objects + Permissions
-- Combined all-in-one for deploy_tool.ps1 (runs on SmartFactoryV2 connection)
-- All table references use SmartFramework.dbo.XXX fully qualified names
-- Author: vanduc
-- Date: 2026-06-23
-- ============================================================================

-- ============================================================================
-- PHASE 1: Register 7 screens in STB_ScreenInfo
-- ============================================================================

-- Safety: Skip if already exists
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY220')
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
    VALUES ('MaterialIqcInfoSampleManagement_HY', 'HY220', 0, '', 0, 'QC_HY', N'^HY_IQC_Confirmation^', 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY310')
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
    VALUES ('ProductionOrderInfo_HY', 'HY310', 0, '', 0, 'Production_HY', N'^HY_ProductionOrderInfo^', 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY442')
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
    VALUES ('ElectrodePlan_HY', 'HY442', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodePlan^', 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY470')
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
    VALUES ('ElectrodePrcsCard_HY', 'HY470', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodePrcsCard^', 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY552')
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
    VALUES ('ElectrodeMeasureResult_HY', 'HY552', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodeMeasureResult^', 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY802')
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
    VALUES ('ElectrodeProdRouteHist_HY', 'HY802', 0, '', 0, 'ElectrodeHY', N'^HY_ElectrodeProdRouteHist^', 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY460')
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, IsFolder, IsDialog, IsNeverClose, ParentName, Caption, ShowAfterStart, ShowInMenu, CurrentVersion)
    VALUES ('ElectrodeInspectionHistoryForBarcode_HY', 'HY460', 0, '', 0, 'QC_HY', N'^HY_ElectrodeInspection^', 0, 1, 1);

PRINT 'PHASE 1 DONE: 7 screens registered.';
