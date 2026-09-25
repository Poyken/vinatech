# ==============================================================================
# validate_excel_import.ps1 — Pre-flight Excel Validator for F330 / B598
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Position = 1)]
    [string]$Screen = 'F330'
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
$pyScript = Join-Path $toolsDir 'validate_excel.py'

if (-not (Test-Path $pyScript)) {
    Write-Host "Loi: Khong tim thay script validate_excel.py tai $pyScript" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $FilePath)) {
    Write-Host "Loi: Khong tim thay file Excel tai: $FilePath" -ForegroundColor Red
    exit 1
}

python $pyScript "$FilePath" "$Screen"
