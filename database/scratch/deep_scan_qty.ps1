$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$lotID = "ML20250825000072"

$sql = @"
DECLARE @SearchValue DECIMAL(18, 10) = 248.6;
DECLARE @LotID NVARCHAR(100) = '$lotID';

DECLARE @Results TABLE (TableName NVARCHAR(MAX), ColumnName NVARCHAR(MAX), Value NVARCHAR(MAX));

DECLARE @TableName NVARCHAR(MAX);
DECLARE @ColumnName NVARCHAR(MAX);
DECLARE @Query NVARCHAR(MAX);

DECLARE TableCursor CURSOR FOR
SELECT t.name AS TableName, c.name AS ColumnName
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE ty.name IN ('decimal', 'numeric', 'float', 'real');

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @TableName, @ColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Kiểm tra xem bảng có cột nào chứa LotID không
    DECLARE @HasLotID BIT = 0;
    DECLARE @LotColumnName NVARCHAR(MAX);
    
    SELECT TOP 1 @LotColumnName = c.name
    FROM sys.columns c
    JOIN sys.tables t ON c.object_id = t.object_id
    WHERE t.name = @TableName AND (c.name LIKE '%LotID%' OR c.name LIKE '%PackingID%');

    IF @LotColumnName IS NOT NULL
    BEGIN
        SET @Query = 'SELECT ''' + @TableName + ''', ''' + @ColumnName + ''', CAST(' + @ColumnName + ' AS NVARCHAR(MAX)) FROM ' + @TableName + ' WHERE ' + @LotColumnName + ' = ''' + @LotID + ''' AND ABS(' + @ColumnName + ' - 248.6) < 0.0001';
        INSERT INTO @Results (TableName, ColumnName, Value)
        EXEC sp_executesql @Query;
    END

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
        Write-Host "Không tìm thấy con số 248.6 ở bất kỳ bảng nào liên quan đến mã Lot này."
    } else {
        $dt | Format-Table -AutoSize
    }
} catch {
    Write-Error $_.Exception.Message
}
