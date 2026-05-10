$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$search = "SL20250909000100"
$sql = @"
SELECT LotNo, MaterialCode, CurrentQty, PackingIdParent, IsSlitting, IsParrent, LotAttr01, LotAttr02 
FROM STB_MaterialLotInfo 
WHERE LotNo LIKE '%$search%' 
   OR LotAttr01 LIKE '%$search%' 
   OR LotAttr02 LIKE '%$search%'
"@

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    if ($dt.Rows.Count -eq 0) {
        Write-Host "No data found for '$search'."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
