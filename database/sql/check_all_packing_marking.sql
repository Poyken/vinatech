-- Check MarkingCode for all PackingIDs of the lot
SELECT PackingID, LotNo, MarkingCode 
FROM STB_MaterialLotInfo 
WHERE LotNo = 'VE251120-002';
