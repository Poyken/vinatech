$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetCode = "SP260508-003"

$sql = "SELECT TOP 1 Data FROM STB_ProcessTerminalDataLog WHERE Data LIKE '%$targetCode%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $data = $cmd.ExecuteScalar()
    $conn.Close()

    Write-Host "Full Data: $data"
} catch {
    Write-Error $_.Exception.Message
}
