-- Procedure: CheckTableInSchemas
CREATE PROCEDURE CheckTableInSchemas
    @TableName NVARCHAR(128)  -- Tên bảng cần kiểm tra
AS
BEGIN
    -- Tạo bảng tạm để lưu trữ kết quả
    CREATE TABLE #SchemaTable (
        SchemaName NVARCHAR(128),
        TableExists BIT
    );

    -- Kiểm tra sự tồn tại của bảng trong các schema
    INSERT INTO #SchemaTable (SchemaName, TableExists)
    SELECT 
        schema_name(t.schema_id) AS SchemaName,
        CASE 
            WHEN t.name IS NOT NULL THEN 1
            ELSE 0
        END AS TableExists
    FROM 
        sys.tables t
    WHERE 
        t.name = @TableName;

    -- Hiển thị kết quả
    SELECT * FROM #SchemaTable;

    -- Xóa bảng tạm
    DROP TABLE #SchemaTable;
END;
GO

