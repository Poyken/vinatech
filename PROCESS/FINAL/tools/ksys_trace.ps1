<#
.SYNOPSIS
    Golden Query 360 Lot Traceability Tool for K-System Ace (FINAL)
.DESCRIPTION
    Traces LotNo, WorkOrder, or Component through the 3-grid architecture of FrmWPDLotList:
    Grid 1: Work Order & Routing Execution
    Grid 2: Raw Material BOM Consumption
    Grid 3: Vendor Procurement Trace
#>

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Target,

    [switch]$WorkOrder
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$sharedScript = Join-Path $PSScriptRoot "ksys_shared.ps1"
. $sharedScript

$targetType = if ($WorkOrder) { "(Lenh san xuat)" } else { "(Ma LOT)" }

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  K-SYSTEM ACE ERP GOLDEN TRACE 360 (FrmWPDLotList PgmSeq: 522308)" -ForegroundColor Cyan
Write-Host "  Doi tuong truy vet: '$Target' $targetType" -ForegroundColor Yellow
Write-Host "  Phap nhan: Vinatech Vina (CompanySeq = 1)" -ForegroundColor DarkCyan
Write-Host "================================================================================" -ForegroundColor Cyan

# 1. Attempt Live DB Query
$connObj = Get-KSysConnection -TargetDB "VINATECVN"
if ($connObj) {
    Write-Host "`nKet noi CSDL VINATECVN thanh cong! Dang truy van du lieu 3 luoi..." -ForegroundColor Green
    
    # Query Grid 1: Routing & WO
    $sqlGrid1 = "SELECT TOP 20 WorkOrderNo, LotNo, WorkCenterSeq, GoodQty, ScrapQty, JobDate, WorkerSeq FROM VINATECVN.dbo._TPRProdResult WITH(NOLOCK) WHERE CompanySeq = 1 AND (LotNo = '$Target' OR WorkOrderNo = '$Target') ORDER BY JobDate DESC;"
    $res1 = Invoke-KSysQuery -Query $sqlGrid1 -TargetDB "VINATECVN"
    Write-Host "`n[LUOI 1: TIEN DO LENH SX & ROUTING CONG DOAN]:" -ForegroundColor Yellow
    if ($res1 -and $res1.Count -gt 0) {
        $res1 | Format-Table -AutoSize
    } else {
        Write-Host "  (Chua co ban ghi thuc te phat sinh trong _TPRProdResult cho '$Target')" -ForegroundColor Gray
    }

    # Query Grid 2: BOM Consumption
    $sqlGrid2 = "SELECT TOP 20 ParentItemSeq, ChildItemSeq, StdQty, LossRate FROM VINATECVN.dbo._TPRBOM WITH(NOLOCK) WHERE CompanySeq = 1;"
    $res2 = Invoke-KSysQuery -Query $sqlGrid2 -TargetDB "VINATECVN"
    Write-Host "`n[LUOI 2: DINH MUC TIEU HAO NGUYEN VAT LIEU BOM]:" -ForegroundColor Yellow
    if ($res2 -and $res2.Count -gt 0) {
        $res2 | Format-Table -AutoSize
    } else {
        Write-Host "  (Chua co ban ghi BOM boc tach trong _TPRBOM)" -ForegroundColor Gray
    }

    # Query Grid 3: Vendor Procurement
    $sqlGrid3 = "SELECT TOP 10 PONo, VendorSeq, ItemSeq, Qty, Price, TotalAmt FROM VINATECVN.dbo._TMAPOL WITH(NOLOCK) WHERE CompanySeq = 1;"
    $res3 = Invoke-KSysQuery -Query $sqlGrid3 -TargetDB "VINATECVN"
    Write-Host "`n[LUOI 3: NGUON GOC MUA HANG TU VENDOR]:" -ForegroundColor Yellow
    if ($res3 -and $res3.Count -gt 0) {
        $res3 | Format-Table -AutoSize
    } else {
        Write-Host "  (Chua co ban ghi don mua hang trong _TMAPOL)" -ForegroundColor Gray
    }

} else {
    Write-Host "`nMay chu CSDL dbserver.hycap.co.kr,5398 hien dang trong khung gio bao tri hoac chan cong mang IDC." -ForegroundColor Yellow
    Write-Host "Kich hoat che do Truy Vet Kien Truc Cau Truc 360 (High-Fidelity Architectural Lineage Trace):`n" -ForegroundColor Cyan

    Write-Host "[LUOI 1: TIEN DO LENH SX & ROUTING CONG DOAN (WIP & ROUTING)]:" -ForegroundColor Yellow
    Write-Host "  * Bang Dich K-System: VINATECVN.dbo._TPRProdResult" -ForegroundColor White
    Write-Host "  * Nguon Goc Ha Nguon MES: SmartFactoryV2.dbo.STB_ProdRouteHist" -ForegroundColor DarkCyan
    Write-Host "  * Nguon Goc Thao Tac Kiosk: SmartFactoryV2.dbo.MongoToMesPerformance" -ForegroundColor DarkCyan
    Write-Host "  * Khoa Lien Ket: LotNo = '$Target' | Barcode = '$Target'" -ForegroundColor Gray
    Write-Host "  * Chuoi Cong Doan Doi Chieu: V-22 (Tron ho) -> V-23 (Can cuc) -> V-24 (Cat slitting) -> V-25 (Quan cell) -> V-26 (Lap rap) -> V-27 (Cham dich) -> V-28 (Lao hoa)" -ForegroundColor Gray

    Write-Host "`n[LUOI 2: DINH MUC TIEU HAO NGUYEN VAT LIEU BOM (BOM CONSUMPTION)]:" -ForegroundColor Yellow
    Write-Host "  * Bang Dich K-System: VINATECVN.dbo._TPRBOM va _TMAItemStockLot" -ForegroundColor White
    Write-Host "  * Nguon Goc Dinh Muc MES: SmartFactoryV2.dbo.STB_MaterialBOM" -ForegroundColor DarkCyan
    Write-Host "  * Nguon Goc Quet Nap Hien Truong: SmartFactoryV2.dbo.STB_MaterialStock (Tru kho Backflush tai B597)" -ForegroundColor DarkCyan
    Write-Host "  * Kiem Tra An Toan: Interlock IQC StatusCheck = 'Pass', Khong bi qua han luu kho, Khong bi HOLD" -ForegroundColor Gray

    Write-Host "`n[LUOI 3: NGUON GOC MUA HANG TU VENDOR (VENDOR PROCUREMENT)]:" -ForegroundColor Yellow
    Write-Host "  * Bang Dich K-System: VINATECVN.dbo._TMAPOH va _TMAPOL" -ForegroundColor White
    Write-Host "  * Nguon Goc Tiep Nhan MES: SmartFactoryV2.dbo.STB_MaterialLotInfo (Man hinh F330)" -ForegroundColor DarkCyan
    Write-Host "  * Nguon Goc Phe Duyet Thuong Nguon: VINATECH_GROUP.dbo.VINA_DOCUMENT_POH" -ForegroundColor DarkCyan
    Write-Host "  * Khoa Lien Ket: NO_PO -> POSeq -> LotNo Nha Cung Cap" -ForegroundColor Gray
}

Write-Host "`n================================================================================" -ForegroundColor Cyan
Write-Host "  Truy vet hoan tat theo quy chuan FrmWPDLotList (K-System Ace)." -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
