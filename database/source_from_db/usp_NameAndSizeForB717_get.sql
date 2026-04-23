-- =============================================
-- Author:		<DinhManh>
-- Create date: <2025-01-14>
-- Description:	<>
-- =============================================
CREATE PROCEDURE [dbo].[usp_NameAndSizeForB717_get] 
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pWorkCenterCode VARCHAR(20) = NULL,
		@pNameProduct VARCHAR(10) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @NameProduct VARCHAR(10) = CASE WHEN ISNULL(@pNameProduct,'') = '' THEN '%' ELSE @pNameProduct END

    -- Insert statements for procedure here
	SELECT 
		NAS.ID,
		NAS.NAMES,
		NAS.SIZE,
		NAS.IsUsed,
		NAS.WorkCenterCode,
		NAS.CreateDateTime,
		NAS.CreateUserID,
		NAS.ChangeDateTime,
		NAS.ChangeUserID

	FROM
		STB_NamesAndSizeForB717 NAS WITH(NOLOCK)

	WHERE 
			NAS.WorkCenterCode LIKE @WorkCenterCode 
		AND NAS.NAMES LIKE @NameProduct
END
