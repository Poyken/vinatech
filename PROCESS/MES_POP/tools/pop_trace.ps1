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
} elseif ($t -match '^(V[VN]EP|VVMM|VNMD|VVMHY)') {
    $type = "EQUIPMENT"
} elseif ($t -match '^(VVC-|VVHYC-|TCX|ELECTRODE|MEA)') {
    $type = "LINE"
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "     [POP-TRACE 360°] TRUY VET SIEU TOC (SINGLE ROUND-TRIP)" -ForegroundColor Yellow
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
} else { # LOT / BARCODE / CONTROLNO
    $cmd.CommandText = @"
-- 1. STB_SetInfo
SELECT TOP 1 ControlNo, PONo, Barcode, MaterialCode, IsProdFinish, IsLineInput, DefectQty, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
WHERE Barcode = '$t' OR ControlNo = '$t';

-- 2. STB_ProdRouteHist
SELECT TOP 10 ProdRouteHistNo, ControlNo, RouteCode, WorkCenterCode, ProdQty, JobDate, ProdDateTime, CompleteRoute 
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) 
WHERE ControlNo = '$t' OR ControlNo = (SELECT TOP 1 ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$t') 
ORDER BY CreateDateTime DESC;

-- 3. MongoToMesPerformance (POP Sync)
SELECT TOP 10 DayPlanNo, Barcode, RouteCode, LineCode, MachineCode, TotalProdQty, TotalDefectQty, IsDone, IsTransferred, InsertDateTime, ModifyDateTime 
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
WHERE Barcode = '$t' OR Barcode = (SELECT TOP 1 Barcode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '$t') 
ORDER BY ModifyDateTime DESC;

-- 4. STB_DefectRepairInfo (Phế phẩm)
SELECT TOP 10 DefectSummaryNo, ControlNo, FindRouteCode, DefectCode, DefectQty, RepairQty, IsDelete, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_DefectRepairInfo WITH(NOLOCK) 
WHERE ControlNo = '$t' OR ControlNo = (SELECT TOP 1 ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$t') 
ORDER BY CreateDateTime DESC;

-- 5. STB_MaterialLotInfo (NVL / Box)
SELECT TOP 10 MaterialLotNo, LotNo, MaterialCode, PackingID, CurrentQty, InitialQty 
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) 
WHERE LotNo = '$t' OR MaterialLotNo = '$t' OR PackingID = '$t' 
   OR LotNo = (SELECT TOP 1 Barcode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '$t');

-- 6. VINA_EQUIPMENT_MAPPING (Thiết bị gán trên Kiosk)
SELECT TOP 10 MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPING_STATUS, MAPPED_AT 
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK) 
WHERE LINE_CODE IN (
    SELECT TOP 1 LineCode FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
    WHERE Barcode = '$t' OR Barcode = (SELECT TOP 1 Barcode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '$t')
) AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');

-- 7. VINA_POP_ACTION_LOG (Nhật ký POP Action)
SELECT TOP 5 SEQ, ACTION_TYPE, ACTION_NAME, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, LOT_NUMBER, QTY, RESULT_STATUS, ERROR_MESSAGE, WORKER_CODE, REG_DATE 
FROM VINATECH_POP.dbo.VINA_POP_ACTION_LOG WITH(NOLOCK) 
WHERE LOT_NUMBER = '$t' OR LOT_NUMBER = (SELECT TOP 1 Barcode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '$t') 
ORDER BY REG_DATE DESC;
"@
}

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$adapter.Fill($ds) | Out-Null
$conn.Close()
$sw.Stop()

# 2. RENDER KET QUA SIEU TOC
function Show-Table([string]$title, [System.Data.DataTable]$table, [string]$color = "Cyan") {
    Write-Host ''
    Write-Host ">>> $title ($($table.Rows.Count) ban ghi):" -ForegroundColor $color
    if ($table.Rows.Count -eq 0) {
        Write-Host "    (Khong co du lieu)" -ForegroundColor Gray
        return
    }
    $table | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
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
} else { # LOT
    Show-Table "1. THONG TIN LOT MES (STB_SetInfo)" $ds.Tables[0] "Yellow"
    Show-Table "2. TIEN DO CONG DOAN MES (STB_ProdRouteHist)" $ds.Tables[1] "Cyan"
    Show-Table "3. TRANG THAI POP KIOSK & DONG BO (MongoToMesPerformance)" $ds.Tables[2] "Green"
    Show-Table "4. THONG KE PHE PHAM (STB_DefectRepairInfo)" $ds.Tables[3] "Red"
    Show-Table "5. NVL NAP & THUNG DONG GOI (STB_MaterialLotInfo)" $ds.Tables[4] "Magenta"
    Show-Table "6. MAY DANG GAN TREN CHUYEN (VINA_EQUIPMENT_MAPPING)" $ds.Tables[5] "Yellow"
    Show-Table "7. NHAT KY THAO TAC POP (VINA_POP_ACTION_LOG)" $ds.Tables[6] "Gray"
}

Write-Host ''
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "-> Hoan thanh truy vet 360° sieu toc trong: $($sw.ElapsedMilliseconds) ms (Single Round-Trip)" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
