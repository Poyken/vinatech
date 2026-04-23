-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 팝업  
-- Description:	생산설비를 가져옵니다
-- Modified: [B530] 작업설비코드 팝업에서도 쓰임. 
-- =============================================

-- EXEC [usp_ProductMachine_popup] '','','','','','E-25'

CREATE PROCEDURE [dbo].[usp_ProductMachine_popup]
						 @pProcessUserID VARCHAR(20),
					 	 @pProcessLanguage VARCHAR(20),
						 @pCompanyCode VARCHAR(20) = NULL,
						 @pWorkCenterCode VARCHAR(20) = NULL,
					 	 @pMachineTypeCode VARCHAR(20) = NULL,  
						 @pRouteCode          VARCHAR(100) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode     VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'')      = '' THEN '*' ELSE @pCompanyCode      END
	DECLARE @WorkCenterCode  VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'')   = '' THEN '*' ELSE @pWorkCenterCode   END
	DECLARE @MachineTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineTypeCode,'') = '' THEN '*' ELSE @pMachineTypeCode END
	DECLARE @RouteCode          VARCHAR(100)  = CASE WHEN ISNULL(@pRouteCode,'')          = '' THEN '*' ELSE @pRouteCode          END
	
	SELECT
			MCM.MachineCode,
			MCM.MachineName,
			MCM.MachineTypeCode,
			MT.MachineTypeName,
			MAX(PM.RouteCode) AS RouteCode

	FROM
			STB_MachineMaster                        MCM   WITH(NOLOCK)
			LEFT OUTER JOIN VW_MachineType     MT     WITH(NOLOCK) ON MT.MachineTypeCode = MCM.MachineTypeCode
		    LEFT OUTER JOIN STB_ProductMachine PM     WITH(NOLOCK) ON PM.MachineCode      = MCM.MachineCode
	WHERE 1=1
	   AND (@CompanyCode = '*' OR MCM.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR MCM.WorkCenterCode = @WorkCenterCode)
	   AND (@MachineTypeCode = '*' OR MCM.MachineTypeCode = @MachineTypeCode)
	   AND MCM.IsProdMachine = 1
	   AND (@RouteCode = '*' OR PM.RouteCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @RouteCode)))
	   AND MCM.IsUsed = 1
	GROUP BY MCM.MachineCode,
			MCM.MachineName,
			MCM.MachineTypeCode,
			MT.MachineTypeName

END