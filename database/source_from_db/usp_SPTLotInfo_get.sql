-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-02-28
-- Browsable : true
-- Group : 지지체
-- Description:	Lot정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SPTLotInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END

	SELECT SI.ControlNo
		  ,SI.Barcode
		  ,SI.PONo
		  ,SI.DayPlanNo
		  ,SI.InputJobDate
		  ,SI.MaterialCode
		  ,MM.MaterialName
		  ,SI.InputLineCode
		  ,LI.LineName
		  ,PRH.RouteCode
		  ,RI.RouteName
		  ,PRH.MachineCode
		  ,MM2.MachineName
		  ,PRH.WorkerCode
		  ,EI.NM_KOR AS WorkerName
		  ,RKISI.KilnTemperature
		  ,RKISI.RunTime
		  ,RKISI.SteamTemperature
		  ,DPP.PlanQty
		  ,CIMH.NumericMeasure AS BET
		  ,CIMH2.NumericMeasure AS XRD
		  ,MQSR.TestValue AS ICP
		  ,SI.CreateDateTime
		  ,SI.CreateUserID
		  ,PRH.ProdQty -- 25.10.18 소병운 [생산량 추가]
		  ,DFI.DefectQty -- 25.10.18 소병운 [불량수량 추가]
		  ,DPP.PlanDate
		  ,ISNULL(PRH.ProdQty, 0) - ISNULL(DFI.DefectQty, 0) AS GoodQty
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM
		ON MM.MaterialCode = SI.MaterialCode
	  LEFT OUTER JOIN STB_LineInfo LI
		ON LI.LineCode = SI.InputLineCode
	  LEFT OUTER JOIN STB_ProdRouteHist PRH
	    ON SI.ControlNo = PRH.ControlNo
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON PRH.RouteCode = RI.RouteCode
	  LEFT OUTER JOIN STB_MachineMaster MM2
	    ON MM2.MachineCode = PRH.MachineCode
	  LEFT OUTER JOIN NEOE.NEOE.MA_EMP EI
	    ON EI.NO_EMP = PRH.WorkerCode 
	   AND EI.CD_COMPANY = '1000'
	  LEFT OUTER JOIN STB_RotaryKilnItemSpecInfo RKISI
	    ON RKISI.BaseDate = SI.InputJobDate
	   AND RKISI.MachineCode = PRH.MachineCode
	  LEFT OUTER JOIN STB_DayProdPlan DPP
	    ON DPP.DayPlanNo = SI.DayPlanNo
	  LEFT OUTER JOIN STB_CommInspDocHistory CIDH
	    ON CIDH.ProdNo = SI.ControlNo
	   AND CommInspTypeCode = 'SPT_ROUTE_QUALITY'
	  LEFT OUTER JOIN STB_CommInspDocItem CIDI
	    ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
	   AND CIDI.CommInspItemCode = 'SPT_RQ02'
	  LEFT OUTER JOIN STB_CommInspMeasureHist CIMH
	    ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
	   AND CIMH.MeasureSeq = 1
	  LEFT OUTER JOIN STB_CommInspDocItem CIDI2
	    ON CIDI2.CommInspDocNo = CIDH.CommInspDocNo
	   AND CIDI2.CommInspItemCode = 'SPT_RQ01'
	  LEFT OUTER JOIN STB_CommInspMeasureHist CIMH2
	    ON CIMH2.CommInspDocItemNo = CIDI2.CommInspDocItemNo
	   AND CIMH2.MeasureSeq = 1
	  LEFT OUTER JOIN STB_MaterialQcInfo MQI
	    ON MQI.MaterialQcNo = SI.LotNumber
	  LEFT OUTER JOIN STB_MaterialQcDetail MQD 
	    ON MQD.MaterialQcNo = MQI.MaterialQcNo
	   AND MQD.QcInspectionItemCode = 'PQC_SPT_001'
	  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
	    ON MQSR.MaterialQcNo = MQI.MaterialQcNo
	   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	   AND MQSR.MaterialQcSampleNo = 1
	 LEFT OUTER JOIN 
	 (
		SELECT 
			CompanyCode, 
			WorkCenterCode, 
			ControlNo,
			FindRouteCode,
			ISNULL(SUM(DefectQty), 0) AS DefectQty
		FROM SmartFactoryV2.dbo.STB_DefectRepairInfo WITH(NOLOCK)
		WHERE 
			RepairType NOT IN ('MISSING')
		GROUP BY 
			CompanyCode, WorkCenterCode, ControlNo, FindRouteCode
	 ) AS DFI
	 ON 
	 DFI.CompanyCode = PRH.CompanyCode
	 AND DFI.WorkCenterCode = PRH.WorkCenterCode
	 AND DFI.ControlNo = PRH.ControlNo
	 AND DFI.FindRouteCode = PRH.RouteCode
	 WHERE 1=1
	   AND SI.InputJobDate BETWEEN @FromDate AND @ToDate
	   AND (@Barcode = '*' OR SI.Barcode = @Barcode)
	   AND SI.InputLineCode LIKE 'SPT_LINE%' -- 지지체 구분은 일일작업지시의 라인정보로 구분. 

	 ORDER BY
		SI.InputJobDate
END