

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스 관리
-- Description:	생산설비정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldProductMachine_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pMachineName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END	
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @MachineName NVARCHAR(50) = CASE WHEN ISNULL(@pMachineName,'') = '' THEN '%' ELSE @pMachineName END

    
	SELECT
	        MPM.MachineCode AS OldMachineCode,
	        MPM.MachineCode,
	        MPM.MachineName,
	        
	        WCI.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        MPM.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        MPM.LineCode,
	        LI.LineName,
	        MPM.RouteCode,
	        RI.RouteName,
	       
	        MPM.DisplayIndex,
	        MPM.InjectType,
	        MPM.Capa,
	        MPM.MachineDesc1,
	        MPM.MonitoringGroup,
	        MPM.ErpMachineCode,
	        MPM.IsTemperatureControl,
	        MPM.IsCommunication,
	        MPM.RunMode,
	        MPM.MachineDesc2,
	        MPM.MachineDesc3,
	        MPM.MachineDesc4,
	        MPM.MachineDesc5,
	        MPM.MoldProdNo,
	        MPM.CreateDateTime,
	        MPM.CreateUserID,
	        MPM.ChangeDateTime,
	        MPM.ChangeUserID
	FROM
	        STB_MoldProductMachine MPM WITH(NOLOCK)
	        LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON WCI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = MPM.LineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = MPM.RouteCode
	WHERE
			WCI.CompanyCode LIKE @CompanyCode AND
	        MPM.WorkCenterCode LIKE @WorkCenterCode AND
	        MPM.MachineName LIKE @MachineName
	ORDER BY
			MPM.DisplayIndex

END