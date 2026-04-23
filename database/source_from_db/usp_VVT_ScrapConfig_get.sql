-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-04
-- Description:	Get scrap config for B598
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_ScrapConfig_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCompanyCode VARCHAR(10) = NULL,
		@pWorkCenterCode VARCHAR(10) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(50) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(50) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END


	SELECT
			VNNG.IDNG,
			VNNG.CodeNG,
			VNNG.NG,
			VNNG.[Desc],
			VNNG.WorkCenterCode,
			VNNG.IsUsed,
			VNNG.CreateDateTime,
			VNNG.CreateUserID,
			VNNG.ChangeDateTime,
			VNNG.ChangeUserID
			
	FROM 
			STB_VN_NG VNNG

	WHERE 
		
			VNNG.WorkCenterCode LIKE @WorkCenterCode


END
