Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Searching for Screens starting with T ---"
$cmd.CommandText = "SELECT TOP 20 Name, Caption FROM STB_ScreenInfo WHERE Name LIKE 'T%' ORDER BY Name"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption'])"
}
$reader.Close()

Write-Host "`n--- Searching for any object or description containing T4029 ---"
$cmd.CommandText = "SELECT TOP 10 ScreenName, ObjectName, Description FROM STB_ScreenObjects WHERE ScreenName LIKE '%4029%' OR ObjectName LIKE '%4029%' OR Description LIKE '%4029%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Screen: $($reader['ScreenName']) | Object: $($reader['ObjectName']) | Desc: $($reader['Description'])"
}
$reader.Close()

$conn.Close()
