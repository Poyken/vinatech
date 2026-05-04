$content = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\source_from_db\usp_Vietnam_GetBoxIDForLotNo_VVT.sql' -Raw

# Use Regex to match the line regardless of line endings
$pattern = "(?m)^(\s*when @LotNo = 'VVPM193R825727' then 'VVPM193R825727'.*)$"
$fix = "`r`n				 when @LotNo like 'VVPQ132R715%' then REPLACE(@LotNo, 'R715', 'R7156')"

if ($content -match $pattern) {
    $newContent = $content -replace $pattern, ('$1' + $fix)
    "Match found and replaced"
} else {
    "Match NOT found"
    # Fallback to a simpler match
    if ($content -match "VVPM193R825727") { "Substring found but pattern failed" }
}

# Change CREATE to ALTER
$alterContent = $newContent -replace "CREATE PROCEDURE", "ALTER PROCEDURE"

# Save with UTF8 WITH BOM
$utf8WithBom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText('C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\final_alter_sp_fixed.sql', $alterContent, $utf8WithBom)

# Verify local file
if ((Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\final_alter_sp_fixed.sql' -Raw).Contains("VVPQ132R7156")) {
    "Local file verification: PASS"
} else {
    "Local file verification: FAIL"
}
