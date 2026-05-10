$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"

$sql = "SELECT LotID, PackingID, MaterialCode, CurrentQty, CreateDateTime 
        FROM STB_MaterialLotInfo 
        WHERE LotID LIKE 'SP260508%' OR LotID LIKE 'SP20260508%' OR PackingID LIKE 'SP260508%' OR PackingID LIKE 'SP20260508%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy Lot nào khớp với tiền tố SP260508."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
