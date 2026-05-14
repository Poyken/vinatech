-- Final check on SetInfo for SIExtText07
SELECT Barcode, SIExtText07 
FROM STB_SetInfo 
WHERE Barcode = 'VE251120-002';

-- Check if there are other entries in STB_CreateMarkingLetterAndQtyForBarcode for this barcode
SELECT * 
FROM STB_CreateMarkingLetterAndQtyForBarcode 
WHERE Barcode = 'VE251120-002';
