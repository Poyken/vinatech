-- =============================================
-- Patch: Fix shelf life for WRHI00-007 from 48 → 36 months (3 years)
-- Author: ducnv
-- Date: 2026-06-23
-- Requested by: Mrs.Van (warehouse)
-- =============================================
BEGIN TRAN

-- 1. Check current value
SELECT MaterialCode, MMExtInt01 AS OldShelfLife
FROM STB_MaterialMaster
WHERE MaterialCode = 'WRHI00-007'

-- 2. Update MMExtInt01 from 48 to 36
UPDATE STB_MaterialMaster
SET MMExtInt01 = 36
WHERE MaterialCode = 'WRHI00-007'
  AND MMExtInt01 = 48

-- 3. Verify
SELECT MaterialCode, MMExtInt01 AS NewShelfLife
FROM STB_MaterialMaster
WHERE MaterialCode = 'WRHI00-007'

-- Change ROLLBACK to COMMIT when confirmed
ROLLBACK
