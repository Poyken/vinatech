$data = Import-Csv "scratch/db_aging_lots.csv"

Write-Output "=== TOTAL QTY IN DB BY DATE & WORKCENTER ==="
$data | Group-Object JobDate | Sort-Object Name | ForEach-Object {
    $f1 = ($_.Group | Where-Object { $_.WorkCenterCode -eq 'VVT_F1' } | Measure-Object -Property ProdQty -Sum).Sum
    $f5 = ($_.Group | Where-Object { $_.WorkCenterCode -eq 'VVT_F5' } | Measure-Object -Property ProdQty -Sum).Sum
    $f2 = ($_.Group | Where-Object { $_.WorkCenterCode -eq 'VVT_F2' } | Measure-Object -Property ProdQty -Sum).Sum
    $tot = ($_.Group | Measure-Object -Property ProdQty -Sum).Sum
    Write-Output "Date: $($_.Name) | VVT_F1: $f1 | VVT_F5: $f5 | VVT_F2: $f2 | Total: $tot"
}
