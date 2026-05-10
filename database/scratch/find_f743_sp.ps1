$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$today = (Get-Date).ToString("yyyy-MM-dd")

# Tìm các bản ghi log liên quan đến màn hình F743 hoặc mã Lot đang xử lý
$sql = "SELECT TOP 20 ProcessDateTime, Data, ProcessResult 
        FROM STB_ProcessTerminalDataLog 
        WHERE CAST(ProcessDateTime as DATE) = '$today'
        AND (Data LIKE '%F743%' OR Data LIKE '%ML20250825000072%')
        ORDER BY ProcessDateTime DESC"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy log giao dịch cho F743 trong ngày hôm nay."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
