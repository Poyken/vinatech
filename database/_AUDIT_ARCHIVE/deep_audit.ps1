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
                if ($v.Length -gt 80) { $v = $v.Substring(0,80) + '...' }
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

Write-Host "===== DEEP AUDIT - Part 1: Logic Verification ====="

# 1. VERIFY: Golden Query from doc (line 221-236) - does it actually work?
Run-Query @"
SELECT TOP 3
    PRH.ControlNo AS [Ma_vach_SP], 
    PRH.PONo AS [Lenh_SX], 
    RI.RouteName AS [Cong_doan],
    PRH.CreateDateTime AS [Gio_quet],
    DP.PackingID AS [Ma_Thung],
    DP.ParentPackingID AS [Ma_BigBox]
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK) ON PRH.ControlNo = DP.LotNo
WHERE PRH.ControlNo = (SELECT TOP 1 ControlNo FROM STB_SetInfo ORDER BY CreateDateTime DESC)
ORDER BY PRH.CreateDateTime ASC
"@ "GOLDEN_QUERY_WORKS"

# 2. VERIFY: Doc claims BarCode column exists in ProdRouteHist (line 3500)
# But we know it doesn't. Check what columns are actually used for barcode linking
Run-Query @"
SELECT TOP 1 c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'STB_ProdRouteHist'
AND c.COLUMN_NAME LIKE '%Bar%'
"@ "PRH_BARCODE_COLUMN_CHECK"

# 3. VERIFY: 6-level barcode chain claim (doc line 4506-4512)
Run-Query @"
SELECT TOP 5 OldBarcode, NewBarcode, ChangeDateTime, ChangeUserID
FROM STB_LotChangeMaterialHistory
ORDER BY ChangeDateTime DESC
"@ "BARCODE_CHAIN_SAMPLE"

# Check if any barcode has been changed 3+ times (verify chain depth)
Run-Query @"
;WITH chain AS (
    SELECT OldBarcode, NewBarcode, 1 AS depth FROM STB_LotChangeMaterialHistory
    UNION ALL
    SELECT c.OldBarcode, h.NewBarcode, c.depth + 1
    FROM chain c
    JOIN STB_LotChangeMaterialHistory h ON h.OldBarcode = c.NewBarcode
    WHERE c.depth < 6
)
SELECT MAX(depth) AS MaxChainDepth FROM chain
"@ "MAX_BARCODE_CHAIN_DEPTH"

# 4. VERIFY: Doc claims STB_MaterialHoldInfo has IsRelease column (line 2289)
Run-Query @"
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'STB_MaterialHoldInfo'
ORDER BY ORDINAL_POSITION
"@ "HOLD_INFO_COLUMNS"

# 5. VERIFY: Gate 20 minutes bug claim (doc line 4678: @SIExtInt01 = Null always FALSE)
# Check if SIExtInt01 column exists in SetInfo
Run-Query @"
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'STB_SetInfo' AND COLUMN_NAME LIKE 'SIExt%'
ORDER BY COLUMN_NAME
"@ "SETINFO_EXT_COLUMNS"

# 6. VERIFY: stb_vvt_materialbo structure (doc line 4594-4599)
Run-Query @"
SELECT TOP 5 * FROM stb_vvt_materialbo
"@ "VVT_MATERIALBO_SAMPLE"

# 7. VERIFY: STB_ProcedureLog audit trail claim (doc line 4399-4403)
Run-Query @"
SELECT TOP 3 * FROM STB_ProcedureLog ORDER BY CreateDateTime DESC
"@ "PROCEDURE_LOG_SAMPLE"

# 8. VERIFY: Doc SQL cheat sheet - Check POType query (line 2277-2280)
Run-Query @"
SELECT TOP 3 PONo, MaterialCode, POType, CompanyCode, WorkCenterCode
FROM STB_ProductionOrderInfo
WHERE CompanyCode = 'VVT'
ORDER BY CreateDateTime DESC
"@ "POTYPE_SAMPLE"

# 9. VERIFY: IsRequireMachine column in RouteInfo (doc line 2782)
Run-Query @"
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'STB_RouteInfo' AND COLUMN_NAME = 'IsRequireMachine'
"@ "ROUTE_ISREQUIREMACHINE"

# 10. VERIFY: STB_DayProdPlan.DPPExtText01 column (doc line 1772-1774, Gate Lot closure)
Run-Query @"
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'STB_DayProdPlan' AND COLUMN_NAME LIKE 'DPPExt%'
ORDER BY COLUMN_NAME
"@ "DAYPRODPLAN_EXT_COLS"

# 11. VERIFY: RouteIndex in ProductionOrderRouting (doc line 4326-4334)
Run-Query @"
SELECT TOP 5 PONo, RouteCode, RouteIndex, IsInputRoute, IsOutputRoute 
FROM STB_ProductionOrderRouting 
WHERE PONo = (SELECT TOP 1 PONo FROM STB_ProductionOrderInfo WHERE CompanyCode='VVT' ORDER BY CreateDateTime DESC)
ORDER BY RouteIndex
"@ "ROUTING_INDEX_SAMPLE"

# 12. VERIFY: Doc claims stb_vvt_OpenExpiredMaterial has OpenExpired column (line 4634)
Run-Query @"
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Stb_VVT_OpenExpiredMaterial'
ORDER BY ORDINAL_POSITION
"@ "OPEN_EXPIRED_COLUMNS"

# 13. VERIFY: CompleteRoute column in ProdRouteHist (doc line 4476)
Run-Query @"
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'STB_ProdRouteHist' AND COLUMN_NAME = 'CompleteRoute'
"@ "PRH_COMPLETEROUTE"

# 14. VERIFY: Backflush claim - does ProdRouteHist link to MaterialWarehouseInOutHist?
Run-Query @"
SELECT TOP 3 h.ControlNo, h.RouteCode, h.PONo, w.MaterialCode, w.InOut, w.Quantity
FROM STB_ProdRouteHist h WITH(NOLOCK)
JOIN STB_MaterialWarehouseInOutHist w WITH(NOLOCK) ON h.PONo = w.PONo
WHERE h.PONo = (SELECT TOP 1 PONo FROM STB_ProdRouteHist WHERE CompanyCode='VVT' ORDER BY CreateDateTime DESC)
AND w.InOut = 'OUT'
ORDER BY h.CreateDateTime DESC
"@ "BACKFLUSH_LINKAGE"

# 15. VERIFY: MMExtInt01 column for shelf life (doc line 2296, 4348)
Run-Query @"
SELECT TOP 3 MaterialCode, MaterialName, MMExtInt01 
FROM STB_MaterialMaster 
WHERE MMExtInt01 IS NOT NULL AND MMExtInt01 > 0
ORDER BY MMExtInt01 DESC
"@ "SHELF_LIFE_SAMPLE"

# 16. VERIFY: IsLineInput, IsProdFinish flags in SetInfo (doc line 4316)
Run-Query @"
SELECT 
    SUM(CASE WHEN IsLineInput = 1 THEN 1 ELSE 0 END) AS LineInput_True,
    SUM(CASE WHEN IsLineInput = 0 THEN 1 ELSE 0 END) AS LineInput_False,
    SUM(CASE WHEN IsProdFinish = 1 THEN 1 ELSE 0 END) AS ProdFinish_True,
    SUM(CASE WHEN IsProdFinish = 0 THEN 1 ELSE 0 END) AS ProdFinish_False,
    COUNT(*) AS Total
FROM STB_SetInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
"@ "SETINFO_FLAGS_DISTRIBUTION"

$conn.Close()
Write-Host "`n===== DEEP AUDIT Part 1 DONE ====="
