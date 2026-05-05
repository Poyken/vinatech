-- Procedure: usp_DoResetUserViewLayout


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 시스템관리
-- Browsable : false
-- Create date : 2019-11-22
-- Description : 사용자의 뷰레이아웃 삭제
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoResetUserViewLayout]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pScreenName VARCHAR(50),
	@pViewName VARCHAR(100),
	@pControlType VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ScreenName VARCHAR(50) = @pScreenName,
			@ViewName VARCHAR(100) = @pViewName,
			@ControlType VARCHAR(20) = @pControlType

	DELETE FROM STB_UserViewLayout
	WHERE
			UserID = @ProcessUserID AND
			ScreenName = @ScreenName AND
			ViewName = @ViewName AND
			ControlType = @ControlType
END

GO

