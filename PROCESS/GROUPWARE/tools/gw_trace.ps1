# ==============================================================================
# gw_trace.ps1 — Golden Query 360 Multi-System Tracer for Vinatech Groupware
# Tracks: Document Code / PO Number / Employee ID / Item Code
# Cross-System: VINATECH_GROUP -> NEOE (ERP) -> SmartFactoryV2 (MES)
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Target
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ('     [TRACE 360] GROUPWARE GOLDEN QUERY TRACER: ' + $Target) -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan

# 1. TRUY VET TREN CSDL GROUPWARE (VINATECH_GROUP)
Write-Host ''
Write-Host '[1/3] Kiem tra tren Groupware (VINATECH_GROUP)...' -ForegroundColor Green

# 1.1 Kiem tra VINA_DOCUMENT_SAVE
$sqlDoc = "SELECT TOP 5 DOCUMENT_SAVE_CODE, DOCUMENT_TYPE_ID, DOCUMENT_SAVE_STATE, NO_EMP_WRITER, CD_COMPANY_WRITER, DOCUMENT_SAVE_SUBJECT, CONVERT(varchar(19), DOCUMENT_SAVE_REG_DATE, 120) AS REG_DATE FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE WITH (NOLOCK) WHERE DOCUMENT_SAVE_CODE LIKE '%$Target%' OR NO_EMP_WRITER = '$Target' OR DOCUMENT_SAVE_SUBJECT LIKE '%$Target%' ORDER BY DOCUMENT_SAVE_REG_DATE DESC;"

$docs = Invoke-DbQuery -Profile 'Groupware' -Query $sqlDoc
if ($docs -and $docs.Rows.Count -gt 0) {
    Write-Host ('-> Tim thay ' + $docs.Rows.Count + ' van ban phu hop:') -ForegroundColor Yellow
    $docs.DefaultView | Format-Table -AutoSize
} else {
    Write-Host '-> Khong tim thay ban ghi phu hop trong VINA_DOCUMENT_SAVE.' -ForegroundColor Gray
}

# 1.2 Kiem tra VINA_DOCUMENT_POH (neu Target co the la PO)
$sqlPO = "SELECT TOP 5 H.DOCUMENT_SAVE_CODE, H.NO_PO, H.CD_PARTNER, H.CD_COMPANY, CONVERT(varchar(10), H.DT_PO, 120) AS DT_PO, H.CD_EXCH, H.RT_EXCH, H.RT_VAT, S.DOCUMENT_SAVE_STATE FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POH H WITH (NOLOCK) LEFT JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE S WITH (NOLOCK) ON H.DOCUMENT_SAVE_CODE = S.DOCUMENT_SAVE_CODE WHERE H.NO_PO LIKE '%$Target%' OR H.DOCUMENT_SAVE_CODE LIKE '%$Target%' ORDER BY H.DT_PO DESC;"

$poRows = Invoke-DbQuery -Profile 'Groupware' -Query $sqlPO
if ($poRows -and $poRows.Rows.Count -gt 0) {
    Write-Host ''
    Write-Host '-> Chi tiet Don Mua Hang (PO) tren Groupware:' -ForegroundColor Yellow
    $poRows.DefaultView | Format-Table -AutoSize

    $docCode = $poRows.Rows[0]['DOCUMENT_SAVE_CODE']
    $sqlLines = "SELECT TOP 10 NO_POLINE, CD_ITEM, QT_PO, UM_EX, AM_EX, AM, DT_LIMIT, CD_SL FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POL WITH (NOLOCK) WHERE DOCUMENT_SAVE_CODE = '$docCode' ORDER BY NO_POLINE ASC;"
    $lines = Invoke-DbQuery -Profile 'Groupware' -Query $sqlLines
    if ($lines -and $lines.Rows.Count -gt 0) {
        Write-Host '-> Danh sach mat hang chi tiet (Lines):' -ForegroundColor Cyan
        $lines.DefaultView | Format-Table -AutoSize
    }
}

# 1.3 Kiem tra VINA_EMP (neu Target co the la Nhan vien)
$sqlEmp = "SELECT TOP 5 NO_EMP, CD_COMPANY, EMP_ADMIN, EMP_SYSTEM_ADMIN, EMP_STOP, DT_ENTER_LEAVE FROM VINATECH_GROUP.dbo.VINA_EMP WITH (NOLOCK) WHERE NO_EMP = '$Target';"
$empRows = Invoke-DbQuery -Profile 'Groupware' -Query $sqlEmp
if ($empRows -and $empRows.Rows.Count -gt 0) {
    Write-Host ''
    Write-Host '-> Thong tin Nhan su tren Groupware:' -ForegroundColor Yellow
    $empRows.DefaultView | Format-Table -AutoSize
}

# 2. TRUY VET TREN CSDL ERP (NEOE)
Write-Host ''
Write-Host '[2/3] Kiem tra tren Douzone ERP (NEOE)...' -ForegroundColor Green
$sqlErpPO = "SELECT TOP 5 NO_PO, CD_COMPANY, CD_PARTNER, DT_PO, CD_PURGRP, NO_EMP, CD_TPPO FROM NEOE.NEOE.PU_POH WITH (NOLOCK) WHERE NO_PO LIKE '%$Target%' ORDER BY DT_PO DESC;"
try {
    $erpPO = Invoke-DbQuery -Profile 'ERP' -Query $sqlErpPO
    if ($erpPO -and $erpPO.Rows.Count -gt 0) {
        Write-Host '-> [DONG BO ERP: THANH CONG] Tim thay don mua tren ERP NEOE:' -ForegroundColor Green
        $erpPO.DefaultView | Format-Table -AutoSize
    } else {
        Write-Host '-> Khong tim thay don PO tuong ung tren ERP NEOE.' -ForegroundColor Gray
    }
} catch {
    Write-Host '-> Khong the ket noi toi ERP NEOE hoac bang PU_POH khong co du lieu.' -ForegroundColor Gray
}

# 3. TRUY VET TREN CSDL MES (SmartFactoryV2)
Write-Host ''
Write-Host '[3/3] Kiem tra tren NAIS MES (SmartFactoryV2)...' -ForegroundColor Green
$sqlMesPO = "SELECT TOP 5 PONo, CompanyCode, WorkCenterCode, PlanYearMonth, MaterialCode, BomVersion FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH (NOLOCK) WHERE PONo LIKE '%$Target%' OR MaterialCode LIKE '%$Target%' ORDER BY PlanYearMonth DESC;"
try {
    $mesPO = Invoke-DbQuery -Profile 'SmartFactoryV2' -Query $sqlMesPO
    if ($mesPO -and $mesPO.Rows.Count -gt 0) {
        Write-Host '-> [DONG BO MES: THANH CONG] Tim thay thong tin tren MES STB_ProductionOrderInfo:' -ForegroundColor Green
        $mesPO.DefaultView | Format-Table -AutoSize
    } else {
        Write-Host '-> Khong tim thay ban ghi tuong ung tren MES SmartFactoryV2.' -ForegroundColor Gray
    }
} catch {
    Write-Host '-> Khong the truy van SmartFactoryV2.' -ForegroundColor Gray
}

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '                     KET THUC TRUY VET 360' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
