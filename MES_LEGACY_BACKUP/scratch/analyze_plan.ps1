$data = Import-Csv "scratch/db_aging_lots.csv"

# Excel lots by day
$excelLots = @{
    '2026-08-13' = @('VVQO183R072714', 'VVQO163R072709', 'VVQO193R072761', 'VVQO183R072716', 'VVQO193R072713', 'VVQO153R072712', 'VVQO193R072734', 'VVQO153R072714', 'VVQO153R072727', 'VVQO173R072751')
    '2026-08-14' = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748', 'VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760', 'VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO183R072711')
    '2026-08-15' = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748')
    '2026-08-16' = @('VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760')
    '2026-08-17' = @('VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735')
    '2026-08-18' = @('VVQO193R072766', 'VVQO193R072712', 'VVQO153R072726', 'VVQO173R072731', 'VVQO163R072742', 'VVQO203R072713')
    '2026-08-19' = @('VVQP263R072710', 'VVQP283R072702', 'VVQP263R072709', 'VVQP183R072706')
}

# Unique lots across all excel
$allExcelLots = @()
foreach ($k in $excelLots.Keys) { $allExcelLots += $excelLots[$k] }
$uniqueExcelLots = $allExcelLots | Select-Object -Unique

Write-Output "Total unique lots in Excel Aging: $($uniqueExcelLots.Count)"

# Check their info in DB
Write-Output "`n=== EXCEL LOTS INFO IN DB ==="
$excelInDb = $data | Where-Object { $uniqueExcelLots -contains $_.Barcode }
$excelInDb | Group-Object Barcode | ForEach-Object {
    $item = $_.Group[0]
    Write-Output "$($item.Barcode) | JobDate: $($item.JobDate) | WC: $($item.WorkCenterCode) | Route: $($item.RouteCode) | Qty: $($item.ProdQty)"
}

Write-Output "`n=== CURRENT HY (VVT_F5) LOTS BY DATE ==="
$hyLots = $data | Where-Object { $_.WorkCenterCode -eq 'VVT_F5' }
$hyLots | Group-Object JobDate | Sort-Object Name | ForEach-Object {
    $tot = ($_.Group | Measure-Object -Property ProdQty -Sum).Sum
    Write-Output "Date: $($_.Name) | Count: $($_.Count) | TotalQty: $tot"
}
