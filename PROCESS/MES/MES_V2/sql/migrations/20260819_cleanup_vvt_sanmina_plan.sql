-- =========================================================================================
-- Clean up unlinked screen VVT_SanminaShipmentPlan from SmartFramework
-- Keep only the official screen SanminaShipmentPlan (B763) created via Designer
-- =========================================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- 1. Remove Screen Objects of VVT_SanminaShipmentPlan
DELETE FROM SmartFramework.dbo.STB_ScreenObjects 
WHERE ScreenName = 'VVT_SanminaShipmentPlan';

-- 2. Remove Screen Info of VVT_SanminaShipmentPlan
DELETE FROM SmartFramework.dbo.STB_ScreenInfo 
WHERE Name = 'VVT_SanminaShipmentPlan';

PRINT 'Cleaned up VVT_SanminaShipmentPlan successfully.';
GO
