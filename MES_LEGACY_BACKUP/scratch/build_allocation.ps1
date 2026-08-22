$data = Import-Csv "scratch/aging_lots_with_material.csv"

$lotDict = @{}
foreach ($row in $data) {
    $lotDict[$row.Barcode] = $row
}

function Get-Sum($lotList) {
    $s = 0.0
    foreach ($b in $lotList) {
        if ($lotDict.ContainsKey($b)) {
            $s += [double]$lotDict[$b].ProdQty
        }
    }
    return $s
}

# 1. Day 13: Target 20,000
$d13_excel = @('VVQO183R072714', 'VVQO163R072709', 'VVQO193R072761', 'VVQO183R072716', 'VVQO193R072713', 'VVQO153R072712', 'VVQO193R072734', 'VVQO153R072714', 'VVQO153R072727', 'VVQO173R072751')
$d13_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-13' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 9)
$d13_lots = $d13_excel + ($d13_vvqq | ForEach-Object { $_.Barcode })
$d13_sum = Get-Sum $d13_lots

# 2. Day 14: Target 40,000
$d13_rem_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-13' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -Skip 9)
$d14_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-14' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d14_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-14' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 23)
$d14_lots = ($d13_rem_vvqq | ForEach-Object { $_.Barcode }) + ($d14_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d14_f1_vvqq | ForEach-Object { $_.Barcode })
$d14_sum = Get-Sum $d14_lots

# 3. Day 15: Target 23,000
$d15_excel = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748')
$d15_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-15' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d15_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-15' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d15_lots = $d15_excel + ($d15_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d15_f1_vvqq | ForEach-Object { $_.Barcode })
$d15_sum = Get-Sum $d15_lots

# 4. Day 16: Target 25,000
# Pick 14 lots from Day 16 VVT_F1
$d16_excel = @('VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760')
$d16_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d16_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 14)
$d16_lots = $d16_excel + ($d16_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d16_f1_vvqq | ForEach-Object { $_.Barcode })
$d16_sum = Get-Sum $d16_lots

# 5. Day 17: Target 25,000
$d17_excel = @('VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735')
$d17_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-17' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d17_lots = $d17_excel + ($d17_f5_vvqq | ForEach-Object { $_.Barcode })
$d17_sum = Get-Sum $d17_lots

# 6. Day 18: Target 25,000
# Pick 9 lots from Day 18 VVT_F1
$d17_rem_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-17' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -Skip 8)
$d18_excel = @('VVQO193R072766', 'VVQO193R072712', 'VVQO153R072726', 'VVQO173R072731', 'VVQO163R072742', 'VVQO203R072713')
$d18_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d18_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d18_lots = $d18_excel + ($d17_rem_vvqq | ForEach-Object { $_.Barcode }) + ($d18_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d18_f1_vvqq | ForEach-Object { $_.Barcode })
$d18_sum = Get-Sum $d18_lots

# 7. Day 19: Target 26,000
# Pick 2 lots (2x 1060 = 2120) or 3 lots from Day 19 VVT_F1
$d19_excel = @('VVQP263R072710', 'VVQP283R072702', 'VVQP263R072709', 'VVQP183R072706', 'VVQO183R072711')
$d19_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d19_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 2)
$d19_lots = $d19_excel + ($d19_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d19_f1_vvqq | ForEach-Object { $_.Barcode })
$d19_sum = Get-Sum $d19_lots

Write-Output ("Day 13 (Target 20,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d13_lots.Count, $d13_sum, ($d13_sum - 20000))
Write-Output ("Day 14 (Target 40,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d14_lots.Count, $d14_sum, ($d14_sum - 40000))
Write-Output ("Day 15 (Target 23,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d15_lots.Count, $d15_sum, ($d15_sum - 23000))
Write-Output ("Day 16 (Target 25,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d16_lots.Count, $d16_sum, ($d16_sum - 25000))
Write-Output ("Day 17 (Target 25,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d17_lots.Count, $d17_sum, ($d17_sum - 25000))
Write-Output ("Day 18 (Target 25,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d18_lots.Count, $d18_sum, ($d18_sum - 25000))
Write-Output ("Day 19 (Target 26,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d19_lots.Count, $d19_sum, ($d19_sum - 26000))

# Check unique across all days
$allAssigned = $d13_lots + $d14_lots + $d15_lots + $d16_lots + $d17_lots + $d18_lots + $d19_lots
$uniqueAssigned = $allAssigned | Select-Object -Unique
Write-Output "`nTotal assigned: $($allAssigned.Count) | Unique: $($uniqueAssigned.Count)"
if ($allAssigned.Count -eq $uniqueAssigned.Count) {
    Write-Output "SUCCESS: NO OVERLAPPING LOTS!"
} else {
    Write-Warning "DUPLICATE FOUND!"
}
