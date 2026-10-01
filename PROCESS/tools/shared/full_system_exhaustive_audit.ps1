# ==============================================================================
# tools/shared/full_system_exhaustive_audit.ps1
# RUNS 100% OF ALL COMMANDS & TOOLS IN PROCESS WORKSPACE
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$processRoot = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "       VINATECH FULL-SYSTEM EXHAUSTIVE TOOL AUDITOR (100% COVERAGE)" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan

$testResults = [System.Collections.ArrayList]::new()

function Execute-Test {
    param(
        [string]$Subsystem,
        [string]$CommandName,
        [scriptblock]$Script
    )
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $err = $null
    $out = $null
    try {
        $out = & $Script 2>&1
        $sw.Stop()
        $isOk = $true
        $outStr = $out | Out-String
        if ($outStr -match "The term .* is not recognized|NullReference|Cannot find path|SyntaxError") {
            $isOk = $false
            $err = $outStr.Trim().Substring(0, [Math]::Min(150, $outStr.Trim().Length))
        }
    } catch {
        $sw.Stop()
        $isOk = $false
        $err = $_.Exception.Message
    }

    $res = [PSCustomObject]@{
        Subsystem = $Subsystem
        Command   = $CommandName
        Status    = if ($isOk) { "PASS" } else { "FAIL" }
        DurationMs = $sw.ElapsedMilliseconds
        Error     = $err
    }
    [void]$testResults.Add($res)

    if ($res.Status -eq "PASS") {
        Write-Host "  [PASS] [$Subsystem] $CommandName ($($res.DurationMs) ms)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] [$Subsystem] $CommandName ($($res.DurationMs) ms) - $err" -ForegroundColor Red
    }
}

# ------------------------------------------------------------------------------
# 1. CORE MES (mes.ps1)
# ------------------------------------------------------------------------------
Write-Host "`n[*] KIEM TRA PHAN HE CORE MES (mes.ps1)..." -ForegroundColor Yellow
Execute-Test "MES" "help" { & "$processRoot\mes.ps1" help }
Execute-Test "MES" "health" { & "$processRoot\mes.ps1" health }
Execute-Test "MES" "trace" { & "$processRoot\mes.ps1" trace "VVQR2601001" }
Execute-Test "MES" "diagnose" { & "$processRoot\mes.ps1" diagnose "VVQR2601001" }
Execute-Test "MES" "lineage" { & "$processRoot\mes.ps1" lineage "VVQR2601001" }
Execute-Test "MES" "nvl" { & "$processRoot\mes.ps1" nvl "VVQR2601001" }
Execute-Test "MES" "b598-price" { & "$processRoot\mes.ps1" b598-price -Target "BEASSY-003" }
Execute-Test "MES" "locks" { & "$processRoot\mes.ps1" locks -Profile "SmartFactoryV2" }
Execute-Test "MES" "clean" { & "$processRoot\mes.ps1" clean }
Execute-Test "MES" "find" { & "$processRoot\mes.ps1" find "B530" }
Execute-Test "MES" "weekly-report" { & "$processRoot\mes.ps1" weekly-report }
Execute-Test "MES" "screen" { & "$processRoot\mes.ps1" screen "B530" }
Execute-Test "MES" "sp" { & "$processRoot\mes.ps1" sp "usp_DoProcessProdRouteHist" }

# ------------------------------------------------------------------------------
# 2. POP KIOSK (pop.ps1)
# ------------------------------------------------------------------------------
Write-Host "`n[*] KIEM TRA PHAN HE POP KIOSK (pop.ps1)..." -ForegroundColor Yellow
Execute-Test "POP" "help" { & "$processRoot\pop.ps1" help }
Execute-Test "POP" "nvl" { & "$processRoot\pop.ps1" nvl "VVQR2601001" }
Execute-Test "POP" "trace" { & "$processRoot\pop.ps1" trace "VVQR2601001" }
Execute-Test "POP" "readiness" { & "$processRoot\pop.ps1" readiness }
Execute-Test "POP" "audit" { & "$processRoot\pop.ps1" audit }
Execute-Test "POP" "find" { & "$processRoot\pop.ps1" find "VVC-01" }

# ------------------------------------------------------------------------------
# 3. GROUPWARE (gw.ps1)
# ------------------------------------------------------------------------------
Write-Host "`n[*] KIEM TRA PHAN HE GROUPWARE (gw.ps1)..." -ForegroundColor Yellow
Execute-Test "GW" "help" { & "$processRoot\gw.ps1" help }
Execute-Test "GW" "form" { & "$processRoot\gw.ps1" form "FORM_PURCHASE_REQ" }
Execute-Test "GW" "find" { & "$processRoot\gw.ps1" find "mua hang" }
Execute-Test "GW" "health" { & "$processRoot\gw.ps1" health }
Execute-Test "GW" "check" { & "$processRoot\gw.ps1" check }
Execute-Test "GW" "audit" { & "$processRoot\gw.ps1" audit }
Execute-Test "GW" "routine" { & "$processRoot\gw.ps1" routine "GETTABLEFROMSPLIT" }

# ------------------------------------------------------------------------------
# 4. DATABASE (db.ps1)
# ------------------------------------------------------------------------------
Write-Host "`n[*] KIEM TRA PHAN HE DATABASE (db.ps1)..." -ForegroundColor Yellow
Execute-Test "DB" "help" { & "$processRoot\db.ps1" help }
Execute-Test "DB" "list" { & "$processRoot\db.ps1" list }
Execute-Test "DB" "health" { & "$processRoot\db.ps1" health }
Execute-Test "DB" "stats" { & "$processRoot\db.ps1" stats }
Execute-Test "DB" "sp" { & "$processRoot\db.ps1" sp -Name "usp_DoProcessProdRouteHist" }
Execute-Test "DB" "schema" { & "$processRoot\db.ps1" schema -Table "STB_ProdRouteHist" }
Execute-Test "DB" "find" { & "$processRoot\db.ps1" find "STB_SetInfo" }
Execute-Test "DB" "jobs" { & "$processRoot\db.ps1" jobs }
Execute-Test "DB" "triggers" { & "$processRoot\db.ps1" triggers -Table "STB_ProdRouteHist" }
Execute-Test "DB" "index" { & "$processRoot\db.ps1" index -Table "STB_ProdRouteHist" }
Execute-Test "DB" "crossdb" { & "$processRoot\db.ps1" crossdb }
Execute-Test "DB" "lineage" { & "$processRoot\db.ps1" lineage -Type "Lot" -Value "VVQR2601001" }
Execute-Test "DB" "auditkb" { & "$processRoot\db.ps1" auditkb }
Execute-Test "DB" "locks" { & "$processRoot\db.ps1" locks }

# ------------------------------------------------------------------------------
# 5. K-SYSTEM ACE ERP (ksys.ps1)
# ------------------------------------------------------------------------------
Write-Host "`n[*] KIEM TRA PHAN HE K-SYSTEM ACE ERP (ksys.ps1)..." -ForegroundColor Yellow
Execute-Test "KSYS" "help" { & "$processRoot\ksys.ps1" help }
Execute-Test "KSYS" "find" { & "$processRoot\ksys.ps1" find "Lot" }
Execute-Test "KSYS" "schema" { & "$processRoot\ksys.ps1" schema -Table "_TPRProdResult" }
Execute-Test "KSYS" "trace" { & "$processRoot\ksys.ps1" trace "VVQR2601001" }
Execute-Test "KSYS" "module" { & "$processRoot\ksys.ps1" module "8" }
Execute-Test "KSYS" "bridge" { & "$processRoot\ksys.ps1" bridge }
Execute-Test "KSYS" "health" { & "$processRoot\ksys.ps1" health }

# ------------------------------------------------------------------------------
# 6. MASTER HUB (ops.ps1)
# ------------------------------------------------------------------------------
Write-Host "`n[*] KIEM TRA TONG HANH DINH MASTER HUB (ops.ps1)..." -ForegroundColor Yellow
Execute-Test "OPS" "help" { & "$processRoot\ops.ps1" help }
Execute-Test "OPS" "health" { & "$processRoot\ops.ps1" health }
Execute-Test "OPS" "trace" { & "$processRoot\ops.ps1" trace "VVQR2601001" }
Execute-Test "OPS" "clean" { & "$processRoot\ops.ps1" clean }
Execute-Test "OPS" "audit-kb" { & "$processRoot\ops.ps1" audit-kb }
Execute-Test "OPS" "weekly-report" { & "$processRoot\ops.ps1" weekly-report }

# ------------------------------------------------------------------------------
# 7. STANDALONE SCRIPTS
# ------------------------------------------------------------------------------
Write-Host "`n[*] KIEM TRA CAC SCRIPTS DOC LAP (STANDALONE SCRIPTS)..." -ForegroundColor Yellow
Execute-Test "TOOL" "unlock_machine.ps1" { & "$processRoot\MES_POP\tools\unlock_machine.ps1" -Machine "VVMHY130" }
Execute-Test "TOOL" "inspect_b598_price.ps1" { & "$processRoot\MES_POP\tools\inspect_b598_price.ps1" }
Execute-Test "TOOL" "inspect_nvl_bom.ps1" { & "$processRoot\MES_POP\tools\inspect_nvl_bom.ps1" -Target "VVQR2601001" }
Execute-Test "TOOL" "pop_readiness.ps1" { & "$processRoot\MES_POP\tools\pop_readiness.ps1" }
Execute-Test "TOOL" "validate_sql.ps1" { & "$processRoot\MES_POP\tools\validate_sql.ps1" -SqlPath "$processRoot\tools\shared\sample_safe_test.sql" }
Execute-Test "TOOL" "DATABASE/audit_indexes.ps1" { & "$processRoot\DATABASE\tools\audit_indexes.ps1" -Table "STB_ProdRouteHist" }
Execute-Test "TOOL" "DATABASE/audit_jobs.ps1" { & "$processRoot\DATABASE\tools\audit_jobs.ps1" }
Execute-Test "TOOL" "DATABASE/audit_triggers.ps1" { & "$processRoot\DATABASE\tools\audit_triggers.ps1" -Table "STB_ProdRouteHist" }
Execute-Test "TOOL" "DATABASE/audit_cross_db.ps1" { & "$processRoot\DATABASE\tools\audit_cross_db.ps1" }
Execute-Test "TOOL" "GROUPWARE/inspect_form.ps1" { & "$processRoot\GROUPWARE\tools\inspect_form.ps1" -FormID "FORM_PURCHASE_REQ" }

# ------------------------------------------------------------------------------
# TONG KET
# ------------------------------------------------------------------------------
$passCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count
$totalCount = $testResults.Count

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "TONG KET KIEM TOAN TOAN DIEN: $passCount / $totalCount lenh DAT YEU CAU" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "================================================================================" -ForegroundColor Cyan

if ($failCount -gt 0) {
    Write-Host "DANH SACH LENH CAN KHAC PHUC ($failCount):" -ForegroundColor Red
    $testResults | Where-Object { $_.Status -eq "FAIL" } | ForEach-Object {
        Write-Host "  [X] [$($_.Subsystem)] $($_.Command) : $($_.Error)" -ForegroundColor Red
    }
}
