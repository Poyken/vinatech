-- Procedure: usp_CodeGroup_get





-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-23
-- Browsable : true
-- Group : 시스템관리
-- Description:	기본코드관리 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CodeGroup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
	SELECT	
			CG.*
	FROM
			VW_CodeGroup CG





GO

