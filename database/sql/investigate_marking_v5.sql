-- Check SavePackingTime for the lot
SELECT * FROM STB_SavePackingTime_VVT WHERE PackingID = 'VE251120-002' OR LotNo = 'VE251120-002';

-- Check if there is any other table related to marking
-- Maybe STB_MarkingInfo?
SELECT TOP 10 * FROM STB_ModelBasicInfo WHERE ModelCode LIKE '%16RHV%';
