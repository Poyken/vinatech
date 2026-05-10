$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$search = "SL20250909000100"
$sql = "SELECT LotID, LotNo, WHCode, AreaCode, CurrentQty, PackingID, PackingIdParent FROM STB_MaterialLotInfo WHERE WHCode = 'ROH_HN_WH' AND (LotNo LIKE '%$search%' OR LotID LIKE '%$search%')"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "No records found for '$search' in ROH_HN_WH."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
