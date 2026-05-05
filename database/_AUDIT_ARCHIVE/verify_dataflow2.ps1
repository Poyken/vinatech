$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()

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

# 1. Check missing tables from doc
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_DayPlanInfo'" "DayPlanInfo_exists"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_DayPlanDetail'" "DayPlanDetail_exists"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_VN_BigBoxPacking'" "BigBoxPacking_exists"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_ConstCodeInfo'" "ConstCodeInfo_exists"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_BaseCode'" "BaseCode_exists"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_VN_FINISHGOODS_HN_ExportDetail'" "HN_ExportDetail_exists"

# 2. Check custom Vietnam tables  
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='stb_vvt_materialbo'" "stb_vvt_materialbo"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_VN_PRODUCTION_ERROR'" "VN_PRODUCTION_ERROR"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_VN_DIVIDEMATERIALSMAL'" "VN_DIVIDEMATERIALSMAL"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_VVT_StagePrices'" "VVT_StagePrices"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_SavePackingTime_VVT'" "SavePackingTime_VVT"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_InterimProdQtyInfo'" "InterimProdQtyInfo"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='gtAndon_v1'" "gtAndon_v1"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_BarrelBarcodeInfo'" "BarrelBarcodeInfo"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_CommInspDocHistory'" "CommInspDocHistory"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_CommInspDocItem'" "CommInspDocItem"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_DefectRepairInfo'" "DefectRepairInfo"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_CoatingToSlittingMaster'" "CoatingToSlittingMaster"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='stb_slittinglocationconfig_vvt'" "slittinglocationconfig_vvt"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='tbl_SlittingStock'" "tbl_SlittingStock"
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='tbl_BomDetail'" "tbl_BomDetail"

# 3. Check view FinishGoodMESInstock_HN
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME='FinishGoodMESInstock_HN'" "VIEW_FinishGoodMESInstock_HN"

# 4. Verify WorkCenterCodes in RouteInfo
Run-Query "SELECT DISTINCT WorkCenterCode FROM STB_RouteInfo WHERE WorkCenterCode IS NOT NULL ORDER BY WorkCenterCode" "ROUTE_WorkCenters"

# 5. Sample ControlNo from SetInfo
Run-Query "SELECT TOP 3 ControlNo, Barcode, PONo, DayPlanNo, IsLineInput, IsProdFinish FROM STB_SetInfo ORDER BY CreateDateTime DESC" "SAMPLE_SetInfo"

# 6. Check SP that doc claims exist but might not (usp_ExportWarehouseFinshGood_RD_HN_uid)
Run-Query "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_NAME LIKE '%ExportWarehouse%'" "SP_ExportWarehouse"

# 7. Check fn_VVT_getdatebyVendorLot
Run-Query "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='FUNCTION' AND ROUTINE_NAME LIKE '%VVT%'" "FN_VVT"

# 8. Barcode prefixes sample
Run-Query "SELECT TOP 3 Barcode FROM STB_SetInfo WHERE Barcode LIKE 'VV%' ORDER BY CreateDateTime DESC" "BARCODE_VV"
Run-Query "SELECT TOP 3 Barcode FROM STB_SetInfo WHERE Barcode LIKE 'VE%' ORDER BY CreateDateTime DESC" "BARCODE_VE"

# 9. ProdRouteHist column BarCode exists?
Run-Query "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_ProdRouteHist' AND COLUMN_NAME='BarCode'" "PRH_BarCode_col"

# 10. STB_MaterialMaster IsFIFO column
Run-Query "SELECT COUNT(*) AS cnt FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_MaterialMaster' AND COLUMN_NAME='IsFIFO'" "MM_IsFIFO"

# 11. ExpiredDate column in MaterialLotInfo?
Run-Query "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='STB_MaterialLotInfo' AND COLUMN_NAME IN ('ExpiredDate','ProductionDate','ExpirationDate') ORDER BY COLUMN_NAME" "MLI_DateCols"

$conn.Close()
Write-Host "`n=== ALL DONE ==="
