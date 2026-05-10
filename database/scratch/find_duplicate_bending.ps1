$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$today = Get-Date -Format "yyyy-MM-dd"

# Tìm các LOTNO xuất hiện nhiều hơn 1 lần trong ngày hôm nay
$sql = "SELECT LOTNO, COUNT(*) as Count 
        FROM STB_VN_BENDING_TAPPING 
        WHERE CAST(CreateDateTime AS DATE) = '$today'
        GROUP BY LOTNO 
        HAVING COUNT(*) > 1"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy LOTNO nào bị lặp trong ngày hôm nay."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
