-- Procedure: usp_DoRevokeAll




-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date: 2017-01-03
-- Description:	사용자그룹에 전체 권한을 제거합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRevokeAll]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUserType VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@UserType VARCHAR(20) = @pUserType;

	DELETE FROM STB_UserTypeBasicPermission
	WHERE
			UserType = @UserType

	DELETE FROM STB_UserTypeViewPermission
	WHERE
			UserType = @UserType

	DELETE FROM STB_UserTypeFunctionPermission
	WHERE
			UserType = @UserType
END





GO

