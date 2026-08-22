$data = Import-Csv "scratch/db_aging_lots.csv"

Write-Output "=== DAY 16 LOTS IN DB ==="
$d16 = $data | Where-Object { $_.JobDate -eq '2026-08-16' }
$d16 | ForEach-Object {
    Write-Output "$($_.Barcode) | Qty: $($_.ProdQty) | WC: $($_.WorkCenterCode) | CompleteRoute: $($_.CompleteRoute) | Route: $($_.RouteCode)"
}
