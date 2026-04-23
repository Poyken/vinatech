-- 1. Update Shelf Life in Material Master to 100 years (1200 months)
UPDATE STB_MaterialMaster 
SET MMExtInt01 = 1200 
WHERE MaterialCode = 'TRAY1320-B015';

-- 2. Check the result
SELECT MaterialCode, MaterialName, MMExtInt01 AS ShelfLifeMonths 
FROM STB_MaterialMaster 
WHERE MaterialCode = 'TRAY1320-B015';
