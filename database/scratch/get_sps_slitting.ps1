$sql = "
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_DoSplitLot')) AS ObjDef
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_DoSlittingLot')) AS ObjDef
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_ChotSlittingLot')) AS ObjDef
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Update_POO_Lot_Transfer_WarehouseCode')) AS ObjDef
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_CreateLotSlitting_NG_HN_uid')) AS ObjDef
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_GetSplittingMaterialLotInfo')) AS ObjDef
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_GetSplitedMaterialLotInfo')) AS ObjDef
"

Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vanduc' -Password 'MK vina1234%6&8' -Query $sql | Format-Table -AutoSize
