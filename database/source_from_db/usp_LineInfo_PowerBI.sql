

-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2023-03-30
-- Description:	팝업용 라인정보를 가져옵니다.
-- usp_LineInfo_PowerBI '',''
-- =============================================

CREATE PROCEDURE [dbo].[usp_LineInfo_PowerBI]
	                    @pProcessUserID VARCHAR(20),
	                    @pProcessLanguage VARCHAR(20)
	--@pCompanyCode VARCHAR(20) = NULL,	
	--@pWorkCenterCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	--DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
 --   DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

    SELECT
			LI.CompanyCode,
			CI.CompanyName,
			LI.WorkCenterCode,
			WCI.WorkCenterName,
			LI.LineCode,
			LI.LineDesc AS LineName,
			LI.LineType
	FROM
			STB_LineInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
	WHERE 1=1
	  --AND 
	  --      ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
	  --      ((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode))  AND
		AND LI.IsUsed = 1 
		AND	LI.LineCode LIKE '%VPC%'

END


