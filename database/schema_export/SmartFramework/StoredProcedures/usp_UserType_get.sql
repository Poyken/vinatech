-- Procedure: usp_UserType_get






-- =============================================
-- Author:		Park Jong Seob (jspark@awoo.co.kr)
-- Create date: 2016-01-18
-- Browsable : true
-- Description:	Get User Type List
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUserType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @UserType VARCHAR(20) = CASE WHEN ISNULL(@pUserType,'') = '' THEN '%' ELSE @pUserTYpe END
	    
	SELECT	
			UT.UserType AS OldUserType,
			UT.*
	FROM		
			STB_UserType UT
	WHERE	
			UT.UserType LIKE @UserType
	
END
GO

