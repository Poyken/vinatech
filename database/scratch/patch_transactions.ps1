$sql = "
BEGIN TRANSACTION;

-- Pattern for faulty barcodes: VVPQ132R715xx
-- xx is 01 to 16

-- STB_SetInfo
UPDATE STB_SetInfo 
SET Barcode = REPLACE(Barcode, 'R715', 'R7156'),
    LotNumber = REPLACE(LotNumber, 'R715', 'R7156')
WHERE Barcode LIKE 'VVPQ132R715%';

-- STB_RawMaterialInputHist
UPDATE STB_RawMaterialInputHist 
SET Barcode = REPLACE(Barcode, 'R715', 'R7156')
WHERE Barcode LIKE 'VVPQ132R715%';

-- STB_SavePackingTime_VVT
UPDATE STB_SavePackingTime_VVT 
SET LotNo = REPLACE(LotNo, 'R715', 'R7156')
WHERE LotNo LIKE 'VVPQ132R715%';

-- STB_MaterialLotInfo
UPDATE STB_MaterialLotInfo 
SET LotNo = REPLACE(LotNo, 'R715', 'R7156'),
    LotID = REPLACE(LotID, 'R715', 'R7156')
WHERE LotNo LIKE 'VVPQ132R715%' OR LotID LIKE 'VVPQ132R715%';

COMMIT TRANSACTION;
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
