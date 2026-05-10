$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"

$sql = "SELECT TOP 10 LotID, ActualExportQuantity, CreateDateTime FROM STB_MaterialWarehouseInOutHist WHERE CAST(ActualExportQuantity AS VARCHAR) LIKE '248.6%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy bản ghi InOut nào có số lượng bắt đầu bằng 248.6."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
