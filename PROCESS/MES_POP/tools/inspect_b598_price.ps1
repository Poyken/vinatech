# ==============================================================================
# inspect_b598_price.ps1 — Tra cuu don gia & ty le can hardcode trong B598
# SP: SmartFactoryV2.dbo.usp_vn_showproductionerror
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$MaterialCode = ''
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "     [B598-PRICE] TRA CUU DON GIA & CONG THUC CAN PHE B598" -ForegroundColor Yellow
if ($MaterialCode) {
    Write-Host "     Ma vat tu loc: $MaterialCode" -ForegroundColor White
} else {
    Write-Host "     Che do: Quet toan bo danh muc hardcode trong SP usp_vn_showproductionerror" -ForegroundColor Gray
}
Write-Host '======================================================================' -ForegroundColor Cyan

$conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
if ($null -eq $conn) {
    Write-Host "Loi: Khong the ket noi toi CSDL SmartFactoryV2!" -ForegroundColor Red
    exit 1
}

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('SmartFactoryV2.dbo.usp_vn_showproductionerror')) AS Def;"
$reader = $cmd.ExecuteReader()

$def = ""
if ($reader.Read()) {
    $def = $reader['Def'].ToString()
}
$reader.Close()
$conn.Close()

if ([string]::IsNullOrWhiteSpace($def)) {
    Write-Host "Loi: Khong the doc ma nguon SP usp_vn_showproductionerror!" -ForegroundColor Red
    exit 1
}

$lines = $def -split "`r?`n"
$weightRules = @()
$priceRules = @()

$inWeightBlock = $false
$inPriceBlock = $false

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    $trimmed = $line.Trim()

    if ($trimmed -match 'Can_Nang_Moi' -or $trimmed -match 'TrongLuongThucTe') {
        $inWeightBlock = $true
    }
    if ($trimmed -match 'PRICES' -or $trimmed -match 'DonGia' -or $trimmed -match 'Price') {
        $inPriceBlock = $true
    }

    # Bat cac dong WHEN MaLotNguyenLieu = '...'
    if ($trimmed -match "WHEN\s+.*MaLotNguyenLieu.*=\s*['""]([^'""]+)['""]\s+THEN\s+(.*)") {
        $mat = $matches[1]
        $formula = $matches[2]
        $lineNum = $i + 1

        if ($formula -match '\*\s*([0-9.]+)') {
            $priceRules += [PSCustomObject]@{
                Line = $lineNum
                Material = $mat
                Formula = $formula
            }
        } else {
            $weightRules += [PSCustomObject]@{
                Line = $lineNum
                Material = $mat
                Formula = $formula
            }
        }
    }
}

if ($MaterialCode) {
    $targetMat = $MaterialCode.Trim().ToUpper()
    Write-Host "`n>>> KET QUA CHO MA VAT TU: $targetMat" -ForegroundColor Green
    
    $wHits = @($weightRules | Where-Object { $_.Material.Trim().ToUpper() -like "*$targetMat*" })
    $pHits = @($priceRules | Where-Object { $_.Material.Trim().ToUpper() -like "*$targetMat*" })
    
    if ($wHits.Count -gt 0) {
        Write-Host "1. Cong thuc chia can nang (Khoi Can_Nang_Moi):" -ForegroundColor Cyan
        foreach ($w in $wHits) {
            Write-Host "   - [Dong $($w.Line)] WHEN MaLotNguyenLieu = '$($w.Material)' THEN $($w.Formula)" -ForegroundColor White
        }
    } else {
        Write-Host "1. Cong thuc can nang: Khong tim thay khai bao rieng (Dang ap dung ELSE mac dinh)" -ForegroundColor DarkGray
    }

    if ($pHits.Count -gt 0) {
        Write-Host "`n2. Don gia USD va thanh tien (Khoi PRICES):" -ForegroundColor Cyan
        foreach ($p in $pHits) {
            Write-Host "   - [Dong $($p.Line)] WHEN MaLotNguyenLieu = '$($p.Material)' THEN $($p.Formula)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n2. Don gia USD: Khong tim thay khai bao rieng (Dang ap dung ELSE mac dinh)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "`n>>> 1. DANH MUC QUY DOI CAN NANG (Khoi Can_Nang_Moi - $($weightRules.Count) ma):" -ForegroundColor Cyan
    $weightRules | Format-Table Line, Material, Formula -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }

    Write-Host "`n>>> 2. DANH MUC DON GIA HARDCODE (Khoi PRICES - $($priceRules.Count) ma):" -ForegroundColor Yellow
    $priceRules | Format-Table Line, Material, Formula -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor White }
}

Write-Host "======================================================================`n"
