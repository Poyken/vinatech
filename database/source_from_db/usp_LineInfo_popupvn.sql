
CREATE PROCEDURE [dbo].[usp_LineInfo_popupvn]
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
			LI.LineType
	FROM
			STB_LineInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
	WHERE
	        ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode))  AND
			LI.IsUsed = 1
END


