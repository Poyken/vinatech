$baseDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES_LEGACY_BACKUP\scratch\repos\data-sorting"
$dates = Get-ChildItem -Path $baseDir -Directory | Where-Object { $_.Name -ne ".git" } | Sort-Object Name

$results = foreach ($d in $dates) {
    $allFiles = Get-ChildItem -Path $d.FullName -Recurse -File -Filter "*.xlsx"
    $f1 = $allFiles | Where-Object { $_.Name -like "1#*" }
    $f2 = $allFiles | Where-Object { $_.Name -like "2#*" }
    $other = $allFiles | Where-Object { $_.Name -notlike "1#*" -and $_.Name -notlike "2#*" }
    [PSCustomObject]@{
        Date = $d.Name
        TotalExcel = $allFiles.Count
        Machine_1 = $f1.Count
        Machine_2 = $f2.Count
        Other_Machines = $other.Count
    }
}
$results | Format-Table -AutoSize
