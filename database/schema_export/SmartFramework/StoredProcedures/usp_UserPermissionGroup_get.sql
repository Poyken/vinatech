-- Procedure: usp_UserPermissionGroup_get






-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 시스템관리
-- Description:	사용자의 유형 할당정보를 가져옵니다.
-- Modified: jspark.
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserPermissionGroup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pUserID VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @UserID VARCHAR(20) = CASE WHEN ISNULL(@pUserID,'') = '' THEN '*' ELSE @pUserID END

    SELECT
			UT.UserType AS OldUserType,
			@pUserID AS OldUserID,
			UT.UserType,
			@pUserID AS UserID,
			UT.UserTypeName,
	        ISNULL(UPG.HasPermission, 0) AS HasPermission,
	        UPG.CreateDateTime,
	        UPG.CreateUserID,
	        UPG.ChangeDateTime,
	        UPG.ChangeUserID    
    FROM
			STB_UserType UT
	        LEFT OUTER JOIN STB_UserPermissionGroup UPG
				ON (UPG.UserType = UT.UserType AND UPG.UserID = @UserID)
	WHERE
			UT.IsUse = 1
END







GO

