


-- =============================================
-- Author: Jeon Gyeong Ho (khjun@awoo.co.kr)
-- Create date: 2016-07-19
-- Browsable : true
-- Group : 팝업
-- Description:	불량원인 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCause_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectCauseGroupCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @DefectCauseGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectCauseGroupCode,'') = '' THEN '%' ELSE @pDefectCauseGroupCode END
	
	SELECT
			DCI.DefectCauseCode,
			DCI.BasicDefectCauseName AS DefectCauseName,
			DCI.DefectCauseGroupCode
	FROM
			STB_DefectCauseInfo DCI WITH(NOLOCK)
	WHERE
			(DCI.DefectCauseGroupCode LIKE @DefectCauseGroupCode) AND
			DCI.IsUsed = 1

END




