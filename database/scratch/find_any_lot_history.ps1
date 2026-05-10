$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$lotID = "ML20250606000109"

$sql = "SELECT LotID, ProcessedLotID, SourceMaterialWarehouseCode, TargetMaterialWarehouseCode, CreateDateTime 
        FROM STB_MaterialWarehouseInOutHist 
        WHERE LotID LIKE '%$lotID%' OR ProcessedLotID LIKE '%$lotID%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "No warehouse history found for LotID: $lotID."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
