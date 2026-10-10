# ==============================================================================
# sync_matrices.ps1 — VINATECH QUICK MATRIX DUAL-SYNC UTILITY
# ==============================================================================
# Đồng bộ L1 Cache Quick Matrix giữa AI Agent Core và Web Operations Portal.
# Đảm bảo Single Source of Truth (AI_AGENT_CONFIG -> web/data).
# ==============================================================================

[CmdletBinding()]
param (
    [switch]$CheckOnly,
    [switch]$Force
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $scriptDir "mes.ps1"))) {
    $scriptDir = $PSScriptRoot
}

$sourceFile = Join-Path $scriptDir "AI_AGENT_CONFIG\QUICK_MATRIX.json"
$targetFile = Join-Path $scriptDir "web\data\QUICK_MATRIX.json"

if (-not (Test-Path $sourceFile)) {
    Write-Error "Khong tim thay source file: $sourceFile"
    exit 1
}

if (-not (Test-Path $targetFile)) {
    Write-Error "Khong tim thay target file: $targetFile"
    exit 1
}

Write-Host "(*) Kiem tra tinh dong nhat giua AI Agent L1 Cache va Web Portal Data..." -ForegroundColor Cyan

# 1. Kiem tra tinh hop le JSON
try {
    $srcJson = Get-Content -Path $sourceFile -Encoding UTF8 -Raw | ConvertFrom-Json
    $srcScreenCount = ($srcJson.screens.PSObject.Properties | Measure-Object).Count
    Write-Host "  -> Source (AI_AGENT_CONFIG) : HOP LE ($srcScreenCount man hinh)" -ForegroundColor Green
} catch {
    Write-Error "Source JSON loi cu phap: $($_.Exception.Message)"
    exit 1
}

# 2. So sanh Hash MD5
$srcHash = (Get-FileHash -Path $sourceFile -Algorithm SHA256).Hash
$tgtHash = (Get-FileHash -Path $targetFile -Algorithm SHA256).Hash

if ($srcHash -eq $tgtHash) {
    Write-Host "  -> Trang thai: 100% DONG BO HOAN HAO (SHA256 Match)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  -> Phat hien DRIFT giua AI Agent va Web Portal!" -ForegroundColor Yellow
    if ($CheckOnly) {
        Write-Warning "L1 Matrix va Web Data dang bi lech (Chay .\tools\sync_matrices.ps1 de dong bo)."
        exit 2
    }
}

# 3. Dong bo du lieu
Write-Host "(*) Dang dong bo AI_AGENT_CONFIG -> web/data..." -ForegroundColor Cyan
try {
    # Sao chep noi dung voi UTF-8
    Copy-Item -Path $sourceFile -Destination $targetFile -Force
    $newTgtHash = (Get-FileHash -Path $targetFile -Algorithm SHA256).Hash
    if ($srcHash -eq $newTgtHash) {
        Write-Host "  [OK] Dong bo thanh cong 100%! Web Portal da cap nhat day du kien thuc moi nhat." -ForegroundColor Green
    } else {
        Write-Error "Dong bo that bai! Hash khong khop sau khi copy."
        exit 1
    }
} catch {
    Write-Error "Loi trong qua trinh dong bo: $($_.Exception.Message)"
    exit 1
}
