<#
.SYNOPSIS
    Truy vet huyet mach du lieu xuyen suot 5 he thong (Cross-System 360 Lineage Tracer).
.DESCRIPTION
    Lien ket du lieu giua Groupware -> ERP Douzone iU -> MES SmartFactoryV2 -> POP -> AndonDB.
#>
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("LOT", "BARCODE", "PO", "WO", "ITEM")]
    [string]$Type,

    [Parameter(Mandatory=$true, Position=0)]
    [string]$Value
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  CROSS-SYSTEM 360 DATA LINEAGE TRACER" -ForegroundColor Cyan
Write-Host "  Search Type: $Type | Target Value: $Value" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$cleanVal = $Value.Replace("'", "''")

# -----------------------------------------------------------------------------
# 1. TRỤ CỘT 1: GROUPWARE ELECTRONIC APPROVAL (VINATECH_GROUP)
# -----------------------------------------------------------------------------
Write-Host "[PILLAR 1: GROUPWARE ELECTRONIC APPROVAL (VINATECH_GROUP)]" -ForegroundColor Yellow
try {
    $gwQuery = switch ($Type) {
        "PO"      { "SELECT TOP 5 DOCUMENT_SAVE_CODE, NO_PO, CD_COMPANY, CD_PARTNER, DT_PO, CD_PURGRP, CD_TPPO FROM VINA_DOCUMENT_POH WITH(NOLOCK) WHERE NO_PO LIKE '%$cleanVal%'" }
        "ITEM"    { "SELECT TOP 5 l.DOCUMENT_SAVE_CODE, l.CD_ITEM, l.QT_PO, l.UM, l.AM, h.NO_PO FROM VINA_DOCUMENT_POL l WITH(NOLOCK) JOIN VINA_DOCUMENT_POH h WITH(NOLOCK) ON l.DOCUMENT_SAVE_CODE = h.DOCUMENT_SAVE_CODE WHERE l.CD_ITEM LIKE '%$cleanVal%'" }
        "WO"      { "SELECT TOP 5 DOCUMENT_SAVE_CODE, DOCUMENT_TITLE, USER_NAME, CREATE_DATE FROM VINA_DOCUMENT_APPROVAL_SAVE WITH(NOLOCK) WHERE DOCUMENT_TITLE LIKE '%$cleanVal%'" }
        default   { $null }
    }

    if ($gwQuery) {
        $gwRes = Invoke-SafeSelect -Query $gwQuery -Profile "Groupware" -MaxRows 5
        if ($gwRes.Success -and $gwRes.RowCount -gt 0) {
            Write-Host "  -> Tim thay $($gwRes.RowCount) ban ghi trong Groupware:" -ForegroundColor Green
            $gwRes.Data | Format-Table -AutoSize
        } else {
            Write-Host "  -> Khong tim thay ban ghi phu hop trong Groupware." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  -> Bo qua tim kiem Groupware cho kieu truy van: $Type" -ForegroundColor DarkGray
    }
} catch {
    Write-Warning "Loi truy van Groupware: $($_.Exception.Message)"
}

# -----------------------------------------------------------------------------
# 2. TRỤ CỘT 2: ERP DOUZONE iU SỔ CÁI DOANH NGHIỆP (NEOE)
# -----------------------------------------------------------------------------
Write-Host "`n[PILLAR 2: ERP DOUZONE iU MASTER & ORDERS (NEOE)]" -ForegroundColor Yellow
try {
    $erpQuery = switch ($Type) {
        "PO"      { "SELECT TOP 5 CD_COMPANY, NO_PO, CD_PLANT, CD_PARTNER, DT_PO, CD_PURGRP, AM FROM NEOE.PU_POH WITH(NOLOCK) WHERE NO_PO LIKE '%$cleanVal%'" }
        "WO"      { "SELECT TOP 5 CD_COMPANY, NO_WO, CD_PLANT, CD_ITEM, QT_ITEM, NO_LOT, ST_WO, DT_REL, DT_DUE FROM NEOE.PR_WO WITH(NOLOCK) WHERE NO_WO LIKE '%$cleanVal%'" }
        "ITEM"    { "SELECT TOP 5 CD_COMPANY, CD_ITEM, NM_ITEM, CLS_ITEM, CD_ZONE, UNIT_IM FROM NEOE.MA_PITEM WITH(NOLOCK) WHERE CD_ITEM LIKE '%$cleanVal%'" }
        "LOT"     { "SELECT TOP 5 CD_COMPANY, NO_WO, CD_PLANT, CD_ITEM, QT_ITEM, NO_LOT, ST_WO FROM NEOE.PR_WO WITH(NOLOCK) WHERE NO_LOT LIKE '%$cleanVal%'" }
        default   { $null }
    }

    if ($erpQuery) {
        $erpRes = Invoke-SafeSelect -Query $erpQuery -Profile "ERP" -MaxRows 5
        if ($erpRes.Success -and $erpRes.RowCount -gt 0) {
            Write-Host "  -> Tim thay $($erpRes.RowCount) ban ghi trong ERP NEOE:" -ForegroundColor Green
            $erpRes.Data | Format-Table -AutoSize
        } else {
            Write-Host "  -> Khong tim thay ban ghi phu hop trong ERP NEOE." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  -> Bo qua tim kiem ERP cho kieu truy van: $Type" -ForegroundColor DarkGray
    }
} catch {
    Write-Warning "Loi truy van ERP NEOE: $($_.Exception.Message)"
}

# -----------------------------------------------------------------------------
# 3. TRỤ CỘT 3: NHÀ XƯỞNG MES SẢN XUẤT (SmartFactoryV2)
# -----------------------------------------------------------------------------
Write-Host "`n[PILLAR 3: MES PRODUCTION & ROUTING (SmartFactoryV2)]" -ForegroundColor Yellow
try {
    # 3.1 Day Plan
    $planQuery = switch ($Type) {
        "WO"      { "SELECT TOP 5 DayPlanNo, CompanyCode, WorkCenterCode, PONo, MaterialCode, PlanQty, PlanDate, IsFixed FROM STB_DayProdPlan WITH(NOLOCK) WHERE PONo LIKE '%$cleanVal%'" }
        "PO"      { "SELECT TOP 5 DayPlanNo, CompanyCode, WorkCenterCode, PONo, MaterialCode, PlanQty, PlanDate FROM STB_DayProdPlan WITH(NOLOCK) WHERE PONo LIKE '%$cleanVal%'" }
        "ITEM"    { "SELECT TOP 5 DayPlanNo, PONo, MaterialCode, LineCode, PlanQty, PlanDate FROM STB_DayProdPlan WITH(NOLOCK) WHERE MaterialCode LIKE '%$cleanVal%'" }
        default   { $null }
    }

    if ($planQuery) {
        $planRes = Invoke-SafeSelect -Query $planQuery -Profile "SmartFactoryV2" -MaxRows 5
        if ($planRes.Success -and $planRes.RowCount -gt 0) {
            Write-Host "  -> STB_DayProdPlan (Ke hoach ngay):" -ForegroundColor Green
            $planRes.Data | Format-Table -AutoSize
        }
    }

    # 3.2 SetInfo / Lot / Barcode
    $setQuery = switch ($Type) {
        "LOT"     { "SELECT TOP 5 ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, LotNumber, CurrentRouteCode, ProdQty, DefectQty, IsProdFinish, CreateDateTime FROM STB_SetInfo WITH(NOLOCK) WHERE LotNumber LIKE '%$cleanVal%'" }
        "BARCODE" { "SELECT TOP 5 ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, LotNumber, CurrentRouteCode, ProdQty, DefectQty, IsProdFinish, CreateDateTime FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$cleanVal'" }
        "WO"      { "SELECT TOP 5 ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, LotNumber, CurrentRouteCode, ProdQty FROM STB_SetInfo WITH(NOLOCK) WHERE PONo LIKE '%$cleanVal%'" }
        "ITEM"    { "SELECT TOP 5 ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, LotNumber, CurrentRouteCode, ProdQty FROM STB_SetInfo WITH(NOLOCK) WHERE MaterialCode LIKE '%$cleanVal%'" }
        default   { $null }
    }

    if ($setQuery) {
        $setRes = Invoke-SafeSelect -Query $setQuery -Profile "SmartFactoryV2" -MaxRows 5
        if ($setRes.Success -and $setRes.RowCount -gt 0) {
            Write-Host "  -> STB_SetInfo (Theo doi Lot & Cong doan):" -ForegroundColor Green
            $setRes.Data | Format-Table -AutoSize
        } else {
            Write-Host "  -> Khong tim thay trong STB_SetInfo." -ForegroundColor DarkGray
        }
    }
} catch {
    Write-Warning "Loi truy van SmartFactoryV2: $($_.Exception.Message)"
}

# -----------------------------------------------------------------------------
# 4. TRỤ CỘT 4: POP SHOP FLOOR & TELEMETRY (VINATECH_POP)
# -----------------------------------------------------------------------------
Write-Host "`n[PILLAR 4: SHOP FLOOR EXECUTION & LOGS (VINATECH_POP)]" -ForegroundColor Yellow
try {
    $popQuery = switch ($Type) {
        "LOT"     { "SELECT TOP 5 * FROM VINA_PROD_LOG WITH(NOLOCK) WHERE LOT_NO LIKE '%$cleanVal%'" }
        "BARCODE" { "SELECT TOP 5 * FROM VINA_PROD_LOG WITH(NOLOCK) WHERE BARCODE LIKE '%$cleanVal%'" }
        default   { $null }
    }

    if ($popQuery) {
        $popRes = Invoke-SafeSelect -Query $popQuery -Profile "POP" -MaxRows 5
        if ($popRes.Success -and $popRes.RowCount -gt 0) {
            Write-Host "  -> VINA_PROD_LOG (Thuc thi tai Kiosk POP):" -ForegroundColor Green
            $popRes.Data | Format-Table -AutoSize
        } else {
            Write-Host "  -> Khong tim thay log POP phu hop." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  -> Bo qua tim kiem POP cho kieu truy van: $Type" -ForegroundColor DarkGray
    }
} catch {
    Write-Warning "Loi truy van VINATECH_POP: $($_.Exception.Message)"
}

Write-Host "================================================================================" -ForegroundColor Cyan
