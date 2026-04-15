[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db     = "SmartFactoryV2"
$uid    = "vinaadmin"
$pwd    = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"
$outDir  = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\cellline_sps"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

# All SPs identified from CellLine.txt + screenshots
$targetSPs = @(
    # === B597 / B540 - Raw Material Input / Validation ===
    "usp_Vietnam_RawMaterialInputHist_uid",
    "usp_VietNam_RawMaterialInput_uid",
    "usp_RawMaterialInputHist_get",
    "usp_DoChangeMaterialDocLotInfo",
    "fn_VVT_getdatebyVendorLot",

    # === B523 - Packing / Gộp Box ===
    "usp_Vietnam_DoProcessProdPacking_VVT",
    "usp_Vietnam_PackingQtyPerSize_popup",
    "usp_Vietnam_GetBoxIDForLotNo_VVT",
    "usp_savePackingLabelQty_VVT",

    # === B450 - Kế hoạch sản xuất theo ngày ===
    "usp_DayProdPlan_get",
    "usp_SetInfo_get",
    "usp_DayProdPlan_iud",
    "usp_DoCancelDayProdPlan",
    "usp_DoFixDayProdPlan",
    "usp_DoFinishDayProdPlan",
    "usp_DoCreateSetInfoForProdCty_VNT",

    # === B530 - Nhập số lượng sản xuất ===
    "usp_GetProdRouteHistForBarcode_VNT",
    "usp_GetProdBarcodeForDefect_VNT",
    "usp_WasteWeight_get",
    "usp_DoProcessDefectRepairInfoByBarcode_SmartApp",
    "usp_DoProcessProdRouteHistForCalc_SmartApp_VNT",
    "usp_DoUpdateProdRouteHistMarkingLetter",
    "usp_DoUpdateDRIExtText02_iud",
    "usp_InternProdQtyInfo_iud",
    "usp_DoCreateTaktTimeForRoute",
    "usp_DoSplitLotAlignN",

    # === B540 - Assy Card Info ===
    "usp_AssyCardInfoCommon_get",
    "usp_AssyCardInfoProdQty_get",
    "usp_AssyCardInfoDivn_get",
    "usp_GetRawMaterialLotFwBarcode_VNT_SF",

    # === B452 - Vietnam Print Lot Changed ===
    "usp_Set_VVT_Info_get",
    "usp_Set_VVT_Info_iud",

    # === B717 - Bending & Tapping ===
    "usp_new_Tapping_VVT_get",
    "usp_STB_BENDING_TAPPING",
    "usp_new_Tapping_VVT_iud",
    "usp_MarkingLabelPrintHistVVT_iud",

    # === B882 - ANDON ===
    "usp_getAndon_v1",

    # === B726 / B791 - Scrap / Module Tracking ===
    "usp_vn_scrapafterproduction",
    "usp_ModuleLotTrackingInfo_VVT2_get",
    "fn_VVT_StagePricesMODULE",

    # === F110 / Warehouse ===
    "usp_VVT_checkHOLD_QC",
    "usp_VVT_checkFIFO_FinishGood",
    "usp_VN_Update_ExportExcel_BG",

    # === C141 / C143 - Inspection Setup ===
    "usp_CommonInspTypeItem_get",
    "usp_DoCommonInspTypeItem_ud",
    "usp_CommonInspIndividualSpec_get",
    "usp_CommonInspIndividualSpec_ud",

    # === A230 - Material Master ===
    "usp_MaterialMaster_get",
    "usp_MaterialMaster_ud",

    # === A410 - Model Basic Info ===
    "usp_ModelBasicInfo_get",
    "usp_ModelBasicInfo_ud",

    # === B310 - Production Order ===
    "usp_ProductionOrderInfo_get",
    "usp_GetMaterialGIForPO",
    "usp_ProductionOrderRouting_get",
    "usp_DraftProductionOrder",
    "usp_ProductionOrderRouting_iud",
    "usp_DoCenterPO"
)

$results = @{}

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Host "Connected to $server / $db" -ForegroundColor Green

    foreach ($sp in $targetSPs) {
        Write-Host "Fetching: $sp ..." -NoNewline
        $cmd = $conn.CreateCommand()
        # Try both PROCEDURE and FUNCTION
        $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.$sp')) AS def, OBJECT_ID('dbo.$sp') AS oid"
        $reader = $cmd.ExecuteReader()
        if ($reader.Read() -and $reader["def"] -ne [DBNull]::Value) {
            $def = $reader["def"].ToString()
            $fileName = "$outDir\$sp.sql"
            [System.IO.File]::WriteAllText($fileName, $def, [System.Text.Encoding]::UTF8)
            $results[$sp] = "OK ($(($def.Length/1024).ToString('F1')) KB)"
            Write-Host " OK ($([math]::Round($def.Length/1024,1)) KB)" -ForegroundColor Green
        } else {
            $results[$sp] = "NOT FOUND"
            Write-Host " NOT FOUND" -ForegroundColor Yellow
        }
        $reader.Close()
    }

    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}

# Summary report
Write-Host "`n=== EXPORT SUMMARY ===" -ForegroundColor Cyan
$found = 0; $notFound = 0
foreach ($sp in $targetSPs) {
    $status = $results[$sp]
    if ($status -eq "NOT FOUND") {
        Write-Host "  [MISS] $sp" -ForegroundColor Yellow
        $notFound++
    } else {
        Write-Host "  [OK]   $sp - $status" -ForegroundColor Green
        $found++
    }
}
Write-Host "`nTotal: $found found, $notFound not found" -ForegroundColor Cyan

# Save summary
$summary = "SP Export Summary - $(Get-Date)`n"
$summary += "=" * 60 + "`n"
foreach ($sp in $targetSPs) {
    $summary += "$($results[$sp].PadLeft(20)) | $sp`n"
}
[System.IO.File]::WriteAllText("$outDir\_export_summary.txt", $summary, [System.Text.Encoding]::UTF8)
Write-Host "`nSaved to: $outDir" -ForegroundColor Cyan
