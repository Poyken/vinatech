-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-09
-- Browsable : true
-- Group : 원가관리
-- Description:	
-- Modified: 
-- 프로시저 실행 :   usp_ManufacturingCostByRoute_get '','','2021-05-05','VNT', 'VNT_F1', 'LIVT38-020', '',''
-- ==========================================================================

CREATE PROCEDURE [dbo].[usp_ManufacturingCostByRoute_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pApplyDate DATE,
						@pCompanyCode VARCHAR(20),
						@pWorkCenterCode VARCHAR(20),
						@pMaterialCode VARCHAR(20) = NULL,
						@pCostTypeCode VARCHAR(10) = NULL,
						@pRouteCode VARCHAR(20) = NULL
AS

BEGIN
	DECLARE @ApplyDate DATE = @pApplyDate
	           , @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	           , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
	           , @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	           , @CostTypeCode VARCHAR(10) = CASE WHEN ISNULL(@pCostTypeCode, '') = '' THEN '*' ELSE @pCostTypeCode END
	           , @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN '*' ELSE @pRouteCode END

	SELECT MCR.ApplyDate AS OldApplyDate
		  ,MCR.CompanyCode AS OldCompanyCode
		  ,MCR.WorkCenterCode AS OldWorkCenterCode
		  ,MCR.MaterialCode AS OldMaterialCode
		  ,MCR.CostTypeCode AS OldCostTypeCode
		  ,MCR.IsManual AS OldIsManual
		  ,MCR.RouteCode AS OldRouteCode
	      ,MCR.ApplyDate
		  ,MCR.CompanyCode
		  ,CI.CompanyName
		  ,MCR.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,MCR.MaterialCode
		  ,MM.MaterialName
		  ,MCR.CostTypeCode
		  ,BC.Description AS CostTypeName
		  ,MCR.IsManual
		  ,MCR.RouteCode
		  ,RI.RouteName
		  ,MCR.CostPrice
		  ,MCR.CreateDateTime
		  ,MCR.CreateUserID
		  ,MCR.ChangeDateTime
		  ,MCR.ChangeUserID
		  ,MCR.IsUsed
	  FROM STB_ManufacturingCostByRoute MCR
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON MCR.CompanyCode = CI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
		ON MCR.WorkCenterCode = WCI.WorkCenterCode
	  LEFT OUTER JOIN STB_MaterialMaster MM
		ON MCR.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
		ON MCR.CostTypeCode = BC.ItemCode
	   AND BC.CodeGroup = 'CostTypeCode'
	  LEFT OUTER JOIN STB_RouteInfo RI
		ON MCR.RouteCode = RI.RouteCode
	 WHERE 1 = 1
	   AND MCR.ApplyDate = @ApplyDate
	   AND (@CompanyCode = '*' OR MCR.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR MCR.WorkCenterCode = @WorkCenterCode)
	   AND (@MaterialCode = '*' OR MCR.MaterialCode = @MaterialCode)
	   AND (@CostTypeCode = '*' OR MCR.CostTypeCode = @CostTypeCode)
	   AND (@RouteCode = '*' OR MCR.RouteCode = @RouteCode)

END