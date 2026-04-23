
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-18
-- Description:	시스템용 문자열 리소스를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSystemStringResource]
	@pLanguage VARCHAR(20),
	@pName NVARCHAR(200),
	@pValue NVARCHAR(500) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Language VARCHAR(20) = @pLanguage,
			@Name NVARCHAR(200) = @pName

	EXEC SmartFramework.dbo.usp_GetSystemStringResource @pLanguage = @Language,
														@pName = @Name,
														@pValue = @pValue OUTPUT
END

