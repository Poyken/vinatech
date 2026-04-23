-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2021-02-18
-- Browsable : true
-- Group : 생산관리
-- Description:	모듈Lot 단셀정보 조회
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_ModuleTrackingCellInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pModuleBarcode VARCHAR(20) = NULL
AS
BEGIN
	Declare @ModuleBarcode VARCHAR(20) = @pModuleBarcode

	--SELECT SI.ModuleBarcode
	--      ,SI.Barcode
	--	  ,SI.MaterialCode
	--	  ,MM.MaterialName
	--	  ,DPP.PlanDate
	--	  ,PRH.ProdQty
	--	  ,PRH.ProdDateTime
	--  FROM STB_SetInfo SI
	--  LEFT OUTER JOIN STB_DayProdPlan DPP
	--    ON SI.DayPlanNo = DPP.DayPlanNo
	--  LEFT OUTER JOIN STB_MaterialMaster MM
	--    ON MM.MaterialCode = SI.MaterialCode
	--  LEFT OUTER JOIN STB_ProdRouteHist PRH
	--    ON PRH.ControlNo = SI.ControlNo
	--  LEFT JOIN STB_SingleCellModuleMappingHist his 
	--	ON SI.ModuleBarcode = his.ModuleLotNo
	--   AND PRH.RouteCode IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = 'Route-28')
	-- WHERE (@ModuleBarcode = '*' OR SI.ModuleBarcode = @ModuleBarcode)


	 	 select distinct
		   his.ModuleLotNo as ModuleBarcode
	      ,his.SingleCellLotNo as Barcode
	      ,SI.MaterialCode
		  ,MM.MaterialName
		  ,DPP.PlanDate
		  ,PRH.ProdQty
		  ,PRH.ProdDateTime
	 FROM STB_SingleCellModuleMappingHist his 
	  left join  STB_SetInfo SI  ON his.ModuleLotNo = si.Barcode
	  LEFT OUTER JOIN STB_DayProdPlan DPP
	    ON SI.DayPlanNo = DPP.DayPlanNo
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = SI.MaterialCode
	  LEFT OUTER JOIN STB_ProdRouteHist PRH
	    ON PRH.ControlNo = SI.ControlNo
	   AND PRH.RouteCode IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = 'Route-28')
	 WHERE (@ModuleBarcode = '*' OR his.ModuleLotNo =@ModuleBarcode)
END