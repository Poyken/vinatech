-- ==============================================================================
-- ROLLBACK SCRIPT: B782_MOVE_6LOTS_DATE_18_TO_17
-- Mục đích: Phục hồi lại ngày ghi nhận sản xuất của 6 Lot trên màn B782 về ngày 18 như ban đầu
-- Barcodes: VVQR173R825701, VVQR173R825702, VVQR173R825703, VVQR173R825704, VVQR173R825705, VVQR173R825706
-- ControlNos: 20260917000445, 20260917000446, 20260917000447, 20260917000448, 20260917000449, 20260917000450
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Rollback ProdDateTime và JobDate cho STB_ProdRouteHist
UPDATE STB_ProdRouteHist 
SET ProdDateTime = DATEADD(DAY, 1, ProdDateTime),
    JobDate = '2026-09-18',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_rollback'
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450')
  AND RouteCode = 'V-22_HY';

-- 2. Rollback CreateDateTime cho STB_DefectRepairInfo
UPDATE STB_DefectRepairInfo 
SET CreateDateTime = DATEADD(DAY, 1, CreateDateTime),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_rollback'
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450')
  AND FindRouteCode = 'V-22_HY';

-- 3. Rollback STB_SetInfo
UPDATE STB_SetInfo 
SET InputDateTime = DATEADD(DAY, 1, InputDateTime),
    InputJobDate = '2026-09-18',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_rollback'
WHERE ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450');

COMMIT TRANSACTION;
GO
