$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetCode = "SP260508-003"
$today = Get-Date -Format "yyyy-MM-dd"

$sql = "SELECT TOP 1 Data FROM STB_ProcessTerminalDataLog WHERE CAST(ProcessDateTime AS DATE) = '$today' AND Data LIKE '%$targetCode%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $data = $cmd.ExecuteScalar()
    $conn.Close()

    if ($data) {
        Write-Host "Full Data: $data"
    } else {
        Write-Host "Không tìm thấy dữ liệu cho mã $targetCode trong ngày hôm nay."
    }
} catch {
    Write-Error $_.Exception.Message
}
