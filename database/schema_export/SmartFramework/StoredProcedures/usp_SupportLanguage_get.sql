-- Procedure: usp_SupportLanguage_get





-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-10-18
-- Browsable : true
-- Group : 시스템
-- Description:	지원 언어 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SupportLanguage_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			SL.Language
	FROM
			VW_SupportLanguage SL WITH(NOLOCK)


END






GO

