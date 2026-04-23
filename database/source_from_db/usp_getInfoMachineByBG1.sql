-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-02-26
-- Description:	Lấy ra danh sách các máy thuộc nhà máy BG1
-- exec usp_getInfoMachineByBG1 'VVBGC-11'
-- =============================================
CREATE PROCEDURE [dbo].[usp_getInfoMachineByBG1]
	-- Add the parameters for the stored procedure here
	@pLineCode VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT
	        MCM.MachineCode,
			MCM.MachineName
			
	FROM
			STB_ProductMachine                      PM    WITH(NOLOCK)
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK) ON PM.MachineCode = MCM.MachineCode
			LEFT OUTER JOIN STB_LineInfo          LI     WITH(NOLOCK) ON LI.LineCode        = PM.LineCode
			LEFT OUTER JOIN STB_RouteInfo        RI     WITH(NOLOCK) ON RI.RouteCode     = PM.RouteCode
			where MCM.WorkCenterCode='VVT_F2' and PM.LineCode=@pLineCode
	UNION ALL
	SELECT
	        'Empty' as MachineCode,
			N'Không có' AS MachineName
			
	
			
END
