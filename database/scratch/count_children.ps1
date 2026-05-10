$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$id = "ML20250825000072"
$sql = "SELECT COUNT(*) FROM STB_MaterialLotInfo WHERE PackingIdParent = '$id'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $res = $cmd.ExecuteScalar()
    Write-Host "Count of records with PackingIdParent='$id': $res"
    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}
