$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES_LEGACY_BACKUP"
$tempDir = Join-Path $baseDir "scratch\excel_extracted"

# Load shared strings
$strings = @()
if (Test-Path (Join-Path $tempDir "xl\sharedStrings.xml")) {
    [xml]$ssXml = Get-Content (Join-Path $tempDir "xl\sharedStrings.xml")
    $strings = $ssXml.sst.si | ForEach-Object { 
        if ($_.t) { $_.t }
        elseif ($_.r) { ($_.r | ForEach-Object { $_.t }) -join "" }
        else { "" }
    }
}

[xml]$sheetXml = Get-Content (Join-Path $tempDir "xl\worksheets\sheet1.xml")
$ns = New-Object Xml.XmlNamespaceManager $sheetXml.NameTable
$ns.AddNamespace("x", "http://schemas.openxmlformats.org/spreadsheetml/2006/main")

$cols = @{
    'B' = '2026-08-13';
    'C' = '2026-08-14';
    'D' = '2026-08-15';
    'E' = '2026-08-16';
    'F' = '2026-08-17';
    'G' = '2026-08-18';
    'H' = '2026-08-19';
}

Write-Output "=== AGING LOTS FROM EXCEL (Rows 7-27) ==="
$agingLotsByDay = @{}
foreach ($colKey in $cols.Keys | Sort-Object) {
    $date = $cols[$colKey]
    $agingLotsByDay[$date] = @()
}

$rows = $sheetXml.SelectNodes("//x:sheetData/x:row", $ns)
foreach ($row in $rows) {
    $rIdx = [int]$row.r
    if ($rIdx -ge 7 -and $rIdx -le 27) {
        $cells = $row.SelectNodes("x:c", $ns)
        foreach ($c in $cells) {
            $colLetter = $c.r -replace '\d+', ''
            if ($cols.ContainsKey($colLetter)) {
                $v = $c.v
                $t = $c.GetAttribute("t")
                $val = $v
                if ($t -eq "s" -and $v -ne $null -and [int]$v -lt $strings.Count) {
                    $val = $strings[[int]$v]
                }
                if ($val -and $val.Trim() -ne "") {
                    $date = $cols[$colLetter]
                    $agingLotsByDay[$date] += $val.Trim()
                }
            }
        }
    }
}

foreach ($d in $cols.Values | Sort-Object) {
    $lots = $agingLotsByDay[$d]
    Write-Output "Day $d : ($($lots.Count) lots) -> $($lots -join ', ')"
}
