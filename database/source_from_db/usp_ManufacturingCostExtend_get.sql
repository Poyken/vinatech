-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021.08.21
-- Browsable : true
-- Group : 원가관리
-- Description: 품목별 원가 확장속성 조회
-- Modified:
-- 프로시저 실행 : [usp_ManufacturingCostExtend_get] '','','2021-05-05', 'VNT', 'VNT_F1', 'LIVT38-020'
-- =========================================================================
CREATE PROC [dbo].[usp_ManufacturingCostExtend_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pApplyDate DATE = NULL
   ,@pCompanyCode VARCHAR(20) = NULL
   ,@pWorkCenterCode VARCHAR(20) = NULL
   ,@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @ApplyDate        DATE = @pApplyDate
	        , @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
            , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
            , @MaterialCode     VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

	IF @ApplyDate IS NULL BEGIN
		SELECT @ApplyDate = ApplyDate FROM STB_ManufacturingCostApplyInfo WHERE IsApply = CONVERT(BIT, 1)
	END

	;WITH CostBaseInfo AS (
		SELECT *
		  FROM (
				SELECT ApplyDate
					  ,CompanyCode
					  ,WorkCenterCode
					  ,MaterialCode
					  ,CostTypeCode
					  ,MIN(CostPrice) AS CostPrice
					  ,IsUsed
				  FROM STB_ManufacturingCostByRoute
				 WHERE RouteCode IN (SELECT RouteCode 
				                       FROM STB_RouteInfo 
									  WHERE RouteType = 'Route-28')
				 GROUP BY ApplyDate
						 ,CompanyCode
						 ,WorkCenterCode
						 ,MaterialCode
						 ,CostTypeCode
						 ,IsUsed
			) AS Base PIVOT (
				MIN(CostPrice) FOR CostTypeCode IN (DC, IC, PC)
			) A
	)
	SELECT CBI.ApplyDate
		  ,CBI.CompanyCode
		  ,CI.CompanyName
		  ,CBI.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,MBI.MBIExtText03 AS ProductType
		  ,CBI.MaterialCode
		  ,MM.MaterialName
		  ,MM.IsClosed
		  ,CBI.IsUsed
		  ,MBI.MBIExtText04 AS [Volt(V)]
		  ,MBI.MBIExtText05 AS [Farad(F)]
		  ,MBI.MBIExtText01 AS Volt
		  ,MBI.MBIExtText02 AS Farad
		  ,MBI.MBISizeH
		  ,MBI.MBISizeW
		  ,CASE WHEN MBI.MBISizeW IS NOT NULL
				THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS MBISizeD
		  ,MT.MaterialTypeCode
		  ,MT.MaterialTypeName
		  ,ISNULL(MCE.IsManual, CONVERT(BIT, 0)) AS IsManual
		  ,CBI.DC AS DirectCostPrice
		  ,CBI.IC AS IndirectCodePrice
		  ,CBI.PC AS ProductionCostPrice
		  ,MCE.ActivatedCarbonCostPrice
		  ,MCE.ActiveMaterialCostPrice
		  ,MCE.ConductiveMaterialCostPrice
		  ,MCE.BinderCostPrice
		  ,MCE.SurfactantCostPrice
		  ,MCE.MenstruumCostPrice
		  ,MCE.CurrentCollectorCostPrice
		  ,MCE.TerminalCostPrice
		  ,MCE.ATLTerminalCostPrice
		  ,MCE.SeparatorCostPrice
		  ,MCE.PiTapeCostPrice
		  ,MCE.RubberStopperCostPrice
		  ,MCE.TerminalBoardCostPrice
		  ,MCE.WasherCostPrice
		  ,MCE.ElectrolyteCostPrice
		  ,MCE.CaseCostPrice
		  ,MCE.SleeveCostPrice
		  ,MCE.BottomPlateCostPrice
		  ,MCE.PackagingMaterialCostPrice
		  ,MCE.PCBForModuleCostPrice
		  ,MCE.WireForModuleCostPrice
		  ,MCE.MaterialCostPrice
		  ,MCE.LaborCostPrice
		  ,MCE.OverheadCostPrice
		  ,MCE.CreateDateTime
		  ,MCE.CreateUserID
		  ,MCE.ChangeDateTime
		  ,MCE.ChangeUserID
		  ,MCE.ApplyDate AS OldApplyDate
          ,MCE.CompanyCode AS OldCompanyCode
          ,MCE.WorkCenterCode AS OldWorkCenterCode
          ,MCE.MaterialCode AS OldMaterialCode
	  FROM CostBaseInfo CBI
	  LEFT OUTER JOIN STB_ManufacturingCostExtend MCE ON CBI.ApplyDate = MCE.ApplyDate	   AND CBI.CompanyCode = MCE.CompanyCode	   AND CBI.WorkCenterCode = MCE.WorkCenterCode	   AND CBI.MaterialCode = MCE.MaterialCode
	  LEFT OUTER JOIN STB_CompanyInfo CI	ON CI.CompanyCode = CBI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI ON WCI.WorkCenterCode = CBI.WorkCenterCode
	  LEFT OUTER JOIN STB_MaterialMaster MM	 ON MM.MaterialCode = CBI.MaterialCode
	  LEFT OUTER JOIN VW_ModelBasicInfo MBI	 ON MBI.ModelCode = CBI.MaterialCode
	  LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)		ON MT.MaterialTypeCode = MBI.MaterialTypeCode 
	  LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)		ON PG.ProductGroupCode = MBI.ProductGroupCode
	 WHERE CBI.ApplyDate = @ApplyDate
	   AND (@CompanyCode = '*' OR CBI.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR CBI.WorkCenterCode = @WorkCenterCode)
	   AND (@MaterialCode = '*' OR CBI.MaterialCode = @MaterialCode)
END


