-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 생산관리 > [B270] 생산설비정보
-- Description:	생산설비를 가져옵니다
-- Modified: 라인편집 2019.05.14 (kilee)

--> 실행 :  exec [usp_ProductMachine_get] '','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductMachine_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMachineTypeCode VARCHAR(20) = NULL  
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @MachineTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineTypeCode,'') = '' THEN '%' ELSE @pMachineTypeCode END
	
	SELECT
			MCM.CompanyCode,
			MCM.WorkCenterCode,
			PM.MachineCode,
			MCM.MachineName,
			MCM.MachineNumber,	-- DinhManh update 2025-01-14
			PM.LineCode,
			LI.LineName,
			PM.RouteCode,
			RI.RouteName,
			PM.DisplayIndex,
			PM.CreateDateTime,
			PM.CreateUserID,
			PM.ChangeDateTime,
			PM.ChangeUserID
	FROM
			STB_ProductMachine                      PM    WITH(NOLOCK)
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK) ON PM.MachineCode = MCM.MachineCode
			LEFT OUTER JOIN STB_LineInfo          LI     WITH(NOLOCK) ON LI.LineCode        = PM.LineCode
			LEFT OUTER JOIN STB_RouteInfo        RI     WITH(NOLOCK) ON RI.RouteCode     = PM.RouteCode
	WHERE 1=1
	  AND MCM.CompanyCode     LIKE @CompanyCode 
	  AND MCM.WorkCenterCode  LIKE @WorkCenterCode 
	  AND MCM.MachineTypeCode LIKE @MachineTypeCode 
	  AND MCM.IsProdMachine = 1

END
