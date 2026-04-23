-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 스마트팩토리
-- Browsable : true
-- Create date : 2020-06-16
-- Description : 라인장애사항전파
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSendGembaTroubleMessage]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pTroubleMessage NVARCHAR(MAX)
AS
BEGIN

	DECLARE @Url VARCHAR(8000) 
		   ,@QueryString varchar(50)
		   ,@TroubleMessage NVARCHAR(MAX) = @pTroubleMessage
	
	SELECT @Url = 'http://jackaroe.pe.kr/sendLineMsgGembaFromProc.php?tmsg=' + @TroubleMessage

	Print @Url

	DECLARE @Response varchar(8000)
	DECLARE @XML xml
	DECLARE @Obj int 
	DECLARE @Result int 
	DECLARE @HTTPStatus int 
	DECLARE @ErrorMsg varchar(MAX)

	EXEC @Result = sp_OACreate 'MSXML2.XMLHttp', @Obj OUT 

	EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @Url, false
	EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
	EXEC @Result = sp_OAMethod @Obj, send, NULL, ''
	EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT 
END