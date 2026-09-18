-- ==============================================================================
-- ROLLBACK SCRIPT: B782_MOVE_3LOTS_V24_DATE_18
-- Mục đích: Khôi phục JobDate ban đầu (2026-09-17) cho 3 Lot công đoạn V-24_HY
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

UPDATE STB_ProdRouteHist 
SET JobDate = '2026-09-17',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ('20260915000222', '20260915000225', '20260915000619')
  AND RouteCode = 'V-24_HY';

COMMIT TRANSACTION;
GO
