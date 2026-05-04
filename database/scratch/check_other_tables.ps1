$sql = "
DECLARE @pattern VARCHAR(20) = 'VVPQ132R715%'
SELECT 'STB_RawMaterialInputHist' as TableName, COUNT(*) as Cnt FROM STB_RawMaterialInputHist WHERE Barcode LIKE @pattern
UNION ALL
SELECT 'STB_LotChangeMaterialHistory' as TableName, COUNT(*) as Cnt FROM STB_LotChangeMaterialHistory WHERE OldBarcode LIKE @pattern OR NewBarcode LIKE @pattern
UNION ALL
SELECT 'STB_SavePackingTime_VVT' as TableName, COUNT(*) as Cnt FROM STB_SavePackingTime_VVT WHERE LotNo LIKE @pattern
UNION ALL
SELECT 'STB_MaterialLotInfo' as TableName, COUNT(*) as Cnt FROM STB_MaterialLotInfo WHERE LotNo LIKE @pattern OR LotID LIKE @pattern
"
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -Query $sql | Format-Table -AutoSize
