-- Find other 2025 lots that might have been incorrectly updated to 2026 marking
SELECT * 
FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE MarkingName LIKE '6%' 
AND Barcode LIKE 'VE25%'
ORDER BY ChangeDateTime DESC;

-- Find lots that have 5H1 marking
SELECT * 
FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE MarkingName = '5H1'
AND Barcode LIKE 'VE25%'
ORDER BY CreateDateTime DESC;
