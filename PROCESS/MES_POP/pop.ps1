# ==============================================================================
# pop.ps1 — VINATECH POP KIOSK UNIFIED CLI HUB (v2.0)
# Trung Tam Dieu Phoi Van Hanh, Nap NVL BOM & Su Co Kiosk POP Tai Xuong
# Author: vanduc (EA Team)
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',
    
    [Parameter(Position = 1)]
    [string]$Target = '',
    
    [string]$Line = '',
    [string]$Machine = '',
    [string]$Route = '',
    [switch]$Deploy,
    [switch]$Force,
    [switch]$Detail,
    [switch]$Clean
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$scriptDir = $PSScriptRoot
$toolsDir = Join-Path $scriptDir 'tools'
. (Join-Path $toolsDir 'db_shared.ps1')

function Show-PopBanner {
    Write-Host ''
    Write-Host '======================================================================' -ForegroundColor Cyan
    Write-Host '             VINATECH POP KIOSK UNIFIED CLI HUB (v2.0)' -ForegroundColor Yellow
    Write-Host '    Trung Tam Dieu Phoi Van Hanh, Nap NVL BOM & Su Co Kiosk POP' -ForegroundColor White
    Write-Host '======================================================================' -ForegroundColor Cyan
}

function Show-Help {
    Show-PopBanner
    Write-Host ''
    Write-Host 'CAC LENH VAN HANH POP KIOSK CHINH:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  1. TRUY VET NAP NVL, TIEN DO & TRANG THAI KIOSK:' -ForegroundColor Cyan
    Write-Host '     .\pop.ps1 trace <Lot/PO/Line/Machine> ' -NoNewline -ForegroundColor Green
    Write-Host '-> Golden Query 360: Soi dinh muc BOM, Ton kho kho chuyen (ROUTE_VN_WH), Lich su nap NVL Kiosk, Tien do POP' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 nvl <Lot/PO>               ' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi nhanh dinh muc BOM, ma thay the (AltCode) va ton kho kha dung cua tung vat tu tai ROUTE_VN_WH' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 sync [-Line <LineCode>]    ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra cac Lot bi ket pipeline dong bo POP -> MES (MongoToMesPerformance)' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  2. GIAI PHONG, MO KHOA & HOTFIX THIET BI KIOSK:' -ForegroundColor Cyan
    Write-Host '     .\pop.ps1 unlock <Machine> [-Deploy] ' -NoNewline -ForegroundColor Green
    Write-Host '-> Mo khoa giai phong may ket ACTIVE tren Kiosk POP tuc thoi 1-Shot (<0.5s)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 release-machines [-Force]  ' -NoNewline -ForegroundColor Green
    Write-Host '-> Giai phong toan bo may POP bi ket khoa mo coi theo Line' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 swap-machine -Target <Lot> -Machine <M> [-Route <R>] [-Deploy]' -ForegroundColor Green
    Write-Host '-> Doi may nham Kiosk dong bo ca STB_ProdRouteHist va MongoToMesPerformance (Rule 20.1)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 fix-solution -Target <Lot/Barrel> [-Deploy]' -ForegroundColor Green
    Write-Host '-> Cap cuu khoi phuc thung dung dich dien giai 150kg bi auto-exhaust ve 0kg' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  3. KIEM TOAN & TRA CUU TRI THUC:' -ForegroundColor Cyan
    Write-Host '     .\pop.ps1 readiness / audit [-Line <L>]' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem toan muc do san sang 100% POP Web (Mode, Slot, ProdMode, Lock, Sync)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 check                      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra ket noi song song toi SmartFactoryV2 (MES DB) va VINATECH_POP (POP DB)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 find <Keyword>             ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu L1 Quick Matrix (<0.001s) va tai lieu POP KB Chuyen sau' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  HE SINH THAI 3 CLI HUBS CHUYEN TRACH:' -ForegroundColor Cyan
    Write-Host '     .\pop.ps1 ...  -> Hub chuyen trach Mat tran Kiosk POP tai xuong (BOM NVL, Kho ROUTE_VN_WH, Unlock may, Sync)' -ForegroundColor Yellow
    Write-Host '     .\mes.ps1 ...  -> Hub chuyen trach Loi San Xuat MES, Vong doi Lot, Man hinh WinForm & Hotfixes' -ForegroundColor Yellow
    Write-Host '     .\gw.ps1  ...  -> Hub chuyen trach Phe Duyet Groupware & Chung Tu ERP NEOE' -ForegroundColor Yellow
    Write-Host ''
}

$cmdLower = $Command.ToLower()

switch ($cmdLower) {
    'help' {
        Show-Help
    }
    'trace' {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma can truy vet (Lot / Barcode / PO / Machine / Line)!' -ForegroundColor Red
            exit 1
        }
        $popTraceScript = Join-Path $toolsDir 'pop_trace.ps1'
        if (Test-Path $popTraceScript) {
            & $popTraceScript -Target $Target
        } else {
            Write-Error "tools/pop_trace.ps1 not found."
        }
    }
    { $_ -in 'nvl', 'bom' } {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma Lot hoac ma PO can tra cuu BOM NVL!' -ForegroundColor Red
            exit 1
        }
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
        if ($null -eq $conn) {
            Write-Host "LOI: Khong the ket noi CSDL SmartFactoryV2!" -ForegroundColor Red
            exit 1
        }
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = @"
SET NOCOUNT ON;
DECLARE @In VARCHAR(50) = '$($Target.Replace("'", "''"))';
DECLARE @PONo VARCHAR(30) = NULL;
DECLARE @RouteCode VARCHAR(20) = NULL;
DECLARE @Model VARCHAR(50) = NULL;

IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @In OR Barcode = @In)
BEGIN
    SELECT TOP 1 @PONo = PONo, @Model = MaterialCode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @In OR Barcode = @In;
    SELECT TOP 1 @RouteCode = RouteCode FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) WHERE Barcode = @In;
END
ELSE IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) WHERE PONo = @In)
BEGIN
    SELECT TOP 1 @PONo = PONo, @Model = MaterialCode FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) WHERE PONo = @In;
END
ELSE
BEGIN
    SET @PONo = @In;
END

SELECT 
    B.RouteCode, 
    B.ChildMaterialCode, 
    ISNULL(MM.MaterialName, '') AS MaterialName, 
    B.UsedQty, 
    ISNULL(MM.DelegateMaterialCode, '-') AS AltCode1, 
    ISNULL(MM.DelegateMaterialCode2, '-') AS AltCode2
INTO #BOM
FROM SmartFactoryV2.dbo.STB_ProductionOrderBom B WITH(NOLOCK)
LEFT JOIN SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK) ON B.ChildMaterialCode = MM.MaterialCode
WHERE B.PONo = @PONo AND (@RouteCode IS NULL OR B.RouteCode = @RouteCode OR B.RouteCode = '' OR B.RouteCode IS NULL);

-- 1. Ton kho chuyen ROUTE_VN_WH
SELECT MaterialCode, SUM(CurrentQty) AS RouteStockQty
INTO #STOCK_ROUTE
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'ROUTE_VN_WH' 
  AND MaterialCode IN (SELECT ChildMaterialCode FROM #BOM)
  AND CurrentQty > 0
GROUP BY MaterialCode;

-- 2. Ton kho tong MAIN_VN_WH
SELECT MaterialCode, SUM(CurrentQty) AS MainStockQty
INTO #STOCK_MAIN
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'MAIN_VN_WH' 
  AND MaterialCode IN (SELECT ChildMaterialCode FROM #BOM)
  AND CurrentQty > 0
GROUP BY MaterialCode;

-- 3. Ton kho AltCode tai ROUTE_VN_WH
SELECT MaterialCode, SUM(CurrentQty) AS AltStockQty
INTO #STOCK_ALT
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'ROUTE_VN_WH' 
  AND MaterialCode IN (SELECT AltCode1 FROM #BOM WHERE AltCode1 <> '-' UNION SELECT AltCode2 FROM #BOM WHERE AltCode2 <> '-')
  AND CurrentQty > 0
GROUP BY MaterialCode;

SELECT 
    b.RouteCode, 
    b.ChildMaterialCode, 
    b.MaterialName, 
    b.UsedQty, 
    b.AltCode1, 
    b.AltCode2,
    ISNULL(sr.RouteStockQty, 0) AS RouteStockQty,
    ISNULL(sm.MainStockQty, 0) AS MainStockQty,
    ISNULL(sa.AltStockQty, 0) AS AltStockQty
FROM #BOM b
LEFT JOIN #STOCK_ROUTE sr ON b.ChildMaterialCode = sr.MaterialCode
LEFT JOIN #STOCK_MAIN sm ON b.ChildMaterialCode = sm.MaterialCode
LEFT JOIN #STOCK_ALT sa ON b.AltCode1 = sa.MaterialCode
ORDER BY b.RouteCode, b.ChildMaterialCode;
"@
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $da.Fill($dt) | Out-Null
        $conn.Close()
        $sw.Stop()

        Show-PopBanner
        Write-Host "-> Tra cuu Dinh muc BOM & Kha dung Ton kho cho: '$Target' ($($sw.ElapsedMilliseconds) ms)" -ForegroundColor Green
        if ($dt.Rows.Count -eq 0) {
            Write-Host "   [-] Khong tim thay ban ghi BOM cho ma: $Target" -ForegroundColor Yellow
        } else {
            Write-Host ''
            Write-Host ">>> DANH MUC NVL BOM & TON KHO KHO CHUYEN (ROUTE_VN_WH) ($($dt.Rows.Count) vat tu):" -ForegroundColor Magenta
            foreach ($row in $dt.Rows) {
                $rt = $row['RouteCode']
                $code = $row['ChildMaterialCode']
                $name = $row['MaterialName']
                $qty = $row['UsedQty']
                $alt1 = $row['AltCode1']
                $alt2 = $row['AltCode2']
                $routeStock = [double]$row['RouteStockQty']
                $mainStock = [double]$row['MainStockQty']
                $altStock = [double]$row['AltStockQty']

                $stockStr = if ($routeStock -eq 0) { "[HET HANG (0)]" } else { "$routeStock" }
                $stockColor = if ($routeStock -eq 0) { "Red" } else { "Green" }

                Write-Host "   [$rt] " -NoNewline -ForegroundColor DarkCyan
                Write-Host "$code " -NoNewline -ForegroundColor Yellow
                Write-Host "($name) " -NoNewline -ForegroundColor White
                Write-Host "Dinh muc: $qty " -NoNewline -ForegroundColor Gray
                Write-Host "| Ton ROUTE: " -NoNewline -ForegroundColor Gray
                Write-Host "$stockStr " -NoNewline -ForegroundColor $stockColor

                if ($routeStock -eq 0) {
                    if ($mainStock -gt 0) {
                        Write-Host "| Kho tong MAIN: $mainStock (Can F430) " -NoNewline -ForegroundColor Cyan
                    } else {
                        Write-Host "| Kho tong MAIN: 0 " -NoNewline -ForegroundColor DarkGray
                    }
                }

                if ($alt1 -ne '-' -or $alt2 -ne '-') {
                    Write-Host "| Alt: $alt1" -NoNewline -ForegroundColor DarkYellow
                    if ($altStock -gt 0) {
                        Write-Host " [Alt ROUTE con: $altStock]" -ForegroundColor Green
                    } else {
                        Write-Host ""
                    }
                } else {
                    Write-Host ""
                }

                if ($routeStock -eq 0 -and $altStock -gt 0) {
                    Write-Host "      --> [GIAI PHAP OP]: Ma $code het ton kho, nhung ma thay the '$alt1' DANG CO SAN $altStock tai ROUTE_VN_WH. Quet ma '$alt1' de chay tiep!" -ForegroundColor Yellow
                }
            }
        }
    }
    'unlock' {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ten hoac ma thiet bi can mo khoa!' -ForegroundColor Red
            exit 1
        }
        $unlockScript = Join-Path $toolsDir 'unlock_machine.ps1'
        if (Test-Path $unlockScript) {
            & $unlockScript -Machine $Target -Line $Line -Deploy:$Deploy -Force:$Force
        } else {
            Write-Error "tools/unlock_machine.ps1 not found."
        }
    }
    { $_ -in 'release-machines', 'release' } {
        $relScript = Join-Path $toolsDir 'release_orphan_machines.ps1'
        if (Test-Path $relScript) {
            & $relScript -Force:$Force
        } else {
            Write-Error "tools/release_orphan_machines.ps1 not found."
        }
    }
    'sync' {
        Show-PopBanner
        Write-Host "-> Kiem tra cac Lot bi tac nghen pipeline dong bo POP -> MES..." -ForegroundColor Yellow
        $conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
        if ($null -eq $conn) {
            Write-Host "LOI: Khong the ket noi CSDL SmartFactoryV2!" -ForegroundColor Red
            exit 1
        }
        $lineFilter = if ($Line) { "AND LineCode = '$($Line.Replace("'", "''"))'" } else { "" }
        $sql = @"
SELECT TOP 20 DayPlanNo, Barcode, RouteCode, LineCode, TotalProdQty, TotalDefectQty, IsDone, IsTransferred, ModifyDateTime 
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
WHERE IsDone = 1 AND IsTransferred = 0 $lineFilter
ORDER BY ModifyDateTime DESC;
"@
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $sql
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $da.Fill($dt) | Out-Null
        $conn.Close()

        if ($dt.Rows.Count -eq 0) {
            Write-Host "   [OK] Pipeline dong bo thong suot! Khong co Lot nao bi ket (IsDone=1, IsTransferred=0)." -ForegroundColor Green
        } else {
            Write-Host ">>> PHAT HIEN $($dt.Rows.Count) LOT BI TAC NGHEN DONG BO:" -ForegroundColor Red
            $dt | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
        }
    }
    { $_ -in 'readiness', 'audit', 'pop-audit' } {
        $readinessScript = Join-Path $toolsDir 'pop_readiness.ps1'
        if (Test-Path $readinessScript) {
            & $readinessScript -Line $Line -Detail:$Detail
        } else {
            Write-Error "tools/pop_readiness.ps1 not found."
        }
    }
    'find' {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap tu khoa tra cuu!' -ForegroundColor Red
            exit 1
        }
        $findScript = Join-Path $toolsDir 'find_kb.ps1'
        if (Test-Path $findScript) {
            & $findScript -Keyword $Target
        } else {
            Write-Error "tools/find_kb.ps1 not found."
        }
    }
    'check' {
        Show-PopBanner
        Write-Host "-> Kiem tra ket noi CSDL phuc vu Kiosk POP..." -ForegroundColor Cyan
        $connMes = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
        if ($connMes) {
            Write-Host "   [OK] SmartFactoryV2 (MES DB): Ket noi thanh cong toi $($connMes.Database) tren $($connMes.DataSource)" -ForegroundColor Green
            $connMes.Close()
        } else {
            Write-Host "   [LOI] SmartFactoryV2: Khong the ket noi!" -ForegroundColor Red
        }
        $connPop = Get-DbConnection -Profile 'POP' -Silent
        if ($connPop) {
            Write-Host "   [OK] VINATECH_POP (POP DB): Ket noi thanh cong toi $($connPop.Database) tren $($connPop.DataSource)" -ForegroundColor Green
            $connPop.Close()
        } else {
            Write-Host "   [LOI] VINATECH_POP: Khong the ket noi!" -ForegroundColor Red
        }
    }
    { $_ -in 'screen', 'diagnose', 'shell', 'repl', 'health', 'weekly-report', 'lineage', 'sp', 'fix-movedate', 'fix-electrode', 'fix-rollback', 'fix-pop-clone', 'fix-cancel-pack', 'swap-machine', 'fix-defect-null', 'fix-lineinput', 'fix-solution', 'deploy' } {
        Write-Host "-> [POP Hub] Lenh '$Command' thuoc ve MES Core Hub -> Chuyen tiep toi .\mes.ps1..." -ForegroundColor DarkCyan
        $passParams = @{}
        if ($Target) { $passParams['Target'] = $Target }
        if ($Machine) { $passParams['Machine'] = $Machine }
        if ($Route) { $passParams['Route'] = $Route }
        if ($Line) { $passParams['Line'] = $Line }
        if ($Deploy) { $passParams['Deploy'] = $true }
        if ($Force) { $passParams['Force'] = $true }
        & (Join-Path $scriptDir 'mes.ps1') $Command @passParams
    }
    default {
        # Fallback: Tu dong nhan dien moi ma dau vao de chay Trace
        Write-Host "-> Tu dong nhan dien '$Command' -> Khoi chay Truy vet POP Kiosk 360 do..." -ForegroundColor Green
        $popTraceScript = Join-Path $toolsDir 'pop_trace.ps1'
        if (Test-Path $popTraceScript) {
            & $popTraceScript -Target $Command
        } else {
            Write-Error "tools/pop_trace.ps1 not found."
        }
    }
}
