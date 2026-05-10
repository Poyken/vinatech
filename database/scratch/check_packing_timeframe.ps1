$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"

# Tìm các bản ghi được tạo từ 15:45 đến 16:00 ngày hôm nay
$sql = "SELECT PackingID, LotNo, MaterialCode, PackQty, PrintTime, EmpNo 
        FROM STB_SavePackingTime_VVT 
        WHERE PrintTime >= '2026-05-08 15:40:00' AND PrintTime <= '2026-05-08 16:00:00'
        ORDER BY PrintTime ASC"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy dữ liệu đóng gói nào trong khung giờ này."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
