-- ==============================================================================
-- ROLLBACK SCRIPT: B782_MOVE_17LOTS_V24_DATE_18
-- Mục đích: Khôi phục lại JobDate ban đầu cho 17 Lot công đoạn V-24_HY
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- Khôi phục JobDate theo từng nhóm giá trị gốc
UPDATE STB_ProdRouteHist SET JobDate = '2026-09-17' WHERE ControlNo IN ('20260911000617', '20260907000380', '20260907000154', '20260902000178', '20260911000606', '20260902000177', '20260902000165', '20260907000139', '20260907000141', '20260902000168') AND RouteCode = 'V-24_HY';
UPDATE STB_ProdRouteHist SET JobDate = '2026-09-16' WHERE ControlNo IN ('20260911000619', '20260902000417', '20260902000424', '20260904000095') AND RouteCode = 'V-24_HY';
UPDATE STB_ProdRouteHist SET JobDate = '2026-09-15' WHERE ControlNo = '20260910000055' AND RouteCode = 'V-24_HY';
UPDATE STB_ProdRouteHist SET JobDate = '2026-09-12' WHERE ControlNo = '20260910000370' AND RouteCode = 'V-24_HY';
UPDATE STB_ProdRouteHist SET JobDate = '2026-09-10' WHERE ControlNo = '20260831000089' AND RouteCode = 'V-24_HY';

-- Khôi phục STB_DefectRepairInfo
UPDATE STB_DefectRepairInfo SET FindJobdate = '2026-09-17' WHERE ControlNo IN ('20260902000177', '20260902000417', '20260907000139') AND FindRouteCode = 'V-24_HY' AND DefectQty = 6;

COMMIT TRANSACTION;
GO
