$sql = "
UPDATE STB_SetInfo SET Barcode = REPLACE(Barcode, '7156', '715'), LotNumber = REPLACE(LotNumber, '7156', '715') WHERE Barcode LIKE 'VVPQ132R7156%';
UPDATE STB_RawMaterialInputHist SET Barcode = REPLACE(Barcode, '7156', '715') WHERE Barcode LIKE 'VVPQ132R7156%';
UPDATE STB_SavePackingTime_VVT SET LotNo = REPLACE(LotNo, '7156', '715') WHERE LotNo LIKE 'VVPQ132R7156%';
UPDATE STB_MaterialLotInfo SET LotNo = REPLACE(LotNo, '7156', '715'), LotID = REPLACE(LotID, '7156', '715') WHERE LotNo LIKE 'VVPQ132R7156%' OR LotID LIKE 'VVPQ132R7156%';
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql
