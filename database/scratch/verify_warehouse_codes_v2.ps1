$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$lotID = "ML20250606000100"
$lotID2 = "ML20250606000109"

$sql = "SELECT LotID, SourceWarehouseCode, TargetWarehouseCode, CreateDateTime 
        FROM STB_MaterialWarehouseInOutHist 
        WHERE LotID IN ('$lotID', '$lotID2') 
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
        Write-Host "No warehouse history found for these IDs."
    } else {
        Write-Host "Warehouse info from history:"
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
