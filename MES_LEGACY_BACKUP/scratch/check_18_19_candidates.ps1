$data = Import-Csv "scratch/db_aging_lots.csv"

# Let's check Day 18 candidate lots in VVT_F1
$d18 = $data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.WorkCenterCode -eq 'VVT_F1' }
Write-Output "=== DAY 18 CANDIDATES IN VVT_F1 ==="
$d18 | Select-Object -First 10 | ForEach-Object {
    Write-Output "$($_.Barcode) | Qty: $($_.ProdQty)"
}

# Let's check Day 19 candidate lots in VVT_F1
$d19 = $data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.WorkCenterCode -eq 'VVT_F1' }
Write-Output "=== DAY 19 CANDIDATES IN VVT_F1 ==="
$d19 | Select-Object -First 10 | ForEach-Object {
    Write-Output "$($_.Barcode) | Qty: $($_.ProdQty)"
}
