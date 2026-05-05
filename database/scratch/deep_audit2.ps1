$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()

function Run-Query($sql, $label) {
    Write-Host "`n=== $label ==="
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 30
    try {
        $rdr = $cmd.ExecuteReader()
        $cols = @()
        for ($i=0; $i -lt $rdr.FieldCount; $i++) { $cols += $rdr.GetName($i) }
        Write-Host ($cols -join ' | ')
        Write-Host ('---')
        $rowCount = 0
        while ($rdr.Read()) {
            $vals = @()
            for ($i=0; $i -lt $rdr.FieldCount; $i++) { 
                $v = $rdr[$i].ToString()
                if ($v.Length -gt 100) { $v = $v.Substring(0,100) + '...' }
                $vals += $v 
            }
            Write-Host ($vals -join ' | ')
            $rowCount++
        }
        if ($rowCount -eq 0) { Write-Host "(no rows)" }
        Write-Host "--- ($rowCount rows)"
        $rdr.Close()
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)"
    }
}

Write-Host "===== DEEP AUDIT - Part 2: SP Logic & Data Cross-Reference ====="

# 1. Check STB_MaterialHoldInfo exists? (doc line 2289 claims it has IsRelease)
Run-Query "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='STB_MaterialHoldInfo'" "TABLE_MaterialHoldInfo"

# 2. VERIFY: Doc claims @SIExtInt01 stores "20 minute flag" - check actual data
Run-Query @"
SELECT TOP 5 SIExtInt01, COUNT(*) AS cnt
FROM STB_SetInfo
WHERE SIExtInt01 IS NOT NULL AND SIExtInt01 <> 0
GROUP BY SIExtInt01
ORDER BY cnt DESC
"@ "SIEXTINT01_DISTRIBUTION"

# 3. VERIFY: Barcode chain max depth = 6 (doc claims up to 6 levels)
# Already confirmed: MaxChainDepth = 6 ✓

# 4. VERIFY: STB_ProcedureLog - is it actually used for audit? Check recent entries
Run-Query @"
SELECT TOP 5 ProcedureName, COUNT(*) AS cnt
FROM STB_ProcedureLog
WHERE CreateDateTime >= DATEADD(DAY, -1, GETDATE())
GROUP BY ProcedureName
ORDER BY cnt DESC
"@ "PROCEDURE_LOG_TOP_SPS"

# 5. VERIFY: Golden Query fix - ControlNo in SetInfo doesn't have matching PRH (check JOIN correctness)
Run-Query @"
SELECT TOP 3 s.ControlNo, s.Barcode, p.RouteCode, ri.RouteName, p.CreateDateTime
FROM STB_SetInfo s WITH(NOLOCK)
JOIN STB_ProdRouteHist p WITH(NOLOCK) ON s.ControlNo = p.ControlNo
JOIN STB_RouteInfo ri WITH(NOLOCK) ON p.RouteCode = ri.RouteCode
WHERE s.CreateDateTime >= DATEADD(DAY, -1, GETDATE())
ORDER BY p.CreateDateTime DESC
"@ "GOLDEN_QUERY_FIXED"

# 6. Check doc claim: DPPExtText01 used for "Lot closure" flag
Run-Query @"
SELECT TOP 5 DayPlanNo, DPPExtText01, DPPExtText02
FROM STB_DayProdPlan 
WHERE DPPExtText01 IS NOT NULL AND DPPExtText01 <> ''
ORDER BY CreateDateTime DESC
"@ "DAYPRODPLAN_CLOSURE_FLAG"

# 7. VERIFY: ProductionOrderRouting - Module routes use MV- prefix
Run-Query @"
SELECT DISTINCT LEFT(RouteCode, 3) AS Prefix, COUNT(*) AS cnt
FROM STB_ProductionOrderRouting
WHERE RouteCode LIKE 'MV-%'
GROUP BY LEFT(RouteCode, 3)
"@ "MODULE_ROUTE_PREFIX"

# 8. VERIFY: MMExtInt01 is actually used for shelf life (days)
Run-Query @"
SELECT TOP 5 MaterialCode, MaterialName, MMExtInt01 AS ShelfLifeDays, MMExtText01
FROM STB_MaterialMaster
WHERE MMExtInt01 > 0 AND MMExtInt01 < 365
ORDER BY MMExtInt01 ASC
"@ "SHELF_LIFE_DAYS_SAMPLE"

# 9. VERIFY: Packing flow - DividePackaging has ParentPackingID for BigBox link
Run-Query @"
SELECT TOP 5 PackingID, LotNo, ParentPackingID, PackingQty, CreateDateTime
FROM STB_DividePackaging
WHERE ParentPackingID IS NOT NULL AND ParentPackingID <> ''
ORDER BY CreateDateTime DESC
"@ "DIVIDEPACKAGING_BIGBOX_LINK"

# 10. VERIFY: stb_MergeBoxReality structure
Run-Query @"
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'stb_MergeBoxReality'
ORDER BY ORDINAL_POSITION
"@ "MERGEBOX_COLUMNS"

# 11. VERIFY: fn_VVT_getdatebyVendorLot - check it returns a date
Run-Query @"
SELECT TOP 3 LotID, LotAttr10 FROM STB_MaterialDocLotInfo
WHERE LotAttr10 IS NOT NULL AND LEN(LotAttr10) > 0
ORDER BY CreateDateTime DESC
"@ "LOTATR10_SAMPLE"

# 12. VERIFY: stb_vvt_materialbo - check actual structure matches doc claim
Run-Query @"
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'stb_vvt_materialbo'
ORDER BY ORDINAL_POSITION
"@ "VVT_MATERIALBO_STRUCTURE"

# 13. VERIFY: STB_VN_PRODUCTION_ERROR structure (doc claims this is for "Bao phe")
Run-Query @"
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'STB_VN_PRODUCTION_ERROR'
ORDER BY ORDINAL_POSITION
"@ "VN_PRODUCTION_ERROR_STRUCTURE"

# 14. VERIFY: CompleteRoute values in ProdRouteHist
Run-Query @"
SELECT DISTINCT CompleteRoute, COUNT(*) AS cnt
FROM STB_ProdRouteHist
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
GROUP BY CompleteRoute
"@ "COMPLETEROUTE_VALUES"

# 15. VERIFY: Actual trigger code - check what tgMaterialLotInfoForInsert does
Run-Query @"
SELECT LEFT(OBJECT_DEFINITION(OBJECT_ID('tgMaterialLotInfoForInsert')), 300) AS TriggerCode
"@ "TRIGGER_CODE_PREVIEW"

# 16. VERIFY: Doc claims SetInfo.Barcode links to DividePackaging.LotNo
Run-Query @"
SELECT TOP 3 s.ControlNo, s.Barcode, dp.PackingID, dp.PackingQty
FROM STB_SetInfo s WITH(NOLOCK)
JOIN STB_DividePackaging dp WITH(NOLOCK) ON s.ControlNo = dp.LotNo
WHERE dp.CreateDateTime >= DATEADD(DAY, -7, GETDATE())
ORDER BY dp.CreateDateTime DESC
"@ "SETINFO_DIVPACK_JOIN"

# 17. VERIFY: InterimProdQtyInfo structure (doc claims "so luong trung gian")
Run-Query @"
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'STB_InterimProdQtyInfo'
ORDER BY ORDINAL_POSITION
"@ "INTERIM_PRODQTY_STRUCTURE"

# 18. VERIFY: How many unique ControlNo values exist (data volume)
Run-Query @"
SELECT 
    COUNT(DISTINCT ControlNo) AS UniqueControlNo_7Days,
    COUNT(*) AS TotalRecords_7Days
FROM STB_ProdRouteHist
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
"@ "PRH_DATA_VOLUME"

# 19. VERIFY: SP naming convention - usp_ prefix consistency
Run-Query @"
SELECT 
    SUM(CASE WHEN ROUTINE_NAME LIKE 'usp_%' THEN 1 ELSE 0 END) AS usp_prefix,
    SUM(CASE WHEN ROUTINE_NAME LIKE 'fn_%' THEN 1 ELSE 0 END) AS fn_prefix,
    SUM(CASE WHEN ROUTINE_NAME LIKE 'sp_%' THEN 1 ELSE 0 END) AS sp_prefix,
    SUM(CASE WHEN ROUTINE_NAME NOT LIKE 'usp_%' AND ROUTINE_NAME NOT LIKE 'fn_%' AND ROUTINE_NAME NOT LIKE 'sp_%' THEN 1 ELSE 0 END) AS no_prefix,
    COUNT(*) AS total
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dbo'
"@ "SP_NAMING_CONVENTION"

# 20. ExportWarehouseFinshGood_RD_HN_uid - verify prefix issue
Run-Query @"
SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_NAME LIKE '%ExportWarehouseFinshGood%'
ORDER BY ROUTINE_NAME
"@ "EXPORT_WH_SP_NAMES"

$conn.Close()
Write-Host "`n===== DEEP AUDIT Part 2 DONE ====="
