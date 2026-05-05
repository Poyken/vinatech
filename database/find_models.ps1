$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()

$sql = "SELECT TOP 5 MaterialCode, MaterialName, BasicRoutingCode FROM STB_MaterialMaster WHERE BasicRoutingCode IS NOT NULL AND IsClosed = 0 ORDER BY CreateDateTime DESC"
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Code: $($reader['MaterialCode']) | Name: $($reader['MaterialName'])"
}
$conn.Close()
