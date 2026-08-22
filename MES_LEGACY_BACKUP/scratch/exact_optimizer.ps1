$data = Import-Csv "scratch/aging_lots_with_material.csv"

# Excel lots defined:
$d13_excel = @('VVQO183R072714', 'VVQO163R072709', 'VVQO193R072761', 'VVQO183R072716', 'VVQO193R072713', 'VVQO153R072712', 'VVQO193R072734', 'VVQO153R072714', 'VVQO153R072727', 'VVQO173R072751')
$d14_excel = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748', 'VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760', 'VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO183R072711')
$d17_excel = @('VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735')
$d18_excel = @('VVQO193R072766', 'VVQO193R072712', 'VVQO153R072726', 'VVQO173R072731', 'VVQO163R072742', 'VVQO203R072713')
$d19_excel = @('VVQP263R072710', 'VVQP283R072702', 'VVQP263R072709', 'VVQP183R072706')

$fixedExcel = @{
    '2026-08-13' = $d13_excel
    '2026-08-14' = $d14_excel
    '2026-08-17' = $d17_excel
    '2026-08-18' = $d18_excel
    '2026-08-19' = $d19_excel
}

$allFixed = $d13_excel + $d14_excel + $d17_excel + $d18_excel + $d19_excel

$targets = @{
    '2026-08-13' = 20000.0
    '2026-08-14' = 40000.0
    '2026-08-15' = 23000.0
    '2026-08-16' = 25000.0
    '2026-08-17' = 25000.0
    '2026-08-18' = 25000.0
    '2026-08-19' = 26000.0
}

# Available lots to distribute: all other lots in $data
$pool = $data | Where-Object { $allFixed -notcontains $_.Barcode }

Write-Output "Pool size: $($pool.Count)"

$lotDict = @{}
foreach ($row in $data) { $lotDict[$row.Barcode] = $row }

function Get-Sum($lotList) {
    $s = 0.0
    foreach ($b in $lotList) {
        if ($lotDict.ContainsKey($b)) {
            $s += [double]$lotDict[$b].ProdQty
        }
    }
    return $s
}

$days = @('2026-08-13', '2026-08-14', '2026-08-15', '2026-08-16', '2026-08-17', '2026-08-18', '2026-08-19')
$used = @{}
foreach ($b in $allFixed) { $used[$b] = $true }

$finalPlan = @{}

foreach ($day in $days) {
    $assigned = @()
    if ($fixedExcel.ContainsKey($day)) {
        $assigned += $fixedExcel[$day]
    }
    
    $currentSum = Get-Sum $assigned
    $needed = $targets[$day] - $currentSum
    
    # Pick from pool matching this day first, then others
    $candidates = $pool | Where-Object { -not $used.ContainsKey($_.Barcode) }
    
    # Sort candidates: prefer those matching $day JobDate
    $sortedCand = $candidates | Sort-Object @{Expression={ if ($_.JobDate -eq $day) { 0 } else { 1 } }}, @{Expression={ [double]$_.ProdQty }; Descending=$true}
    
    $picked = @()
    $runningSum = $currentSum
    foreach ($cand in $sortedCand) {
        $qty = [double]$cand.ProdQty
        if ($runningSum + $qty -le $targets[$day] + 300) {
            $picked += $cand.Barcode
            $used[$cand.Barcode] = $true
            $runningSum += $qty
            if ($runningSum -ge $targets[$day] - 300) {
                break
            }
        }
    }
    
    $finalPlan[$day] = $assigned + $picked
    $tot = Get-Sum $finalPlan[$day]
    Write-Output ("Day: {0} | Lots: {1,2} | Sum: {2,9:N2} | Target: {3,5} | Diff: {4,6:N2}" -f $day, $finalPlan[$day].Count, $tot, $targets[$day], ($tot - $targets[$day]))
}
