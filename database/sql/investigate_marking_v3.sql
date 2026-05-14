-- Detailed check for the material and lot
SELECT *
FROM STB_ModelBasicInfo 
WHERE ModelCode = '16RHV470MC11XXT001';

-- Check the specific PackingID/Lot
SELECT *
FROM STB_DividePackaging
WHERE PackingID = 'VE251120-002' OR LotNo = 'VE251120-002';

-- Check SetInfo for that LotNo
SELECT *
FROM STB_SetInfo
WHERE Barcode = 'VE251120-002' OR LotNumber = 'VE251120-002' OR ControlNo = 'VE251120-002';
