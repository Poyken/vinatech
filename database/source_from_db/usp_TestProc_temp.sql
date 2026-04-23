CREATE PROC usp_TestProc_temp 
	@pTableName VARCHAR(100)
AS
BEGIN
	Declare @sql VARCHAR(MAX)
	       ,@TableName VARCHAR(100) = @pTableName

	SET @sql = 'SELECT TOP 100 * FROM ' + @TableName

	execute (@sql)
END