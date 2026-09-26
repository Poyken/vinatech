# ==============================================================================
# inspect_pack.ps1 — 360° Comprehensive Packaging & PackingID Investigator
# Tables: STB_MaterialLotInfo | STB_DividePackaging | STB_SavePackingTime_VVT
#         STB_PackingLabelPrintHist | stb_MergeBoxReality | VINA_PACKING_REMAIN_QTY
# Tối ưu hóa 1-Shot (<1s), triệt tiêu nhu cầu chạy SELECT dò dẫm
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Target
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$t = $Target.Trim()
if ([string]::IsNullOrWhiteSpace($t)) {
    Write-Host "Loi: Vui long nhap ma can kiem tra dong goi (LotNo, Barcode hoac PackingID)!" -ForegroundColor Red
    Write-Host "Vi du: .\mes.ps1 pack 'VVQR232R710618'" -ForegroundColor Yellow
    Write-Host "       .\mes.ps1 pack 'PKQR2501480'" -ForegroundColor Yellow
    exit 1
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '     [PACK-INVESTIGATOR 360] TRUY VET DONG GOI & IN TEM PACKING' -ForegroundColor Yellow
Write-Host "     Doi tuong: $t | Pham vi: SmartFactoryV2 & VINATECH_POP" -ForegroundColor White
Write-Host '======================================================================' -ForegroundColor Cyan

$conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
if (-not $conn) {
    Write-Host "LOI: Khong the ket noi CSDL SmartFactoryV2!" -ForegroundColor Red
    exit 1
}

try {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
SET NOCOUNT ON;

DECLARE @Target VARCHAR(50) = '$t';
DECLARE @LotNo VARCHAR(50) = @Target;
DECLARE @PackingID VARCHAR(50) = @Target;

-- 0. Nhan dien doi tuong
IF @Target LIKE 'PK%'
BEGIN
    SELECT TOP 1 @LotNo = LotNo FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE PackingID = @Target;
    IF @LotNo IS NULL
        SELECT TOP 1 @LotNo = LotNo FROM SmartFactoryV2.dbo.STB_SavePackingTime_VVT WITH(NOLOCK) WHERE PackingID = @Target;
END
ELSE
BEGIN
    SELECT TOP 1 @PackingID = PackingID FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = @Target OR MaterialLotNo = @Target;
    IF @PackingID IS NULL
        SELECT TOP 1 @PackingID = PackingID FROM SmartFactoryV2.dbo.STB_SavePackingTime_VVT WITH(NOLOCK) WHERE LotNo = @Target;
END

-- 1. STB_SetInfo (Thong tin Lot goc)
SELECT TOP 1 
    ControlNo, 
    PONo, 
    Barcode, 
    MaterialCode, 
    IsProdFinish, 
    IsLineInput, 
    DefectQty, 
    CreateDateTime
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE Barcode = @LotNo OR ControlNo = @LotNo;

-- 2. STB_MaterialLotInfo (Thung / Box luu kho thanh pham)
SELECT TOP 10 
    MaterialLotNo, 
    LotNo, 
    MaterialCode, 
    PackingID, 
    CurrentQty, 
    InitialQty, 
    CreateUserID, 
    CreateDateTime, 
    ChangeUserID, 
    ChangeDateTime
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotNo = @LotNo 
   OR MaterialLotNo = @Target 
   OR (@Target LIKE 'PK%' AND PackingID = @Target) 
   OR (@PackingID IS NOT NULL AND @PackingID <> '' AND PackingID = @PackingID)
ORDER BY CreateDateTime DESC;

-- 3. STB_SavePackingTime_VVT (Thoi gian dong goi & ma tem in)
SELECT TOP 10 
    PackingID, 
    LotNo, 
    MaterialCode, 
    PackQty, 
    PrintTime, 
    EmpNo, 
    isPrinted, 
    LableQty
FROM SmartFactoryV2.dbo.STB_SavePackingTime_VVT WITH(NOLOCK)
WHERE LotNo = @LotNo 
   OR (@Target LIKE 'PK%' AND PackingID = @Target) 
   OR (@PackingID IS NOT NULL AND @PackingID <> '' AND PackingID = @PackingID)
ORDER BY id DESC;

-- 4. STB_PackingLabelPrintHist (Lich su in tem dong goi)
SELECT TOP 10 
    PackingID, 
    PrintCount, 
    IsPrintAllow, 
    CreateDateTime, 
    CreateUserID, 
    ChangeDateTime, 
    ChangeUserID
FROM SmartFactoryV2.dbo.STB_PackingLabelPrintHist WITH(NOLOCK)
WHERE (@Target LIKE 'PK%' AND PackingID = @Target) 
   OR (@PackingID IS NOT NULL AND @PackingID <> '' AND PackingID = @PackingID)
ORDER BY CreateDateTime DESC;

-- 5. STB_DividePackaging (Chia tach hop / thung con B523)
SELECT TOP 10 
    DividePackagingID, 
    PackingID, 
    LotNo, 
    Qty, 
    MaterialCode, 
    TypeBox, 
    IsSmailBox, 
    IsNilonlBox, 
    CreateDateTime, 
    CreateUserID
FROM SmartFactoryV2.dbo.STB_DividePackaging WITH(NOLOCK)
WHERE LotNo = @LotNo 
   OR (@Target LIKE 'PK%' AND PackingID = @Target) 
   OR (@PackingID IS NOT NULL AND @PackingID <> '' AND PackingID = @PackingID)
ORDER BY CreateDateTime DESC;

-- 6. stb_MergeBoxReality (Gop thung thuc te)
SELECT TOP 10 
    ParentLotNo, 
    ControlNo, 
    PONo, 
    ChildLotNo, 
    BoxQty, 
    CreateDateTime, 
    MergeNumber, 
    WorkerCode
FROM SmartFactoryV2.dbo.stb_MergeBoxReality WITH(NOLOCK)
WHERE ParentLotNo = @LotNo OR ChildLotNo = @LotNo OR ParentLotNo = @Target OR ChildLotNo = @Target
ORDER BY CreateDateTime DESC;

-- 7. Quy cach dong goi tieu chuan cua Model (MaterialMaster)
SELECT TOP 1 
    MM.MaterialCode, 
    MM.MaterialName, 
    MM.BasicPackingQty
FROM SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK)
WHERE MM.MaterialCode IN (
    SELECT MaterialCode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = @LotNo OR ControlNo = @LotNo
    UNION
    SELECT MaterialCode FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = @LotNo OR PackingID = @Target
);

-- 8. Tien do dong goi POP Kiosk (VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY)
SELECT TOP 5 
    DAY_PLAN_NO, 
    BARCODE, 
    ROUTE_CODE, 
    TOTAL_PROD_QTY, 
    PACKED_QTY, 
    REMAIN_QTY, 
    REG_DATE
FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY WITH(NOLOCK)
WHERE BARCODE = @LotNo
ORDER BY REG_DATE DESC;
"@

    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $null = $da.Fill($ds)

    $t0 = $ds.Tables[0] # SetInfo
    $t1 = $ds.Tables[1] # MaterialLotInfo
    $t2 = $ds.Tables[2] # SavePackingTime_VVT
    $t3 = $ds.Tables[3] # PackingLabelPrintHist
    $t4 = $ds.Tables[4] # DividePackaging
    $t5 = $ds.Tables[5] # MergeBoxReality
    $t6 = $ds.Tables[6] # MaterialMaster
    $t7 = $ds.Tables[7] # VINA_PACKING_REMAIN_QTY

    # 1. SETINFO
    Write-Host ''
    Write-Host '--- 1. Thong Tin Lot San Xuat (STB_SetInfo) ---' -ForegroundColor Magenta
    if ($t0.Rows.Count -gt 0) {
        $t0 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    } else {
        Write-Host "  (Khong tim thay Lot trong STB_SetInfo)" -ForegroundColor Gray
    }

    # 2. MATERIALLOTINFO
    Write-Host '--- 2. Tuan Thu Kho & PackingID (STB_MaterialLotInfo) ---' -ForegroundColor Magenta
    if ($t1.Rows.Count -gt 0) {
        $t1 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    } else {
        Write-Host "  (Chua co dong STB_MaterialLotInfo - Lot chua duoc tao thung/box thanh pham)" -ForegroundColor Yellow
    }

    # 3. SAVEPACKINGTIME
    Write-Host '--- 3. Thoi Gian Dong Goi & Trang Thai In Tem (STB_SavePackingTime_VVT) ---' -ForegroundColor Magenta
    if ($t2.Rows.Count -gt 0) {
        $t2 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    } else {
        Write-Host "  (Chua ghi nhan dong goi trong STB_SavePackingTime_VVT)" -ForegroundColor Yellow
    }

    # 4. PRINT HIST
    Write-Host '--- 4. Lich Su In Tem Packing (STB_PackingLabelPrintHist) ---' -ForegroundColor Magenta
    if ($t3.Rows.Count -gt 0) {
        $t3 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    } else {
        Write-Host "  (Chua co lich su in tem trong STB_PackingLabelPrintHist)" -ForegroundColor Gray
    }

    # 5. DIVIDE PACKAGING
    if ($t4.Rows.Count -gt 0) {
        Write-Host '--- 5. Chia Tach Hop / Thung (STB_DividePackaging) ---' -ForegroundColor Magenta
        $t4 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    }

    # 6. MERGE BOX
    if ($t5.Rows.Count -gt 0) {
        Write-Host '--- 6. Gop Thung Thuc Te (stb_MergeBoxReality) ---' -ForegroundColor Magenta
        $t5 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    }

    # 7. STANDARD QTY
    if ($t6.Rows.Count -gt 0) {
        Write-Host '--- 7. Quy Cach Dong Goi Chuan (STB_MaterialMaster) ---' -ForegroundColor DarkCyan
        $t6 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    }

    # 8. POP REMAIN
    if ($t7.Rows.Count -gt 0) {
        Write-Host '--- 8. Tien Do Dong Goi Tren Kiosk POP (VINA_PACKING_REMAIN_QTY) ---' -ForegroundColor Magenta
        $t7 | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
    }

    # DIAGNOSTIC CONCLUSION
    Write-Host ''
    Write-Host '======================================================================' -ForegroundColor Cyan
    Write-Host '                [CHAN DOAN & ROOT CAUSE DONG GOI]' -ForegroundColor Yellow
    Write-Host '======================================================================' -ForegroundColor Cyan

    $hasMatLot = ($t1.Rows.Count -gt 0)
    $hasPackTime = ($t2.Rows.Count -gt 0)
    $hasPrintHist = ($t3.Rows.Count -gt 0)

    $currentPackingId = $null
    if ($hasMatLot) { $currentPackingId = $t1.Rows[0]['PackingID'] }
    if (-not $currentPackingId -and $hasPackTime) { $currentPackingId = $t2.Rows[0]['PackingID'] }

    if ([string]::IsNullOrWhiteSpace($currentPackingId)) {
        Write-Host '  [CANH BAO]: Lot CHUA DUOC GAN PackingID!' -ForegroundColor Red
        Write-Host '  -> Nguyen nhan: Cong doan dong goi (B523 hoac POP Web) chua sinh ma PackingID.' -ForegroundColor Yellow
        Write-Host '  -> Huong xu ly: Thuc hien dong goi tren Kiosk POP hoac WinForm B523 de he thong tu dong sinh PackingID.' -ForegroundColor Gray
    } else {
        Write-Host "  -> PackingID hien tai: $currentPackingId" -ForegroundColor Green
        if ($hasPackTime) {
            $isPrinted = $t2.Rows[0]['isPrinted']
            $printTime = $t2.Rows[0]['PrintTime']
            Write-Host "  -> Trang thai in (STB_SavePackingTime_VVT): isPrinted = $isPrinted | PrintTime = $printTime" -ForegroundColor Cyan
        }
        if ($hasPrintHist) {
            $printCount = $t3.Rows[0]['PrintCount']
            $allow = $t3.Rows[0]['IsPrintAllow']
            Write-Host "  -> Lich su in tem (STB_PackingLabelPrintHist): PrintCount = $printCount | IsPrintAllow = $allow" -ForegroundColor Cyan
            if ($allow -eq '0' -or $allow -eq 'N') {
                Write-Host '  [CHU Y]: Co IsPrintAllow dang bi khoa, co the gay chan in tem!' -ForegroundColor Yellow
            }
        }
    }

} catch {
    Write-Host "LOI THUC THI: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    $conn.Close()
}

$sw.Stop()
Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "  Hoan tat truy vet dong goi trong: $([Math]::Round($sw.Elapsed.TotalSeconds, 2))s" -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
