$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$today = Get-Date -Format "yyyy-MM-dd"

$sql = "SELECT TOP 100 PackingID, LotNo, MaterialCode, PackQty, PrintTime, EmpNo 
        FROM STB_SavePackingTime_VVT 
        WHERE CAST(PrintTime AS DATE) = '$today'
        ORDER BY PrintTime DESC"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy dữ liệu đóng gói nào trong ngày hôm nay."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
