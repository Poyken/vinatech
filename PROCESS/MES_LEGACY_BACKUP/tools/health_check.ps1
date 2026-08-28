# ==============================================================================
# health_check.ps1 — Morning Operational Health Check for Vinatech MES
# Kiem tra ket noi da CSDL | Quet Lot ket/HOLD | Kiem tra bat thuong dong goi
#
# Cach dung:
#   .\health_check.ps1
#   .\health_check.ps1 -Detail
# ==============================================================================

param(
    [switch]$Detail
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

. (Join-Path $PSScriptRoot "db_shared.ps1")

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "         VINATECH MES - MORNING OPERATIONAL HEALTH CHECK" -ForegroundColor Yellow
Write-Host ("Thoi gian: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Multi-DB Connections
Write-Host "1. KIEM TRA KET NOI 15 CO SO DU LIEU HE SINH THAI:" -ForegroundColor Cyan
$coreProfiles = @("SmartFactoryV2", "SmartFramework", "Groupware", "ERP", "POP", "Andon")

foreach ($pName in $coreProfiles) {
    $pCfg = Get-DbProfileConfig -Profile $pName
    $srv = $pCfg.Server
    $db = $pCfg.Database
    
    $conn = Get-DbConnection -Profile $pName -Silent -ConnectTimeoutSeconds 5
    if ($conn -ne $null) {
        Write-Host ("  [OK] Profile: " + $pName.PadRight(16) + " | DB: " + $db.PadRight(18) + " | Server: " + $srv) -ForegroundColor Green
        $conn.Close()
    } else {
        Write-Host ("  [FAIL] Profile: " + $pName.PadRight(14) + " | DB: " + $db.PadRight(18) + " | Server: " + $srv) -ForegroundColor Red
    }
}

# 2. Check Core MES Operations (SmartFactoryV2)
Write-Host ""
Write-Host "2. KIEM TRA TRANG THAI SAN XUAT & NGHIEP VU MES (SmartFactoryV2):" -ForegroundColor Cyan
$mesConn = Get-DbConnection -Profile "SmartFactoryV2" -Silent

if ($mesConn -eq $null) {
    Write-Host "  [ERROR] Khong the ket noi toi SmartFactoryV2 de kiem tra chi tiet!" -ForegroundColor Red
} else {
    try {
        # 2.1 Check Hold Lots (Kho HOLDING_WH)
        $cmd = $mesConn.CreateCommand()
        $cmd.CommandTimeout = 15
        $cmd.CommandText = "SELECT COUNT(1) AS HoldCount FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE MaterialWarehouseCode LIKE '%HOLD%'"
        $holdCount = [int]$cmd.ExecuteScalar()
        
        if ($holdCount -eq 0) {
            Write-Host "  [OK] Lot bi HOLD: 0 lot dang nam o kho HOLDING_WH." -ForegroundColor Green
        } else {
            Write-Host ("  [WARN] Lot bi HOLD: Co " + $holdCount + " lot dang nam o kho HOLDING_WH!") -ForegroundColor Yellow
            if ($Detail) {
                $cmd.CommandText = "SELECT TOP 5 MaterialLotNo, MaterialCode, CurrentQty, MaterialWarehouseCode, CreateDateTime FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE MaterialWarehouseCode LIKE '%HOLD%' ORDER BY CreateDateTime DESC"
                $adp = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
                $dt = New-Object System.Data.DataTable
                $null = $adp.Fill($dt)
                $dt | Format-Table -AutoSize | Out-String -Width 4000 | Write-Host -ForegroundColor Gray
            }
        }

        # 2.2 Check Active WIP Lots (last 24 hours)
        $cmd.CommandText = "SELECT COUNT(DISTINCT ControlNo) FROM STB_ProdRouteHist WITH(NOLOCK) WHERE CreateDateTime >= DATEADD(HOUR, -24, GETDATE())"
        $wip24h = [int]$cmd.ExecuteScalar()
        Write-Host ("  [INFO] Hoat dong 24h qua: " + $wip24h + " ControlNo co phat sinh giao dich san xuat.") -ForegroundColor Green

        # 2.3 Check Unclosed/Pending Packing Boxes
        $cmd.CommandText = "SELECT COUNT(1) FROM STB_SetInfo WITH(NOLOCK) WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE()) AND ISNULL(IsProdFinish, 0) = 0"
        $unpackedBoxes = [int]$cmd.ExecuteScalar()
        Write-Host ("  [INFO] Ban ghi San xuat trong 7 ngay chua ket thuc (IsProdFinish=0): " + $unpackedBoxes + " control.") -ForegroundColor Cyan

        # 2.4 Check Blocked Processes / Active Locks
        $cmd.CommandText = "SELECT COUNT(1) FROM sys.dm_exec_requests r WITH(NOLOCK) WHERE r.blocking_session_id <> 0"
        $blockedCount = [int]$cmd.ExecuteScalar()
        if ($blockedCount -eq 0) {
            Write-Host "  [OK] CSDL Lock/Blocking: Khong co session nao bi block tren SQL Server." -ForegroundColor Green
        } else {
            Write-Host ("  [WARN] Canh bao Lock: Co " + $blockedCount + " session dang bi block!") -ForegroundColor Red
        }

    } catch {
        Write-Host ("  [ERROR] Loi truy van chi tiet: " + $_) -ForegroundColor Red
    } finally {
        if ($mesConn.State -eq 'Open') { $mesConn.Close() }
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Kiem tra suc khoe hoan tat! Dung '.\mes.ps1 health -Detail' de xem chi tiet." -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
