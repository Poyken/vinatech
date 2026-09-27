# ==============================================================================
# test_master_suite.ps1 — VINATECH MES MASTER BENCHMARK TEST SUITE
# Kiem tra do hoan thien, toc do phan hoi va tinh chinh xac cua toan bo Hub
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = $PSScriptRoot
$mesRoot = Split-Path -Parent $scriptDir
$mesHub = Join-Path $mesRoot 'mes.ps1'

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '     VINATECH MES MASTER BENCHMARK TEST SUITE (GOAL VERIFICATION)' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''

$totalTests = 0
$passedTests = 0
$failedTests = 0

function Assert-Test {
    param(
        [string]$TestName,
        [scriptblock]$Action,
        [string[]]$ExpectedKeywords,
        [double]$MaxSeconds = 10.0
    )
    $script:totalTests++
    Write-Host "[TEST $script:totalTests] $TestName ... " -NoNewline -ForegroundColor White
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $output = ''
    $success = $false
    $err = ''
    try {
        $output = & $Action *>&1 | Out-String
        $sw.Stop()
        $elapsed = [Math]::Round($sw.Elapsed.TotalSeconds, 2)
        
        $missing = @()
        foreach ($kw in $ExpectedKeywords) {
            if ($output -notmatch [regex]::Escape($kw)) {
                $missing += $kw
            }
        }
        
        if ($missing.Count -eq 0 -and $elapsed -le $MaxSeconds) {
            Write-Host "PASS ($elapsed s)" -ForegroundColor Green
            $script:passedTests++
            $success = $true
        } else {
            if ($missing.Count -gt 0) {
                $err = "Thieu tu khoa: $($missing -join ', ')"
            } elseif ($elapsed -gt $MaxSeconds) {
                $err = "Qua thoi gian quy dinh ($elapsed s > $MaxSeconds s)"
            }
            Write-Host "FAIL ($elapsed s)" -ForegroundColor Red
            Write-Host "       Ly do: $err" -ForegroundColor Yellow
            $script:failedTests++
        }
    } catch {
        $sw.Stop()
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $script:failedTests++
    }
}

# --- TEST 1: AUTO-ROUTER NATURAL LANGUAGE & SYMPTOMS ---
Assert-Test -TestName 'Auto-Router: Packing Label Failure Prompt' -ExpectedKeywords @('STB_PackingLabelPrintHist', 'vanduc', 'BEGIN TRAN') -MaxSeconds 7.0 -Action {
    & $mesHub 'check xem 2 ma PackingID PKQR2608180004 va PKQR2608180005 bi loi gi'
}

Assert-Test -TestName 'Auto-Router: ERP MA_USER Login Failure Prompt' -ExpectedKeywords @('P_MA_USER', 'vanduc', 'BEGIN TRAN') -MaxSeconds 4.0 -Action {
    & $mesHub 'check tai khoan ERP MA_USER cua nhan vien 92603003 khong dang nhap duoc'
}

Assert-Test -TestName 'Auto-Router: Direct Screen ID (B530)' -ExpectedKeywords @('B530') -MaxSeconds 4.0 -Action {
    & $mesHub B530
}

# --- TEST 2: GOLDEN QUERY 360 BENCHMARK ---
Assert-Test -TestName 'Golden Query 360 (trace)' -ExpectedKeywords @('POP-TRACE 360', 'STB_SetInfo', 'STB_ProdRouteHist') -MaxSeconds 15.0 -Action {
    & $mesHub trace 'VVQR253R018601'
}

# --- TEST 3: PACKAGING 360 BENCHMARK (MULTI-TARGET) ---
Assert-Test -TestName 'Packaging 360 Multi-Target (pack)' -ExpectedKeywords @('PACK-INVESTIGATOR 360', 'PKQR2608180004', 'PKQR2608180005') -MaxSeconds 8.0 -Action {
    & $mesHub pack 'PKQR2608180004 PKQR2608180005'
}

# --- TEST 4: PERSONNEL & 5-DB AUTH BENCHMARK ---
Assert-Test -TestName 'Personnel 5-DB Authentication (user)' -ExpectedKeywords @('USER-INVESTIGATOR 360', '92603003', 'SmartFramework', 'ERP') -MaxSeconds 6.0 -Action {
    & $mesHub user '92603003'
}

# --- TEST 5: BOM NVL & WAREHOUSE STOCK BENCHMARK ---
Assert-Test -TestName 'BOM NVL & Ton kho ROUTE_VN_WH vs MAIN_VN_WH (nvl)' -ExpectedKeywords @('BOM & TON KHO', 'ROUTE_VN_WH') -MaxSeconds 5.0 -Action {
    & $mesHub nvl '260829000018'
}

# --- TEST 6: SAFE HOTFIX TEMPLATE BENCHMARK ---
Assert-Test -TestName 'Safe Hotfix Generator (new-fix rollback)' -ExpectedKeywords @('BEGIN TRAN', 'ROLLBACK TRAN', 'vanduc') -MaxSeconds 4.0 -Action {
    $fixOutput = & $mesHub new-fix test_suite_sample -Template rollback *>&1 | Out-String
    if ($fixOutput -match 'Path:\s*(.+?\.sql)') {
        $filePath = $matches[1].Trim()
        if (Test-Path $filePath) {
            $fileContent = Get-Content $filePath -Raw
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
            Write-Output ($fixOutput + "`n" + $fileContent)
            return
        }
    }
    Write-Output $fixOutput
}

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "TONG KET: $passedTests / $totalTests tests PASSED!" -ForegroundColor $(if ($failedTests -eq 0) { 'Green' } else { 'Red' })
Write-Host '======================================================================' -ForegroundColor Cyan

if ($failedTests -gt 0) {
    exit 1
} else {
    exit 0
}
