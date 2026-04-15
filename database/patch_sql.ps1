$filePath = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_Vietnam_RawMaterialInputHist_uid.sql'
$content = Get-Content $filePath
$newContent = New-Object System.Collections.Generic.List[string]

foreach ($line in $content) {
    $newContent.Add($line)
    if ($line -like "*'GBEC00-011' AS electrolyte, 'VEC2R7406QC'*") {
        $newContent.Add("						  UNION ALL")
        $newContent.Add("						  select 'GBEC00-011' AS electrolyte, 'VEC3R0406QC'  as model, '1346' size -- Added 2026-04-11 for Model 1346-40F")
    }
}

Set-Content $filePath -Value ($newContent.ToArray()) -Encoding UTF8
Write-Host "Patched $filePath"
