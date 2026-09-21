# ==============================================================================
# mes_shell.ps1 — Ultra-Fast Persistent REPL Shell for Vinatech MES_POP
# Zero Cold-Start | Connection Keep-Alive | In-Memory L1 Cache Lookup (<0.05s)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $scriptDir "mes.ps1"))) {
    $scriptDir = $PSScriptRoot
}
$toolsDir = Join-Path $scriptDir "tools"
. (Join-Path $toolsDir "db_shared.ps1")

# Pre-load L1 Cache in RAM
$matrixPath = Join-Path $scriptDir "AI_AGENT_CONFIG\QUICK_MATRIX.json"
$popMatrixPath = Join-Path $scriptDir "AI_AGENT_CONFIG\POP_MATRIX.json"
$global:l1Matrix = $null
$global:l1Pop = $null

if (Test-Path $matrixPath) {
    try {
        $global:l1Matrix = Get-Content -Path $matrixPath -Encoding UTF8 -Raw | ConvertFrom-Json
    } catch {}
}
if (Test-Path $popMatrixPath) {
    try {
        $global:l1Pop = Get-Content -Path $popMatrixPath -Encoding UTF8 -Raw | ConvertFrom-Json
    } catch {}
}

# Persistent DB Connection
$activeProfile = "SmartFactoryV2"
$global:shellConn = $null

function Connect-ShellDb([string]$ProfileName) {
    if ($global:shellConn -ne $null -and $global:shellConn.State -eq 'Open') {
        try { $global:shellConn.Close() } catch {}
    }
    Write-Host "Dang ket noi CSDL profile: $ProfileName..." -ForegroundColor Cyan
    $global:shellConn = Get-DbConnection -Profile $ProfileName -Silent
    if ($global:shellConn -ne $null) {
        Write-Host "-> [ONLINE] Da ket noi CSDL: $($global:shellConn.Database) (Server: $($global:shellConn.DataSource))" -ForegroundColor Green
        return $true
    } else {
        Write-Host "-> [LOI] Khong the ket noi CSDL profile: $ProfileName!" -ForegroundColor Red
        return $false
    }
}

function Show-ShellBanner {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "       VINATECH MES_POP ULTRA-FAST PERSISTENT REPL SHELL (v1.0)       " -ForegroundColor Yellow
    Write-Host "   Zero Cold-Start | Connection Keep-Alive | In-Memory Cache (<0.05s) " -ForegroundColor White
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "Go 'help' de xem danh sach lenh, 'clear' de xoa man hinh, 'exit' de thoat." -ForegroundColor Gray
    Write-Host ""
}

function Show-ShellHelp {
    Write-Host ""
    Write-Host "CAC LENH TUC THOI (SUB-100MS RESPONSE):" -ForegroundColor Yellow
    Write-Host "  trace <Lot/Box/Machine/Line>  : Truy vet Golden Query 360 do" -ForegroundColor Green
    Write-Host "  find <Keyword>                : Tra cuu sieu toc L1 Cache trong RAM (<5ms)" -ForegroundColor Green
    Write-Host "  health [-Detail]              : Quet suc khoe CSDL truc tiep" -ForegroundColor Green
    Write-Host "  readiness                     : Kiem toan san sang chuyen 100% POP Web" -ForegroundColor Green
    Write-Host "  release [-Force]              : Khao sat hoac giai phong may POP ket" -ForegroundColor Green
    Write-Host "  query <SELECT_SQL>            : Chay query SELECT an toan truc tiep" -ForegroundColor Green
    Write-Host "  profile <SmartFactoryV2|POP..>: Chuyen CSDL profile thuong truc" -ForegroundColor Green
    Write-Host "  clear / cls                   : Xoa man hinh" -ForegroundColor Green
    Write-Host "  exit / quit / q               : Dong ket noi va thoat Shell" -ForegroundColor Green
    Write-Host ""
}

# Khoi tao ket noi dau tien
Show-ShellBanner
$null = Connect-ShellDb -ProfileName $activeProfile

# Vong lap REPL
while ($true) {
    # Check connection health, auto-reconnect if dropped
    if ($global:shellConn -eq $null -or $global:shellConn.State -ne 'Open') {
        Write-Host "(!) Phat hien mat ket noi CSDL. Dang tu dong ket noi lai..." -ForegroundColor Yellow
        $null = Connect-ShellDb -ProfileName $activeProfile
    }

    Write-Host "MES_POP [" -NoNewline -ForegroundColor Cyan
    Write-Host $activeProfile -NoNewline -ForegroundColor Green
    Write-Host "] > " -NoNewline -ForegroundColor Cyan

    $inputLine = [Console]::ReadLine()
    if ($null -eq $inputLine) { break }
    $trimmed = $inputLine.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    $parts = $trimmed -split '\s+', 2
    $cmd = $parts[0].ToLower()
    $arg = if ($parts.Length -gt 1) { $parts[1] } else { "" }

    switch ($cmd) {
        { $_ -in @("exit", "quit", "q", "bye") } {
            Write-Host "Dong ket noi CSDL va thoat Shell. Tam biet!" -ForegroundColor Yellow
            if ($global:shellConn -ne $null -and $global:shellConn.State -eq 'Open') {
                $global:shellConn.Close()
            }
            return
        }

        { $_ -in @("cls", "clear") } {
            Clear-Host
            Show-ShellBanner
            continue
        }

        { $_ -in @("help", "?") } {
            Show-ShellHelp
            continue
        }

        "profile" {
            if ([string]::IsNullOrWhiteSpace($arg)) {
                Write-Host "Vui long nhap ten profile: SmartFactoryV2, POP, Groupware, ERP, Andon..." -ForegroundColor Yellow
            } else {
                $activeProfile = $arg
                $null = Connect-ShellDb -ProfileName $activeProfile
            }
        }

        "find" {
            if ([string]::IsNullOrWhiteSpace($arg)) {
                Write-Host "Vui long nhap tu khoa tra cuu. Vi du: find B530, find VVC-10" -ForegroundColor Yellow
            } else {
                $qUpper = $arg.ToUpper().Trim()
                $found = $false
                # Check Screen in L1 RAM
                if ($global:l1Matrix -and $global:l1Matrix.screens.$qUpper) {
                    $sc = $global:l1Matrix.screens.$qUpper
                    Write-Host ""
                    Write-Host "=== [L1 RAM HIT] MAN HINH $($qUpper): $($sc.name) ===" -ForegroundColor Green
                    Write-Host "  * Module    : $($sc.module)" -ForegroundColor White
                    Write-Host "  * SP Search : $($sc.sp_get)" -ForegroundColor Cyan
                    Write-Host "  * SP Process: $($sc.sp_iud)" -ForegroundColor Cyan
                    Write-Host "  * Bang CSDL : $($sc.tables -join ', ')" -ForegroundColor Yellow
                    Write-Host "  * Cac loi thuong gap:" -ForegroundColor White
                    foreach ($prop in $sc.common_bugs.PSObject.Properties) {
                        Write-Host "    - $($prop.Name) : $($prop.Value)" -ForegroundColor Gray
                    }
                    if ($sc.fix_template) {
                        Write-Host "  * Hotfix Mau: $($sc.fix_template)" -ForegroundColor Green
                    }
                    $found = $true
                }
                # Check POP Line in L1 RAM
                if ($global:l1Pop -and $global:l1Pop.lines.$qUpper) {
                    $ln = $global:l1Pop.lines.$qUpper
                    Write-Host ""
                    Write-Host "=== [L1 POP HIT] DAY CHUYEN $qUpper ($($ln.factory)) ===" -ForegroundColor Green
                    Write-Host "  * Che do nap: $($ln.input_mode) | Che do SX: $($ln.prod_mode)" -ForegroundColor White
                    Write-Host "  * So slots  : $($ln.total_slots) (W:$($ln.winding_slots) A:$($ln.assembly_slots) S:$($ln.sleeving_slots))" -ForegroundColor Cyan
                    Write-Host "  * Trang thai: $($ln.status) - $($ln.note)" -ForegroundColor (if ($ln.status -eq 'PASS') { 'Green' } else { 'Yellow' })
                    $found = $true
                }
                # Fallback to find_kb.ps1 if not exact match
                if (-not $found) {
                    & (Join-Path $toolsDir "find_kb.ps1") -Query $arg
                }
            }
        }

        "trace" {
            if ([string]::IsNullOrWhiteSpace($arg)) {
                Write-Host "Vui long nhap ma can truy vet. Vi du: trace VVQR153R060615" -ForegroundColor Yellow
            } else {
                & (Join-Path $toolsDir "pop_trace.ps1") -Target $arg
            }
        }

        "health" {
            $isDetail = $arg -match "-Detail"
            if ($isDetail) {
                & (Join-Path $toolsDir "health_check.ps1") -Detail
            } else {
                & (Join-Path $toolsDir "health_check.ps1")
            }
        }

        "readiness" {
            & (Join-Path $toolsDir "pop_readiness.ps1") -Line $arg
        }

        "release" {
            $isForce = $arg -match "-Force"
            $lineArg = ($arg -replace "-Force", "").Trim()
            $params = @{}
            if ($lineArg) { $params['Target'] = $lineArg }
            if ($isForce) { $params['Force'] = $true }
            & (Join-Path $toolsDir "release_orphan_machines.ps1") @params
        }

        "query" {
            if ([string]::IsNullOrWhiteSpace($arg)) {
                Write-Host "Vui long nhap cau lenh SQL SELECT. Vi du: query SELECT TOP 5 * FROM STB_MaterialStock WITH(NOLOCK)" -ForegroundColor Yellow
            } else {
                $test = Test-SqlReadOnlySafety -SqlText $arg
                if (-not $test.IsValid) {
                    Write-Host "LOI: $($test.Error)" -ForegroundColor Red
                } else {
                    $warns = Get-NoLockWarnings -SqlText $arg
                    foreach ($w in $warns) { Write-Host $w -ForegroundColor Yellow }
                    Execute-SqlQuery -Connection $global:shellConn -Query $arg
                }
            }
        }

        default {
            Write-Host "Lenh khong hop le: '$cmd'. Go 'help' de xem danh sach lenh." -ForegroundColor Red
        }
    }

    $sw.Stop()
    Write-Host "-> [Thoi gian phan hoi: $($sw.ElapsedMilliseconds) ms]" -ForegroundColor DarkGray
    Write-Host ""
}
