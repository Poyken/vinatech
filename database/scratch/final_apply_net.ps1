$content = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\source_from_db\usp_Vietnam_GetBoxIDForLotNo_VVT.sql' -Raw

$pattern = "(?m)^(\s*when @LotNo = 'VVPM193R825727' then 'VVPM193R825727'.*)$"
$fix = "`r`n				 when @LotNo like 'VVPQ132R715%' then REPLACE(@LotNo, 'R715', 'R7156')"

$newContent = $content -replace $pattern, ('$1' + $fix)
$alterContent = $newContent -replace "CREATE PROCEDURE", "ALTER PROCEDURE"

# Execute directly as a string from PowerShell (which is Unicode)
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandTimeout = 120
    $cmd.CommandText = $alterContent
    $cmd.ExecuteNonQuery()
    "Successfully applied ALTER via .NET (Unicode)"
} catch {
    "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
