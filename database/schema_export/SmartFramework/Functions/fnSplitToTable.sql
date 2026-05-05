-- Function: fnSplitToTable




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr
-- Create date: 2009-08-31
-- Description:	구분자로 구성된 문자열을 테이블로 변환하는 함수
-- ChangeDate : 2016-05-18
-- Description: 테이블에 RowNo 추가
-- =============================================
CREATE FUNCTION [dbo].[fnSplitToTable]
(	
	@pDelimeter NVARCHAR(MAX),
	@pItems NVARCHAR(MAX)
)
RETURNS @ItemTable TABLE
(
	RowNo INT,
	Item NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @TotalLength INT,
			@DelimeterLength INT,
			@Pos1 INT,
			@Pos2 INT,
			@Count INT
	SET @TotalLength = LEN(@pItems)
	SET @DelimeterLength = LEN(@pDelimeter)
	SET @Pos1 = 1
	SET @Count = 1
	
	IF @pItems IS NOT NULL
	BEGIN
			WHILE 1 = 1
				BEGIN
					SET @Pos2 = CHARINDEX(@pDelimeter,@pItems,@Pos1)
					IF @Pos2 <= 0
						BREAK
					INSERT INTO @ItemTable VALUES (@Count,SUBSTRING(@pItems,@Pos1,@Pos2 - 1))
					SET @Count = @Count + 1
					SET @pItems = SUBSTRING(@pItems,@Pos2 + @DelimeterLength,LEN(@pItems) - (@Pos2))
				END
			IF LEN(@pItems) > 0
			BEGIN
				INSERT INTO @ItemTable VALUES (@Count,@pItems)
				SET @Count = @Count + 1
			END
	END
	
	RETURN
END




GO

