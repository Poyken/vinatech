$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$startTime = (Get-Date).AddHours(-1).ToString("yyyy-MM-dd HH:mm:ss")

$sql = "SELECT ID, CODEPRODUCTION, LOTNO, FWAL, Vol, CreateDateTime, MachineName 
        FROM STB_VN_BENDING_TAPPING 
        WHERE CreateDateTime >= '$startTime'
        ORDER BY CreateDateTime DESC"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không có dữ liệu Bending Tapping nào trong 1 giờ qua."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
