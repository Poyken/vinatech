-- Check MaterialLotInfo for Marking columns
SELECT TOP 1 * FROM STB_MaterialLotInfo;

-- Check the specific lot in MaterialLotInfo
SELECT LotNo, PackingID, MaterialCode, MarkingCode, MarkingName
FROM STB_MaterialLotInfo 
WHERE LotNo = 'VE251120-002' OR PackingID = 'VE251120-002';

-- Check the Marking Master table
SELECT * FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE MarkingCode IN (SELECT MarkingCode FROM STB_MaterialLotInfo WHERE LotNo = 'VE251120-002')
OR MarkingName = '6D1' OR MarkingName = '5H1';

-- Check SetInfo SIExtText07 as well
SELECT Barcode, SIExtText07 
FROM STB_SetInfo 
WHERE Barcode = 'VE251120-002';
