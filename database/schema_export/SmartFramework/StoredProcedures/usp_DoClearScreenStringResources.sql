-- Procedure: usp_DoClearScreenStringResources



-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2016-12-13
-- Description:	화면의 리소스를 삭제합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoClearScreenStringResources]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pScreenName NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ScreenName VARCHAR(50) = @pScreenName

	DELETE FROM STB_ScreenStringResources
	WHERE ScreenName = @ScreenName
END




GO

