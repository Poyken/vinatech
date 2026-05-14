-- Check if 5H1 exists in STB_CreateMarkingLetterAndQtyForBarcode
SELECT * FROM STB_CreateMarkingLetterAndQtyForBarcode WHERE MarkingName = '5H1';

-- Also find the MarkingCode for VE251120-002
SELECT MarkingCode FROM STB_MaterialLotInfo WHERE LotNo = 'VE251120-002' OR PackingID = 'VE251120-002';
