-- Find 2025 lots with 2026 marking (MarkingName starts with 6)
SELECT MarkingCode, MarkingName, Barcode, CreateDateTime, ChangeDateTime, ChangeUserID
FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE MarkingName LIKE '6%' 
AND Barcode LIKE 'VE25%'
ORDER BY ChangeDateTime DESC;
