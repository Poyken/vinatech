-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-27
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_PackingQtyWarehouse_A419_get]
	-- Add the parameters for the stored procedure here
	    @pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pModelCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pModelCode,'') = '' THEN '%' ELSE @pModelCode END

	SELECT 
			PQW.ID,
			PQW.ModelCode,
			PQW.ModelName,
			PQW.Qty,
			PQW.Kind,
			PQW.IsUsed,
			PQW.CreateDateTime,
			PQW.CreateUserID,
			PQW.ChangeDateTime,
			PQW.ChangeUserID
	FROM 
		STB_PackingQtyWarehouse PQW

	WHERE
		PQW.ModelCode LIKE @ModelCode

END
