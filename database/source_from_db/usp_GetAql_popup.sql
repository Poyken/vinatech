

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	AQL 팝업을 조회합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetAql_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
			DISTINCT
	        ABR.AQL
	FROM
	        STB_AqlBasicRule ABR WITH(NOLOCK)
	ORDER BY
			ABR.AQL

END


