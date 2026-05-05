-- Procedure: usp_DoInsertScreenStringResource



-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2016-12-13
-- Description:	화면의 문자열 리소스를 저장합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoInsertScreenStringResource]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pScreenName VARCHAR(50),
	@pResourceName NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	INSERT INTO STB_ScreenStringResources
	(
		ScreenName,
		ResourceName
	)
	VALUES
	(
		@pScreenName,
		@pResourceName
	)
END




GO

