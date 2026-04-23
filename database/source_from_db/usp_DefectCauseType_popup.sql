

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2016-07-19
-- Browsable : true
-- Group : 팝업
-- Description: 불량원인 귀책종류 팝업용
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCauseType_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectCauseType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefectCauseType VARCHAR(20) = CASE WHEN ISNULL(@pDefectCauseType,'') = '' THEN '%' ELSE @pDefectCauseType END

	SELECT
			DCT.DefectCauseType,
			DCT.DefectCauseName AS DefectCauseTypeName
	FROM
			VW_DefectCauseType DCT
	WHERE
			(DCT.DefectCauseType LIKE @DefectCauseType)

END




