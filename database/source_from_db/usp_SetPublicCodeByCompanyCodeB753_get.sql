-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-25
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SetPublicCodeByCompanyCodeB753_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCompanyCode VARCHAR(50),
		@pPublicCode VARCHAR(100) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(50) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @PublicCode VARCHAR(50) = CASE WHEN ISNULL(@pPublicCode,'') = '' THEN '%' ELSE @pPublicCode END


	SELECT 
			ID,
			CompanyCode,
			PublicCode,
			PartNo,
			IsUsed,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID

	FROM
		STB_SetPublicCodeByCompanyCode

	WHERE
		PublicCode LIKE @PublicCode



END
