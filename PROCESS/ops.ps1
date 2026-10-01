# ==============================================================================
# ops.ps1 — VINATECH ENTERPRISE MASTER OPERATIONS HUB (v4.0)
# ==============================================================================
# Tong Hanh Dinh Dieu Hanh 5 Tru Cot: MES_POP | GROUPWARE | DATABASE | FINAL | .agents
# May chu: dbserver.hycap.co.kr,5398 (15 CSDL) | Kiosk POP | Web Portal
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$Command = "help",

    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$TargetArgs,

    [string]$Target = "",
    [string]$Profile = "SmartFactoryV2",
    [string]$StartDate = "",
    [string]$EndDate = "",
    [switch]$Force,
    [switch]$Detail,
    [switch]$Deploy,
    [switch]$Json
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Gộp arguments nếu chưa gán Target
if (-not $Target -and $TargetArgs) {
    $Target = ($TargetArgs -join " ").Trim()
}

$scriptDir = $PSScriptRoot
$sharedDir = Join-Path $scriptDir "tools\shared"
$sharedFile = Join-Path $sharedDir "db_shared.ps1"

if (-not (Test-Path $sharedFile)) {
    # Fallback to local MES_POP/tools/db_shared.ps1 if run from subfolder
    $sharedFile = Join-Path $scriptDir "MES_POP\tools\db_shared.ps1"
}

if (Test-Path $sharedFile) {
    . $sharedFile
} else {
    Write-Error "Cannot locate db_shared.ps1 at $sharedFile"
    exit 1
}

function Show-OpsBanner {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "         VINATECH ENTERPRISE MASTER OPERATIONS HUB (ops.ps1 v4.0)" -ForegroundColor Yellow
    Write-Host "     TONG HANH DINH DIEU HANH 5 TRU COT: MES/POP - GW - 15 DB - K-SYSTEM" -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
}

function Show-OpsHelp {
    Show-OpsBanner
    Write-Host ""
    Write-Host "(*) UNIVERSAL SMART AUTO-ROUTER: Chi can go '.\ops.ps1 <MA_BAT_KY>'" -ForegroundColor Magenta
    Write-Host "    - Ma Lot/Barcode (VVQR...)      -> Tu dong dieu phoi sang Golden Query 360 MES & POP" -ForegroundColor Gray
    Write-Host "    - So PO / Ma van ban (2608...)  -> Tu dong dieu phoi sang Groupware & ERP Lineage" -ForegroundColor Gray
    Write-Host "    - Ma thiet bi (VVMHY130...)     -> Tu dong kiem tra Kiosk POP & Machine Mapping" -ForegroundColor Gray
    Write-Host "    - Ma man hinh (B530, B782...)   -> Tu dong tra cuu WinForm MES Screen Debugger" -ForegroundColor Gray
    Write-Host "    - Ma bang / SP (STB_..., usp_)  -> Tu dong tra cuu CSDL Schema & Stored Procedure" -ForegroundColor Gray
    Write-Host "    - Module K-System (_TPR, _TMA)  -> Tu dong tra cuu phan he K-System Ace ERP" -ForegroundColor Gray
    Write-Host ""
    Write-Host "CAC LENH DIEU HANH TOAN HE THONG:" -ForegroundColor Yellow
    Write-Host "  1. .\ops.ps1 health [-Detail]      - [*] Morning 360 Patrol: Quet 15 DB, POP, MES, GW, K-Sys (<3s)" -ForegroundColor Green
    Write-Host "  2. .\ops.ps1 trace <Keyword>       - Universal 360 Trace: Tu nhan dien 10 loai thuc the" -ForegroundColor Green
    Write-Host "  3. .\ops.ps1 clean [-Force]        - Deep Workspace Purge: Don rac, log cu & tieu diet zombie process" -ForegroundColor Green
    Write-Host "  4. .\ops.ps1 audit-kb              - Anti-Drift: Kiem toan L1 Cache vs Schema DB Production thuc te" -ForegroundColor Green
    Write-Host "  5. .\ops.ps1 deploy <file.sql>     - Trien khai Hotfix: Kiem toan an toan, Pre-flight Snapshot & Transaction" -ForegroundColor Green
    Write-Host "  6. .\ops.ps1 rollback -Target <ID> - 1-Click Undo: Khoi phuc du lieu tu snapshot hotfix an toan" -ForegroundColor Green
    Write-Host "  7. .\ops.ps1 weekly-report         - Tu dong tong hop Bao Cao Tuan IT (Chuan Rule 22: POP vs MES)" -ForegroundColor Green
    Write-Host "  8. .\ops.ps1 <mes|pop|gw|db|ksys>  - Chuyen tiep lenh truc tiep den tung Sub-Hub chuyen dung" -ForegroundColor Gray
    Write-Host "================================================================================" -ForegroundColor Cyan
}

# 1. ENTERPRISE MORNING 360 PATROL HEALTH CHECK
function Invoke-EnterpriseHealthCheck {
    param ([switch]$Detail)
    Show-OpsBanner
    Write-Host "[*] DANG KHOI CHAY ENTERPRISE MORNING 360 PATROL (<3s)..." -ForegroundColor Yellow
    Write-Host ""

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $statusTable = [System.Collections.ArrayList]::new()

    # 1.1 Check 15 CSDL Server Connectivity & Latency
    $dbPingStart = [System.Diagnostics.Stopwatch]::StartNew()
    $dbOnline = $false
    $dbLatencyMs = 0
    $blockingCount = 0

    try {
        $dbConfig = Get-DbProfileConfig -Profile "SmartFactoryV2"
        $connStr = Get-ConnectionString -Profile "SmartFactoryV2"
        $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
        $conn.Open()
        $dbPingStart.Stop()
        $dbLatencyMs = [math]::Round($dbPingStart.Elapsed.TotalMilliseconds)
        $dbOnline = $true

        # Check blocking locks
        $lockCmd = $conn.CreateCommand()
        $lockCmd.CommandText = "SELECT COUNT(*) FROM sys.dm_exec_requests WITH (NOLOCK) WHERE blocking_session_id <> 0"
        $lockCmd.CommandTimeout = 5
        $blockingCount = [int]$lockCmd.ExecuteScalar()
        $conn.Close()
    } catch {
        $dbOnline = $false
    }

    $dbStatusStr = if ($dbOnline) { "ONLINE (${dbLatencyMs}ms | Locks: $blockingCount)" } else { "OFFLINE / UNREACHABLE" }
    $dbColor = if ($dbOnline -and $blockingCount -eq 0) { "Green" } elseif ($dbOnline) { "Yellow" } else { "Red" }
    Write-Host "  [1/5] [DB]  15 CSDL CLUSTER (dbserver.hycap.co.kr,5398) : " -NoNewline -ForegroundColor White
    Write-Host $dbStatusStr -ForegroundColor $dbColor

    # 1.2 Check POP Kiosk (Orphan ACTIVE machines & Sync backlog)
    $popActiveMachines = 0
    $popSyncBacklog = 0
    if ($dbOnline) {
        try {
            $popQuery = "SELECT (SELECT COUNT(*) FROM VINA_EQUIPMENT_MAPPING WITH (NOLOCK) WHERE MAPPING_STATUS = 'ACTIVE') AS ActiveMachines, (SELECT COUNT(*) FROM MongoToMesPerformance WITH (NOLOCK) WHERE IsDone = 1 AND (IsTransferred = 0 OR IsTransferred IS NULL)) AS SyncBacklog"
            $popRows = Invoke-SafeSqlQuery -Query $popQuery -Profile "SmartFactoryV2" -TimeoutSeconds 5
            if ($popRows -and $popRows.Count -gt 0) {
                $popActiveMachines = [int]$popRows[0].ActiveMachines
                $popSyncBacklog = [int]$popRows[0].SyncBacklog
            }
        } catch {}
    }
    $popStatusStr = "Machines ACTIVE: $popActiveMachines | Sync Backlog: $popSyncBacklog Lots"
    $popColor = if ($popSyncBacklog -eq 0 -and $popActiveMachines -lt 15) { "Green" } elseif ($popSyncBacklog -lt 5) { "Yellow" } else { "Red" }
    Write-Host "  [2/5] [POP] KIOSK POP XUONG (pop.vinatech.com)             : " -NoNewline -ForegroundColor White
    Write-Host $popStatusStr -ForegroundColor $popColor

    # 1.3 Check Core MES (Lot HOLD & WIP >24h)
    $mesHoldCount = 0
    $mesWipOldCount = 0
    if ($dbOnline) {
        try {
            $mesQuery = "SELECT (SELECT COUNT(*) FROM STB_SetInfo WITH (NOLOCK) WHERE Status = 'HOLD') AS HoldLots, (SELECT COUNT(*) FROM STB_ProdRouteHist WITH (NOLOCK) WHERE CompleteRoute = 0 AND MoveDate < DATEADD(DAY, -1, GETDATE())) AS OldWip"
            $mesRows = Invoke-SafeSqlQuery -Query $mesQuery -Profile "SmartFactoryV2" -TimeoutSeconds 5
            if ($mesRows -and $mesRows.Count -gt 0) {
                $mesHoldCount = [int]$mesRows[0].HoldLots
                $mesWipOldCount = [int]$mesRows[0].OldWip
            }
        } catch {}
    }
    $mesStatusStr = "Lots HOLD: $mesHoldCount | Old WIP (>24h): $mesWipOldCount"
    $mesColor = if ($mesHoldCount -eq 0 -and $mesWipOldCount -lt 50) { "Green" } elseif ($mesHoldCount -lt 5) { "Yellow" } else { "Red" }
    Write-Host "  [3/5] [MES]  CORE MES SAN XUAT (NAIS MES B-Series)          : " -NoNewline -ForegroundColor White
    Write-Host $mesStatusStr -ForegroundColor $mesColor

    # 1.4 Check Groupware (Pending documents >48h)
    $gwPendingCount = 0
    try {
        $gwQuery = "SELECT COUNT(*) FROM VINATECH_GROUP..TEAG_APPRDOC WITH (NOLOCK) WHERE DOC_STATUS = '002' AND REG_DT < DATEADD(HOUR, -48, GETDATE())"
        $gwVal = Invoke-SafeSqlScalar -Query $gwQuery -Profile "Groupware"
        if ($gwVal -ne $null) { $gwPendingCount = [int]$gwVal }
    } catch {}
    $gwStatusStr = "Pending Docs (>48h): $gwPendingCount"
    $gwColor = if ($gwPendingCount -eq 0) { "Green" } elseif ($gwPendingCount -lt 10) { "Yellow" } else { "Red" }
    Write-Host "  [4/5] [GW]  GROUPWARE BIZBOX (gw.vinatech.com)            : " -NoNewline -ForegroundColor White
    Write-Host $gwStatusStr -ForegroundColor $gwColor

    # 1.5 Check K-System Ace ERP (Smart Factory Bridge Module 132)
    $ksysStatusStr = "Module 132 Ready (CompanySeq = 1)"
    $ksysColor = "Green"
    try {
        $ksysCheck = Invoke-SafeSqlScalar -Query "SELECT COUNT(*) FROM VINATECVN.._TPR1000 WITH (NOLOCK) WHERE CompanySeq = 1" -Profile "VINATECVN"
        if ($ksysCheck -ne $null) {
            $ksysStatusStr = "Bridge Active (Records: $ksysCheck | CompanySeq = 1)"
        }
    } catch {
        $ksysStatusStr = "Standby / Web ERP Available"
        $ksysColor = "Yellow"
    }
    Write-Host "  [5/5] [KSYS] K-SYSTEM ACE ERP (evn.vinatech.com)             : " -NoNewline -ForegroundColor White
    Write-Host $ksysStatusStr -ForegroundColor $ksysColor

    $stopwatch.Stop()
    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "-> THOI GIAN QUET TOAN CUC: $([math]::Round($stopwatch.Elapsed.TotalMilliseconds)) ms | He thong hoat dong on dinh!" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan
}

# 2. UNIVERSAL SMART AUTO-ROUTER
function Invoke-UniversalRouter {
    param ([string]$Keyword)
    if ([string]::IsNullOrEmpty($Keyword)) {
        Write-Warning "Vui long nhap tu khoa tra cuu. Vi du: .\ops.ps1 trace VVQR153R060615"
        return
    }

    $kw = $Keyword.Trim()
    Write-Host "[ROUTER] Phan tich dinh dang thuc the: '$kw'..." -ForegroundColor Cyan

    # Pattern 1: Equipment / Machine Code (VVM...)
    if ($kw -match "^VVM[A-Z0-9_]+") {
        Write-Host "-> Nhan dien: [THIET BI KIOSK POP] -> Chuyen tiep toi '.\pop.ps1 trace'" -ForegroundColor Green
        $popScript = Join-Path $scriptDir "MES_POP\pop.ps1"
        & $popScript trace $kw
        return
    }

    # Pattern 2: Lot / Barcode (Starts with VV or 14-20 chars alphanumeric)
    if ($kw -match "^VV[A-Z0-9]+" -or $kw -match "^[A-Z0-9]{14,20}$") {
        Write-Host "-> Nhan dien: [LOT/BARCODE SAN XUAT] -> Chuyen tiep toi '.\mes.ps1 trace'" -ForegroundColor Green
        $mesScript = Join-Path $scriptDir "MES_POP\mes.ps1"
        & $mesScript trace $kw
        return
    }

    # Pattern 3: PO / Groupware Doc (12 digits or starts with GW/PO)
    if ($kw -match "^\d{12}$" -or $kw -match "^(PO|GW|DOC)" -or $kw -match "^FORM_") {
        Write-Host "-> Nhan dien: [GROUPWARE / PO MASTER] -> Chuyen tiep toi '.\gw.ps1 trace'" -ForegroundColor Green
        $gwScript = Join-Path $scriptDir "GROUPWARE\gw.ps1"
        & $gwScript trace $kw
        return
    }

    # Pattern 4: MES WinForm Screen ID (B530, B782, S510...)
    if ($kw -match "^(?:HN)?[a-zA-Z]\d{3}$") {
        Write-Host "-> Nhan dien: [MAN HINH MES WINFORM] -> Chuyen tiep toi '.\mes.ps1 screen'" -ForegroundColor Green
        $mesScript = Join-Path $scriptDir "MES_POP\mes.ps1"
        & $mesScript screen $kw
        return
    }

    # Pattern 5: K-System ERP Table Prefix (_TPR, _TMA, _TAC...)
    if ($kw -match "^_T[A-Z]{2,4}\d*") {
        Write-Host "-> Nhan dien: [BANG K-SYSTEM ACE] -> Chuyen tiep toi '.\ksys.ps1 schema'" -ForegroundColor Green
        $ksysScript = Join-Path $scriptDir "FINAL\ksys.ps1"
        & $ksysScript schema -Prefix $kw
        return
    }

    # Pattern 6: SQL Stored Procedure (usp_...)
    if ($kw -match "^usp_[a-zA-Z0-9_]+") {
        Write-Host "-> Nhan dien: [STORED PROCEDURE] -> Chuyen tiep toi '.\mes.ps1 sp'" -ForegroundColor Green
        $mesScript = Join-Path $scriptDir "MES_POP\mes.ps1"
        & $mesScript sp $kw
        return
    }

    # Pattern 7: Database Table (STB_..., VINA_..., T_...)
    if ($kw -match "^(STB_|VINA_|VVT_|T_)[a-zA-Z0-9_]+") {
        Write-Host "-> Nhan dien: [CSDL TABLE SCHEMA] -> Chuyen tiep toi '.\db.ps1 schema'" -ForegroundColor Green
        $dbScript = Join-Path $scriptDir "DATABASE\db.ps1"
        & $dbScript schema -Table $kw
        return
    }

    # Fallback: Tra cứu L1 Quick Matrix toàn diện
    Write-Host "-> Tu khoa tu do -> Tra cuu L1 Quick Matrix tong hop..." -ForegroundColor Yellow
    $mesScript = Join-Path $scriptDir "MES_POP\mes.ps1"
    & $mesScript find $kw
}

# 3. DEEP WORKSPACE PURGE & ZOMBIE KILLER
function Invoke-DeepClean {
    param ([switch]$Force)
    Show-OpsBanner
    Write-Host "[*] DANG KHOI CHAY DEEP WORKSPACE PURGE..." -ForegroundColor Yellow

    # Clean Scratch Directories
    $scratchDirs = @(
        (Join-Path $scriptDir "scratch"),
        (Join-Path $scriptDir "MES_POP\scratch"),
        (Join-Path $scriptDir "GROUPWARE\tools\scratch"),
        (Join-Path $scriptDir "DATABASE\scratch")
    )

    $deletedFiles = 0
    foreach ($sd in $scratchDirs) {
        if (Test-Path $sd) {
            $files = Get-ChildItem -Path $sd -File -Recurse -ErrorAction SilentlyContinue
            foreach ($f in $files) {
                Remove-Item -Path $f.FullName -Force -ErrorAction SilentlyContinue
                $deletedFiles++
            }
        }
    }
    Write-Host "  -> Da don dep $deletedFiles tep tin scratch/tam thoi." -ForegroundColor Green

    # Clean Log files >7 days
    $logDirs = @(
        (Join-Path $scriptDir "logs"),
        (Join-Path $scriptDir "MES_POP\logs")
    )
    $purgedLogs = 0
    foreach ($ld in $logDirs) {
        if (Test-Path $ld) {
            $oldLogs = Get-ChildItem -Path $ld -Filter "*.log" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
            foreach ($ol in $oldLogs) {
                Remove-Item -Path $ol.FullName -Force -ErrorAction SilentlyContinue
                $purgedLogs++
            }
        }
    }
    Write-Host "  -> Da thanh ly $purgedLogs tep log cu (>7 ngay)." -ForegroundColor Green

    # Detect Zombie Processes
    Write-Host "  -> Quet tien trinh chay ngam tren may tram..." -ForegroundColor Gray
    $zombies = Get-Process -Name "cloudflared", "node" -ErrorAction SilentlyContinue
    if ($zombies) {
        Write-Host "     Phat hien $($zombies.Count) tien trinh web/tunnel: $($zombies.Name -join ', ')" -ForegroundColor Yellow
        if ($Force) {
            $zombies | Stop-Process -Force -ErrorAction SilentlyContinue
            Write-Host "     [OK] Da tieu diet cac tien trinh chay ngam de bao ve CPU!" -ForegroundColor Green
        } else {
            Write-Host "     (Them co -Force de tieu diet cac tien trinh nay neu khong su dung Web Portal)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "     May tram hoat dong toi uu, khong co zombie process!" -ForegroundColor Green
    }

    Write-Host "[OK] Deep Workspace Purge hoan tat!" -ForegroundColor Cyan
}

# 4. 1-CLICK ROLLBACK HOTFIX
function Invoke-SafeRollback {
    param ([string]$TargetId)
    if ([string]::IsNullOrEmpty($TargetId)) {
        Write-Warning "Vui long nhap ma can hoan tac. Vi du: .\ops.ps1 rollback -Target VVQR..."
        return
    }

    $undoDir = Join-Path $scriptDir "backups\undo"
    if (-not (Test-Path $undoDir)) {
        Write-Error "Khong tim thay thu muc Undo tai $undoDir"
        return
    }

    $matchingFiles = Get-ChildItem -Path $undoDir -Filter "*$TargetId*.sql" | Sort-Object LastWriteTime -Descending
    if (-not $matchingFiles -or $matchingFiles.Count -eq 0) {
        Write-Warning "Khong tim thay script Undo nao cho Target: $TargetId trong $undoDir"
        return
    }

    $latestUndo = $matchingFiles[0]
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Yellow
    Write-Host "           PHAT HIEN SCRIPT UNDO MOI NHAT CHO TARGET: $TargetId" -ForegroundColor Yellow
    Write-Host "  Tep tin: $($latestUndo.FullName)" -ForegroundColor White
    Write-Host "  Ngay tao: $($latestUndo.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Get-Content -Path $latestUndo.FullName -Encoding UTF8 | Select-Object -First 25 | Write-Host -ForegroundColor Gray
    Write-Host "================================================================================" -ForegroundColor Yellow
    Write-Host ""

    if ($Deploy) {
        Write-Host "[*] DANG THUC THI HOAN TAC TRONG TRANSACTION..." -ForegroundColor Yellow
        $sqlText = [System.IO.File]::ReadAllText($latestUndo.FullName, [System.Text.Encoding]::UTF8).Trim()
        
        # Auto-detect profile from header
        $targetProfile = if ($Profile -and $Profile -ne "SmartFactoryV2") { $Profile } else { "SmartFactoryV2" }
        if ($sqlText -match "(?i)-- Profile:\s*(\w+)") {
            $targetProfile = $matches[1]
        }
        
        Write-Host "-> Ket noi CSDL Profile: $targetProfile" -ForegroundColor Cyan
        $connStr = Get-ConnectionString -Profile $targetProfile
        $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $sqlText
        $cmd.CommandTimeout = 30
        $cmd.ExecuteNonQuery() | Out-Null
        $conn.Close()
        Write-Host "[SUCCESS] Du lieu da duoc hoan tac ve nguyen trang tren Profile [$targetProfile]!" -ForegroundColor Green
        Write-HotfixAuditLog -System $targetProfile -Target $TargetId -Action "ROLLBACK" -ScriptFile $latestUndo.FullName -Status "REVERTED"
    } else {
        Write-Host "(Chay kem co -Deploy de thuc thi file Undo nay tren CSDL: .\ops.ps1 rollback -Target $TargetId -Deploy)" -ForegroundColor Magenta
    }
}


# 5. DISPATCH MAIN COMMAND
switch ($Command.ToLower()) {
    "help" {
        Show-OpsHelp
    }
    "health" {
        Invoke-EnterpriseHealthCheck -Detail:$Detail
    }
    "morning" {
        Invoke-EnterpriseHealthCheck -Detail:$Detail
    }
    "patrol" {
        Invoke-EnterpriseHealthCheck -Detail:$Detail
    }
    "trace" {
        Invoke-UniversalRouter -Keyword $Target
    }
    "clean" {
        Invoke-DeepClean -Force:$Force
    }
    "deploy" {
        $deployScript = Join-Path $scriptDir "MES_POP\tools\deploy_tool.ps1"
        if (-not (Test-Path $deployScript)) {
            Write-Error "Khong tim thay deploy_tool.ps1 tai $deployScript"
            exit 1
        }
        $deployParams = @{ SqlPath = $Target }
        if ($Profile) { $deployParams["Profile"] = $Profile }
        if ($Force) { $deployParams["Force"] = $true }
        & $deployScript @deployParams
    }
    "rollback" {
        Invoke-SafeRollback -TargetId $Target
    }
    "undo" {
        Invoke-SafeRollback -TargetId $Target
    }
    "mes" {
        $mesScript = Join-Path $scriptDir "MES_POP\mes.ps1"
        & $mesScript $Target @TargetArgs
    }
    "pop" {
        $popScript = Join-Path $scriptDir "MES_POP\pop.ps1"
        & $popScript $Target @TargetArgs
    }
    "gw" {
        $gwScript = Join-Path $scriptDir "GROUPWARE\gw.ps1"
        & $gwScript $Target @TargetArgs
    }
    "db" {
        $dbScript = Join-Path $scriptDir "DATABASE\db.ps1"
        & $dbScript $Target @TargetArgs
    }
    "audit-kb" {
        Show-OpsBanner
        Write-Host "[*] KHOI CHAY KIEM TOAN ANTI-DRIFT L1 CACHE & LIVE SCHEMA..." -ForegroundColor Yellow
        $mesAudit = Join-Path $scriptDir "MES_POP\tools\audit_l1_cache.ps1"
        if (Test-Path $mesAudit) {
            & $mesAudit
        }
        $dbAudit = Join-Path $scriptDir "DATABASE\tools\audit_kb_reliability.ps1"
        if (Test-Path $dbAudit) {
            & $dbAudit
        }
    }
    "weekly-report" {
        Show-OpsBanner
        Write-Host "[*] TONG HOP BAO CAO TUAN IT (EA TEAM - RULE 22)..." -ForegroundColor Yellow
        $reportScript = Join-Path $scriptDir "MES_POP\tools\it_weekly_report.ps1"
        if (Test-Path $reportScript) {
            $params = @{}
            if ($StartDate) { $params["StartDate"] = $StartDate }
            if ($EndDate) { $params["EndDate"] = $EndDate }
            & $reportScript @params
        }
    }
    "ksys" {
        $ksysScript = Join-Path $scriptDir "FINAL\ksys.ps1"
        & $ksysScript $Target @TargetArgs
    }
    default {
        # Fallback: Tự động truyền thẳng vào Universal Auto-Router
        Invoke-UniversalRouter -Keyword $Command
    }
}
