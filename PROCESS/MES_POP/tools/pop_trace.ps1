# ==============================================================================
# pop_trace.ps1 — Ultra-Fast 360° Trace with Smart Identifier Resolver
# Single Round-Trip | Auto Pattern Detection (Lot / Packing / Machine / Line)
# Tham chiếu: RULE 6 (Golden Query), POP_KB_01, POP_KB_02, POP_KB_03
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Target,
    [switch]$Json
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$t = $Target.Trim()
if ([string]::IsNullOrWhiteSpace($t)) {
    Write-Host "Loi: Vui long nhap ma can truy vet!" -ForegroundColor Red
    exit 1
}

# 1. SMART IDENTIFIER RESOLVER (Tu dong phan loai ma dau vao)
$type = "LOT"
if ($t -match '^PK') {
    $type = "PACKING"
} elseif ($t -match '^(V[VN]EP|VVMM|VNMD|VVMHY|EQ)') {
    $type = "EQUIPMENT"
} elseif ($t -match '^(VVC-|VVHYC-|TCX|ELECTRODE|MEA)') {
    $type = "LINE"
} elseif ($t -match '^\d{12}$') {
    $type = "PO"
} elseif ($t -match '^(ECVT|CRFY|SRFH|LIVT|CREH|WIC|WSC)') {
    $type = "MODEL"
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "     [POP-TRACE 360] TRUY VET SIEU TOC (SINGLE ROUND-TRIP)" -ForegroundColor Yellow
Write-Host "     Ma truy vet: $t | Loai nhan dien: $type" -ForegroundColor White
Write-Host '======================================================================' -ForegroundColor Cyan

$conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
if ($null -eq $conn) {
    Write-Host "LOI: Khong the ket noi toi CSDL SmartFactoryV2!" -ForegroundColor Red
    exit 1
}

$cmd = $conn.CreateCommand()
$ds = New-Object System.Data.DataSet

if ($type -eq "PACKING") {
    $cmd.CommandText = @"
-- 1. STB_SavePackingTime_VVT
SELECT TOP 10 PackingID, Barcode, PackingTime, RegDate 
FROM SmartFactoryV2.dbo.STB_SavePackingTime_VVT WITH(NOLOCK) 
WHERE PackingID = '$t';

-- 2. STB_MaterialLotInfo
SELECT TOP 20 MaterialLotNo, LotNo, MaterialCode, PackingID, CurrentQty, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) 
WHERE PackingID = '$t';

-- 3. STB_PackingLabelPrintHist
SELECT TOP 5 PackingID, PrintCount, IsPrintAllow, CreateDateTime, CreateUserID 
FROM SmartFactoryV2.dbo.STB_PackingLabelPrintHist WITH(NOLOCK) 
WHERE PackingID = '$t';

-- 4. STB_VN_FINISHGOODS
SELECT TOP 10 PackingID, LotNo, MaterialCode, PackQty, CreateDate 
FROM SmartFactoryV2.dbo.STB_VN_FINISHGOODS WITH(NOLOCK) 
WHERE PackingID = '$t';
"@
} elseif ($type -eq "EQUIPMENT") {
    $cmd.CommandText = @"
-- 1. VINA_EQUIPMENT_SETTING
SELECT TOP 1 EQUIPMENT_SETTING_ID, MODEL_ID, EQUIPMENT_SETTING_NAME, EQUIPMENT_SETTING_ROUTE_TYPE, EQUIPMENT_SETTING_DEFAULT, EQUIPMENT_SETTING_DATA_COLLECTION_TIME 
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_SETTING WITH(NOLOCK) 
WHERE EQUIPMENT_SETTING_ID = '$t' OR EQUIPMENT_SETTING_NAME LIKE '%$t%';

-- 2. VINA_PLC_BASELINE
SELECT TOP 5 EQUIPMENT_ID, PROD_BASELINE, DEF_BASELINE, REG_DATE, MODIFY_DATE 
FROM VINATECH_POP.dbo.VINA_PLC_BASELINE WITH(NOLOCK) 
WHERE EQUIPMENT_ID = '$t';

-- 3. VINA_EQUIPMENT_REMAINDER
SELECT TOP 5 SEQ, EQUIPMENT_ID, DAY_PLAN_NO, LOT_NUMBER, PROD_REMAIN, DEF_REMAIN, REMAIN_STATUS, REG_DATE 
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_REMAINDER WITH(NOLOCK) 
WHERE EQUIPMENT_ID = '$t' 
ORDER BY REG_DATE DESC;

-- 4. VINA_EQUIPMENT_MAPPING
SELECT TOP 5 MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, MAPPING_STATUS, MAPPED_AT, RELEASED_AT 
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK) 
WHERE EQUIPMENT_ID = '$t' 
ORDER BY MAPPED_AT DESC;
"@
} elseif ($type -eq "LINE") {
    $cmd.CommandText = @"
-- 1. Assembly Mode & Prod Mode
SELECT g.LINE_CODE, g.INPUT_MODE, ISNULL(p.PROD_MODE, 'THIEU') AS PROD_MODE 
FROM VINATECH_POP.dbo.VINA_ASSEMBLY_GROUP_MODE g WITH(NOLOCK) 
LEFT JOIN (SELECT DISTINCT LINE_CODE, PROD_MODE FROM VINATECH_POP.dbo.VINA_LINE_PROD_MODE WITH(NOLOCK)) p ON p.LINE_CODE = g.LINE_CODE 
WHERE g.LINE_CODE = '$t';

-- 2. Slots
SELECT SLOT_CODE, SLOT_NAME, ROUTE_CODE, MASTER_GROUP_CODES, IS_REQUIRED, DISPLAY_ORDER 
FROM VINATECH_POP.dbo.VINA_GROUP_INPUT_ROUTE WITH(NOLOCK) 
WHERE LINE_CODE = '$t' 
ORDER BY DISPLAY_ORDER;

-- 3. Active Machine Locks
SELECT MAPPING_ID, DAY_PLAN_NO, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPING_STATUS, MAPPED_AT 
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK) 
WHERE LINE_CODE = '$t' AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');

-- 4. Pending Sync Lots
SELECT TOP 10 DayPlanNo, Barcode, RouteCode, TotalProdQty, IsDone, IsTransferred, ModifyDateTime 
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
WHERE LineCode = '$t' AND IsDone = 1 AND IsTransferred = 0 
ORDER BY ModifyDateTime DESC;
"@
} elseif ($type -eq "PO") {
    $cmd.CommandText = @"
-- 1. PO Summary
SELECT 
    PONo, 
    MaterialCode, 
    COUNT(*) AS TotalLots,
    SUM(CASE WHEN IsProdFinish = 1 THEN 1 ELSE 0 END) AS FinishedLots,
    SUM(CASE WHEN IsLineInput = 1 THEN 1 ELSE 0 END) AS InputLots,
    SUM(DefectQty) AS TotalDefects,
    MIN(CreateDateTime) AS FirstLotDate,
    MAX(CreateDateTime) AS LastLotDate
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE PONo = '$t'
GROUP BY PONo, MaterialCode;

-- 2. Danh sach cac Lot thuoc PO
SELECT TOP 30 
    ControlNo, 
    Barcode, 
    MaterialCode, 
    IsProdFinish, 
    IsLineInput, 
    DefectQty, 
    CreateDateTime
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE PONo = '$t'
ORDER BY CreateDateTime DESC;
"@
} elseif ($type -eq "MODEL") {
    $cmd.CommandText = @"
-- 1. Model Summary
SELECT 
    MaterialCode, 
    COUNT(DISTINCT PONo) AS TotalPOs, 
    COUNT(DISTINCT ControlNo) AS TotalLots,
    SUM(CASE WHEN IsProdFinish = 1 THEN 1 ELSE 0 END) AS FinishedLots,
    MAX(CreateDateTime) AS LastActiveDate
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE MaterialCode = '$t'
GROUP BY MaterialCode;

-- 2. Cac PO gan nhat
SELECT TOP 10 
    PONo, 
    COUNT(*) AS LotsInPO, 
    SUM(CASE WHEN IsProdFinish = 1 THEN 1 ELSE 0 END) AS FinishedLots, 
    MAX(CreateDateTime) AS RecentDate
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE MaterialCode = '$t'
GROUP BY PONo
ORDER BY RecentDate DESC;

-- 3. Cac Lot gan nhat
SELECT TOP 15 
    ControlNo, Barcode, PONo, IsProdFinish, CreateDateTime
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE MaterialCode = '$t'
ORDER BY CreateDateTime DESC;
"@
} else { # LOT / BARCODE / CONTROLNO
    $cmd.CommandText = @"
SET NOCOUNT ON;
DECLARE @Ctrl VARCHAR(30) = '$t';
DECLARE @Bar VARCHAR(50) = '$t';
DECLARE @LineCode VARCHAR(30) = NULL;

-- 0. RESOLVE CONTROLNO VA BARCODE (Index Seek <1ms)
IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '$t')
BEGIN
    SELECT TOP 1 @Bar = Barcode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '$t';
END
ELSE IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$t')
BEGIN
    SELECT TOP 1 @Ctrl = ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$t';
END
ELSE
BEGIN
    -- Fallback: Do theo phan he Chat luong / PQC Web (CommInspDocItemNo hoac CommInspDocNo)
    SELECT TOP 1 @Ctrl = H.ProdNo 
    FROM SmartFactoryV2.dbo.STB_CommInspDocHistory H WITH(NOLOCK)
    LEFT JOIN SmartFactoryV2.dbo.STB_CommInspDocItem I WITH(NOLOCK) ON H.CommInspDocNo = I.CommInspDocNo
    WHERE I.CommInspDocItemNo = '$t' OR H.CommInspDocNo = '$t';

    IF @Ctrl IS NOT NULL
    BEGIN
        SELECT TOP 1 @Bar = Barcode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @Ctrl;
    END
END

SELECT TOP 1 @LineCode = LineCode FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) WHERE Barcode = @Bar;

-- 1. STB_SetInfo (Index Seek)
SELECT TOP 1 ControlNo, PONo, Barcode, MaterialCode, IsProdFinish, IsLineInput, DefectQty, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
WHERE ControlNo = @Ctrl;

-- 2. STB_ProdRouteHist (Index Seek)
SELECT TOP 10 ProdRouteHistNo, ControlNo, RouteCode, WorkCenterCode, ProdQty, JobDate, ProdDateTime, CompleteRoute 
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) 
WHERE ControlNo = @Ctrl 
ORDER BY CreateDateTime DESC;

-- 3. MongoToMesPerformance (POP Sync)
SELECT TOP 10 DayPlanNo, Barcode, RouteCode, LineCode, MachineCode, TotalProdQty, TotalDefectQty, IsDone, IsTransferred, InsertDateTime, ModifyDateTime 
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
WHERE Barcode = @Bar 
ORDER BY ModifyDateTime DESC;

-- Lay nhanh LineCode tu buoc sync
SELECT TOP 1 @LineCode = LineCode 
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
WHERE Barcode = @Bar;

-- 4. STB_DefectRepairInfo (Index Seek)
SELECT TOP 10 DefectSummaryNo, ControlNo, FindRouteCode, DefectCode, DefectQty, RepairQty, IsDelete, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_DefectRepairInfo WITH(NOLOCK) 
WHERE ControlNo = @Ctrl 
ORDER BY CreateDateTime DESC;

-- 5.1. STB_ProductionOrderBom (Dinh muc BOM, Alt Code & Ton kho kho chuyen ROUTE_VN_WH)
SELECT 
    B.RouteCode, 
    B.ChildMaterialCode, 
    ISNULL(MM_Base.MaterialName, '') AS MaterialName, 
    B.UsedQty, 
    ISNULL(MM_Base.DelegateMaterialCode, '-') AS AltCode1, 
    ISNULL(MM_Base.DelegateMaterialCode2, '-') AS AltCode2,
    ISNULL(S.StockQty, 0) AS WhStockQty
FROM SmartFactoryV2.dbo.STB_ProductionOrderBom B WITH(NOLOCK)
LEFT JOIN SmartFactoryV2.dbo.STB_MaterialMaster MM_Base WITH(NOLOCK) ON B.ChildMaterialCode = MM_Base.MaterialCode
OUTER APPLY (
    SELECT SUM(CurrentQty) AS StockQty 
    FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
    WHERE MaterialCode = B.ChildMaterialCode AND MaterialWarehouseCode = 'ROUTE_VN_WH'
) S
WHERE B.PONo = (SELECT TOP 1 PONo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @Ctrl) 
  AND (@LineCode IS NULL OR B.RouteCode = (SELECT TOP 1 RouteCode FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) WHERE Barcode = @Bar) OR (SELECT TOP 1 RouteCode FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) WHERE Barcode = @Bar) IS NULL)
ORDER BY B.RouteCode, B.ChildMaterialCode;

-- 5.2. STB_RawMaterialInputHist (Lich su NVL da nap tai Kiosk POP)
SELECT TOP 15 RawMaterialBarcode, MaterialCode, Qty, RouteCode, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_RawMaterialInputHist WITH(NOLOCK) 
WHERE Barcode = @Bar 
ORDER BY CreateDateTime DESC;

-- 5.3. STB_MaterialLotInfo (Neu ma nhap vao la cuon BTP / Box dong goi trong kho)
SELECT TOP 10 MaterialLotNo, LotNo, MaterialCode, PackingID, CurrentQty, InitialQty 
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) 
WHERE LotNo = @Bar OR MaterialLotNo = @Bar OR PackingID = @Bar;

-- 6. VINA_EQUIPMENT_MAPPING (Thiet bi gan tren Kiosk theo Line)
SELECT TOP 10 MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPING_STATUS, MAPPED_AT 
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK) 
WHERE (@LineCode IS NOT NULL AND LINE_CODE = @LineCode) AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');

-- 7. VINA_POP_ACTION_LOG (Nhat ky thao tac POP)
SELECT TOP 5 SEQ, ACTION_TYPE, ACTION_NAME, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, LOT_NUMBER, QTY, RESULT_STATUS, ERROR_MESSAGE, WORKER_CODE, REG_DATE 
FROM VINATECH_POP.dbo.VINA_POP_ACTION_LOG WITH(NOLOCK) 
WHERE LOT_NUMBER = @Bar 
ORDER BY REG_DATE DESC;

-- 8. STB_CommInspDocHistory & STB_CommInspDocItem (Chung tu QC PQC)
SELECT TOP 5 H.CommInspDocNo, I.CommInspDocItemNo, I.CommInspItemCode, H.CommInspTypeCode, H.MaterialCode, H.CreateUserID, H.CreateDateTime 
FROM SmartFactoryV2.dbo.STB_CommInspDocHistory H WITH(NOLOCK) 
LEFT JOIN SmartFactoryV2.dbo.STB_CommInspDocItem I WITH(NOLOCK) ON H.CommInspDocNo = I.CommInspDocNo 
WHERE I.CommInspDocItemNo = '$t' OR H.CommInspDocNo = '$t' OR (H.ProdNo = @Ctrl AND @Ctrl IS NOT NULL) 
ORDER BY H.CreateDateTime DESC;
"@
}

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$adapter.Fill($ds) | Out-Null
$conn.Close()
$sw.Stop()

# 2. RENDER KET QUA SIEU TOC (UI CHUAN DEP & DE NHIN)
function Show-Table([string]$title, [System.Data.DataTable]$table, [string]$color = "Cyan") {
    if ($null -eq $table -or $table.Rows.Count -eq 0) {
        Write-Host "   [-] $title : 0 ban ghi" -ForegroundColor DarkGray
        return
    }
    Write-Host ''
    Write-Host ">>> $title ($($table.Rows.Count) ban ghi):" -ForegroundColor $color
    $table | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
}

function Show-BomCard([System.Data.DataTable]$table) {
    if ($null -eq $table -or $table.Rows.Count -eq 0) {
        Write-Host "   [-] 5.1. DINH MUC BOM CONG DOAN: 0 ban ghi" -ForegroundColor DarkGray
        return
    }
    Write-Host ''
    Write-Host ">>> 5.1. DINH MUC BOM CONG DOAN & TON KHO KHO CHUYEN (ROUTE_VN_WH) ($($table.Rows.Count) vat tu):" -ForegroundColor Magenta
    foreach ($row in $table.Rows) {
        $rt = $row['RouteCode']
        $code = $row['ChildMaterialCode']
        $name = $row['MaterialName']
        $qty = $row['UsedQty']
        $alt1 = $row['AltCode1']
        $alt2 = $row['AltCode2']
        $stock = [double]$row['WhStockQty']
        $stockStr = if ($stock -eq 0) { "[HET HANG (0)]" } else { "$stock" }
        $stockColor = if ($stock -eq 0) { "Red" } else { "Green" }

        Write-Host "   [$rt] " -NoNewline -ForegroundColor DarkCyan
        Write-Host "$code " -NoNewline -ForegroundColor Yellow
        Write-Host "($name) " -NoNewline -ForegroundColor White
        Write-Host "Dinh muc: $qty " -NoNewline -ForegroundColor Gray
        if ($alt1 -ne '-' -or $alt2 -ne '-') {
            Write-Host "| Alt: $alt1, $alt2 " -NoNewline -ForegroundColor DarkYellow
        }
        Write-Host "| Ton kho: " -NoNewline -ForegroundColor Gray
        Write-Host "$stockStr" -ForegroundColor $stockColor
    }
}

function Show-LotCard([System.Data.DataTable]$table) {
    if ($null -eq $table -or $table.Rows.Count -eq 0) {
        Write-Host ''
        Write-Host "   [-] 1. THONG TIN LOT MES (STB_SetInfo): Khong tim thay ban ghi" -ForegroundColor DarkYellow
        return
    }
    $r = $table.Rows[0]
    $ctrl = $r['ControlNo']
    $bar = $r['Barcode']
    $po = $r['PONo']
    $mat = $r['MaterialCode']
    $isFin = if ($r['IsProdFinish'] -eq $true) { "DA HOAN THANH (True)" } else { "CHUA HOAN THANH (False)" }
    $finColor = if ($r['IsProdFinish'] -eq $true) { "Green" } else { "Yellow" }
    $isLine = if ($r['IsLineInput'] -eq $true) { "DA NAP CHUYEN (True)" } else { "CHUA NAP CHUYEN (False)" }
    $defQty = $r['DefectQty']
    $crDate = if ($r['CreateDateTime']) { ([datetime]$r['CreateDateTime']).ToString("dd/MM/yyyy HH:mm:ss") } else { "N/A" }

    Write-Host ''
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|  [1. THONG TIN LOT MES COT LOI - STB_SetInfo]                                 |" -ForegroundColor Cyan
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "   * Ma Barcode tem       : " -NoNewline -ForegroundColor Gray
    Write-Host "$bar" -ForegroundColor Green
    Write-Host "   * Ma Lot MES (Control) : " -NoNewline -ForegroundColor Gray
    Write-Host "$ctrl" -ForegroundColor White
    Write-Host "   * Ma San pham / Model  : " -NoNewline -ForegroundColor Gray
    Write-Host "$mat" -ForegroundColor Yellow
    Write-Host "   * Lenh san xuat (PO)   : " -NoNewline -ForegroundColor Gray
    Write-Host "$po" -ForegroundColor White
    Write-Host "   * Tien do san xuat     : " -NoNewline -ForegroundColor Gray
    Write-Host "$isFin" -ForegroundColor $finColor
    Write-Host "   * Trang thai nap chuyen: " -NoNewline -ForegroundColor Gray
    Write-Host "$isLine" -ForegroundColor White
    Write-Host "   * Tong phe (DefectQty) : " -NoNewline -ForegroundColor Gray
    Write-Host "$defQty" -ForegroundColor $(if ([int]$defQty -gt 0) { "Red" } else { "Green" })
    Write-Host "   * Thoi gian tao Lot    : " -NoNewline -ForegroundColor Gray
    Write-Host "$crDate" -ForegroundColor DarkGray
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
}

function Show-QcCard([System.Data.DataTable]$table) {
    if ($null -eq $table -or $table.Rows.Count -eq 0) { return }
    $r = $table.Rows[0]
    $docNo = $r['CommInspDocNo']
    $itemNo = $r['CommInspDocItemNo']
    $itemCode = $r['CommInspItemCode']
    $typeCode = $r['CommInspTypeCode']
    $user = $r['CreateUserID']
    $crDate = if ($r['CreateDateTime']) { ([datetime]$r['CreateDateTime']).ToString("dd/MM/yyyy HH:mm:ss") } else { "N/A" }

    Write-Host ''
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Magenta
    Write-Host "|  [CHUNG TU KIEM TRA PQC / CHAT LUONG - STB_CommInspDocHistory]               |" -ForegroundColor Magenta
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Magenta
    Write-Host "   * Ma phieu QC (DocNo)  : " -NoNewline -ForegroundColor Gray
    Write-Host "$docNo" -ForegroundColor Yellow
    if ($itemNo) {
        Write-Host "   * Hang muc do (ItemNo) : " -NoNewline -ForegroundColor Gray
        Write-Host "$itemNo ($itemCode)" -ForegroundColor White
    }
    Write-Host "   * Loai kiem tra        : " -NoNewline -ForegroundColor Gray
    Write-Host "$typeCode" -ForegroundColor White
    Write-Host "   * Nguoi tao & Thoi gian: " -NoNewline -ForegroundColor Gray
    Write-Host "$user - $crDate" -ForegroundColor Green
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Magenta
}

function Show-BomDelegateCard([System.Data.DataTable]$table) {
    if ($null -eq $table -or $table.Rows.Count -eq 0) {
        Write-Host "   [-] 8. BOM DINH MUC & NVL THAY THE (STB_ProductionOrderBom): 0 ban ghi" -ForegroundColor DarkGray
        return
    }
    Write-Host ''
    Write-Host ">>> 8. BOM DINH MUC & NVL THAY THE (STB_ProductionOrderBom + STB_MaterialMaster) ($($table.Rows.Count) ban ghi):" -ForegroundColor Cyan
    
    # Kiem tra xem co mismatch size giua ma goc va ma thay the khong
    $mismatches = @($table | Where-Object { $_['DelegateStatus'] -eq 'MISMATCH_SIZE' })
    if ($mismatches.Count -gt 0) {
        Write-Host "   +-------------------------------------------------------------------------------+" -ForegroundColor Red
        Write-Host "   | [!] CANH BAO: PHAT HIEN MISMATCH QUY CACH NGUYEN VAT LIEU THAY THE!          |" -ForegroundColor Red
        Write-Host "   +-------------------------------------------------------------------------------+" -ForegroundColor Red
        foreach ($m in $mismatches) {
            Write-Host "   * Ma BOM goc  : $($m['ChildMaterialCode']) ($($m['BaseMaterialName']))" -ForegroundColor Yellow
            Write-Host "   * Ma thay the : $($m['DelegateCode']) ($($m['DelegateMaterialName']))" -ForegroundColor Red
            Write-Host "   * Nguyen nhan : Quy cach bi lech (5mm vs 10mm)! Kiosk POP se chan khong cho quet tem." -ForegroundColor Magenta
            Write-Host "   * Khac phuc   : Vao WinForm [A230] sua DelegateMaterialCode hoac bao IT hotfix STB_MaterialMaster." -ForegroundColor White
        }
        Write-Host "   +-------------------------------------------------------------------------------+" -ForegroundColor Red
    }
    
    $table | Format-Table -Property RouteCode, ChildMaterialCode, BaseMaterialName, UsedQty, DelegateCode, DelegateMaterialName, DelegateStatus -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
}

function Show-PoCard([System.Data.DataTable]$table) {
    if ($null -eq $table -or $table.Rows.Count -eq 0) {
        Write-Host "   [-] THONG TIN PO: Khong tim thay du lieu" -ForegroundColor DarkYellow
        return
    }
    $r = $table.Rows[0]
    $po = $r['PONo']
    $mat = $r['MaterialCode']
    $tot = $r['TotalLots']
    $fin = $r['FinishedLots']
    $inp = $r['InputLots']
    $def = $r['TotalDefects']
    $first = if ($r['FirstLotDate']) { ([datetime]$r['FirstLotDate']).ToString("dd/MM/yyyy HH:mm") } else { "N/A" }
    $last = if ($r['LastLotDate']) { ([datetime]$r['LastLotDate']).ToString("dd/MM/yyyy HH:mm") } else { "N/A" }
    $pct = if ($tot -gt 0) { [math]::Round(($fin / $tot) * 100, 1) } else { 0 }

    Write-Host ''
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|  [THONG TIN LENH SAN XUAT - PO DASHBOARD]                                     |" -ForegroundColor Cyan
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "   * Ma Don hang / PO     : " -NoNewline -ForegroundColor Gray
    Write-Host "$po" -ForegroundColor Green
    Write-Host "   * Ma San pham / Model  : " -NoNewline -ForegroundColor Gray
    Write-Host "$mat" -ForegroundColor Yellow
    Write-Host "   * Tong so Lot da tao   : " -NoNewline -ForegroundColor Gray
    Write-Host "$tot Lots" -ForegroundColor White
    Write-Host "   * Tien do hoan thanh   : " -NoNewline -ForegroundColor Gray
    Write-Host "$fin / $tot Lots ($pct%)" -ForegroundColor $(if ($fin -eq $tot) { "Green" } else { "Yellow" })
    Write-Host "   * So Lot da nap chuyen : " -NoNewline -ForegroundColor Gray
    Write-Host "$inp / $tot Lots" -ForegroundColor White
    Write-Host "   * Tong phe pham        : " -NoNewline -ForegroundColor Gray
    Write-Host "$def" -ForegroundColor $(if ([int]$def -gt 0) { "Red" } else { "Green" })
    Write-Host "   * Khoang thoi gian tao : " -NoNewline -ForegroundColor Gray
    Write-Host "$first -> $last" -ForegroundColor DarkGray
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
}

function Show-ModelCard([System.Data.DataTable]$table) {
    if ($null -eq $table -or $table.Rows.Count -eq 0) {
        Write-Host "   [-] THONG TIN MODEL: Khong tim thay du lieu" -ForegroundColor DarkYellow
        return
    }
    $r = $table.Rows[0]
    $mat = $r['MaterialCode']
    $pos = $r['TotalPOs']
    $lots = $r['TotalLots']
    $fin = $r['FinishedLots']
    $last = if ($r['LastActiveDate']) { ([datetime]$r['LastActiveDate']).ToString("dd/MM/yyyy HH:mm") } else { "N/A" }

    Write-Host ''
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|  [THONG TIN SAN PHAM / MODEL - STB_SetInfo]                                   |" -ForegroundColor Cyan
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "   * Ma San pham / Model  : " -NoNewline -ForegroundColor Gray
    Write-Host "$mat" -ForegroundColor Yellow
    Write-Host "   * Tong so PO da tao    : " -NoNewline -ForegroundColor Gray
    Write-Host "$pos Don hang" -ForegroundColor White
    Write-Host "   * Tong so Lot san xuat : " -NoNewline -ForegroundColor Gray
    Write-Host "$lots Lots" -ForegroundColor White
    Write-Host "   * So Lot da hoan thanh : " -NoNewline -ForegroundColor Gray
    Write-Host "$fin / $lots Lots" -ForegroundColor Green
    Write-Host "   * Hoat dong gan nhat   : " -NoNewline -ForegroundColor Gray
    Write-Host "$last" -ForegroundColor DarkGray
    Write-Host "+-------------------------------------------------------------------------------+" -ForegroundColor Cyan
}

if ($type -eq "PACKING") {
    Show-Table "1. LICH SU DONG GOI (STB_SavePackingTime_VVT)" $ds.Tables[0] "Yellow"
    Show-Table "2. DANH SACH LOT TRONG THUNG (STB_MaterialLotInfo)" $ds.Tables[1] "Cyan"
    Show-Table "3. LICH SU IN TEM THUNG (STB_PackingLabelPrintHist)" $ds.Tables[2] "Green"
    Show-Table "4. THANH PHAM DONG THUNG (STB_VN_FINISHGOODS)" $ds.Tables[3] "Magenta"
} elseif ($type -eq "EQUIPMENT") {
    Show-Table "1. CAU HINH SOCKET MAY (VINA_EQUIPMENT_SETTING)" $ds.Tables[0] "Yellow"
    Show-Table "2. DIEM MOC COUNTER PLC (VINA_PLC_BASELINE)" $ds.Tables[1] "Cyan"
    Show-Table "3. SO DU COUNTER THEO CA (VINA_EQUIPMENT_REMAINDER)" $ds.Tables[2] "Green"
    Show-Table "4. TRANG THAI GAN MAY KIOSK (VINA_EQUIPMENT_MAPPING)" $ds.Tables[3] "Magenta"
} elseif ($type -eq "LINE") {
    Show-Table "1. CHE DO VAN HANH LINE (VINA_ASSEMBLY_GROUP_MODE)" $ds.Tables[0] "Yellow"
    Show-Table "2. CAU HINH SLOT NAP NVL (VINA_GROUP_INPUT_ROUTE)" $ds.Tables[1] "Cyan"
    Show-Table "3. MAY DANG BI KHOA ACTIVE (VINA_EQUIPMENT_MAPPING)" $ds.Tables[2] "Red"
    Show-Table "4. CAC LOT DANG TAC NGHEN DONG BO (IsTransferred=0)" $ds.Tables[3] "Magenta"
} elseif ($type -eq "PO") {
    Show-PoCard $ds.Tables[0]
    Show-Table "DANH SACH CAC LOT THUOC PO (STB_SetInfo)" $ds.Tables[1] "Yellow"
} elseif ($type -eq "MODEL") {
    Show-ModelCard $ds.Tables[0]
    Show-Table "CAC PO GAN NHAT DANG SAN XUAT" $ds.Tables[1] "Yellow"
    Show-Table "CAC LOT GAN NHAT (STB_SetInfo)" $ds.Tables[2] "Cyan"
} else { # LOT
    if ($ds.Tables.Count -ge 10 -and $ds.Tables[9].Rows.Count -gt 0) {
        Show-QcCard $ds.Tables[9]
    }
    Show-LotCard $ds.Tables[0]
    Show-Table "2. TIEN DO CONG DOAN MES (STB_ProdRouteHist)" $ds.Tables[1] "Cyan"
    Show-Table "3. TRANG THAI POP KIOSK & DONG BO (MongoToMesPerformance)" $ds.Tables[2] "Green"
    Show-Table "4. THONG KE PHE PHAM (STB_DefectRepairInfo)" $ds.Tables[3] "Red"
    Show-BomCard $ds.Tables[4]
    Show-Table "5.2. LICH SU NVL DA NAP TREN KIOSK POP (STB_RawMaterialInputHist)" $ds.Tables[5] "Magenta"
    Show-Table "5.3. BTP HOAC THUNG DONG GOI (STB_MaterialLotInfo)" $ds.Tables[6] "DarkMagenta"
    Show-Table "6. MAY DANG GAN TREN CHUYEN (VINA_EQUIPMENT_MAPPING)" $ds.Tables[7] "Yellow"
    Show-Table "7. NHAT KY THAO TAC POP (VINA_POP_ACTION_LOG)" $ds.Tables[8] "Gray"
}

Write-Host ''
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "-> Hoan thanh truy vet 360 Do sieu toc trong: $($sw.ElapsedMilliseconds) ms (Single Round-Trip)" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

