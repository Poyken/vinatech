CREATE PROC usp_GembaworkMemoNo_get
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pGembaworkMemoNo VARCHAR(20) OUTPUT
AS
BEGIN
	Declare @GembaworkMemoNo VARCHAR(20)

	EXEC usp_DoCreateSerial 'STB_GembaworkMemo',@GembaworkMemoNo OUTPUT

	Set @pGembaworkMemoNo = @GembaworkMemoNo
END