Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

Write-Host "--- STB_DividePackaging Columns ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 0 * FROM STB_DividePackaging"
$reader = $cmd.ExecuteReader()
for ($i = 0; $i -lt $reader.FieldCount; $i++) {
    Write-Host $reader.GetName($i)
}
$reader.Close()

$conn.Close()
