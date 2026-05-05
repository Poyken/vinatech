-- Procedure: usp_DoRemoveHelpFromScreen


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-13
-- Description:	화면에서 도움말을 제거합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRemoveHelpFromScreen]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pId VARCHAR(20),
	@pScreenName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@Id VARCHAR(20) = @pId,
			@ScreenName VARCHAR(50) = @pScreenName

	DELETE FROM STB_ScreenHelp
	WHERE
			Name = @ScreenName AND
			Id = @Id
END



GO

