Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Searching for Screen Info by Caption ---"
$cmd.CommandText = "SELECT ScreenName, ScreenID, ScreenNameText, Description FROM STB_ScreenInfo WHERE ScreenNameText LIKE N'%lỗi phế%' OR ScreenName LIKE '%T101%' OR ScreenID LIKE '%T101%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "ScreenName: $($reader['ScreenName']), ScreenID: $($reader['ScreenID']), Text: $($reader['ScreenNameText']), Desc: $($reader['Description'])"
}
$reader.Close()

Write-Host "`n--- Searching for Screen Info by ZSRT ---"
$cmd.CommandText = "SELECT ScreenName, ScreenID, ScreenNameText FROM STB_ScreenInfo WHERE ScreenName LIKE '%ZSRT%' OR ScreenID LIKE '%ZSRT%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "ScreenName: $($reader['ScreenName']), ScreenID: $($reader['ScreenID']), Text: $($reader['ScreenNameText'])"
}
$reader.Close()

$conn.Close()
