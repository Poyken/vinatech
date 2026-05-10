$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetCode = "SP260508-003"

$sql = "SELECT TOP 10 ProcessDateTime, ProcessTerminalID, IPAddress, Data, ProcessResult 
        FROM STB_ProcessTerminalDataLog 
        WHERE Data LIKE '%$targetCode%'
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
        Write-Host "Không tìm thấy log cho mã $targetCode."
    } else {
        $dt | Format-List
    }
} catch {
    Write-Error $_.Exception.Message
}
