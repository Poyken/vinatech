-- ==============================================================================
-- ROLLBACK SCRIPT: B782_ADD_HOURS_20LOTS_V24_DATE_18
-- Mục đích: Khôi phục lại ProdDateTime ban đầu (-10 giờ) cho công đoạn V-24_HY của 20 Lot
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

UPDATE STB_ProdRouteHist 
SET ProdDateTime = DATEADD(HOUR, -10, ProdDateTime),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN (
    '20260911000619', '20260910000370', '20260911000617', '20260910000055', '20260907000380',
    '20260907000154', '20260902000417', '20260902000178', '20260911000606', '20260902000177',
    '20260902000424', '20260902000165', '20260831000089', '20260907000139', '20260907000141',
    '20260904000095', '20260902000168', '20260915000222', '20260915000225', '20260915000619'
)
  AND RouteCode = 'V-24_HY';

COMMIT TRANSACTION;
GO
