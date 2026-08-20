-- =========================================================================================
-- Reset PlanID 6 to 0 printed boxes and ACTIVE status
-- =========================================================================================

UPDATE STB_SanminaShipmentPlan
SET PrintedBoxCount = 0,
    Status = 'ACTIVE',
    IsActive = 1
WHERE PlanID = 6;

PRINT 'Reset PlanID 6 successfully.';
GO
