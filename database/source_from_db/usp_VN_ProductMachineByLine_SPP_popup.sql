-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-12
-- Description:	Popup search LineInfo for Sparepart
-- =============================================
CREATE PROCEDURE usp_VN_ProductMachineByLine_SPP_popup
	-- Add the parameters for the stored procedure here
		@pWorkCenterCode VARCHAR(20) = NULL,
		@pLineCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END




		SELECT
				PM.MachineCode,
				MCM.MachineName,
				MCM.MachineNumber,	
				PM.LineCode,
				LI.LineName
		FROM
				STB_ProductMachine                      PM    WITH(NOLOCK)
				LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK) ON PM.MachineCode = MCM.MachineCode
				LEFT OUTER JOIN STB_LineInfo          LI     WITH(NOLOCK) ON LI.LineCode        = PM.LineCode
				--LEFT OUTER JOIN STB_RouteInfo        RI     WITH(NOLOCK) ON RI.RouteCode     = PM.RouteCode
		WHERE 1=1
		  AND MCM.WorkCenterCode LIKE @WorkCenterCode
		  AND PM.LineCode LIKE @LineCode
		  AND MCM.IsProdMachine = 1


END
