$path = 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\usp_Vietnam_GetBoxIDForLotNo_VVT.sql'
# Read with Latin1 (Default for many systems)
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(1252))
# Write as UTF8 with BOM
$utf8WithBom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path + '.fixed', $content, $utf8WithBom)

# Check a snippet
$fixedContent = Get-Content ($path + '.fixed') -Raw
$fixedContent.Substring($fixedContent.IndexOf("LotNoFirst"), 200)
