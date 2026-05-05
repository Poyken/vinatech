-- Procedure: usp_DoSaveUserTypePermissionAll






-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.01.27
-- Group : 시스템
-- Description:	그룹별권한정보 데이터를 모두 저장합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveUserTypePermissionAll]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	EXEC usp_UserTypeBasicPermission_iud @pProcessUserID, @pProcessLanguage, 'MenuList', @pXml
	EXEC usp_UserTypeViewPermission_iud @pProcessUserID, @pProcessLanguage, 'ViewList', @pXml
	EXEC usp_UserTypeFunctionPermission_iud @pProcessUserID, @pProcessLanguage, 'FunctionList', @pXml
	
END







GO

