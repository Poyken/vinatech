$data = Import-Csv "scratch/db_aging_lots.csv"

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

# 1. Day 13 (Target 20,000): 10 Lots Excel (10,590) + 9 Lots HY VVQQ (9,594) = 20,184 (Diff: +184)
$d13_excel = @('VVQO183R072714', 'VVQO163R072709', 'VVQO193R072761', 'VVQO183R072716', 'VVQO193R072713', 'VVQO153R072712', 'VVQO193R072734', 'VVQO153R072714', 'VVQO153R072727', 'VVQO173R072751')
$d13_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-13' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 9)
$d13_lots = $d13_excel + ($d13_vvqq | ForEach-Object { $_.Barcode })
$d13_sum = Get-Sum $d13_lots

# 2. Day 14 (Target 40,000): Toàn bộ 21 Lots Excel của ngày 14 (21,598) + 18 Lots VVQQ
$d14_excel_21 = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748', 'VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760', 'VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO183R072711')
$d14_excel_sum = Get-Sum $d14_excel_21
Write-Output "Day 14 Excel 21 lots sum: $d14_excel_sum"

# Available VVQQ lots for Day 14
$d14_vvqq_avail = ($data | Where-Object { $_.JobDate -eq '2026-08-14' -and $_.Barcode -like 'VVQQ*' -and $d13_lots -notcontains $_.Barcode })
$d14_vvqq_selected = $d14_vvqq_avail | Select-Object -First 18
$d14_lots = $d14_excel_21 + ($d14_vvqq_selected | ForEach-Object { $_.Barcode })
$d14_sum = Get-Sum $d14_lots

# 3. Day 15 (Target 23,000): 22 lots VVQQ
$d15_vvqq_avail = ($data | Where-Object { $_.JobDate -eq '2026-08-15' -and $_.Barcode -like 'VVQQ*' -and $d13_lots -notcontains $_.Barcode -and $d14_lots -notcontains $_.Barcode })
$d15_vvqq_selected = $d15_vvqq_avail | Select-Object -First 22
$d15_lots = ($d15_vvqq_selected | ForEach-Object { $_.Barcode })
$d15_sum = Get-Sum $d15_lots

# 4. Day 16 (Target 25,000): 24 lots VVQQ
$d16_vvqq_avail = ($data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.Barcode -like 'VVQQ*' -and $d13_lots -notcontains $_.Barcode -and $d14_lots -notcontains $_.Barcode -and $d15_lots -notcontains $_.Barcode })
$d16_vvqq_selected = $d16_vvqq_avail | Select-Object -First 24
$d16_lots = ($d16_vvqq_selected | ForEach-Object { $_.Barcode })
$d16_sum = Get-Sum $d16_lots

# 5. Day 17 (Target 25,000): 4 Lots Excel mới ngày 17 (4,244) + 20 Lots VVQQ
$d17_excel_4 = @('VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735')
$d17_vvqq_avail = ($data | Where-Object { $_.JobDate -eq '2026-08-17' -and $_.Barcode -like 'VVQQ*' -and $d13_lots -notcontains $_.Barcode -and $d14_lots -notcontains $_.Barcode -and $d15_lots -notcontains $_.Barcode -and $d16_lots -notcontains $_.Barcode })
$d17_vvqq_selected = $d17_vvqq_avail | Select-Object -First 20
$d17_lots = $d17_excel_4 + ($d17_vvqq_selected | ForEach-Object { $_.Barcode })
$d17_sum = Get-Sum $d17_lots

# 6. Day 18 (Target 25,000): 6 Lots Excel ngày 18 (6,394) + 18 Lots VVQQ
$d18_excel_6 = @('VVQO193R072766', 'VVQO193R072712', 'VVQO153R072726', 'VVQO173R072731', 'VVQO163R072742', 'VVQO203R072713')
$d18_vvqq_avail = ($data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.Barcode -like 'VVQQ*' -and $d13_lots -notcontains $_.Barcode -and $d14_lots -notcontains $_.Barcode -and $d15_lots -notcontains $_.Barcode -and $d16_lots -notcontains $_.Barcode -and $d17_lots -notcontains $_.Barcode })
$d18_vvqq_selected = $d18_vvqq_avail | Select-Object -First 18
$d18_lots = $d18_excel_6 + ($d18_vvqq_selected | ForEach-Object { $_.Barcode })
$d18_sum = Get-Sum $d18_lots

# 7. Day 19 (Target 26,000): 4 Lots Excel ngày 19 (4,273) + 21 Lots VVQQ
$d19_excel_4 = @('VVQP263R072710', 'VVQP283R072702', 'VVQP263R072709', 'VVQP183R072706')
$d19_vvqq_avail = ($data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.Barcode -like 'VVQQ*' -and $d13_lots -notcontains $_.Barcode -and $d14_lots -notcontains $_.Barcode -and $d15_lots -notcontains $_.Barcode -and $d16_lots -notcontains $_.Barcode -and $d17_lots -notcontains $_.Barcode -and $d18_lots -notcontains $_.Barcode })
$d19_vvqq_selected = $d19_vvqq_avail | Select-Object -First 21
$d19_lots = $d19_excel_4 + ($d19_vvqq_selected | ForEach-Object { $_.Barcode })
$d19_sum = Get-Sum $d19_lots

Write-Output ("Day 13 (Target 20,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d13_lots.Count, $d13_sum, ($d13_sum - 20000))
Write-Output ("Day 14 (Target 40,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d14_lots.Count, $d14_sum, ($d14_sum - 40000))
Write-Output ("Day 15 (Target 23,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d15_lots.Count, $d15_sum, ($d15_sum - 23000))
Write-Output ("Day 16 (Target 25,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d16_lots.Count, $d16_sum, ($d16_sum - 25000))
Write-Output ("Day 17 (Target 25,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d17_lots.Count, $d17_sum, ($d17_sum - 25000))
Write-Output ("Day 18 (Target 25,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d18_lots.Count, $d18_sum, ($d18_sum - 25000))
Write-Output ("Day 19 (Target 26,000): {0,2} lots | Sum: {1,9:N2} | Diff: {2,7:N2}" -f $d19_lots.Count, $d19_sum, ($d19_sum - 26000))

# Check unique
$all = $d13_lots + $d14_lots + $d15_lots + $d16_lots + $d17_lots + $d18_lots + $d19_lots
Write-Output "`nTotal assigned: $($all.Count) | Unique: $(($all | Select-Object -Unique).Count)"
