-- =========================================================================================
-- Simplify STB_SanminaShipmentPlan: Add LotNo and IsActive
-- =========================================================================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'STB_SanminaShipmentPlan' AND COLUMN_NAME = 'LotNo')
BEGIN
    ALTER TABLE STB_SanminaShipmentPlan ADD [LotNo] VARCHAR(50) NULL;
    PRINT 'Added LotNo column to STB_SanminaShipmentPlan.';
END

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'STB_SanminaShipmentPlan' AND COLUMN_NAME = 'IsActive')
BEGIN
    ALTER TABLE STB_SanminaShipmentPlan ADD [IsActive] BIT NOT NULL CONSTRAINT DF_STB_SanminaShipmentPlan_IsActive DEFAULT (1);
    PRINT 'Added IsActive column to STB_SanminaShipmentPlan.';
END
GO
