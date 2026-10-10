# ==============================================================================
# pop.ps1 — VINATECH POP KIOSK UNIFIED CLI HUB (v3.0)
# Trung Tam Dieu Phoi Van Hanh, Nap NVL BOM & Su Co Kiosk POP Tai Xuong
# Author: vanduc (EA Team)
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',
    
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$TargetArgs,
    
    [string]$Target = '',
    [string]$Profile = 'SmartFactoryV2',
    [string]$Line = '',
    [string]$Machine = '',
    [string]$Route = '',
    [string]$Lots = '',
    [switch]$Deploy,
    [switch]$Force,
    [switch]$Detail,
    [switch]$Clean,
    [switch]$Json,
    [switch]$Fast
)

# Gop cac doi so con lai vao Target neu khong chi dinh tuong minh -Target
if (-not $Target -and $TargetArgs) {
    $Target = ($TargetArgs -join ' ').Trim()
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$scriptDir = $PSScriptRoot
$toolsDir = Join-Path $scriptDir 'tools'
. (Join-Path $toolsDir 'db_shared.ps1')

function Show-PopBanner {
    Write-Host ''
    Write-Host '======================================================================' -ForegroundColor Cyan
    Write-Host '             VINATECH POP KIOSK UNIFIED CLI HUB (v3.0)' -ForegroundColor Yellow
    Write-Host '    Trung Tam Dieu Phoi Van Hanh, Nap NVL BOM & Su Co Kiosk POP' -ForegroundColor White
    Write-Host '======================================================================' -ForegroundColor Cyan
}

function Show-Help {
    Show-PopBanner
    Write-Host ''
    Write-Host '(*) SMART AUTO-ROUTER: Chi can go ".\pop.ps1 <MA_BAT_KY>" - He thong tu dong nhan dien & xu ly!' -ForegroundColor Magenta
    Write-Host '    - Ma Lot / Barcode (VVQR...)  -> Tu dong chay Golden Query 360 do Kiosk POP' -ForegroundColor Gray
    Write-Host '    - So PO (260829000018 - 12 so)-> Tu dong truy vet huyet mach Lineage & BOM' -ForegroundColor Gray
    Write-Host '    - Ma thiet bi (VVMHY130...)   -> Tu dong kiem tra mapping & khoa ACTIVE' -ForegroundColor Gray
    Write-Host '    - Ma Nhan Vien (32605098...)  -> Tu dong tra cuu nhan su tren 5 CSDL' -ForegroundColor Gray
    Write-Host '    - Ma Thung (PKQS.../PK...)    -> Tu dong truy vet quy cach dong thung & in tem' -ForegroundColor Gray
    Write-Host ''
    Write-Host 'CAC LENH VAN HANH POP KIOSK CHINH:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  1. TRUY VET NAP NVL, TIEN DO & TRANG THAI KIOSK:' -ForegroundColor Cyan
    Write-Host '     .\pop.ps1 trace <Lot/PO/Line/Machine> [-Json]' -ForegroundColor Green
    Write-Host '-> Golden Query 360: Soi dinh muc BOM, Ton kho kho chuyen (ROUTE_VN_WH), Lich su nap NVL Kiosk, Tien do POP' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 nvl <Lot/PO>               ' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi nhanh dinh muc BOM, ma thay the (AltCode) va ton kho kha dung cua tung vat tu tai ROUTE_VN_WH' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 pack <Lot/PackingID>       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Truy vet dong goi & in tem PackingID 360 do tren Kiosk POP & SmartFactoryV2' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 user <EmpNo/UserId>        ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu nhan su & quyen dang nhap Kiosk tren 5 CSDL (VINA_EMP, ERP, GW, SSO)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 lineage <Target>           ' -NoNewline -ForegroundColor Green
    Write-Host '-> Truy vet huyet mach lien he thong 4 tru cot (PO/GW -> Kho NVL -> Core MES -> Kiosk POP)' -ForegroundColor Gray
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
    Write-Host '  3. GIAM SAT KHOA, CHAN DOAN & KIEM TOAN:' -ForegroundColor Cyan
    Write-Host '     .\pop.ps1 locks [-Profile <DB>]      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi khoa blocking & deadlock thoi gian thuc tren CSDL POP / MES (<1s)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 diagnose "<Text/Lot>"      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Master Auto-Diagnostic: Chan doan su co tuc thoi 1-Shot xuat 4 Dong Vang' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 health                     ' -NoNewline -ForegroundColor Green
    Write-Host '-> Morning Health Check toan dien he thong (WIP 24h, Sync pending, Locks)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 readiness / audit [-Line <L>]' -ForegroundColor Green
    Write-Host '-> Kiem toan muc do san sang 100% POP Web (Mode, Slot, ProdMode, Lock, Sync)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 check                      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra ket noi song song toi SmartFactoryV2 (MES DB) va VINATECH_POP (POP DB)' -ForegroundColor Gray
    Write-Host '     .\pop.ps1 find <Keyword>             ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu L1 Quick Matrix (<0.001s) va tai lieu POP KB Chuyen sau' -ForegroundColor Gray
    Write-Host ''
}

$cmdLower = $Command.ToLower()

switch ($cmdLower) {
    'help' {
        Show-Help
    }
    { $_ -in 'trace', 'pop-trace' } {
        $targetVal = if ($Target) { $Target } else { $Lots }
        if ([string]::IsNullOrWhiteSpace($targetVal)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma can truy vet (Lot / Barcode / PO / Machine / Line)!' -ForegroundColor Red
            exit 1
        }
        $popTraceScript = Join-Path $toolsDir 'pop_trace.ps1'
        if (Test-Path $popTraceScript) {
            & $popTraceScript -Target $targetVal -Json:$Json -Fast:$Fast
        } else {
            Write-Error "tools/pop_trace.ps1 not found."
        }
    }
    { $_ -in 'nvl', 'bom' } {
        $targetVal = if ($Target) { $Target } else { $Lots }
        if ([string]::IsNullOrWhiteSpace($targetVal)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma Lot hoac ma PO can tra cuu BOM NVL!' -ForegroundColor Red
            exit 1
        }
        $nvlScript = Join-Path $toolsDir 'inspect_nvl_bom.ps1'
        if (Test-Path $nvlScript) {
            & $nvlScript $targetVal
        } else {
            Write-Error "tools/inspect_nvl_bom.ps1 not found."
        }
    }
    { $_ -in 'pack', 'packing' } {
        $targetVal = if ($Target) { $Target } else { $Lots }
        if ([string]::IsNullOrWhiteSpace($targetVal)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma can kiem tra dong goi (Lot / PackingID)!' -ForegroundColor Red
            exit 1
        }
        $packScript = Join-Path $toolsDir 'inspect_pack.ps1'
        if (Test-Path $packScript) {
            & $packScript $targetVal
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
    'lineage' {
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Show-PopBanner
            Write-Host 'Loi: Vui long nhap ma can truy vet huyet mach (Lot, Barcode hoac PO)!' -ForegroundColor Red
            exit 1
        }
        $lineageScript = Join-Path $toolsDir 'trace_lineage.ps1'
        if (Test-Path $lineageScript) {
            & $lineageScript -Target $Target
        } else {
            Write-Error "tools/trace_lineage.ps1 not found."
        }
    }
    'locks' {
        $locksScript = Join-Path $toolsDir 'inspect_db_locks.ps1'
        if (Test-Path $locksScript) {
            & $locksScript -Profile $Profile
        } else {
            Write-Error "tools/inspect_db_locks.ps1 not found."
        }
    }
    'health' {
        $healthScript = Join-Path $toolsDir 'health_check.ps1'
        if (Test-Path $healthScript) {
            & $healthScript
        } else {
            Write-Error "tools/health_check.ps1 not found."
        }
    }
    { $_ -in 'diagnose', 'screen' } {
        $diagScript = Join-Path $toolsDir 'mes_diagnose.py'
        if (Test-Path $diagScript) {
            python $diagScript "$Target"
        } else {
            Write-Error "tools/mes_diagnose.py not found."
        }
    }
    'b598-price' {
        $b598Script = Join-Path $toolsDir 'inspect_b598_price.ps1'
        if (Test-Path $b598Script) {
            & $b598Script -Target $Target
        } else {
            Write-Error "tools/inspect_b598_price.ps1 not found."
        }
    }
    'validate-excel' {
        $valScript = Join-Path $toolsDir 'validate_excel_preflight.ps1'
        if (Test-Path $valScript) {
            & $valScript -FilePath $Target -Route $Route
        } else {
            Write-Error "tools/validate_excel_preflight.ps1 not found."
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
    'swap-machine' {
        $lotsVal = if ($Lots) { $Lots } else { $Target }
        & (Join-Path $scriptDir 'mes.ps1') swap-machine -Lots $lotsVal -Machine $Machine -Route $Route -Deploy:$Deploy
    }
    'fix-solution' {
        $lotsVal = if ($Lots) { $Lots } else { $Target }
        & (Join-Path $scriptDir 'mes.ps1') fix-solution -Lots $lotsVal -Deploy:$Deploy
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
    'clean' {
        & (Join-Path $scriptDir 'mes.ps1') clean
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
    { $_ -in 'shell', 'repl', 'weekly-report', 'sp', 'fix-movedate', 'fix-electrode', 'fix-rollback', 'fix-pop-clone', 'fix-cancel-pack', 'fix-defect-null', 'fix-lineinput', 'deploy' } {
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
        $q = if ($Target) { "$Command $Target".Trim() } else { $Command.Trim() }

        # 1. Ma PackingID (PK...)
        if ($q -match '\b(PKQR[A-Za-z0-9_-]+|PK[A-Za-z0-9_-]{4,})\b') {
            $pk = $matches[1]
            Write-Host "-> Tu dong nhan dien '$pk' la Ma PackingID. Khoi chay Truy vet Dong Goi 360..." -ForegroundColor Yellow
            $packScript = Join-Path $toolsDir 'inspect_pack.ps1'
            if (Test-Path $packScript) {
                & $packScript $pk
                exit 0
            }
        }
        
        # 2. Ma Nhan Vien (8 chu so)
        if ($q -match '\b(\d{8})\b') {
            $empNo = $matches[1]
            Write-Host "-> Tu dong nhan dien '$empNo' la Ma Nhan Vien. Khoi chay Tra cuu Nhan Su & Tai Khoan 360..." -ForegroundColor Yellow
            $userScript = Join-Path $toolsDir 'inspect_user.ps1'
            if (Test-Path $userScript) {
                & $userScript $empNo
                exit 0
            }
        }

        # 3. Lenh San Xuat (PO: 12 chu so)
        if ($q -match '\b(\d{12})\b') {
            $poNo = $matches[1]
            Write-Host "-> Tu dong nhan dien '$poNo' la Lenh San Xuat (PO). Khoi chay Truy vet Huyet mach Lineage & BOM..." -ForegroundColor Yellow
            $lineageScript = Join-Path $toolsDir 'trace_lineage.ps1'
            if (Test-Path $lineageScript) {
                & $lineageScript -Target $poNo
                exit 0
            }
        }

        # 4. Ma Thiet Bi (VVMHY..., VINA..., EQ...)
        if ($q -match '\b(VVM[A-Za-z0-9_-]+|VINA[A-Za-z0-9_-]+|EQ[A-Za-z0-9_-]+)\b') {
            $mCode = $matches[1]
            Write-Host "-> Tu dong nhan dien '$mCode' la Ma Thiet Bi. Kiem tra trang thai Khoa & Mapping tren Kiosk..." -ForegroundColor Yellow
            $unlockScript = Join-Path $toolsDir 'unlock_machine.ps1'
            if (Test-Path $unlockScript) {
                & $unlockScript -Machine $mCode -Line $Line -Deploy:$Deploy -Force:$Force
                exit 0
            }
        }

        # 5. Ma Man Hinh WinForm (B530, B782, F330...)
        if ($q -match '\b([BHF]\d{3}[A-Za-z]?)\b') {
            $screenCode = $matches[1].ToUpper()
            Write-Host "-> Tu dong nhan dien '$screenCode' la Ma Man Hinh MES. Khoi chay Master Diagnostic..." -ForegroundColor Yellow
            $diagScript = Join-Path $toolsDir 'mes_diagnose.py'
            if (Test-Path $diagScript) {
                python $diagScript $screenCode
                exit 0
            }
        }

        # 6. Fallback: Tu dong nhan dien moi ma dau vao de chay Trace
        Write-Host "-> Tu dong nhan dien '$q' -> Khoi chay Truy vet POP Kiosk 360 do..." -ForegroundColor Green
        $popTraceScript = Join-Path $toolsDir 'pop_trace.ps1'
        if (Test-Path $popTraceScript) {
            & $popTraceScript -Target $q -Json:$Json
        } else {
            Write-Error "tools/pop_trace.ps1 not found."
        }
    }
}
