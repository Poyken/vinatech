-- =============================================
-- Author:		DinhManh
-- Create date: 2024-12-24
-- Description:	config width slitting for Slitting room 
-- =============================================
CREATE PROCEDURE [dbo].[usp_WidthSlitting_get]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
    
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	SELECT 
		WS.MaterialCode,
		MM.MaterialName,
		WS.CustomName,
		WS.Width,
		WS.MaterialUnit,
		--CAST(WS.Width AS NUMERIC(20, 1)) AS Width,
		WS.IsUsed,       -- update 2025-01-20
		WS.CreateDateTime,
		WS.CreateUserID,
		WS.ChangeDateTime,
		WS.ChangeUserID

	FROM
		STB_WidthSlitting WS WITH(NOLOCK)
		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
			ON WS.MaterialCode = MM.MaterialCode
	
	WHERE 
		WS.MaterialCode LIKE @MaterialCode


END
