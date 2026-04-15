Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name, definition FROM sys.sql_modules m JOIN sys.objects o ON m.object_id = o.object_id WHERE definition LIKE '%MaterialName%' AND definition LIKE '%CASE%';"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Object: $($reader['name'])"
}
$conn.Close()
