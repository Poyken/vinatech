$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetPart = "260508-003"

$sql = "SELECT LotID, PackingID, MaterialCode, CurrentQty, CreateDateTime 
        FROM STB_MaterialLotInfo 
        WHERE LotID LIKE '%$targetPart%' OR PackingID LIKE '%$targetPart%' OR LotNo LIKE '%$targetPart%'"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "Không tìm thấy mã nào chứa $targetPart trong STB_MaterialLotInfo."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
