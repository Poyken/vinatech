# ==============================================================================
# mes.ps1 — VINATECH MES UNIFIED CLI HUB (Trung Tam Dieu Phoi Lenh Van Hanh)
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',
    
    [Parameter(Position = 1)]
    [string]$Target = '',
    
    [string]$Profile = 'SmartFactoryV2',
    [string]$Template = '',
    [switch]$Force,
    [switch]$Detail,
    [switch]$Clean
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$scriptDir = $PSScriptRoot
$toolsDir = Join-Path $scriptDir 'tools'
. (Join-Path $toolsDir 'db_shared.ps1')

function Show-MesBanner {
    Write-Host ''
    Write-Host '======================================================================' -ForegroundColor Cyan
    Write-Host '             VINATECH MES UNIFIED CLI HUB (v2.1)' -ForegroundColor Yellow
    Write-Host '    Trung Tam Dieu Phoi Van Hanh, Chan Doan & Khac Phuc Su Co MES' -ForegroundColor White
    Write-Host '======================================================================' -ForegroundColor Cyan
}

function Show-Help {
    Show-MesBanner
    Write-Host ''
    Write-Host 'CAC LENH VAN HANH CHINH:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  1. TRUY VET DU LIEU & SU CO (INVESTIGATION):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 trace <Lot/Barcode>       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Golden Query 360 do quet sach Lot, Routing, Kho, Thung' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 screen <ScreenID>         ' -NoNewline -ForegroundColor Green
    Write-Host '-> Debug man hinh MES (Grid, SP, Bang lien quan: B530, B540...)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 sp <SP_Name>              ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tai SP goc moi nhat tu DB ve local de phan tich' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 find <Keyword>            ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu L1 Quick Matrix (<0.001s) va 78+ file Markdown' -ForegroundColor Gray

    Write-Host ''
    Write-Host '  2. TRUY VAN & KIEM TRA HE THONG (SYSTEM & QUERY):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 pop-readiness [-Target <Line>]' -ForegroundColor Green
    Write-Host '-> Kiem toan 8 buoc san sang cat WinForm & chay 100% POP Web theo Line' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 release-machines [-Target <Line>] [-Force]' -ForegroundColor Green
    Write-Host '-> Giai phong thiet bi bi treo khoa ACTIVE o ke hoach (DayPlan) cu tren Kiosk POP' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 pop-audit                 ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem toan & doi soat lech du lieu POP Kiosk vs MES (IsTransferred=0)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 check [-Profile <Name>]   ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra ket noi toi 15 Database (MES, GW, ERP, POP...)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 health [-Detail]          ' -NoNewline -ForegroundColor Green
    Write-Host '-> Morning Health Check quet Lot HOLD, WIP 24h, Box do dang' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 audit                     ' -NoNewline -ForegroundColor Green
    Write-Host '-> Audit do tin cay toan bo tai lieu Markdown vs Live DB' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 query "<SELECT_SQL>"      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Chay cau SELECT an toan (kem NOLOCK warning & Multi-DB)' -ForegroundColor Gray

    Write-Host ''
    Write-Host '  3. KHAC PHUC SU CO & TRIEN KHAI (HOTFIX & DEPLOY):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 new-fix <Name> [-Template <b552|b782|rollback>]' -ForegroundColor Green
    Write-Host '-> Sinh template SQL Fix chuan (ho tro B552 dien cuc, B782 chuyen ngay, Rollback chot)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 deploy <Path.sql> [-Force]' -NoNewline -ForegroundColor Green
    Write-Host '-> Deploy SQL an toan (Tu dong Snapshot Pre-flight backup)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 clean                     ' -NoNewline -ForegroundColor Green
    Write-Host '-> Don dep scratch workspace, kiem tra an toan token & git status' -ForegroundColor Gray

    Write-Host ''
    Write-Host '  4. TRO LY DI DONG (TELEGRAM BOT):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 bot                       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Khoi dong Telegram Assistant de dieu khien tu dien thoai' -ForegroundColor Gray

    Write-Host ''
    Write-Host 'Cac Profile CSDL ho tro:' -ForegroundColor Yellow
    Write-Host '  SmartFactoryV2 (Mac dinh), SmartFramework, Groupware, ERP, Bizbox, POP, Andon...' -ForegroundColor Gray
    Write-Host ''
}

# Main Command Dispatcher
$cmdLower = $Command.ToLower()
if ($cmdLower -eq 'help' -or $cmdLower -eq '-h' -or $cmdLower -eq '--help') {
    Show-Help
}
elseif ($cmdLower -eq 'check') {
    Show-MesBanner
    if ($Target) { $Profile = $Target }
    Write-Host "Kiem tra ket noi Database Profile: $Profile..." -ForegroundColor Cyan
    $conn = Get-DbConnection -Profile $Profile
    if ($conn -ne $null) {
        Write-Host "-> Ket noi thanh cong toi Database: $($conn.Database) tren may chu: $($conn.DataSource)" -ForegroundColor Green
        $conn.Close()
    } else {
        Write-Host "-> Khong the ket noi toi profile: $Profile" -ForegroundColor Red
    }
}
elseif ($cmdLower -eq 'trace') {
    Show-MesBanner
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host 'Loi: Vui long nhap ma LotID hoac Barcode can truy vet!' -ForegroundColor Red
        Write-Host 'Vi du: .\mes.ps1 trace "VN-2026-LOT001"' -ForegroundColor Yellow
        exit 1
    }

    Write-Host "(*) [GOLDEN QUERY 360] Dang truy vet toan dien ma: $Target..." -ForegroundColor Cyan
    
    $conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
    if ($conn -eq $null) { exit 1 }

    $q1 = "SELECT TOP 1 MaterialLotNo, MaterialCode, CurrentQty, MaterialWarehouseCode, EndOfLifeDate, CreateDateTime FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE MaterialLotNo LIKE '%$Target%'"
    $q2 = "SELECT TOP 1 ControlNo, PONo, Barcode, MaterialCode, IsProdFinish, IsLineInput, CreateDateTime FROM STB_SetInfo WITH(NOLOCK) WHERE ControlNo LIKE '%$Target%' OR Barcode LIKE '%$Target%'"
    $q3 = "SELECT TOP 10 ProdRouteHistNo, ControlNo, RouteCode, WorkCenterCode, ProdQty, CreateDateTime FROM STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = '$Target' OR ControlNo IN (SELECT ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '$Target') ORDER BY CreateDateTime DESC"
    $q4 = "SELECT TOP 5 MaterialCode, MaterialWarehouseCode, StockQty FROM STB_MaterialStock WITH(NOLOCK) WHERE MaterialCode LIKE '%$Target%'"
    $q5 = "SELECT TOP 10 DayPlanNo, Barcode, RouteCode, LineCode, TotalProdQty, IsDone, IsTransferred, ModifyDateTime FROM MongoToMesPerformance WITH(NOLOCK) WHERE Barcode = '$Target' OR Barcode IN (SELECT Barcode FROM STB_SetInfo WITH(NOLOCK) WHERE ControlNo = '$Target') ORDER BY ModifyDateTime DESC"

    Write-Host ''
    Write-Host '1. THONG TIN KHO & VAT TU (STB_MaterialLotInfo):' -ForegroundColor Yellow
    Execute-SqlQuery -Connection $conn -Query $q1

    Write-Host ''
    Write-Host '2. THONG TIN SET / THUNG SAN PHAM (STB_SetInfo):' -ForegroundColor Yellow
    Execute-SqlQuery -Connection $conn -Query $q2

    Write-Host ''
    Write-Host '3. LICH SU CONG DOAN SAN XUAT (STB_ProdRouteHist - Top 10):' -ForegroundColor Yellow
    Execute-SqlQuery -Connection $conn -Query $q3

    Write-Host ''
    Write-Host '4. TON KHO VAT TU THEO MA (STB_MaterialStock - Top 5):' -ForegroundColor Yellow
    Execute-SqlQuery -Connection $conn -Query $q4

    Write-Host ''
    Write-Host '5. TRANG THAI POP KIOSK & DONG BO (MongoToMesPerformance):' -ForegroundColor Yellow
    Execute-SqlQuery -Connection $conn -Query $q5

    $conn.Close()
    Write-Host ''
    Write-Host '-> Hoan thanh truy vet 360 do.' -ForegroundColor Green
}
elseif ($cmdLower -eq 'screen') {
    $dbgScript = Join-Path $toolsDir 'debug_screen.ps1'
    if (Test-Path $dbgScript) {
        if ($Target -match '^[A-Za-z0-9_]+$') {
            & $dbgScript -TCode $Target
        } else {
            & $dbgScript -ErrorMsg $Target
        }
    } else {
        Write-Error 'tools/debug_screen.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'sp') {
    $spScript = Join-Path $toolsDir 'db_sync_tool.ps1'
    if (Test-Path $spScript) {
        if ($Clean) {
            & $spScript -Clean
        } else {
            if ([string]::IsNullOrWhiteSpace($Target)) {
                Write-Host 'Loi: Vui long nhap ten Stored Procedure can tai!' -ForegroundColor Red
                Write-Host 'Vi du: .\mes.ps1 sp "usp_DoProcessProdRouteHist"' -ForegroundColor Yellow
                exit 1
            }
            & $spScript -SPName $Target
        }
    } else {
        Write-Error 'tools/db_sync_tool.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'query') {
    $qScript = Join-Path $toolsDir 'run_query.ps1'
    if (Test-Path $qScript) {
        & $qScript -Query $Target -Profile $Profile
    } else {
        Write-Error 'tools/run_query.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'new-fix') {
    Show-MesBanner
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host 'Loi: Vui long nhap ma su co hoac ten mo ta cho Hotfix!' -ForegroundColor Red
        Write-Host 'Vi du: .\mes.ps1 new-fix "FIX_B530_LOT_HOLD"' -ForegroundColor Yellow
        exit 1
    }

    $sqlDir = Join-Path $scriptDir 'sql'
    if (!(Test-Path $sqlDir)) {
        New-Item -ItemType Directory -Path $sqlDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $fileName = "hotfix_${timestamp}_${Target}.sql"
    $filePath = Join-Path $sqlDir $fileName

    # Chon template phu hop
    $tplName = 'template_hotfix.sql'
    $targetLower = $Target.ToLower()
    $tplParamLower = $Template.ToLower()

    if ($tplParamLower -eq 'b552' -or $tplParamLower -eq 'electrode' -or $targetLower -match 'b552|electrode|mixing|slitting') {
        $tplName = 'template_B552_ELECTRODE_CLEANUP.sql'
    }
    elseif ($tplParamLower -eq 'b782' -or $tplParamLower -eq 'movedate' -or $targetLower -match 'b782|movedate|move_date') {
        $tplName = 'template_B782_MOVE_JOBDATE.sql'
    }
    elseif ($tplParamLower -eq 'rollback' -or $targetLower -match 'rollback') {
        $tplName = 'template_B782_B530_ROLLBACK_CHOT.sql'
    }

    $templatePath = Join-Path $sqlDir $tplName
    $content = ''
    if (Test-Path $templatePath) {
        $content = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
        $content = $content.Replace('{{ISSUE_CODE}}', $Target)
        $content = $content.Replace('{{DATE_CREATED}}', (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
        $content = $content.Replace('{{DATE_TAG}}', (Get-Date -Format 'yyyyMMdd'))
    } else {
        $content = "-- HOTFIX: $Target`nUSE SmartFactoryV2;`nGO`nBEGIN TRAN;`n-- Add your SQL here`nROLLBACK TRAN;`nGO"
    }

    $utf8WithBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($filePath, $content, $utf8WithBom)

    Write-Host '-> Da tao thanh cong template Hotfix chuan UTF-8-BOM:' -ForegroundColor Green
    Write-Host "  Template su dung: $tplName" -ForegroundColor Yellow
    Write-Host "  Path: $filePath" -ForegroundColor Cyan
    Write-Host 'Huong dan tiep theo:' -ForegroundColor Yellow
    Write-Host '  1. Mo file dien thong so/bien can thiet ({{...}}).' -ForegroundColor Gray
    Write-Host "  2. Chay thu nghiem an toan: .\mes.ps1 deploy $filePath" -ForegroundColor Gray
}
elseif ($cmdLower -eq 'deploy') {
    $depScript = Join-Path $toolsDir 'deploy_tool.ps1'
    if (Test-Path $depScript) {
        if ($Force) {
            & $depScript -SqlPath $Target -Profile $Profile -Force
        } else {
            & $depScript -SqlPath $Target -Profile $Profile
        }
    } else {
        Write-Error 'tools/deploy_tool.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'find') {
    $findScript = Join-Path $toolsDir 'find_kb.ps1'
    if (Test-Path $findScript) {
        & $findScript -Query $Target
    } else {
        Write-Error 'tools/find_kb.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'health') {
    $healthScript = Join-Path $toolsDir 'health_check.ps1'
    if (Test-Path $healthScript) {
        if ($Detail) {
            & $healthScript -Detail
        } else {
            & $healthScript
        }
    } else {
        Write-Error 'tools/health_check.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'audit' -or $cmdLower -eq 'verify-kb') {
    $auditScript = Join-Path $toolsDir 'audit_kb_reliability.ps1'
    if (Test-Path $auditScript) {
        & $auditScript
    } else {
        Write-Error 'tools/audit_kb_reliability.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'pop-audit' -or $cmdLower -eq 'pop-sync' -or $cmdLower -eq 'reconcile') {
    Write-Host "(*) [POP-AUDIT] Dang kiem toan doi soat du lieu POP Kiosk vs MES..." -ForegroundColor Cyan
    $conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
    if ($conn -eq $null) { exit 1 }

    Write-Host ''
    Write-Host '1. DANH SACH CONG DOAN POP BI KET CHUA CHUYEN SANG MES (IsTransferred = 0):' -ForegroundColor Yellow
    $qPending = "SELECT LineCode, COUNT(*) AS SoLuongKet, MIN(ModifyDateTime) AS TuNgay, MAX(ModifyDateTime) AS DenNgay FROM MongoToMesPerformance WITH(NOLOCK) WHERE IsDone = 1 AND IsTransferred = 0 GROUP BY LineCode"
    Execute-SqlQuery -Connection $conn -Query $qPending

    Write-Host ''
    Write-Host '2. TOP 10 BAN GHI KET CAN XU LY (IsTransferred = 0):' -ForegroundColor Yellow
    $qTopPending = "SELECT TOP 10 DayPlanNo, Barcode, RouteCode, LineCode, TotalProdQty, ModifyDateTime FROM MongoToMesPerformance WITH(NOLOCK) WHERE IsDone = 1 AND IsTransferred = 0 ORDER BY ModifyDateTime DESC"
    Execute-SqlQuery -Connection $conn -Query $qTopPending

    Write-Host ''
    Write-Host '3. DOI SOAT LECH DU LIEU HOM NAY (POP vs MES):' -ForegroundColor Yellow
    $qMismatched = "SELECT TOP 10 MMP.DayPlanNo, MMP.Barcode, MMP.RouteCode, MMP.TotalProdQty AS POP_Qty, PRH.ProdQty AS MES_Qty, CASE WHEN PRH.ProdRouteHistNo IS NULL THEN 'CHUA_SANG_MES' WHEN MMP.TotalProdQty <> PRH.ProdQty THEN 'LECH_SO_LUONG' ELSE 'KHOP' END AS SyncStatus, MMP.ModifyDateTime FROM MongoToMesPerformance MMP WITH (NOLOCK) LEFT JOIN STB_SetInfo SETI WITH (NOLOCK) ON MMP.Barcode = SETI.Barcode LEFT JOIN STB_ProdRouteHist PRH WITH (NOLOCK) ON PRH.ControlNo = SETI.ControlNo AND PRH.RouteCode = MMP.RouteCode WHERE MMP.IsDone = 1 AND (PRH.ProdRouteHistNo IS NULL OR MMP.TotalProdQty <> PRH.ProdQty) AND MMP.ModifyDateTime >= CAST(GETDATE() AS DATE) ORDER BY MMP.ModifyDateTime DESC"
    Execute-SqlQuery -Connection $conn -Query $qMismatched

    $conn.Close()
    Write-Host ''
    Write-Host '-> Hoan thanh kiem toan doi soat POP vs MES.' -ForegroundColor Green
}
elseif ($cmdLower -eq 'pop-readiness' -or $cmdLower -eq 'readiness') {
    $popReadinessScript = Join-Path $toolsDir 'pop_readiness.ps1'
    if (Test-Path $popReadinessScript) {
        & $popReadinessScript -Line $Target
    } else {
        Write-Error 'tools/pop_readiness.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'release-machines' -or $cmdLower -eq 'release-orphan-machines') {
    $relScript = Join-Path $toolsDir 'release_orphan_machines.ps1'
    if (Test-Path $relScript) {
        $params = @{}
        if ($Target) { $params['Target'] = $Target }
        if ($Force) { $params['Force'] = $true }
        & $relScript @params
    } else {
        Write-Error 'tools/release_orphan_machines.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'bot' -or $cmdLower -eq 'telegram') {
    $botScript = Join-Path $toolsDir 'mes_telegram_bot.py'
    if (Test-Path $botScript) {
        python -u $botScript
    } else {
        Write-Error 'tools/mes_telegram_bot.py not found.'
    }
}
elseif ($cmdLower -eq 'clean') {
    Show-MesBanner
    Write-Host '(*) Dang tien hanh kiem tra va don dep Workspace...' -ForegroundColor Cyan
    
    # 1. Don dep tools/scratch
    $scratchDir = Join-Path $toolsDir 'scratch'
    if (Test-Path $scratchDir) {
        $subDirs = Get-ChildItem -Path (Join-Path $scratchDir '*') -Directory
        $files = Get-ChildItem -Path (Join-Path $scratchDir '*') -File | Where-Object { $_.Name -ne 'README.md' }
        $count = $subDirs.Count + $files.Count
        if ($count -gt 0) {
            $subDirs | Remove-Item -Recurse -Force
            $files | Remove-Item -Force
            Write-Host "-> Da don dep $count muc trong $scratchDir." -ForegroundColor Green
        } else {
            Write-Host "-> Thu muc $scratchDir da sach se." -ForegroundColor Green
        }
    }
    
    # 2. Kiem tra bao mat telegram_config.json
    $cfgPath = Join-Path $toolsDir 'telegram_config.json'
    if (Test-Path $cfgPath) {
        $content = Get-Content $cfgPath -Raw
        if ($content -match 'YOUR_TELEGRAM_BOT_TOKEN_HERE') {
            Write-Host "-> telegram_config.json: AN TOAN (Su dung Placeholder mẫu)." -ForegroundColor Green
        } else {
            Write-Host "-> CANH BAO: telegram_config.json co the chua Token that! Vui long kiem tra." -ForegroundColor Red
        }
    }

    # 3. Kiem tra Git Working Tree
    Write-Host ''
    Write-Host '(*) Trang thai Git Working Tree:' -ForegroundColor Cyan
    git status --short
    Write-Host ''
    Write-Host '-> Hoan tat kiem tra & don dep Workspace.' -ForegroundColor Green
}
else {
    Write-Host "Lenh khong hop le: $Command" -ForegroundColor Red
    Show-Help
}
