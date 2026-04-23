-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-09
-- Browsable : true
-- Group : 원가관리
-- Description:	
-- Modified: 
-- =============================================

CREATE PROCEDURE [dbo].[usp_ManufacturingCostByRoute_Dashboard]
	@pApplyDate DATE,
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pMaterialCode VARCHAR(20) = NULL,
	@pCostTypeCode VARCHAR(10) = NULL,
	@pRouteCode VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ApplyDate DATE = @pApplyDate
	       ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
	       ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	       ,@CostTypeCode VARCHAR(10) = CASE WHEN ISNULL(@pCostTypeCode, '') = '' THEN '*' ELSE @pCostTypeCode END
	       ,@RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN '*' ELSE @pRouteCode END

	SELECT MCR.ApplyDate
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
		  ,MBI.MBIExtText03 AS ModelType
		  ,MBI.MBIExtText04 AS [Volt(V)]
		  ,MBI.MBIExtText05 AS [Farad(F)]
		  ,MBI.MBIExtText01 AS Volt
		  ,MBI.MBIExtText02 AS Farad
		  ,MBI.MBISizeW
		  ,MBI.MBISizeH
		  ,CASE WHEN MBI.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS MBISizeD
		  ,MBI.MaterialTypeCode --자재유형코드
          ,MT.BasicMaterialType --자재유형기준
          ,MT.MaterialTypeName --자재유형명
          ,MBI.MBIExtText06 AS SingleCellMaterialCode --단셀품목코드
          ,MBI.MBIExtInt01 AS ModuleQty --모듈구성수
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
	  LEFT OUTER JOIN VW_ModelBasicInfo MBI
	    ON MBI.ModelCode = MCR.MaterialCode
	  LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
	    ON MT.MaterialTypeCode = MBI.MaterialTypeCode 
	 WHERE 1 = 1
	   AND MCR.ApplyDate = @ApplyDate
	   AND (@CompanyCode = '*' OR MCR.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR MCR.WorkCenterCode = @WorkCenterCode)
	   AND (@MaterialCode = '*' OR MCR.MaterialCode = @MaterialCode)
	   AND (@CostTypeCode = '*' OR MCR.CostTypeCode = @CostTypeCode)
	   AND (@RouteCode = '*' OR MCR.RouteCode = @RouteCode)

END