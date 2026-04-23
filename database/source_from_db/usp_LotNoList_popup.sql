-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-07-17
-- Browsable : true
-- Group : 팝업
-- Description: 계획일자 기준의 Lot 리스트를 조회한다.
-- =============================================
CREATE PROC [dbo].[usp_LotNoList_popup]
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pCompanyCode VARCHAR(20)
   ,@pWorkCenterCode VARCHAR(20)
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
		   ,@CompanyCode VARCHAR(20) = @pCompanyCode
		   ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode

	SELECT DPP.PlanDate
	      ,SI.Barcode
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_DayProdPlan DPP
	    ON SI.DayPlanNo = DPP.DayPlanNo
	 WHERE DPP.PlanDate BETWEEN @FromDate AND @ToDate
	   AND DPP.CompanyCode = @CompanyCode
	   AND DPP.WorkCenterCode = @WorkCenterCode
	   AND LEN(SI.Barcode) = 5
	 ORDER BY DPP.PlanDate, SI.Barcode
END