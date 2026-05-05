-- Procedure: usp_UserInfoUserPermissionGroup_iud






-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 시스템
-- Description:	사용자 리스트와 사용자 그룹정보를 저장합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserInfoUserPermissionGroup_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	EXEC usp_UserInfo_iud @pProcessUserID, @pProcessLanguage, 'UserList', @pXml
	EXEC usp_UserInfo_iud @pProcessUserID, @pProcessLanguage, 'UserExtInfo', @pXml
	EXEC usp_UserPermissionGroup_iud @pProcessUserID, @pProcessLanguage, 'UserPermissonGroup', @pXml
END







GO

