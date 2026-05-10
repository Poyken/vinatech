$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$searchString = "SP260508-003"

$sql = @"
DECLARE @SearchString NVARCHAR(100) = '%$searchString%';
DECLARE @Results TABLE (TableName NVARCHAR(MAX), ColumnName NVARCHAR(MAX));

DECLARE @TableName NVARCHAR(MAX);
DECLARE @ColumnName NVARCHAR(MAX);
DECLARE @Query NVARCHAR(MAX);

DECLARE TableCursor CURSOR FOR
SELECT t.name AS TableName, c.name AS ColumnName
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE ty.name IN ('nvarchar', 'varchar', 'nchar', 'char')
  AND t.name NOT LIKE 'STB_ProcessTerminalDataLog%'; -- Exclude log table to save time

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @TableName, @ColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Query = 'IF EXISTS (SELECT 1 FROM ' + @TableName + ' WHERE ' + @ColumnName + ' LIKE ''' + @SearchString + ''') INSERT INTO @Results SELECT ''' + @TableName + ''', ''' + @ColumnName + '''';
    EXEC sp_executesql @Query;
    FETCH NEXT FROM TableCursor INTO @TableName, @ColumnName;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;

SELECT * FROM @Results;
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
        Write-Host "Không tìm thấy chuỗi $searchString ở bất kỳ bảng nào (ngoại trừ bảng log)."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
