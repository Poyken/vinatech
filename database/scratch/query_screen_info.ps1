Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- T101_Test Objects ---"
$cmd.CommandText = "SELECT ScreenName, ObjectName, ObjectType, Description FROM STB_ScreenObjects WHERE ScreenName = 'T101_Test' OR ScreenName LIKE '%T101%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Screen: $($reader['ScreenName']), ObjectName: $($reader['ObjectName']), ObjectType: $($reader['ObjectType']), Description: $($reader['Description'])"
}
$reader.Close()

Write-Host "`n--- ZSRT01 Objects ---"
$cmd.CommandText = "SELECT ScreenName, ObjectName, ObjectType, Description FROM STB_ScreenObjects WHERE ScreenName = 'ZSRT01' OR ScreenName LIKE '%ZSRT%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Screen: $($reader['ScreenName']), ObjectName: $($reader['ObjectName']), ObjectType: $($reader['ObjectType']), Description: $($reader['Description'])"
}
$reader.Close()

$conn.Close()
