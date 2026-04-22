Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Schema for STB_ScreenInfo ---"
$cmd.CommandText = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'STB_ScreenInfo'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) { Write-Host $reader['COLUMN_NAME'] }
$reader.Close()

Write-Host "`n--- Recent screens to find naming pattern ---"
$cmd.CommandText = "SELECT TOP 10 Name, Caption FROM STB_ScreenInfo ORDER BY CreateDateTime DESC"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption'])"
}
$reader.Close()

Write-Host "`n--- Searching for anything containing 4029 ---"
$cmd.CommandText = "SELECT Name, Caption FROM STB_ScreenInfo WHERE Name LIKE '%4029%' OR Caption LIKE '%4029%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption'])"
}
$reader.Close()

$conn.Close()
