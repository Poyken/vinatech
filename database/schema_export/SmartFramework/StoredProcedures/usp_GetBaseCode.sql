-- Procedure: usp_GetBaseCode






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : true
-- Group : 기준정보
-- Description:	Login as Developer
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBaseCode]
	@pProcessUserID VARCHAR(20) = NULL,	-- LOB 테스트 이후에 = NULL 삭제할 것
	@pProcessLanguage VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			BC.ItemCode,
			BC.CodeGroup,
			BC.Description,
			BC.ChangeDateTime
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	
END







GO

