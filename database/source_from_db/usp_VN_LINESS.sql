CREATE PROC [dbo].[usp_VN_LINESS] -- EXEC usp_VN_LINESS '' , '' ,'' ,'VVT_F2'
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
SET NOCOUNT ON;
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
		 
	SELECT
	        LI.LineCode,
	        LI.LineName
		
	FROM
	        STB_LineInfo LI WITH(NOLOCK)
			
	WHERE
	        ((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode)) 

END

