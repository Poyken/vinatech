-- ==============================================================================
-- HOTFIX SCRIPT: B782_ROLLBACK_WINDING_20260911
-- Mục đích: Rollback công đoạn Winding (V-22_HY) do OP chốt nhầm sản lượng
-- Chuẩn IT Vinatech: HOTFIX_LOG.md ID_22 & ID_23
-- 1) Xóa bản ghi phế NG trong STB_DefectRepairInfo (FindRouteCode = 'V-22_HY')
-- 2) Xóa công đoạn downstream tự sinh trong STB_ProdRouteHist (RouteCode = 'V-23_HY')
-- 3) Reset CompleteRoute = NULL trên STB_ProdRouteHist cho công đoạn Winding ('V-22_HY')
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Xóa bản ghi lỗi phế của công đoạn Winding
DELETE FROM STB_DefectRepairInfo 
WHERE ControlNo IN ('20260910000423', '20260910000424') 
  AND FindRouteCode = 'V-22_HY';

-- 2. Xóa công đoạn downstream (V-23_HY) tự sinh trong STB_ProdRouteHist
DELETE FROM STB_ProdRouteHist 
WHERE ControlNo IN ('20260910000423', '20260910000424') 
  AND RouteCode = 'V-23_HY';

-- 3. Reset CompleteRoute = NULL ở công đoạn Winding (V-22_HY) để công nhân chốt lại
UPDATE STB_ProdRouteHist 
SET CompleteRoute = NULL 
WHERE ControlNo IN ('20260910000423', '20260910000424') 
  AND RouteCode = 'V-22_HY';

-- Kiểm tra lại sau xử lý:
SELECT ControlNo, RouteCode, ProdQty, CompleteRoute 
FROM STB_ProdRouteHist WITH(NOLOCK) 
WHERE ControlNo IN ('20260910000423', '20260910000424');

SELECT ControlNo, DefectCode, FindRouteCode, DefectQty 
FROM STB_DefectRepairInfo WITH(NOLOCK) 
WHERE ControlNo IN ('20260910000423', '20260910000424');

COMMIT TRANSACTION;
GO
