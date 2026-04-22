Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Searching for Objects containing T4029 in SmartFactoryV2 ---"
$cmd.CommandText = "SELECT name, type_desc FROM sys.objects WHERE name LIKE '%4029%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Name: $($reader['name']) | Type: $($reader['type_desc'])"
}
$reader.Close()

$conn.ChangeDatabase("SmartFramework")
Write-Host "`n--- Searching for Objects containing T4029 in SmartFramework ---"
$cmd.CommandText = "SELECT name, type_desc FROM sys.objects WHERE name LIKE '%4029%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Name: $($reader['name']) | Type: $($reader['type_desc'])"
}
$reader.Close()

$conn.Close()
