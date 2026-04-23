-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-15
-- Browsable : true
-- Group : PO정보조회 팝업
-- =============================================
CREATE PROC usp_ProductionOrderInfo_popup
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pCompanyCode VARCHAR(20)
   ,@pWorkCenterCode VARCHAR(20)
   ,@pPlanYearMonth DATE
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
		   ,@PlanYearMonth CHAR(7) = CONVERT(CHAR(7), @pPlanYearMonth, 121)

	SELECT POI.PlanYearMonth
	      ,POI.PONo
	      ,POI.MaterialCode
		  ,MM.MaterialName
		  ,POI.CompanyCode
	      ,POI.WorkCenterCode
	  FROM STB_ProductionOrderInfo POI
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = POI.MaterialCode
	 WHERE CompanyCode = @CompanyCode
	   AND WorkCenterCode = @WorkCenterCode
	   AND PlanYearMonth = @PlanYearMonth
	 ORDER BY  POI.PONo
END
