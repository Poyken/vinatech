Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM sys.objects WHERE type = 'U' AND (name LIKE '%WAREHOUSE%' OR name LIKE '%LINE%') ORDER BY name"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host $reader['name']
}
$conn.Close()
