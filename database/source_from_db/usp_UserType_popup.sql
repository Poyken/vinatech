-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 팝업
-- Browsable : true
-- Create date : 2019-03-17
-- Description : 사용자유형 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserType_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT '%' AS UserType, '전체' AS UserTypeName
	UNION ALL
	SELECT UserType, UserTypeName
	  FROM SmartFramework.dbo.STB_UserType
	 ORDER BY UserType ASC
END