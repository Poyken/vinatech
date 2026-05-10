$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"

$sql = "SELECT CODEPRODUCTION, LOTNO, COUNT(*) as Count 
        FROM STB_VN_BENDING_TAPPING 
        WHERE LOTNO IN (
            SELECT LOTNO 
            FROM STB_VN_BENDING_TAPPING 
            WHERE CAST(CreateDateTime AS DATE) = CAST(GETDATE() AS DATE)
            GROUP BY LOTNO 
            HAVING COUNT(*) > 1
        )
        GROUP BY CODEPRODUCTION, LOTNO
        ORDER BY Count DESC"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    $conn.Close()

    $dt | Format-Table -AutoSize
} catch {
    Write-Error $_.Exception.Message
}
