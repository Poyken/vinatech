-- Just get columns for STB_MaterialLotInfo
SELECT TOP 1 * FROM STB_MaterialLotInfo;

-- Check if 6D1 or 5H1 exists in STB_CreateMarkingLetterAndQtyForBarcode
SELECT * FROM STB_CreateMarkingLetterAndQtyForBarcode WHERE MarkingName = '6D1' OR MarkingName = '5H1';
