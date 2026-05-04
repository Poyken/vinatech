$sql = "
BEGIN TRANSACTION;

-- 1. Revert Master Data
UPDATE STB_ModelBasicInfo 
SET MBIExtText05 = '15', 
    ChangeDateTime = GETDATE(), 
    ChangeUserID = 'vanduc_revert' 
WHERE ModelCode = 'ECVT27-404';

-- 2. Revert Barcodes from R7156 back to R715
UPDATE STB_SetInfo 
SET Barcode = REPLACE(Barcode, 'R7156', 'R715'),
    LotNumber = REPLACE(LotNumber, 'R7156', 'R715')
WHERE Barcode LIKE 'VVPQ132R7156%';

UPDATE STB_RawMaterialInputHist 
SET Barcode = REPLACE(Barcode, 'R7156', 'R715')
WHERE Barcode LIKE 'VVPQ132R7156%';

UPDATE STB_SavePackingTime_VVT 
SET LotNo = REPLACE(LotNo, 'R7156', 'R715')
WHERE LotNo LIKE 'VVPQ132R7156%';

UPDATE STB_MaterialLotInfo 
SET LotNo = REPLACE(LotNo, 'R7156', 'R715'),
    LotID = REPLACE(LotID, 'R7156', 'R715')
WHERE LotNo LIKE 'VVPQ132R7156%' OR LotID LIKE 'VVPQ132R7156%';

COMMIT TRANSACTION;
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
