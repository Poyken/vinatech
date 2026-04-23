-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-04
-- Description:	Get Special SparePart Info
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SpecialSparePartInfo_get]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END


	SELECT 
		SSPI.SparePartCode,
		SSPI.SparePartName,
		SSPI.SparePartSpec01,
		SSPI.UsingQty,
		SSPI.Model,
		SSPI.LotQty,
		SSPI.CycleReplace,
		FLOOR(SSPI.CycleReplace / SSPI.LotQty)  AS LifeLotQty,
		SSPI.IsUsed,
		SSPI.CompanyCode,
		SSPI.WorkCenterCode,
		SSPI.SPNote,
		SSPI.CreateDateTime,
		SSPI.CreateUserID,
		SSPI.ChangeDateTime,
		SSPI.ChangeUserID


	FROM 
		STB_VN_SpecialSparePartInfo SSPI WITH(NOLOCK)

	WHERE SSPI.WorkCenterCode LIKE @WorkCenterCode




END
