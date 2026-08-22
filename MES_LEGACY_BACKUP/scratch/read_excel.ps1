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

function Read-Sheet-Formatted($xmlPath) {
    [xml]$sheetXml = Get-Content $xmlPath
    $ns = New-Object Xml.XmlNamespaceManager $sheetXml.NameTable
    $ns.AddNamespace("x", "http://schemas.openxmlformats.org/spreadsheetml/2006/main")
    
    $rows = $sheetXml.SelectNodes("//x:sheetData/x:row", $ns)
    foreach ($row in $rows) {
        $rIdx = $row.r
        $cells = $row.SelectNodes("x:c", $ns)
        $cellDict = @{}
        foreach ($c in $cells) {
            $t = $c.GetAttribute("t")
            $v = $c.v
            $val = $v
            if ($t -eq "s" -and $v -ne $null -and [int]$v -lt $strings.Count) {
                $val = $strings[[int]$v]
            }
            # extract column letter
            $col = $c.r -replace '\d+', ''
            $cellDict[$col] = $val
        }
        $cols = @('A','B','C','D','E','F','G','H','I','J','K','L')
        $lineVals = @()
        foreach ($k in $cols) {
            $lineVals += if ($cellDict.ContainsKey($k)) { $cellDict[$k] } else { "" }
        }
        Write-Output ("R{0,2}: {1}" -f $rIdx, ($lineVals -join "`t| "))
    }
}

Write-Output "`n========== SHEET 1 (Chuyển công đoạn Aging ,packing) =========="
Read-Sheet-Formatted (Join-Path $tempDir "xl\worksheets\sheet1.xml")
