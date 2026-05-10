$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetCode = "SP260508-003"

$sql = @"
DECLARE @target NVARCHAR(100) = '$targetCode';
SELECT 'STB_MergeBoxRealityHist_531_VVT' as TableName, ID, LotNo, PackingID, CreateDateTime FROM STB_MergeBoxRealityHist_531_VVT WHERE LotNo LIKE '%' + @target + '%' OR PackingID LIKE '%' + @target + '%'
UNION ALL
SELECT 'STB_VN_BENDING_TAPPING' as TableName, ID, LOTNO, CODEPRODUCTION, CreateDateTime FROM STB_VN_BENDING_TAPPING WHERE CODEPRODUCTION LIKE '%' + @target + '%' OR LOTNO LIKE '%' + @target + '%'
UNION ALL
SELECT 'STB_MaterialLotInfo' as TableName, id, LotID, PackingID, CreateDateTime FROM STB_MaterialLotInfo WHERE LotID LIKE '%' + @target + '%' OR PackingID LIKE '%' + @target + '%' OR LotNo LIKE '%' + @target + '%'
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
        Write-Host "Không tìm thấy mã $targetCode trong các bảng nghiệp vụ chính."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
