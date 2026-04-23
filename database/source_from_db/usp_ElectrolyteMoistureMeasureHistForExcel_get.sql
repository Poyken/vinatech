-- ============================================================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020.06.30
-- Description : 
-- Modified : 
-- Procedure Execute : usp_ElectrolyteMoistureMeasureHistForExcel_get '2021-01-01', '2021-12-31'
-- ===========================================================================
CREATE PROCEDURE [dbo].[usp_ElectrolyteMoistureMeasureHistForExcel_get]
	@pFromDate DATE,
	@pToDate DATE
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	          ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	SELECT MMH.MoistureMeasureHistNo AS 수분측정일련번호
		  ,MMH.MeasureDate AS 측정일시
		  ,MMH.TimeShiftCode AS 주야구분코드
		  ,BC1.Description AS 주야구분명
		  ,MMH.InspWorkerCode AS 검사자사번
		  ,PWI.WorkerName AS 검사자명
		  ,MMH.CompanyCode AS 사업장코드
		  ,CI.CompanyName AS 사업장명
		  ,MMH.WorkCenterCode AS 작업장코드
		  ,WCI.WorkCenterName AS 작업장명
		  ,MMH.LineCode AS 라인코드
		  ,LI.LineDesc AS 라인명
		  ,MMH.MachineCode AS 설비코드
		  ,MM.MachineName AS 설비명
		  ,MMH.SpecificComment AS 유의사항
		  ,EMMH.ProductSizeCode AS 제품사이즈
		  ,EMMH.Temperature AS 온도
		  ,EMMH.DewPoint AS 노점온도
		  ,EMMH.ElectrolyteMoistureValue AS 전해액수분값
		  ,EMMH.IsPass AS 합격여부
		  ,EMMH.IsMaterial AS 원자재여부
	  FROM STB_MoistureMeasureHist MMH
			  INNER JOIN STB_ElectrolyteMoistureMeasureHist EMMH		ON MMH.MoistureMeasureHistNo = EMMH.MoistureMeasureHistNo
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	ON BC1.ItemCode = MMH.TimeShiftCode	   AND BC1.CodeGroup = 'TimeShiftCode'
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		ON PWI.WorkerCode = MMH.InspWorkerCode
			  LEFT OUTER JOIN STB_CompanyInfo CI		   ON CI.CompanyCode = MMH.CompanyCode
			  LEFT OUTER JOIN STB_WorkCenterInfo WCI		ON WCI.WorkCenterCode = MMH.WorkCenterCode
			  LEFT OUTER JOIN STB_LineInfo LI		            ON LI.LineCode = MMH.LineCode
			  LEFT OUTER JOIN STB_MachineMaster MM		ON MM.MachineCode = MMH.MachineCode
	 WHERE MMH.MeasureDate BETWEEN @FromDate AND @ToDate
	   --AND EMMH.ElectrolyteMoistureValue < 100
	   --AND MMH.LineCode Not In ('ASSYLINE-02')  -- 삼성심사 대응 2022.01.19
	 ORDER BY MMH.MoistureMeasureHistNo
END