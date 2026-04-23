-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-09-24
-- Description:	팝업용 라인정보를 가져옵니다.(품목 클리어를 위한 더미를 추가합니다.)
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineInfoWithDummy_popup]
	@pCompanyCode VARCHAR(20) = NULL,	
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

    SELECT
			LI.CompanyCode,
			CI.CompanyName,
			LI.WorkCenterCode,
			WCI.WorkCenterName,
			LI.LineCode,
			LI.LineDesc AS LineName,
			LI.LineType,
			'' AS MaterialCode,
			'' AS MaterialName
	FROM
			STB_LineInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
	WHERE
	        ((LI.CompanyCode = @CompanyCode) OR (@CompanyCode = '*')) AND
	        ((LI.WorkCenterCode = @WorkCenterCode) OR (@WorkCenterCode = '*'))  AND
			LI.IsUsed = 1
END



