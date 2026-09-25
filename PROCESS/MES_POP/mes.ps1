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
    [string]$Lots = '',
    [string]$TargetDate = '',
    [string]$Route = '',
    [string]$Type = 'Slitting',
    [int]$Hours = 10,
    [string]$SourceSp = '',
    [string]$TargetFactory = 'HY',
    [string]$BoxId = '',
    [string]$Machine = '',
    [string]$Line = '',
    [double]$Qty = 0,
    [switch]$Deploy,
    [switch]$ViewOnly,
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
    Write-Host '           VINATECH MES ALL-IN-ONE MASTER CLI HUB (v3.0)' -ForegroundColor Yellow
    Write-Host '     CONG CU TOAN NANG: MES SAN XUAT - KIOSK POP - GROUPWARE - 15 DB' -ForegroundColor White
    Write-Host '======================================================================' -ForegroundColor Cyan
}

function Show-Help {
    Show-MesBanner
    Write-Host ''
    Write-Host '(*) SMART AUTO-ROUTER: Chi can go ".\mes.ps1 <MA_BAT_KY>" - He thong tu dong nhan dien & xu ly!' -ForegroundColor Magenta
    Write-Host '    - Ma Lot / Barcode (VVQR...)  -> Tu dong chay Golden Query 360 & chan doan' -ForegroundColor Gray
    Write-Host '    - So PO (260829000018 - 12 so)-> Tu dong truy vet huyet mach Lineage & BOM' -ForegroundColor Gray
    Write-Host '    - Ma man hinh (B530, B782...) -> Tu dong tra cuu man hinh WinForm & chan doan' -ForegroundColor Gray
    Write-Host '    - Ma thiet bi (VVMHY130...)   -> Tu dong kiem tra mapping & khoa ACTIVE' -ForegroundColor Gray
    Write-Host '    - Mo ta loi (HOLD, ACTIVE...) -> Tu dong Master Diagnostic xuat 4 Dong Vang' -ForegroundColor Gray
    Write-Host ''
    Write-Host 'CAC LENH VAN HANH CHINH THEO 5 PHAN HE:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  1. TRUY VET DU LIEU & SU CO (INVESTIGATION):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 shell                     ' -NoNewline -ForegroundColor Green
    Write-Host '-> Bat Persistent REPL Shell tuc thoi (Zero Cold-Start, <0.05s response)' -ForegroundColor Yellow
    Write-Host '     .\mes.ps1 diagnose "<Text/Lot>"     ' -NoNewline -ForegroundColor Green
    Write-Host '-> Master Auto-Diagnostic: Chan doan tuc thoi 1-Shot xuat 4 Dong Vang (<1s)' -ForegroundColor Yellow
    Write-Host '     .\mes.ps1 trace <Lot/Line/Machine/Box>' -NoNewline -ForegroundColor Green
    Write-Host '-> Golden Query 360 sieu toc (Single Round-Trip) tu dong nhan dien Lot, Line, Thiet bi, Thung' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 lineage <Target>          ' -NoNewline -ForegroundColor Green
    Write-Host '-> Truy vet huyet mach lien he thong (PO/GW -> Kho -> MES -> POP Kiosk)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 nvl <Lot/PO>              ' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi BOM NVL, ma thay the (AltCode) & ton kha dung ROUTE_VN_WH vs MAIN_VN_WH' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 gw <PO/DocCode>           ' -NoNewline -ForegroundColor Green
    Write-Host '-> Truy vet to trinh thay the vat tu Groupware, phe duyet & ERP NEOE' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 screen <ScreenID>         ' -NoNewline -ForegroundColor Green
    Write-Host '-> Debug man hinh MES (Grid, SP, Bang lien quan: B530, B540...)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 sp <SP_Name>              ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tai SP goc moi nhat tu DB ve local de phan tich' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 find <Keyword>            ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu L1 Quick Matrix (<0.001s) va 78+ file Markdown' -ForegroundColor Gray


    Write-Host ''
    Write-Host '  2. TRUY VAN & KIEM TRA HE THONG (SYSTEM & QUERY):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 sync [-Line <Line>]       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Quet phat hien cac Lot bi ket pipeline dong bo POP -> MES (IsTransferred=0)' -ForegroundColor Gray
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
    Write-Host '     .\mes.ps1 audit-l1                  ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem toan do tin cay tuyet doi giua L1 Quick Matrix va Live DB' -ForegroundColor Yellow
    Write-Host '     .\mes.ps1 locks [-Profile <Name>]   ' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi real-time cac khoa blocking, U-locks, deadlocks tren 15 CSDL' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 b598-price [-Target <Code>]' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi nhanh don gia USD & ty le can hardcode trong SP usp_vn_showproductionerror' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 validate-excel <File.xlsx> [-Route F330|B598]' -ForegroundColor Green
    Write-Host '-> Kiem toan pre-flight file Excel, bat loi lech cot (Ma khay E04, E05 vao StartPeriod)' -ForegroundColor Yellow
    Write-Host '     .\mes.ps1 query "<SELECT_SQL>"      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Chay cau SELECT an toan (kem NOLOCK warning & Multi-DB)' -ForegroundColor Gray

    Write-Host ''
    Write-Host '  3. KHAC PHUC SU CO & TRIEN KHAI (HOTFIX & DEPLOY):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 unlock <Machine> [-Deploy]' -NoNewline -ForegroundColor Yellow
    Write-Host '-> Mo khoa giai phong may POP Kiosk bi ket ACTIVE (1-Shot < 0.5s)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-movedate -Lots "..." -TargetDate "yyyy-MM-dd" [-Hours 10] [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL chuyen ngay chot B782 cat ca 10:00 AM chuan Author/ChangeUserID vanduc' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-electrode -Lots "..." [-Type Slitting|Mixing] [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL xoa cuon/me tron dien cuc B552 & reset IsLineInput cuon me an toan' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-rollback -Lots "..." [-Route "V-22_HY"] [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL rollback luot chot cong doan ket B530 / POP Kiosk an toan' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-pop-clone -Lots "..." [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL xoa dong tu sinh CompleteRoute IS NULL de mo chot POP Kiosk (Cap thu Aging)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-cancel-pack -Target "<Lot>" [-BoxId "<Box>"] [-PackingId "<PK>"] [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL huy le tung Box/Pack dong goi (STB_MaterialDocLotInfo, STB_ProdRouteHist, PO)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 swap-machine -Lots "..." -Machine "<M>" [-Route "<R>"] [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL doi may nham Kiosk dong bo ca STB_ProdRouteHist va MongoToMesPerformance (Rule 20.1)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-defect-null -Lots "..." [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL chuan hoa RepairQty = 0 de hien thi lai cot NG bi trang do logic NULL tren B782' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-lineinput -Lots "..." [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL kich hoat lai IsLineInput = 1 cho Lot bi ket khong vao duoc chuyen' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 fix-solution -Lots "..." [-Deploy]' -ForegroundColor Yellow
    Write-Host '-> Sinh SQL cap cuu khoi phuc thung dung dich dien giai 150kg bi auto-exhaust ve 0kg' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 new-fix <Name> [-Template <b552|b782|rollback|swap-machine|force-stock|clone-defect|pqc|thick|packing-id>]' -ForegroundColor Green
    Write-Host '-> Sinh template SQL Fix chuan (ho tro B552, B782, Rollback, Doi may Kiosk, Cuong che ton kho, Clone phe, PQC, Do day)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 deploy <Path.sql> [-Force]' -NoNewline -ForegroundColor Green
    Write-Host '-> Deploy SQL an toan (Tu dong Snapshot Pre-flight backup)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 clean                     ' -NoNewline -ForegroundColor Green
    Write-Host '-> Don dep scratch workspace, kiem tra an toan token & git status' -ForegroundColor Gray

    Write-Host ''
    Write-Host '  4. NANG SUAT & TU DONG HOA IT (IT AUTOMATION):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 weekly-report [-StartDate "..." -EndDate "..."] [-ViewOnly]' -ForegroundColor Yellow
    Write-Host '-> Tu dong soan Bao Cao Tuan IT (CSV tai Desktop/thanks_and_ojt_reports, phan loai REMARK MES/GW/ECM/HW)' -ForegroundColor Green

    Write-Host ''
    Write-Host '  5. TRO LY DI DONG & QUAN LY BOT (TELEGRAM):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 bot                       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Khoi dong Telegram Assistant tren Console' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 bot-hidden                ' -NoNewline -ForegroundColor Green
    Write-Host '-> Khoi dong Bot ngam an toan co lockfile chong 409' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 bot-status                ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra trang thai Bot dang chay hay dung' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 bot-stop                  ' -NoNewline -ForegroundColor Green
    Write-Host '-> Dung an toan tien trinh Bot Telegram' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 watchdog-hidden           ' -NoNewline -ForegroundColor Green
    Write-Host '-> Bat Auto-Pilot Watchdog tuan tra 24/7 & tu ban alert Telegram' -ForegroundColor Yellow
    Write-Host '     .\mes.ps1 watchdog-status           ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra trang thai Watchdog' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 watchdog-stop             ' -NoNewline -ForegroundColor Green
    Write-Host '-> Dung an toan tien trinh Watchdog' -ForegroundColor Gray

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
elseif ($cmdLower -eq 'shell' -or $cmdLower -eq 'repl') {
    $shellScript = Join-Path $toolsDir 'mes_shell.ps1'
    if (Test-Path $shellScript) {
        & $shellScript
    } else {
        Write-Error 'tools/mes_shell.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'pop') {
    $popScript = Join-Path $scriptDir 'pop.ps1'
    if (Test-Path $popScript) {
        Write-Host "-> [MES Hub] Chuyen tiep toi POP Kiosk CLI Hub: .\pop.ps1 $Target..." -ForegroundColor DarkCyan
        & $popScript $Target @args
    } else {
        Write-Error 'pop.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'nvl' -or $cmdLower -eq 'bom') {
    $targetVal = if ($Target) { $Target } else { $Lots }
    if ([string]::IsNullOrWhiteSpace($targetVal)) {
        Write-Host "Loi: Vui long nhap ma Lot hoac ma PO can tra cuu BOM NVL!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 nvl 'VVQR253R018601'" -ForegroundColor Yellow
        Write-Host "       .\mes.ps1 nvl '260829000018'" -ForegroundColor Yellow
        exit 1
    }
    $nvlScript = Join-Path $toolsDir 'inspect_nvl_bom.ps1'
    if (Test-Path $nvlScript) {
        & $nvlScript $targetVal
    } else {
        Write-Error 'tools/inspect_nvl_bom.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'trace' -or $cmdLower -eq 'pop-trace') {
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Show-MesBanner
        Write-Host 'Loi: Vui long nhap ma can truy vet (Lot, Line, Thiet bi, hoac Thung PackingID)!' -ForegroundColor Red
        Write-Host 'Vi du: .\mes.ps1 trace "VVQR153R060615"' -ForegroundColor Yellow
        Write-Host '       .\mes.ps1 trace "VVC-10"' -ForegroundColor Yellow
        Write-Host '       .\mes.ps1 trace "PKQR1900142"' -ForegroundColor Yellow
        exit 1
    }

    $popTraceScript = Join-Path $toolsDir 'pop_trace.ps1'
    if (Test-Path $popTraceScript) {
        & $popTraceScript -Target $Target
    } else {
        Write-Error 'tools/pop_trace.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'lineage') {
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Show-MesBanner
        Write-Host 'Loi: Vui long nhap ma can truy vet huyet mach (Lot, Barcode hoac PO)!' -ForegroundColor Red
        Write-Host 'Vi du: .\mes.ps1 lineage "VVQR153R060615"' -ForegroundColor Yellow
        exit 1
    }

    $lineageScript = Join-Path $toolsDir 'trace_lineage.ps1'
    if (Test-Path $lineageScript) {
        & $lineageScript -Target $Target
    } else {
        Write-Error 'tools/trace_lineage.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'screen' -or $cmdLower -eq 'diagnose') {
    $diagScript = Join-Path $toolsDir 'mes_diagnose.py'
    if (Test-Path $diagScript) {
        python $diagScript "$Target"
    } else {
        Write-Error 'tools/mes_diagnose.py not found.'
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
    $tplParamLower = if ($Template) { $Template.ToLower() } else { '' }

    if ($tplParamLower -eq 'b552' -or $tplParamLower -eq 'electrode' -or $targetLower -match 'b552|electrode|mixing|slitting') {
        $tplName = 'template_B552_ELECTRODE_CLEANUP.sql'
    }
    elseif ($tplParamLower -eq 'b782' -or $tplParamLower -eq 'movedate' -or $targetLower -match 'b782|movedate|move_date') {
        $tplName = 'template_B782_MOVE_JOBDATE.sql'
    }
    elseif ($tplParamLower -eq 'rollback' -or $targetLower -match 'rollback') {
        $tplName = 'template_B782_B530_ROLLBACK_CHOT.sql'
    }
    elseif ($tplParamLower -match 'swap-machine|machine|doi-may' -or $targetLower -match 'machine|doi_may|doi-may') {
        $tplName = 'template_SWAP_MACHINE_CODE.sql'
    }
    elseif ($tplParamLower -match 'force-stock|roll-stock|cuong-che' -or $targetLower -match 'force_stock|roll_stock|cuong_che') {
        $tplName = 'template_FORCE_ROLL_STOCK.sql'
    }
    elseif ($tplParamLower -match 'clone-defect|defect-group|phe' -or $targetLower -match 'defect|clone_defect') {
        $tplName = 'template_CLONE_DEFECT_GROUP.sql'
    }
    elseif ($tplParamLower -match 'pqc|fix-pqc|route-pqc' -or $targetLower -match 'pqc') {
        $tplName = 'template_FIX_PQC_INSP_ROUTE.sql'
    }
    elseif ($tplParamLower -match 'thick|do-day|cut-button' -or $targetLower -match 'thick|do_day') {
        $tplName = 'template_FIX_ELECTRODE_THICKNESS.sql'
    }
    elseif ($tplParamLower -match 'packing-id|label' -or $targetLower -match 'packing_id|label') {
        $tplName = 'template_GENERATE_POP_PACKING_ID.sql'
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
elseif ($cmdLower -eq 'audit-l1' -or $cmdLower -eq 'audit-matrix') {
    $auditL1Script = Join-Path $toolsDir 'audit_l1_cache.ps1'
    if (Test-Path $auditL1Script) {
        & $auditL1Script
    } else {
        Write-Error 'tools/audit_l1_cache.ps1 not found.'
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
elseif ($cmdLower -eq 'sync') {
    Show-MesBanner
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
elseif ($cmdLower -eq 'gw' -or $cmdLower -eq 'gw-trace') {
    $targetVal = if ($Target) { $Target } else { $Lots }
    if ([string]::IsNullOrWhiteSpace($targetVal)) {
        Write-Host "Loi: Vui long nhap ma can truy vet Groupware (PO / Ma Van Ban / Nhan Vien / Vat Tu)!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 gw '260829000018'" -ForegroundColor Yellow
        Write-Host "       .\mes.ps1 gw 'PO202606001'" -ForegroundColor Yellow
        exit 1
    }
    $processRoot = Split-Path -Parent $scriptDir
    $gwTraceScript = Join-Path $processRoot 'GROUPWARE\tools\gw_trace.ps1'
    if (Test-Path $gwTraceScript) {
        & $gwTraceScript -Target $targetVal
    } else {
        Write-Error "Khong tim thay script: $gwTraceScript"
    }
}
elseif ($cmdLower -eq 'gw-form' -or $cmdLower -eq 'form') {
    $processRoot = Split-Path -Parent $scriptDir
    $gwScript = Join-Path $processRoot 'GROUPWARE\gw.ps1'
    if (Test-Path $gwScript) {
        & $gwScript form $Target
    } else {
        Write-Error "Khong tim thay script: $gwScript"
    }
}
elseif ($cmdLower -eq 'gw-chain' -or $cmdLower -eq 'chain') {
    $processRoot = Split-Path -Parent $scriptDir
    $gwScript = Join-Path $processRoot 'GROUPWARE\gw.ps1'
    if (Test-Path $gwScript) {
        & $gwScript chain $Target
    } else {
        Write-Error "Khong tim thay script: $gwScript"
    }
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
elseif ($cmdLower -eq 'unlock' -or $cmdLower -eq 'unlock-machine' -or $cmdLower -eq 'release-machine') {
    $unlockScript = Join-Path $toolsDir 'unlock_machine.ps1'
    if (Test-Path $unlockScript) {
        $params = @{}
        $targetMachine = if ($Machine) { $Machine } else { $Target }
        if ($targetMachine) { $params['Machine'] = $targetMachine }
        if ($Line) { $params['Line'] = $Line }
        if ($Deploy -or $Force) { $params['Deploy'] = $true }
        & $unlockScript @params
    } else {
        Write-Error 'tools/unlock_machine.ps1 not found.'
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
elseif ($cmdLower -eq 'bot-hidden') {
    $vbsScript = Join-Path $scriptDir 'start_telegram_bot_hidden.vbs'
    if (Test-Path $vbsScript) {
        Write-Host "(*) Dang khoi dong Bot Telegram chay ngam..." -ForegroundColor Cyan
        cscript //nologo $vbsScript
        Start-Sleep -Seconds 1
        & (Join-Path $scriptDir 'mes.ps1') bot-status
    } else {
        Write-Error 'start_telegram_bot_hidden.vbs not found.'
    }
}
elseif ($cmdLower -eq 'bot-status') {
    $lockFile = Join-Path $toolsDir '.bot.lock'
    if (Test-Path $lockFile) {
        $pidText = (Get-Content $lockFile -Raw).Trim()
        $proc = Get-Process -Id $pidText -ErrorAction SilentlyContinue
        if ($proc) {
            $memMb = [math]::Round($proc.WorkingSet64 / 1MB, 2)
            $startTime = $proc.StartTime.ToString('yyyy-MM-dd HH:mm:ss')
            Write-Host "-> [ONLINE] Bot Telegram dang hoat dong voi PID: $pidText (RAM: $memMb MB, Started: $startTime)" -ForegroundColor Green
        } else {
            Write-Host "-> [STALE LOCK] File .bot.lock ton tai (PID: $pidText) nhung tien trinh da dung." -ForegroundColor Yellow
            Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            Write-Host "   Da tu dong thu hoi file lock moi." -ForegroundColor Gray
        }
    } else {
        $procs = Get-CimInstance Win32_Process -Filter "Name LIKE '%python%'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match 'mes_telegram_bot' }
        if ($procs) {
            Write-Host "-> [ONLINE] Phat hien Bot Telegram dang chay ngoai lockfile (PID: $($procs.ProcessId))" -ForegroundColor Yellow
        } else {
            Write-Host "-> [OFFLINE] Bot Telegram hien khong chay." -ForegroundColor Gray
            Write-Host "   - Khoi dong che do console : .\mes.ps1 bot" -ForegroundColor Cyan
            Write-Host "   - Khoi dong che do chay ngam: .\mes.ps1 bot-hidden" -ForegroundColor Cyan
        }
    }
}
elseif ($cmdLower -eq 'bot-stop') {
    $lockFile = Join-Path $toolsDir '.bot.lock'
    $stopped = $false
    if (Test-Path $lockFile) {
        $pidText = (Get-Content $lockFile -Raw).Trim()
        $proc = Get-Process -Id $pidText -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Id $pidText -Force -ErrorAction SilentlyContinue
            Write-Host "-> Da dung tien trinh Bot Telegram (PID: $pidText)." -ForegroundColor Green
            $stopped = $true
        }
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
    $procs = Get-CimInstance Win32_Process -Filter "Name LIKE '%python%'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match 'mes_telegram_bot' }
    foreach ($p in $procs) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "-> Da dung tien trinh Bot phu (PID: $($p.ProcessId))." -ForegroundColor Green
        $stopped = $true
    }
    if (-not $stopped) {
        Write-Host "-> Khong tim thay tien trinh Bot Telegram nao dang hoat dong." -ForegroundColor Gray
    }
}
elseif ($cmdLower -eq 'watchdog') {
    $wdScript = Join-Path $toolsDir 'mes_watchdog.py'
    if (Test-Path $wdScript) {
        python -u $wdScript
    } else {
        Write-Error 'tools/mes_watchdog.py not found.'
    }
}
elseif ($cmdLower -eq 'watchdog-once') {
    $wdScript = Join-Path $toolsDir 'mes_watchdog.py'
    if (Test-Path $wdScript) {
        python $wdScript --once
    } else {
        Write-Error 'tools/mes_watchdog.py not found.'
    }
}
elseif ($cmdLower -eq 'watchdog-hidden') {
    $wdScript = Join-Path $toolsDir 'mes_watchdog.py'
    if (Test-Path $wdScript) {
        Write-Host "(*) Dang khoi dong Auto-Pilot Watchdog chay ngam..." -ForegroundColor Cyan
        Start-Process python -ArgumentList "-u", $wdScript -WindowStyle Hidden
        Start-Sleep -Seconds 1
        & (Join-Path $scriptDir 'mes.ps1') watchdog-status
    } else {
        Write-Error 'tools/mes_watchdog.py not found.'
    }
}
elseif ($cmdLower -eq 'watchdog-status') {
    $lockFile = Join-Path $toolsDir '.watchdog.lock'
    if (Test-Path $lockFile) {
        $pidText = (Get-Content $lockFile -Raw).Trim()
        $proc = Get-Process -Id $pidText -ErrorAction SilentlyContinue
        if ($proc) {
            $memMb = [math]::Round($proc.WorkingSet64 / 1MB, 2)
            $startTime = $proc.StartTime.ToString('yyyy-MM-dd HH:mm:ss')
            Write-Host "-> [ONLINE] Auto-Pilot Watchdog dang hoat dong voi PID: $pidText (RAM: $memMb MB, Started: $startTime)" -ForegroundColor Green
        } else {
            Write-Host "-> [STALE LOCK] File .watchdog.lock ton tai (PID: $pidText) nhung tien trinh da dung." -ForegroundColor Yellow
            Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
            Write-Host "   Da tu dong thu hoi file lock moi." -ForegroundColor Gray
        }
    } else {
        Write-Host "-> [OFFLINE] Auto-Pilot Watchdog hien khong chay." -ForegroundColor Gray
        Write-Host "   - Khoi dong che do console: .\mes.ps1 watchdog" -ForegroundColor Cyan
        Write-Host "   - Khoi dong che do ngam   : .\mes.ps1 watchdog-hidden" -ForegroundColor Cyan
        Write-Host "   - Tuan tra 1 lan thu nghiem: .\mes.ps1 watchdog-once" -ForegroundColor Cyan
    }
}
elseif ($cmdLower -eq 'watchdog-stop') {
    $lockFile = Join-Path $toolsDir '.watchdog.lock'
    $stopped = $false
    if (Test-Path $lockFile) {
        $pidText = (Get-Content $lockFile -Raw).Trim()
        $proc = Get-Process -Id $pidText -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Id $pidText -Force -ErrorAction SilentlyContinue
            Write-Host "-> Da dung tien trinh Auto-Pilot Watchdog (PID: $pidText)." -ForegroundColor Green
            $stopped = $true
        }
        Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    }
    $procs = Get-CimInstance Win32_Process -Filter "Name LIKE '%python%'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match 'mes_watchdog' }
    foreach ($p in $procs) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "-> Da dung tien trinh Watchdog phu (PID: $($p.ProcessId))." -ForegroundColor Green
        $stopped = $true
    }
    if (-not $stopped) {
        Write-Host "-> Khong tim thay tien trinh Auto-Pilot Watchdog nao dang hoat dong." -ForegroundColor Gray
    }
}
elseif ($cmdLower -eq 'diagnose' -or $cmdLower -eq 'diag' -or $cmdLower -eq 'chan-doan') {
    $diagScript = Join-Path $toolsDir 'mes_diagnose.py'
    if (Test-Path $diagScript) {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Write-Host 'Loi: Vui long nhap noi dung loi, ma Lot hoac ma man hinh can chan doan!' -ForegroundColor Red
            Write-Host 'Vi du: .\mes.ps1 diagnose "B530 ket so luong"' -ForegroundColor Yellow
            Write-Host '       .\mes.ps1 diagnose "This route is already completed in MES"' -ForegroundColor Yellow
            Write-Host '       .\mes.ps1 diagnose "VVQR153R060615"' -ForegroundColor Yellow
            exit 1
        }
        python $diagScript $Target
    } else {
        Write-Error 'tools/mes_diagnose.py not found.'
    }
}
elseif ($cmdLower -eq 'fix-movedate' -or $cmdLower -eq 'fix-date') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma Lot can chuyen ngay!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-movedate -Lots 'VVQR153R825707,VVQR153R825706' -TargetDate '2026-09-22'" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action movedate -Lots $lotsVal -TargetDate $TargetDate -Hours $Hours -Route $Route -DeployNow
    } else {
        & $fixScript -Action movedate -Lots $lotsVal -TargetDate $TargetDate -Hours $Hours -Route $Route
    }
}
elseif ($cmdLower -eq 'fix-electrode' -or $cmdLower -eq 'fix-elec') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma cuon hoac me tron can xoa!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-electrode -Lots 'VVQR0720001' -Type Slitting" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action electrode -Lots $lotsVal -Type $Type -DeployNow
    } else {
        & $fixScript -Action electrode -Lots $lotsVal -Type $Type
    }
}
elseif ($cmdLower -eq 'fix-rollback') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma Lot can rollback cong doan!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-rollback -Lots 'VVQR153R060615' -Route 'V-22_HY'" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action rollback-route -Lots $lotsVal -Route $Route -DeployNow
    } else {
        & $fixScript -Action rollback-route -Lots $lotsVal -Route $Route
    }
}
elseif ($cmdLower -eq 'fix-pop-clone' -or $cmdLower -eq 'fix-clone') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma Lot can xoa dong tu sinh CompleteRoute IS NULL!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-pop-clone -Lots 'VVQR073R072777,VVQR073R072765' -Deploy" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action clean-pop-clone -Lots $lotsVal -DeployNow
    } else {
        & $fixScript -Action clean-pop-clone -Lots $lotsVal
    }
}
elseif ($cmdLower -eq 'fix-cancel-pack' -or $cmdLower -eq 'fix-pack') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma Lot can huy le pack!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-cancel-pack -Target 'VVQR143R060619' -BoxId 'ECVT30-260QR2300003'" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action cancel-pack -Lots $lotsVal -Route $Route -BoxId $BoxId -PackingId $PackingId -Qty $Qty -DeployNow
    } else {
        & $fixScript -Action cancel-pack -Lots $lotsVal -Route $Route -BoxId $BoxId -PackingId $PackingId -Qty $Qty
    }
}
elseif ($cmdLower -eq 'swap-machine' -or $cmdLower -eq 'fix-machine') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal) -or [string]::IsNullOrWhiteSpace($Machine)) {
        Write-Host "Loi: Bắt buộc cung cấp mã Lot (-Lots) và mã máy mới (-Machine)!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 swap-machine -Lots 'VVQR253R018601' -Machine 'VVMHY130' -Route 'V-22' [-Deploy]" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action swap-machine -Lots $lotsVal -Machine $Machine -Route $Route -DeployNow
    } else {
        & $fixScript -Action swap-machine -Lots $lotsVal -Machine $Machine -Route $Route
    }
}
elseif ($cmdLower -eq 'fix-defect-null' -or $cmdLower -eq 'fix-defect') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma Lot can chuan hoa RepairQty = 0!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-defect-null -Lots 'VVQR153R060615' [-Deploy]" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action fix-defect-null -Lots $lotsVal -DeployNow
    } else {
        & $fixScript -Action fix-defect-null -Lots $lotsVal
    }
}
elseif ($cmdLower -eq 'fix-lineinput') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma Lot can kich hoat lai IsLineInput = 1!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-lineinput -Lots 'VVQR153R060615' [-Deploy]" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action fix-lineinput -Lots $lotsVal -DeployNow
    } else {
        & $fixScript -Action fix-lineinput -Lots $lotsVal
    }
}
elseif ($cmdLower -eq 'fix-solution') {
    $fixScript = Join-Path $toolsDir 'generate_safe_hotfix.ps1'
    $lotsVal = if ($Lots) { $Lots } else { $Target }
    if ([string]::IsNullOrWhiteSpace($lotsVal)) {
        Write-Host "Loi: Vui long cung cap ma thung dung dich hoac ma Lot can khoi phuc 150kg!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 fix-solution -Lots 'CRECO85-03-2401' [-Deploy]" -ForegroundColor Yellow
        exit 1
    }
    if ($Deploy) {
        & $fixScript -Action fix-solution -Lots $lotsVal -DeployNow
    } else {
        & $fixScript -Action fix-solution -Lots $lotsVal
    }
}
elseif ($cmdLower -eq 'weekly-report' -or $cmdLower -eq 'report-it') {
    $rptScript = Join-Path $toolsDir 'it_weekly_report.ps1'
    if (Test-Path $rptScript) {
        if ($ViewOnly) {
            & $rptScript -StartDate $TargetDate -ViewOnly
        } else {
            & $rptScript -StartDate $TargetDate
        }
    } else {
        Write-Error 'tools/it_weekly_report.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'locks' -or $cmdLower -eq 'db-locks') {
    $lScript = Join-Path $toolsDir 'inspect_db_locks.ps1'
    if (Test-Path $lScript) {
        $targetProfile = if ($Target) { $Target } else { $Profile }
        & $lScript -Profile $targetProfile
    } else {
        Write-Error 'tools/inspect_db_locks.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'b598-price' -or $cmdLower -eq 'scrap-price') {
    $pScript = Join-Path $toolsDir 'inspect_b598_price.ps1'
    if (Test-Path $pScript) {
        & $pScript -MaterialCode $Target
    } else {
        Write-Error 'tools/inspect_b598_price.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'validate-excel' -or $cmdLower -eq 'check-excel') {
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Show-MesBanner
        Write-Host "Loi: Vui long nhap duong dan toi file Excel can kiem tra!" -ForegroundColor Red
        Write-Host "Vi du: .\mes.ps1 validate-excel 'C:\Users\...\import.xlsx' -Route F330" -ForegroundColor Yellow
        exit 1
    }
    $targetScreen = if ($Route) { $Route } else { 'F330' }
    $vScript = Join-Path $toolsDir 'validate_excel_import.ps1'
    if (Test-Path $vScript) {
        & $vScript -FilePath $Target -Screen $targetScreen
    } else {
        Write-Error 'tools/validate_excel_import.ps1 not found.'
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

    # 3. Kiem tra va tieu diet zombie process ngam (Powershell/Python orphan chay > 60s gay ru quat CPU)
    Write-Host '(*) Kiem tra va tieu diet cac tien trinh ngam chay qua han (Zombie CPU Cleanup)...' -ForegroundColor Cyan
    $zombieCount = 0
    $bgProcs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { 
        ($_.Name -match 'powershell|python' -and $_.CommandLine -match 'mes_diagnose|pop_trace|watchdog|inspect_') -and
        $_.ProcessId -ne $PID
    }
    if ($bgProcs) {
        foreach ($zp in $bgProcs) {
            try {
                Stop-Process -Id $zp.ProcessId -Force -ErrorAction SilentlyContinue
                Write-Host "   -> Da dung tien trinh ngam tre (PID: $($zp.ProcessId), CMD: $($zp.Name))" -ForegroundColor Yellow
                $zombieCount++
            } catch {}
        }
    }
    if ($zombieCount -gt 0) {
        Write-Host "-> Da giai phong $zombieCount tien trinh ngam, bao ve CPU & quat laptop." -ForegroundColor Green
    } else {
        Write-Host "-> Khong co tien trinh ngam nao gay qua tai CPU." -ForegroundColor Green
    }

    # 4. Kiem tra Git Working Tree
    Write-Host ''
    Write-Host '(*) Trang thai Git Working Tree:' -ForegroundColor Cyan
    git status --short
    Write-Host ''
    Write-Host '-> Hoan tat kiem tra & don dep Workspace.' -ForegroundColor Green
}

else {
    # ==============================================================================
    # SMART AUTO-ROUTER (TOAN NANG 1-SHOT CHO POP & MES)
    # Tu dong nhan dien moi loai ma / loi ma khong can go ten lenh
    # ==============================================================================
    
    # 1. Kiem tra neu la ma man hinh (B530, B540, C443, B782, B552, C141...)
    if ($Command -match '^[BCbc]\d{3}[A-Za-z]?$') {
        Write-Host "-> Tu dong nhan dien '$Command' la ma man hinh MES. Tien hanh tra cuu & chan doan..." -ForegroundColor Yellow
        $diagScript = Join-Path $toolsDir 'mes_diagnose.py'
        if (Test-Path $diagScript) {
            python $diagScript $Command
            exit 0
        }
    }
    
    # 2. Kiem tra neu la mo ta su co / loi pho bien
    if ($Command -match '(HOLD|Already completed|Socket|ACTIVE|Bi khoa|Thieu|Thickness|DayPlan|Transferred|Khong the|Loi|Error)') {
        Write-Host "-> Tu dong nhan dien mo ta su co: '$Command'. Tien hanh chan doan 4 Dong Vang..." -ForegroundColor Yellow
        $diagScript = Join-Path $toolsDir 'mes_diagnose.py'
        if (Test-Path $diagScript) {
            python $diagScript "$Command $Target"
            exit 0
        }
    }

    # 3. Kiem tra neu la Lenh San Xuat (PO: 12 chu so)
    if ($Command -match '^\d{12}$') {
        Write-Host "-> Tu dong nhan dien '$Command' la Lenh San Xuat (PO). Khoi chay Truy vet Huyet mach Lineage & BOM..." -ForegroundColor Yellow
        $lineageScript = Join-Path $toolsDir 'trace_lineage.ps1'
        if (Test-Path $lineageScript) {
            & $lineageScript -Target $Command
            exit 0
        }
    }

    # 4. Kiem tra neu la Ma Chung Tu / PO Groupware (GW, DOC, PO20..., EX...)
    if ($Command -match '^(GW|DOC|PO20\d{5}|EX\d+)') {
        Write-Host "-> Tu dong nhan dien '$Command' la Ma Chung Tu Groupware. Khoi chay Truy vet Groupware..." -ForegroundColor Yellow
        $processRoot = Split-Path -Parent $scriptDir
        $gwTraceScript = Join-Path $processRoot 'GROUPWARE\tools\gw_trace.ps1'
        if (Test-Path $gwTraceScript) {
            & $gwTraceScript -Target $Command
            exit 0
        }
    }

    # 5. Kiem tra neu la Ma Thiet Bi (VVMHY..., VINA..., EQ...)
    if ($Command -match '^(VVM|VINA|EQ)') {
        Write-Host "-> Tu dong nhan dien '$Command' la Ma Thiet Bi. Kiem tra trang thai Khoa & Mapping tren Kiosk..." -ForegroundColor Yellow
        $unlockScript = Join-Path $toolsDir 'unlock_machine.ps1'
        if (Test-Path $unlockScript) {
            & $unlockScript -Machine $Command
            exit 0
        }
    }

    # 6. Mac dinh toan nang: Tu dong nhan dien moi ma (Lot, Barcode, Model, QC Doc, Line, Box)
    Write-Host "-> Tu dong nhan dien '$Command' -> Khoi chay Golden Query 360 do..." -ForegroundColor Green
    $popTraceScript = Join-Path $toolsDir 'pop_trace.ps1'
    if (Test-Path $popTraceScript) {
        & $popTraceScript -Target $Command
    } else {
        Write-Error 'tools/pop_trace.ps1 not found.'
    }
}

