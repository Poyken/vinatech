-- Function: fnAppendTextLine



CREATE FUNCTION [dbo].[fnAppendTextLine]
(
	@pOldText NVARCHAR(MAX) = NULL,
	@pAddedText NVARCHAR(MAX) 
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Result NVARCHAR(MAX)
	
	SET @Result = ISNULL(@pOldText,'') + '[' + CONVERT(VARCHAR,GETDATE(),120) + ']' + CHAR(9) + @pAddedText + CHAR(13) + CHAR(10)
	
	RETURN @Result
END




GO

