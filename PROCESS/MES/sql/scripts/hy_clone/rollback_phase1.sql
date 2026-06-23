-- Rollback: Xóa 7 screen records đã insert nhầm
IF EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY220' AND Name = 'MaterialIqcInfoSampleManagement_HY')
    DELETE FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY220' AND Name = 'MaterialIqcInfoSampleManagement_HY';
IF EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY310' AND Name = 'ProductionOrderInfo_HY')
    DELETE FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY310' AND Name = 'ProductionOrderInfo_HY';
IF EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY442' AND Name = 'ElectrodePlan_HY')
    DELETE FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY442' AND Name = 'ElectrodePlan_HY';
IF EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY470' AND Name = 'ElectrodePrcsCard_HY')
    DELETE FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY470' AND Name = 'ElectrodePrcsCard_HY';
IF EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY552' AND Name = 'ElectrodeMeasureResult_HY')
    DELETE FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY552' AND Name = 'ElectrodeMeasureResult_HY';
IF EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY802' AND Name = 'ElectrodeProdRouteHist_HY')
    DELETE FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY802' AND Name = 'ElectrodeProdRouteHist_HY';
IF EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY460' AND Name = 'ElectrodeInspectionHistoryForBarcode_HY')
    DELETE FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'HY460' AND Name = 'ElectrodeInspectionHistoryForBarcode_HY';

PRINT 'Rollback done: 7 screen records removed.';
