# ==============================================================================
# health_check.ps1 — VINATECH MES PRODUCTION MORNING HEALTH CHECK (v3.0)
# Quét toàn diện: Kết nối CSDL | Lot WIP 24h | Kẹt Sync POP | Máy kẹt ACTIVE | Locks
# ==============================================================================

param(
    [switch]$Detail
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '           VINATECH MES PRODUCTION MORNING HEALTH CHECK' -ForegroundColor Yellow
Write-Host '     Quet toan dien: WIP 24h, Kiet Sync POP, Khoa Thiet bi, Blocking Locks' -ForegroundColor White
Write-Host '======================================================================' -ForegroundColor Cyan

# 1. Kiem tra ket noi CSDL Cot loi
Write-Host ''
Write-Host '--- 1. KET NOI CO SO DU LIEU COT LOI ---' -ForegroundColor Magenta
$profiles = @('SmartFactoryV2', 'SmartFramework', 'POP')
$connStatus = @{}
foreach ($p in $profiles) {
    $tSw = [System.Diagnostics.Stopwatch]::StartNew()
    $c = Get-DbConnection -Profile $p -Silent
    $tSw.Stop()
    if ($c) {
        $ms = [Math]::Round($tSw.Elapsed.TotalMilliseconds, 1)
        Write-Host "  [OK] Profile $p : Ket noi thanh cong (${ms} ms)" -ForegroundColor Green
        $connStatus[$p] = $true
        $c.Close()
    } else {
        Write-Host "  [ERROR] Profile $p : KHONG THE KET NOI!" -ForegroundColor Red
        $connStatus[$p] = $false
    }
}

if (-not $connStatus['SmartFactoryV2']) {
    Write-Host 'Loi nghiem trong: Khong the ket noi SmartFactoryV2. Dung Health Check!' -ForegroundColor Red
    exit 1
}

$connMes = Get-DbConnection -Profile 'SmartFactoryV2' -Silent

# 2. Quet Lot WIP chay qua 24 gio
Write-Host ''
Write-Host '--- 2. GIAM SAT LOT WIP QUA 24 GIO (CANH BAO TAC NGHEN CHUYEN) ---' -ForegroundColor Magenta
try {
    $cmd = $connMes.CreateCommand()
    $cmd.CommandText = @"
SELECT 
    COUNT(*) AS TotalOverdueWIP,
    ISNULL(MIN(CreateDateTime), GETDATE()) AS OldestLotDate
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE IsProdFinish = 0 
  AND IsLineInput = 1 
  AND CreateDateTime < DATEADD(HOUR, -24, GETDATE());
"@
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $null = $da.Fill($dt)
    $wipCount = $dt.Rows[0]['TotalOverdueWIP']
    $oldestDate = $dt.Rows[0]['OldestLotDate']
    if ($wipCount -eq 0) {
        Write-Host '  [OK] Khong co Lot WIP nao chay qua 24 gio chua chot!' -ForegroundColor Green
    } else {
        Write-Host "  [CANH BAO] Phat hien $wipCount Lot WIP dang chay qua 24h (Lot lau nhat tu: $oldestDate)" -ForegroundColor Yellow
        if ($Detail) {
            $cmd.CommandText = @"
SELECT TOP 5 ControlNo, Barcode, MaterialCode, PONo, CreateDateTime
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE IsProdFinish = 0 AND IsLineInput = 1 AND CreateDateTime < DATEADD(HOUR, -24, GETDATE())
ORDER BY CreateDateTime ASC;
"@
            $dtDetail = New-Object System.Data.DataTable
            $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmd)).Fill($dtDetail)
            $dtDetail | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "  Loi kiem tra WIP: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Quet cac Lot bi tac nghen pipeline dong bo POP -> MES
Write-Host ''
Write-Host '--- 3. KIEM TRA PIPELINE DONG BO POP -> MES (MongoToMesPerformance) ---' -ForegroundColor Magenta
try {
    $cmd.CommandText = @"
SELECT COUNT(*) AS PendingSync
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
WHERE IsDone = 1 AND IsTransferred = 0;
"@
    $dtSync = New-Object System.Data.DataTable
    $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmd)).Fill($dtSync)
    $pending = $dtSync.Rows[0]['PendingSync']
    if ($pending -eq 0) {
        Write-Host '  [OK] Pipeline dong bo thong suot (0 Lot bi ton dong IsTransferred=0)' -ForegroundColor Green
    } else {
        Write-Host "  [CANH BAO] Phat hien $pending Lot hoan thanh tren POP nhung chua dong bo vao MES!" -ForegroundColor Yellow
        Write-Host '  -> Khac phuc: Dung lenh .\pop.ps1 sync de quet va phan tich chi tiet' -ForegroundColor Gray
        if ($Detail) {
            $cmd.CommandText = @"
SELECT TOP 5 DayPlanNo, Barcode, LineCode, RouteCode, TotalProdQty, ModifyDateTime
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
WHERE IsDone = 1 AND IsTransferred = 0
ORDER BY ModifyDateTime DESC;
"@
            $dtSyncDet = New-Object System.Data.DataTable
            $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmd)).Fill($dtSyncDet)
            $dtSyncDet | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "  Loi kiem tra Sync: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Quet Blocking Lock & Deadlock tren SmartFactoryV2
Write-Host ''
Write-Host '--- 4. KIEM TRA BLOCKING & DEADLOCK TREN CSDL SAN XUAT ---' -ForegroundColor Magenta
try {
    $cmd.CommandText = @"
SELECT COUNT(*) AS BlockingCount
FROM sys.dm_exec_requests WITH(NOLOCK)
WHERE blocking_session_id <> 0;
"@
    $dtLock = New-Object System.Data.DataTable
    $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmd)).Fill($dtLock)
    $blocks = $dtLock.Rows[0]['BlockingCount']
    if ($blocks -eq 0) {
        Write-Host '  [OK] Khong co Blocking session nao tren CSDL SmartFactoryV2' -ForegroundColor Green
    } else {
        Write-Host "  [CANH BAO] Phat hien $blocks session dang bi khoa chan (Blocking)!" -ForegroundColor Red
        Write-Host '  -> Khac phuc: Dung lenh .\mes.ps1 locks de soi chi tiet va xu ly' -ForegroundColor Gray
    }
} catch {
    Write-Host "  Loi kiem tra Locks: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    $connMes.Close()
}

# 5. Quet Thiet Bi POP bi ket khoa ACTIVE tren VINATECH_POP
if ($connStatus['POP']) {
    Write-Host ''
    Write-Host '--- 5. KIEM TRA THIET BI BI TREO KHOA ACTIVE TREN KIOSK POP ---' -ForegroundColor Magenta
    $connPop = Get-DbConnection -Profile 'POP' -Silent
    if ($connPop) {
        try {
            $cmdPop = $connPop.CreateCommand()
            $cmdPop.CommandText = @"
SELECT COUNT(*) AS ActiveLocks
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK)
WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');
"@
            $dtPop = New-Object System.Data.DataTable
            $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmdPop)).Fill($dtPop)
            $activeCount = $dtPop.Rows[0]['ActiveLocks']
            if ($activeCount -eq 0) {
                Write-Host '  [OK] Khong co thiet bi nao bi treo khoa ACTIVE mo coi tren Kiosk' -ForegroundColor Green
            } else {
                Write-Host "  [THONG TIN] Hien tai co $activeCount thiet bi dang trong phien lam viec ACTIVE" -ForegroundColor Cyan
                if ($Detail) {
                    $cmdPop.CommandText = @"
SELECT TOP 5 MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPED_AT
FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK)
WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
ORDER BY MAPPED_AT DESC;
"@
                    $dtPopDet = New-Object System.Data.DataTable
                    $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmdPop)).Fill($dtPopDet)
                    $dtPopDet | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
                }
            }
        } catch {
            Write-Host "  Loi kiem tra thiet bi POP: $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            $connPop.Close()
        }
    }
}

$sw.Stop()
Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "  Hoan tat Morning Health Check trong: $([Math]::Round($sw.Elapsed.TotalSeconds, 2))s" -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
