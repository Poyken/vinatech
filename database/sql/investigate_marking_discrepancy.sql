-- Query SmartFactoryV2 for Model Basic Info
SELECT ModelCode, ModelName, MarkingCode, MarkingName, Vol, Farad, SizeH, SizeW
FROM STB_ModelBasicInfo 
WHERE ModelCode = '16RHV470MC11XXT001';

-- Query SmartFramework for Label Info
-- Note: I need to use the full name if it's a different database
SELECT * 
FROM SmartFramework.dbo.STB_LabelInfo 
WHERE LabelName LIKE '%16RHV470MC11XXT001%'
OR LabelID IN (SELECT LabelID FROM SmartFactoryV2.dbo.STB_ModelBasicInfo WHERE ModelCode = '16RHV470MC11XXT001');

-- Check the Lot/Packing info
SELECT PackingID, ParentPackingID, LotNo, PackQty, CreateUserID, CreateDateTime
FROM STB_DividePackaging
WHERE PackingID = 'VE251120-002' OR LotNo = 'VE251120-002';

-- Check SetInfo for Marking info if any
SELECT Barcode, ControlNo, MaterialCode, LotNo, MarkingCode, MarkingName
FROM STB_SetInfo
WHERE Barcode = 'VE251120-002' OR ControlNo = 'VE251120-002';
