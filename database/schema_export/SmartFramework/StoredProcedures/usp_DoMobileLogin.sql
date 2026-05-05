-- Procedure: usp_DoMobileLogin






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Login as Mobile
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMobileLogin]
	@pUserID VARCHAR(20),
	@pPassword VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @UserID VARCHAR(20) = @pUserID,
			@Password VARCHAR(20) = @pPassword,
			@AllowFlag VARCHAR(20),
			@CurrPassword VARCHAR(20)
			
	SELECT
			@AllowFlag = UI.AllowFlag,
			@CurrPassword = UI.Password
	FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @pUserID
			
	IF @CurrPassword IS NULL BEGIN
		RAISERROR('Not found user',16,1)
		RETURN
	END
	IF @AllowFlag <> 'Allow' BEGIN
		RAISERROR('You are not allowed',16,1)
		RETURN
	END
	IF @CurrPassword <> @Password BEGIN
		RAISERROR('Invalid Password..',16,1)
		RETURN
	END

	SELECT
			UI.*
    FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @UserID
END







GO

