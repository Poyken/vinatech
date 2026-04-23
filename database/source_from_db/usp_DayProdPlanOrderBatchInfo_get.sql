-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-15
-- Browsable : true
-- Group : 일일작업지시 및 Lot번호 일괄생성 내역 조회

-- =============================================
CREATE PROC usp_DayProdPlanOrderBatchInfo_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pPlanYearMonth DATE
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @PlanYearMonth CHAR(7) = CONVERT(CHAR(7), @pPlanYearMonth, 121)
	       ,@FromDate DATE = @pFromDate
		   ,@ToDate DATE = @pToDate

	SELECT DPPOB.DayProdPlanOrderBatchNo
		  ,CONVERT(DATE, DPPOB.PlanYearMonth + '-01', 121) AS PlanYearMonth
		  ,DPPOB.ParentPONo
		  ,DPPOB.TargetPONo
		  ,POI.MaterialCode
		  ,MM.MaterialName
		  ,DPPOB.LineCode
		  ,LI.LineName
		  ,DPPOB.PlanShiftCode
		  ,SC.Shift
		  ,DPPOB.PlanDate
		  ,DPPOB.PlanQty
		  ,DPPOB.DayPlanNo
		  ,DPPOB.Barcode
		  ,DPPOB.CreateDateTime
		  ,DPPOB.CreateUserID
		  ,DPPOB.ChangeDateTime
		  ,DPPOB.ChangeUserID
	  FROM STB_DayProdPlanOrderBatchInfo DPPOB
	  LEFT OUTER JOIN STB_ProductionOrderInfo POI
	    ON POI.PONo = DPPOB.TargetPONo
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = POI.MaterialCode
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON LI.LineCode = DPPOB.LineCode
	  LEFT OUTER JOIN VW_ShiftCode SC
	    ON SC.ShiftCode = DPPOB.PlanShiftCode
	 WHERE DPPOB.PlanYearMonth = @PlanYearMonth
	   AND DPPOB.PlanDate BETWEEN @FromDate AND @ToDate
END