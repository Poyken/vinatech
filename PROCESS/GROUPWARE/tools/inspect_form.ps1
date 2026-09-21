# ==============================================================================
# inspect_form.ps1 — Deep Form Inspector for Vinatech Groupware Ecosystem
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$FormID
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$matrixFile = Join-Path $rootDir 'AI_AGENT_CONFIG\GW_FORM_MATRIX.json'

. (Join-Path $toolsDir 'db_shared.ps1')

$fUpper = $FormID.ToUpper().Trim()
if (-not (Test-Path $matrixFile)) {
    Write-Error "Khong tim thay $matrixFile"
    exit 1
}

$matrix = Get-Content -Path $matrixFile -Encoding UTF8 -Raw | ConvertFrom-Json
$formObj = $matrix.forms.$fUpper

if (-not $formObj) {
    foreach ($prop in $matrix.forms.PSObject.Properties) {
        if ($prop.Name -like "*$fUpper*" -or $prop.Value.name -match "(?i)$fUpper") {
            $formObj = $prop.Value
            $fUpper = $prop.Name
            break
        }
    }
}

if (-not $formObj) {
    Write-Host "Khong tim thay bieu mau nao co ma: '$FormID' trong GW_FORM_MATRIX.json" -ForegroundColor Red
    Write-Host "Cac Form ID hop le:" -ForegroundColor Yellow
    ($matrix.forms.PSObject.Properties | ForEach-Object { $_.Name }) -join ', '
    exit 1
}

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Green
Write-Host "  THONG TIN CHI TIET BIEU MAU: $fUpper" -ForegroundColor Yellow
Write-Host "  Ten: $($formObj.name)" -ForegroundColor White
Write-Host '======================================================================' -ForegroundColor Green
Write-Host "  * Phan he quan ly : $($formObj.module)" -ForegroundColor White
Write-Host "  * Bang Groupware  : $($formObj.tables -join ', ')" -ForegroundColor Cyan
Write-Host "  * Bang ERP tuong ung: $($formObj.erp_tables -join ', ')" -ForegroundColor Magenta
Write-Host "  * Man hinh MES lien quan: $($formObj.mes_screens -join ', ')" -ForegroundColor Green
Write-Host "  * Tuyen duyet mac dinh : $($formObj.approval_line)" -ForegroundColor Yellow

Write-Host ''
Write-Host '  * Cac loi thuong gap va cach xu ly:' -ForegroundColor Yellow
foreach ($p in $formObj.common_errors.PSObject.Properties) {
    $errKey = $p.Name
    $errVal = $p.Value
    Write-Host "    - [$errKey] : $errVal" -ForegroundColor Gray
}

Write-Host ''
Write-Host '  * Thong ke du lieu thuc te tren CSDL VINATECH_GROUP:' -ForegroundColor Green
foreach ($tbl in $formObj.tables) {
    if ($tbl -ne 'VINA_DOCUMENT_SAVE') {
        try {
            $sqlCount = "SELECT COUNT(1) AS CNT FROM VINATECH_GROUP.dbo.$tbl WITH (NOLOCK);"
            $res = Invoke-DbQuery -Profile 'Groupware' -Query $sqlCount
            if ($res -and $res.Rows.Count -gt 0) {
                $countNum = $res.Rows[0]['CNT']
                Write-Host ('    - Bang ' + $tbl + ' : ' + $countNum + ' ban ghi') -ForegroundColor White
            }
        } catch {
            Write-Host ('    - Bang ' + $tbl + ' : (Khong the lay count)') -ForegroundColor Gray
        }
    }
}

if ($formObj.diagnostic_query) {
    Write-Host ''
    Write-Host '  * Mau truy van kiem tra:' -ForegroundColor Cyan
    Write-Host ('    ' + $formObj.diagnostic_query) -ForegroundColor Gray
}

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Green
Write-Host ''
