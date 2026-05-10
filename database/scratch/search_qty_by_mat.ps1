$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"

$sql = "SELECT TOP 10 LotID, InitialQty, CurrentQty, CreateDateTime FROM STB_MaterialLotInfo WHERE MaterialCode = '10140105000' AND (ABS(InitialQty - 248.6) < 0.001 OR ABS(CurrentQty - 248.6) < 0.001)"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy Lot nào có số lượng 248.6 cho mã vật tư này."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
