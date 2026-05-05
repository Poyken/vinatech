$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
try {
    $conn.Open()
    Write-Host "Connected OK"
} catch {
    Write-Host "Connection failed: $($_.Exception.Message)"
    exit 1
}

function Run-Query($sql, $label) {
    Write-Host "`n=== $label ==="
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 15
    try {
        $rdr = $cmd.ExecuteReader()
        $cols = @()
        for ($i=0; $i -lt $rdr.FieldCount; $i++) { $cols += $rdr.GetName($i) }
        Write-Host ($cols -join ' | ')
        Write-Host ('---')
        $rowCount = 0
        while ($rdr.Read()) {
            $vals = @()
            for ($i=0; $i -lt $rdr.FieldCount; $i++) { $vals += $rdr[$i].ToString() }
            Write-Host ($vals -join ' | ')
            $rowCount++
        }
        if ($rowCount -eq 0) { Write-Host "(no rows)" }
        $rdr.Close()
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)"
    }
}

# 1. Tables
Run-Query @"
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME IN (
  'STB_BomHeader','STB_BomDetail','STB_RouteInfo','STB_MaterialMaster','STB_LineInfo',
  'STB_DayProdPlan','STB_ProductionOrderInfo','STB_SetInfo','STB_LineRouteMapping',
  'STB_MaterialLotInfo','STB_MaterialStock','STB_MaterialDocInfo','STB_MaterialDocDetail','STB_MaterialDocLotInfo',
  'STB_MaterialWarehouseInOutHist','STB_RawMaterialInputHist','STB_MaterialQcInfo','STB_IQcDefectReport','STB_NCR_REPORT',
  'STB_ElectrodeCoatingInfo','STB_ElectrodeRollPressingInfo','STB_ElectrodeSlittingResult','STB_ElectrodeSlittingResultHist',
  'STB_ElectrodeWasteInfoNew','STB_MaterialWarehouseUsageHist',
  'STB_ProdRouteHist','STB_ProcedureLog',
  'STB_AgingSortingData','STB_DefectInfo','STB_VN_SCRAP_WEIGHSCALE_PRODUCTIONS',
  'STB_DividePackaging','stb_MergeBoxReality','STB_PackingLabelSpec','STB_PackingStandard',
  'STB_ModelBasicInfo','STB_ModelLabelInfo','STB_ProductionOrderRouting','STB_ProductionOrderBom',
  'STB_MaterialStockAttributeInfo','STB_BaseCode','STB_ConstCodeInfo',
  'stb_vvt_OpenExpiredMaterial','STB_VN_BigBoxPacking',
  'STB_DayPlanInfo','STB_DayPlanDetail',
  'STB_VN_FINISHGOODS_HN_New','STB_VN_FINISHGOODS_HN_Export','STB_VN_FINISHGOODS_HN_ExportDetail','STB_VN_FINISHGOODS_BG',
  'STB_ChangeMaterialCode_Config','STB_ChangeMaterialCode_HN','STB_CreateMarkingLetterAndQtyForBarcode',
  'STB_MasterProductionScheduleInfo','STB_MaterialDocPickingPlan',
  'STB_NCR_Report','STB_UserInfo','STB_MaterialAttribute','STB_MaterialHoldInfo',
  'STB_LotChangeMaterialHistory','STB_VN_BENDING_TAPPING','STB_Vietnam_packingPrinting'
) ORDER BY TABLE_NAME
"@ "TABLES"

# 2. SPs
Run-Query @"
SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME IN (
  'usp_BomHeader_iud','usp_BomDetail_iud','usp_RouteInfo_iud','usp_RouteInfo_get',
  'usp_RawMaterialInputHist_iud','usp_Vietnam_RawMaterialInputHist_uid',
  'usp_MaterialQcInfo_iud','usp_MaterialWarehouseInOutHist_iud','usp_VVTMaterialWarehouse_validFIFO',
  'pop_Electrode_Coating_iud','pop_Electrode_RollPressing_iud',
  'usp_ElectrodeSlittingResult_iud','usp_ElectrodeWasteInfoNew_iud',
  'usp_DoProcessProdRouteHist','usp_DoProcessProdGIMaterialByBOM','usp_DoProcessProdGRMaterialByOne',
  'usp_InsertDataAgingAndSorting','usp_DefectInfo_iud','usp_Add_VN_SCRAP_WEIGHSCALE_PRODUCTIONS',
  'usp_DivideAndPrintPackagingLabels','usp_Vietnam_DoProcessBigBoxPacking_VVT_F3',
  'usp_VN_FinishGood_BG_StockIn_iud',
  'usp_CheckInputRawMaterialCodeForProduct','usp_DoProcessProdRouteSummary',
  'usp_DoFinishMaterialDoc','usp_DoFixMaterialDoc',
  'usp_PDADoPutaway','usp_PDADoPutaway_AddDateConfirmEX_new',
  'usp_VVTMaterialWarehouse_HOLDexpired',
  'usp_Prod_Daily_Input_Schedule_iud','usp_ProductionOrderRouting_iud','usp_SetInfo_iud',
  'usp_MasterProductionScheduleInfo_get','usp_DoCreateProductionOrderBatch',
  'usp_VVT_checkFIFO_FinishGood',
  'ImportWarehouseFinshGood_uid','ExportWarehouseFinshGood_uid',
  'usp_Vietnam_DoProcessProdPacking_VVT',
  'usp_DoProcessProdRouteHistForCalc_SmartApp_VNT',
  'usp_Medium_Daily_Input',
  'usp_DoCreateMaterialDocLotInfoNotUsedBarcode',
  'usp_VN_UpdateSpecialSparePartLot',
  'usp_ExportWarehouseFinshGood_RD_HN_uid',
  'usp_Prod_Daily_Input_Schedule',
  'usp_ProductionOrderBatchInfo_iud',
  'usp_PDADoPicking'
) ORDER BY ROUTINE_NAME
"@ "SPs"

# 3. Triggers
Run-Query "SELECT name FROM sys.triggers WHERE name IN ('tgMaterialLotInfoForInsert','tgMaterialDocDetailForInsert')" "TRIGGERS"

# 4. Views
Run-Query "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME IN ('VW_ModelBasicInfo','FinishGoodMESInstock_HN')" "VIEWS"

# 5. Functions
Run-Query "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'FUNCTION' AND ROUTINE_NAME = 'fnGetJobDateShiftTime'" "FUNCTIONS"

# 6. Route samples
Run-Query "SELECT TOP 5 RouteCode, RouteName, WorkCenterCode FROM STB_RouteInfo WHERE RouteCode LIKE 'V-%' ORDER BY RouteCode" "ROUTE_V_PREFIX"
Run-Query "SELECT TOP 5 RouteCode, RouteName, WorkCenterCode FROM STB_RouteInfo WHERE RouteCode LIKE 'E-%' ORDER BY RouteCode" "ROUTE_E_PREFIX"
Run-Query "SELECT TOP 3 RouteCode, RouteName, WorkCenterCode FROM STB_RouteInfo WHERE RouteCode LIKE 'K-%' ORDER BY RouteCode" "ROUTE_K_PREFIX"

# 7. Plant codes
Run-Query "SELECT DISTINCT CompanyCode, WorkCenterCode FROM STB_ProductionOrderInfo WHERE CompanyCode IN ('VNT','VVT') ORDER BY CompanyCode, WorkCenterCode" "PLANT_CODES"

# 8. DayPlanInfo vs DayProdPlan
Run-Query @"
SELECT 'STB_DayPlanInfo' AS tbl, COUNT(*) AS cnt FROM STB_DayPlanInfo
UNION ALL SELECT 'STB_DayPlanDetail', COUNT(*) FROM STB_DayPlanDetail
UNION ALL SELECT 'STB_DayProdPlan', COUNT(*) FROM STB_DayProdPlan
"@ "PLAN_TABLES_COUNT"

# 9. Column checks
Run-Query "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_MaterialLotInfo' AND COLUMN_NAME IN ('LotID','InitialQty','CurrentQty','MaterialLocationCode','CompanyCode','MaterialCode','LotAttr10') ORDER BY COLUMN_NAME" "COLS_MaterialLotInfo"
Run-Query "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_ProdRouteHist' AND COLUMN_NAME IN ('ControlNo','BarCode','PONo','RouteCode','ProdQty','JobDate','ShiftCode','CreateDateTime','ProdDateTime','LineCode') ORDER BY COLUMN_NAME" "COLS_ProdRouteHist"
Run-Query "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_DividePackaging' AND COLUMN_NAME IN ('PackingID','LotNo','ParentPackingID') ORDER BY COLUMN_NAME" "COLS_DividePackaging"
Run-Query "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_SetInfo' AND COLUMN_NAME IN ('ControlNo','Barcode','IsLineInput','IsProdFinish','DayPlanNo','PONo') ORDER BY COLUMN_NAME" "COLS_SetInfo"

# 10. Verify non-existent SP claim
Run-Query "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_NAME='usp_ExportWarehouseFinshGood_RD_HN_uid'" "CLAIMED_MISSING_SP"

# 11. Check table STB_MaterialDocPickingPlan
Run-Query "SELECT COUNT(*) AS exist_flag FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_MaterialDocPickingPlan'" "PICKING_PLAN_TABLE"

# 12. Golden Query columns verify
Run-Query "SELECT TOP 1 PRH.ControlNo, PRH.PONo, RI.RouteName, PRH.CreateDateTime FROM STB_ProdRouteHist PRH WITH(NOLOCK) LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode ORDER BY PRH.CreateDateTime DESC" "GOLDEN_QUERY_VERIFY"

$conn.Close()
Write-Host "`n=== ALL DONE ==="
