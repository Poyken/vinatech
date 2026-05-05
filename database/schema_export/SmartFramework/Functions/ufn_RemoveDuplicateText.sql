-- Function: ufn_RemoveDuplicateText
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-24
-- Description:	loại bỏ dữ liệu text trùng lặp
-- =============================================
CREATE FUNCTION dbo.ufn_RemoveDuplicateText
(
    @Input NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Temp TABLE (Item NVARCHAR(100));
    DECLARE @pos INT = 0, @start INT = 1, @value NVARCHAR(100);
    DECLARE @Output NVARCHAR(MAX) = '';

    WHILE 1 = 1
    BEGIN
        SET @pos = CHARINDEX(',', @Input, @start);
        
        IF @pos = 0
        BEGIN
            SET @value = LTRIM(RTRIM(SUBSTRING(@Input, @start, LEN(@Input))));
            IF @value <> '' AND NOT EXISTS (SELECT 1 FROM @Temp WHERE Item = @value)
                INSERT INTO @Temp VALUES (@value);
            BREAK;
        END

        SET @value = LTRIM(RTRIM(SUBSTRING(@Input, @start, @pos - @start)));
        IF @value <> '' AND NOT EXISTS (SELECT 1 FROM @Temp WHERE Item = @value)
            INSERT INTO @Temp VALUES (@value);

        SET @start = @pos + 1;
    END

    -- Ghép lại thành chuỗi kết quả
    SELECT @Output = @Output + CASE WHEN @Output = '' THEN '' ELSE ',' END + Item
    FROM @Temp;

    RETURN @Output;
END
GO

