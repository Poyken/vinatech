$content = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\source_from_db\usp_Vietnam_GetBoxIDForLotNo_VVT.sql' -Raw

$pattern = "(?m)^(\s*when @LotNo = 'VVPM193R825727' then 'VVPM193R825727'.*)$"
$fix = "`r`n				 when @LotNo like 'VVPQ132R715%' then REPLACE(@LotNo, 'R715', 'R7156')"

$newContent = $content -replace $pattern, ('$1' + $fix)
$alterContent = $newContent -replace "CREATE PROCEDURE", "ALTER PROCEDURE"

$utf8WithBom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText('C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\final_alter_sp_fixed.sql', $alterContent, $utf8WithBom)

# Apply to DB with N-prefix trick to ensure UTF8
# Since Invoke-Sqlcmd with -InputFile can be tricky with encoding, we'll read the file and execute as a string if possible, 
# but it's too big. So we use -Encoding UTF8
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -InputFile 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\final_alter_sp_fixed.sql' -Encoding UTF8
