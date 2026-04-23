-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-12
-- Description:	Popup search LineInfo for Sparepart
-- =============================================
CREATE PROCEDURE usp_VN_LineInfo_SPP_popup
	-- Add the parameters for the stored procedure here
		@pCompanyCode VARCHAR(20) = NULL,	
		@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END



		SELECT
				--LI.CompanyCode,
				--CI.CompanyName,
				--LI.WorkCenterCode,
				--WCI.WorkCenterName,
				LI.LineCode,
				LI.LineDesc AS LineName,
				LI.LineType
		FROM
				STB_LineInfo LI WITH(NOLOCK)
				--LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
				--LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
		WHERE
				((@CompanyCode = '*') OR (LI.CompanyCode LIKE @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (LI.WorkCenterCode LIKE @WorkCenterCode))  AND
				LI.IsUsed = 1


END
