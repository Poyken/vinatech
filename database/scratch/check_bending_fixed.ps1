$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetCode = "SP260508-003"

$sql = "SELECT ID, CODEPRODUCTION, LOTNO, FWAL, Vol, CreateDateTime, MachineName 
        FROM STB_VN_BENDING_TAPPING 
        WHERE CODEPRODUCTION = '$targetCode' OR LOTNO LIKE '%$targetCode%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy mã $targetCode trong STB_VN_BENDING_TAPPING."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
