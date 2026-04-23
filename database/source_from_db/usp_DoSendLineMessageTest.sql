-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2020-04-03
-- Description : 라인메시지 조립 및 데이터 Insert
-- Modified :
-- Desc : @pParams에 치환 문자열을 ,로 연결하여 입력하면, @pMsg에서 {#1}부터 순서대로 치환하여 메시지를 완성한다.
--        @pParams의 개수와 {#..}의 개수가 다르면 @pParams의 개수 기준으로 적용된다.
-- =============================================
CREATE PROC usp_DoSendLineMessageTest
	@pProcessUserID varchar(20)
   ,@pProcessLanguage varchar(20)
   ,@pMsg NVARCHAR(MAX)
   ,@pParams NVARCHAR(500)
AS
BEGIN
	Declare @Msg NVARCHAR(MAX) = @pMsg
		   ,@Params NVARCHAR(500) = @pParams
		   ,@RowNo INT
		   ,@Item VARCHAR(100) 

	-- @Params 를 테이블로 변환 커서를 통해 반복 처리하여 최종 문자열 완성
	DECLARE cur CURSOR FOR

	SELECT RowNo, Item FROM dbo.fnSplitToTable(',', @Params)

	OPEN cur

	FETCH NEXT FROM cur INTO @RowNo, @Item

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Msg = REPLACE(@Msg, '{#'+CONVERT(VARCHAR(10), @RowNo)+'}', @Item)
	
		FETCH NEXT FROM cur INTO @RowNo, @Item
	END

	CLOSE cur
	DEALLOCATE cur

	SET @Msg = REPLACE(@Msg, '&', '_')
	SET @Msg = REPLACE(@Msg, '#', '_')

	exec usp_DoSendGembaTroubleMessageTest '', '', @Msg
END