-- ==============================================================================
-- ROLLBACK SCRIPT: B782_MOVE_4LOTS_DATE_17_TO_18
-- Mục đích: Khôi phục lại trạng thái ban đầu của 4 lot trên B782 (về lại rạng sáng ngày 18, tính vào ngày 17)
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Khôi phục STB_ProdRouteHist
UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 05:57:57.567', JobDate = '2026-09-15'
WHERE ControlNo = '20260915000223' AND RouteCode = 'V-23_HY';

UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 05:57:57.270', JobDate = '2026-09-18'
WHERE ControlNo = '20260915000223' AND RouteCode = 'V-24_HY';

UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 01:05:34.597', JobDate = '2026-09-15'
WHERE ControlNo = '20260915000224' AND RouteCode = 'V-23_HY';

UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 01:05:33.727', JobDate = '2026-09-18'
WHERE ControlNo = '20260915000224' AND RouteCode = 'V-24_HY';

UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 01:05:45.400', JobDate = '2026-09-15'
WHERE ControlNo = '20260915000618' AND RouteCode = 'V-23_HY';

UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 01:05:43.763', JobDate = '2026-09-18'
WHERE ControlNo = '20260915000618' AND RouteCode = 'V-24_HY';

UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 05:58:35.393', JobDate = '2026-09-15'
WHERE ControlNo = '20260915000620' AND RouteCode = 'V-23_HY';

UPDATE STB_ProdRouteHist 
SET ProdDateTime = '2026-09-18 05:58:35.137', JobDate = '2026-09-18'
WHERE ControlNo = '20260915000620' AND RouteCode = 'V-24_HY';

-- 2. Khôi phục STB_DefectRepairInfo
UPDATE STB_DefectRepairInfo 
SET CreateDateTime = '2026-09-18 05:57:52'
WHERE ControlNo = '20260915000223' AND FindRouteCode = 'V-23_HY';

UPDATE STB_DefectRepairInfo 
SET CreateDateTime = '2026-09-18 05:58:30'
WHERE ControlNo = '20260915000620' AND FindRouteCode = 'V-23_HY';

COMMIT TRANSACTION;
GO
