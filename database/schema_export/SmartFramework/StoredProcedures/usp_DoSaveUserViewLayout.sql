-- Procedure: usp_DoSaveUserViewLayout


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 시스템관리
-- Browsable : false
-- Create date : 2019-11-22
-- Description : 사용자의 뷰레이아웃 저장
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveUserViewLayout]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pScreenName VARCHAR(50),
	@pViewName VARCHAR(100),
	@pControlType VARCHAR(20),
	@pLayout NVARCHAR(MAX),
	@pSettings NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ScreenName VARCHAR(50) = @pScreenName,
			@ViewName VARCHAR(100) = @pViewName,
			@ControlType VARCHAR(20) = @pControlType

	UPDATE	STB_UserViewLayout
	SET
			Layout = @pLayout,
			Settings = @pSettings,
			ChangeDateTime = GETDATE()
	WHERE
			UserID = @ProcessUserID AND
			ScreenName = @ScreenName AND
			ViewName = @ViewName AND
			ControlType = @ControlType

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO STB_UserViewLayout
		(
			UserID,
			ScreenName,
			ViewName,
			ControlType,
			Layout,
			Settings,
			CreateDateTime
		)
		VALUES
		(
			@ProcessUserID,
			@ScreenName,
			@ViewName,
			@ControlType,
			@pLayout,
			@pSettings,
			GETDATE()
		)
	END
END

GO

