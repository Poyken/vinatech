$content = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\source_from_db\usp_Vietnam_GetBoxIDForLotNo_VVT.sql' -Raw
# The file has correct Vietnamese, let's keep it that way.

# Insert the fix after the first WHEN in the LotNo CASE statement (line 614-615)
$target = "				when @LotNo = 'VVPM193R825727' then 'VVPM193R825727'  -- update 2025-04-24 following Ms.Trinh request"
$fix = "`r`n				 when @LotNo like 'VVPQ132R715%' then REPLACE(@LotNo, 'R715', 'R7156')"
$newContent = $content.Replace($target, $target + $fix)

# Change CREATE to ALTER
$alterContent = $newContent -replace "CREATE PROCEDURE", "ALTER PROCEDURE"

# Save with UTF8 WITH BOM to a new file
$utf8WithBom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText('C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\final_alter_sp_fixed.sql', $alterContent, $utf8WithBom)

# Apply to DB
Invoke-Sqlcmd -ServerInstance 'dbserver.hycap.co.kr,5398' -Database 'SmartFactoryV2' -Username 'vinaadmin' -Password 'vina1234%6&8' -InputFile 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\final_alter_sp_fixed.sql'
