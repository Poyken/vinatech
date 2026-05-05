-- Procedure: usp_DoUpdateUserInfo






-- =============================================
-- Author:		Kim Han Young
-- Browsable : false
-- Create date: 2016-01-21
-- Description:	Change user info
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateUserInfo]
	@pUserID VARCHAR(20),
	@pPassword VARCHAR(20),
	@pPasswordConfirm VARCHAR(20) = NULL,
	@pUserName NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF ISNULL(@pPasswordConfirm,'') <> '' AND  @pPassword <> @pPasswordConfirm BEGIN
		RAISERROR('Unmatch Password',16,1)
		RETURN
    END
    
    DECLARE @OldPassword VARCHAR(20)
    
    IF ISNULL(@pPasswordConfirm,'') = '' BEGIN
    
		SELECT
				@OldPassword = Password
		FROM
				STB_UserInfo 
		WHERE
				UserID = @pUserID
				
		IF @pPassword <> @OldPassword BEGIN
			RAISERROR('Invalid Password',16,1)
			RETURN
		END
		
	END

	UPDATE STB_UserInfo
	SET
			UserName = @pUserName,
			Password = CASE WHEN @pPasswordConfirm IS NOT NULL THEN PWDENCRYPT(@pPassword) ELSE Password END
	WHERE
			UserID = @pUserID
END







GO

