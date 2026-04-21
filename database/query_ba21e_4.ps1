$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = @"
SELECT 
    MaterialCode, MaterialName, MaterialThickness, MaterialWidth
FROM STB_MaterialMaster 
WHERE MaterialCode IN ('CREBO83-01')
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()

Write-Host "--- STB_MaterialMaster ---"
while ($reader.Read()) {
    Write-Host "Code: $($reader['MaterialCode']) | Name: $($reader['MaterialName']) | Thickness: $($reader['MaterialThickness']) | Width: $($reader['MaterialWidth'])"
}
$reader.Close()

$conn.Close()
