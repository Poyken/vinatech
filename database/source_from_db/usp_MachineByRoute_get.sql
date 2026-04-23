-- =============================================
-- Author:		<DinhManh>
-- Create date: <12-30-2024>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineByRoute_get]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	SELECT 
		MBR.RouteCode,
		RI.RouteName,
		MBR.MachineName,
		MBR.CreateDateTime,
		MBR.CreateUserID,
		MBR.ChangeDateTime,
		MBR.ChangeUserID,
		MBR.ID,
		MBR.IsUsed

	FROM
		STB_MachineByRoute_HN MBR WITH(NOLOCK)
		LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
			ON RI.RouteCode = MBR.RouteCode
	
END
