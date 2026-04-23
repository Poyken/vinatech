-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2021-02-18
-- Browsable : true
-- Group : 생산관리
-- Description:	모듈Lot 정보 조회
-- Modified:
-- =============================================
CREATE PROC usp_ModuleTrackingMdlInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE,
	@pMaterialCode VARCHAR(20) = NULL,
	@pModuleBarcode VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
	       ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	       ,@ModuleBarcode VARCHAR(20) = CASE WHEN ISNULL(@pModuleBarcode, '') = '' THEN '*' ELSE @pModuleBarcode END

	SELECT SI.Barcode
		  ,SI.MaterialCode
		  ,MM.MaterialName
		  ,DPP.PlanDate
		  ,SI.InputJobDate
		  ,SI.CurrentRouteCode
		  ,SI.ProdQty
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_DayProdPlan DPP
	    ON SI.DayPlanNo = DPP.DayPlanNo
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON SI.MaterialCode = MM.MaterialCode
	 WHERE (@ModuleBarcode = '*' OR SI.Barcode = @ModuleBarcode)
	   AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)
	   AND DPP.PlanDate BETWEEN @FromDate AND @ToDate
	   AND MM.MaterialTypeCode = 'MDL'
END