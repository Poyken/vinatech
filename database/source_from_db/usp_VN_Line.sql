CREATE PROC [dbo].[usp_VN_Line]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;
		SELECT CodeLine,
			   Line
		FROM STB_VN_LINE WITH(NOLOCK)
			WHERE IsUsed='1'
END