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
    Write-Host '     .\pop.ps1 pack <Lot/PackingID>       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Truy vet dong goi & in tem PackingID 360 do tren Kiosk POP & SmartFactoryV2' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 user <EmpNo/UserId>        ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu nhan su & quyen dang nhap Kiosk tren 5 CSDL (VINA_EMP, ERP, GW, SSO)' -ForegroundColor Gray
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
        $nvlScript = Join-Path $toolsDir 'inspect_nvl_bom.ps1'
        if (Test-Path $nvlScript) {
            & $nvlScript $Target
        } else {
            Write-Error "tools/inspect_nvl_bom.ps1 not found."
        }
    }
    { $_ -in 'pack', 'packing' } {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma can kiem tra dong goi (Lot / PackingID)!' -ForegroundColor Red
            exit 1
        }
        $packScript = Join-Path $toolsDir 'inspect_pack.ps1'
        if (Test-Path $packScript) {
            & $packScript $Target
        } else {
            Write-Error "tools/inspect_pack.ps1 not found."
        }
    }
    { $_ -in 'user', 'emp' } {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma nhan vien hoac username can tra cuu!' -ForegroundColor Red
            exit 1
        }
        $userScript = Join-Path $toolsDir 'inspect_user.ps1'
        if (Test-Path $userScript) {
            & $userScript $Target
        } else {
            Write-Error "tools/inspect_user.ps1 not found."
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
        # 1. Kiem tra neu la Ma PackingID (PK...)
        if ($Command -match '^PK') {
            Write-Host "-> Tu dong nhan dien '$Command' la Ma PackingID. Khoi chay Truy vet Dong Goi 360..." -ForegroundColor Yellow
            $packScript = Join-Path $toolsDir 'inspect_pack.ps1'
            if (Test-Path $packScript) {
                & $packScript $Command
                exit 0
            }
        }
        
        # 2. Kiem tra neu la Ma Nhan Vien (8 chu so)
        if ($Command -match '^\d{8}$') {
            Write-Host "-> Tu dong nhan dien '$Command' la Ma Nhan Vien. Khoi chay Tra cuu Nhan Su & Tai Khoan 360..." -ForegroundColor Yellow
            $userScript = Join-Path $toolsDir 'inspect_user.ps1'
            if (Test-Path $userScript) {
                & $userScript $Command
                exit 0
            }
        }

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
