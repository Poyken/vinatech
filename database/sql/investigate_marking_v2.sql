-- Detailed check for the material and lot
SELECT 
    ModelCode, 
    ModelName, 
    MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05,
    AssembleLabel, PartLabel
FROM STB_ModelBasicInfo 
WHERE ModelCode = '16RHV470MC11XXT001';

-- Check the specific PackingID/Lot
SELECT 
    PackingID, ParentPackingID, LotNo, Qty, CreateDateTime, CreateUserID
FROM STB_DividePackaging
WHERE PackingID = 'VE251120-002' OR LotNo = 'VE251120-002';

-- Check SetInfo for that LotNo
SELECT 
    Barcode, ControlNo, MaterialCode, LotNumber, SIExtText01, SIExtText02, SIExtText03
FROM STB_SetInfo
WHERE Barcode = 'VE251120-002' OR LotNumber = 'VE251120-002' OR ControlNo = 'VE251120-002';

-- Check if there is any other lot with marking 5H1
SELECT TOP 10 
    Barcode, ControlNo, MaterialCode, LotNumber, SIExtText01, SIExtText02, SIExtText03
FROM STB_SetInfo
WHERE SIExtText01 = '5H1' OR SIExtText02 = '5H1' OR SIExtText03 = '5H1';
