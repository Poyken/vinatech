Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Tables in SmartFramework ---"
$cmd.CommandText = "SELECT name FROM sys.tables WHERE name LIKE '%Screen%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) { Write-Host $reader['name'] }
$reader.Close()

$conn.ChangeDatabase("SmartFactoryV2")
Write-Host "`n--- Tables in SmartFactoryV2 ---"
$cmd.CommandText = "SELECT name FROM sys.tables WHERE name LIKE '%Screen%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) { Write-Host $reader['name'] }
$reader.Close()

$conn.Close()
