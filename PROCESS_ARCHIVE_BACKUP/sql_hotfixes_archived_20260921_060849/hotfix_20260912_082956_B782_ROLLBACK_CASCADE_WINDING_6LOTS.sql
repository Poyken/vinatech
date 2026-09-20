-- ==============================================================================
-- HOTFIX SCRIPT: B782_ROLLBACK_CASCADE_WINDING_6LOTS
-- Date: 2026-09-12 08:29:56
-- Target Database: SmartFactoryV2
-- Screen: [B782] / [B530]
-- Barcodes: VVQQ203R072720, VVQQ213R072726, VVQR103R072760, VVQR103R072761, VVQR113R072731, VVQR113R072734
-- ControlNos: 20260820000244, 20260821000637, 20260910000423, 20260910000424, 20260911000196, 20260911000199
-- Reason: Rollback cascade toan bo cac cong doan sau Winding (V-22_HY) ve trang thai chua chot
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [XOA PHE NG] Xoa toan bo ban ghi phe NG cua 6 Lot tren cac cong doan
DELETE FROM STB_DefectRepairInfo
WHERE ControlNo IN ('20260820000244', '20260821000637', '20260910000423', '20260910000424', '20260911000196', '20260911000199');

-- 2. [XOA DOWNSTREAM] Xoa toan bo cac cong doan phat sinh sau Winding (V-23 den V-28)
DELETE FROM STB_ProdRouteHist
WHERE ControlNo IN ('20260820000244', '20260821000637', '20260910000423', '20260910000424', '20260911000196', '20260911000199')
AND RouteCode <> 'V-22_HY';

-- 3. [RESET WINDING] Dua trang thai Winding (V-22_HY) ve chua hoan thanh de OP chot lai tren B530
UPDATE STB_ProdRouteHist
SET CompleteRoute = NULL
WHERE ControlNo IN ('20260820000244', '20260821000637', '20260910000423', '20260910000424', '20260911000196', '20260911000199')
AND RouteCode = 'V-22_HY';

-- 4. [RESET FINISH STATUS] Dua trang thai hoan thanh san pham tren STB_SetInfo ve chua hoan thanh
UPDATE STB_SetInfo
SET IsProdFinish = 0,
    ProdFinishDateTime = NULL,
    ProdFinishJobDate = NULL
WHERE ControlNo IN ('20260820000244', '20260821000637', '20260910000423', '20260910000424', '20260911000196', '20260911000199');

COMMIT TRANSACTION;
GO
