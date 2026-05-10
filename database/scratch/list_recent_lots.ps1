$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$startTime = (Get-Date).AddHours(-2).ToString("yyyy-MM-dd HH:mm:ss")

$sql = "SELECT LotID, PackingID, MaterialCode, CurrentQty, CreateDateTime 
        FROM STB_MaterialLotInfo 
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
        Write-Host "Không có Lot mới nào trong 2 giờ qua."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
