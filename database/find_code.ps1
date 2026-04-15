Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_NAME(object_id) AS sp_name FROM sys.sql_modules WHERE definition LIKE '%GBAKAC-%' OR definition LIKE '%VPC%';"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host $reader['sp_name']
}
$conn.Close()
