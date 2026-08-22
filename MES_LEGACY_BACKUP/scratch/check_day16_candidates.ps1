$data = Import-Csv "scratch/aging_lots_with_material.csv"

# Let's inspect Day 16 candidate lots in DB
$d16_candidates = $data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.RouteCode -like 'V-26%' }
Write-Output "=== DAY 16 CANDIDATES ==="
$d16_candidates | ForEach-Object {
    Write-Output "$($_.Barcode) | Qty: $($_.ProdQty) | WC: $($_.WorkCenterCode) | Route: $($_.RouteCode)"
}
