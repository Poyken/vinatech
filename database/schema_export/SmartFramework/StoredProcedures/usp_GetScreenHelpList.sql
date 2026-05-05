-- Procedure: usp_GetScreenHelpList


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-13
-- Description:	화면 도움말을 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetScreenHelpList]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pScreenName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ScreenName VARCHAR(50) = @pScreenName

	SELECT
			SH.Id,
			ISNULL(HL.Title, H.Title) AS Title,
			H.CreateDateTime,
			H.CreateUserID,
			HL.ChangeDateTime,
			HL.ChangeUserID
	FROM
			STB_ScreenHelp SH WITH(NOLOCK)
			INNER JOIN STB_Help H WITH(NOLOCK)
				ON	H.Id = SH.Id
			LEFT OUTER JOIN STB_HelpLanguage HL WITH(NOLOCK)
				ON	HL.Id = H.Id AND
					HL.Language = @ProcessLanguage
END



GO

