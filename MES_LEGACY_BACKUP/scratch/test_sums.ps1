$data = Import-Csv "scratch/aging_lots_with_material.csv"

# Let's write an algorithm that assigns lots to each day from 13 to 19 to achieve targets:
# Day 13: Target 20000 (19000 - 21000)
# Day 14: Target 40000 (39000 - 41000)
# Day 15: Target 23000 (22000 - 24000)
# Day 16: Target 25000 (24000 - 26000)
# Day 17: Target 25000 (24000 - 26000)
# Day 18: Target 25000 (24000 - 26000)
# Day 19: Target 26000 (25000 - 27000)

# 1. Define Excel lots strictly per day:
$day13_excel = @('VVQO183R072714', 'VVQO163R072709', 'VVQO193R072761', 'VVQO183R072716', 'VVQO193R072713', 'VVQO153R072712', 'VVQO193R072734', 'VVQO153R072714', 'VVQO153R072727', 'VVQO173R072751')
$day15_excel = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748')
$day16_excel = @('VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760')
$day17_excel = @('VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735')
$day18_excel = @('VVQO193R072766', 'VVQO193R072712', 'VVQO153R072726', 'VVQO173R072731', 'VVQO163R072742', 'VVQO203R072713')
$day19_excel = @('VVQP263R072710', 'VVQP283R072702', 'VVQP263R072709', 'VVQP183R072706', 'VVQO183R072711')

$allExcel = $day13_excel + $day15_excel + $day16_excel + $day17_excel + $day18_excel + $day19_excel
Write-Output "Excel lots total: $($allExcel.Count) (unique: $(($allExcel | Select-Object -Unique).Count))"

# Let's get lot object lookup
$lotDict = @{}
foreach ($row in $data) {
    $lotDict[$row.Barcode] = $row
}

# Function to sum lots
function Get-Sum($lotList) {
    $s = 0.0
    foreach ($b in $lotList) {
        if ($lotDict.ContainsKey($b)) {
            $s += [double]$lotDict[$b].ProdQty
        }
    }
    return $s
}

Write-Output "Day 13 Excel Sum: $(Get-Sum $day13_excel)"
Write-Output "Day 15 Excel Sum: $(Get-Sum $day15_excel)"
Write-Output "Day 16 Excel Sum: $(Get-Sum $day16_excel)"
Write-Output "Day 17 Excel Sum: $(Get-Sum $day17_excel)"
Write-Output "Day 18 Excel Sum: $(Get-Sum $day18_excel)"
Write-Output "Day 19 Excel Sum: $(Get-Sum $day19_excel)"
