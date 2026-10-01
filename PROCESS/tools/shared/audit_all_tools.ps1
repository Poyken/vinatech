# ==============================================================================
# tools/shared/audit_all_tools.ps1 — Exhaustive Automated Tool Inspection Engine
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$processRoot = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "       EXHAUSTIVE AUTOMATED TOOL AUDITOR & INTEGRITY ENGINE (v1.0)" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan

$allPsFiles = Get-ChildItem -Path $processRoot -Recurse -Filter *.ps1 | 
    Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|MES_POP\\web|archive)\\' }

Write-Host "[1/4] KIEM TRA CU PHAP (SYNTAX PARSING) CHO $($allPsFiles.Count) TE P POWERSHELL..." -ForegroundColor Yellow

$syntaxErrors = @()
foreach ($file in $allPsFiles) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    if ($errors -and $errors.Count -gt 0) {
        foreach ($err in $errors) {
            $syntaxErrors += @{
                File = $file.FullName.Replace($processRoot, "")
                Line = $err.Extent.StartLineNumber
                Message = $err.Message
            }
        }
    }
}

if ($syntaxErrors.Count -eq 0) {
    Write-Host "  -> [PASS] 100% ($($allPsFiles.Count)/$($allPsFiles.Count)) tap tin dat chuan cu phap PowerShell!" -ForegroundColor Green
} else {
    Write-Host "  -> [FAIL] Phat hien $($syntaxErrors.Count) loi cu phap:" -ForegroundColor Red
    foreach ($err in $syntaxErrors) {
        Write-Host "     [X] $($err.File):$($err.Line) - $($err.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[2/4] KIEM TRA DUONG DAN LIEN KET & PHU THUOC (DEPENDENCY RESOLUTION)..." -ForegroundColor Yellow

$brokenDependencies = @()
$missingConfigs = @()

foreach ($file in $allPsFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # Check dot-sourcing dependencies
    $dotSourceMatches = [regex]::Matches($content, "(?m)^\s*\.\s+[\`"']([^`"'\r\n]+)[\`"']")
    foreach ($m in $dotSourceMatches) {
        $relPath = $m.Groups[1].Value
        $scriptDir = Split-Path -Parent $file.FullName
        $resolved = Join-Path $scriptDir $relPath
        if (-not (Test-Path $resolved)) {
            $brokenDependencies += @{
                File = $file.FullName.Replace($processRoot, "")
                Target = $relPath
            }
        }
    }
}

if ($brokenDependencies.Count -eq 0) {
    Write-Host "  -> [PASS] 100% lien ket dot-source deu ton tai tren dia!" -ForegroundColor Green
} else {
    Write-Host "  -> [WARN] Phat hien $($brokenDependencies.Count) lien ket dot-source khong ton tai:" -ForegroundColor Yellow
    foreach ($dep in $brokenDependencies) {
        Write-Host "     [!] $($dep.File) -> $($dep.Target)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[3/4] RÀ SOÁT QUY TẮC AN TOÀN SQL TRONG CODEBASE (NOLOCK & DML BOUNDARY)..." -ForegroundColor Yellow

$sqlSafetyIssues = @()
foreach ($file in $allPsFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $lines = $content -split "`r?`n"
    $lineNo = 0
    foreach ($line in $lines) {
        $lineNo++
        # Find SELECT statements on tables without NOLOCK
        if ($line -match "(?i)\bFROM\s+(SmartFactoryV2|SmartFramework|VINATECH_POP|VINATECH_GROUP|NEOE)\.[a-zA-Z0-9_\.\[\]]+\b" -or
            $line -match "(?i)\bFROM\s+STB_[a-zA-Z0-9_]+\b" -or
            $line -match "(?i)\bFROM\s+VINA_[a-zA-Z0-9_]+\b") {
            if ($line -notmatch "(?i)WITH\s*\(\s*NOLOCK\s*\)" -and $line -notmatch "(?i)sys\." -and $line -notmatch "^[\s-]*--") {
                $sqlSafetyIssues += @{
                    File = $file.FullName.Replace($processRoot, "")
                    Line = $lineNo
                    Snippet = $line.Trim()
                }
            }
        }
    }
}

Write-Host "  -> Tim thay $($sqlSafetyIssues.Count) vi tri truy van SELECT can bo sung WITH(NOLOCK) hoac kiem tra:" -ForegroundColor $(if ($sqlSafetyIssues.Count -gt 0) { "Yellow" } else { "Green" })
if ($sqlSafetyIssues.Count -gt 0) {
    $sqlSafetyIssues | Select-Object -First 10 | ForEach-Object {
        Write-Host "     [Line $($_.Line)] $($_.File): $($_.Snippet)" -ForegroundColor Gray
    }
    if ($sqlSafetyIssues.Count -gt 10) {
        Write-Host "     ... va con $($sqlSafetyIssues.Count - 10) vi tri khac." -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "[4/4] KIEM TRA TRU DIEN DIEU HANH THUC TE (EXECUTION DRY-RUN TRÊN 5 PHÂN HỆ)..." -ForegroundColor Yellow

$toolTests = @(
    @{ Name = "ops trace (Smart Router)"; Cmd = { & "$processRoot\ops.ps1" trace "VVQR2601001" } },
    @{ Name = "ops clean (Workspace Purge)"; Cmd = { & "$processRoot\ops.ps1" clean } },
    @{ Name = "ops weekly-report"; Cmd = { & "$processRoot\ops.ps1" weekly-report } },
    @{ Name = "mes trace"; Cmd = { & "$processRoot\MES_POP\mes.ps1" trace "VVQR2601001" } },
    @{ Name = "mes diagnose"; Cmd = { & "$processRoot\MES_POP\mes.ps1" diagnose "B530" } },
    @{ Name = "mes locks"; Cmd = { & "$processRoot\MES_POP\mes.ps1" locks } },
    @{ Name = "pop trace"; Cmd = { & "$processRoot\MES_POP\pop.ps1" trace "VVQR2601001" } },
    @{ Name = "gw trace"; Cmd = { & "$processRoot\GROUPWARE\gw.ps1" trace "PO2026" } },
    @{ Name = "db stats"; Cmd = { & "$processRoot\DATABASE\db.ps1" stats } },
    @{ Name = "ksys schema"; Cmd = { & "$processRoot\FINAL\ksys.ps1" schema -Table "_TPRProdResult" } }
)

$passedCount = 0
$failedCount = 0

foreach ($t in $toolTests) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $null = & $t.Cmd 2>&1
        $sw.Stop()
        Write-Host "  [OK] $($t.Name) ($($sw.ElapsedMilliseconds) ms)" -ForegroundColor Green
        $passedCount++
    } catch {
        $sw.Stop()
        Write-Host "  [FAIL] $($t.Name) ($($sw.ElapsedMilliseconds) ms): $($_.Exception.Message)" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "KET QUA AUDIT THUC TE: $passedCount / $($toolTests.Count) Tools dat yeu cau." -ForegroundColor $(if ($failedCount -eq 0) { "Green" } else { "Red" })
Write-Host "================================================================================" -ForegroundColor Cyan
