-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020.06.30
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductMoistureMeasureHistForExcel_get]
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
		  ,PMMH.MaterialCode AS 품목코드
		  ,MM2.MaterialName AS 품목명
          ,PMMH.Barcode AS LotNo
          ,PMMH.IsAging AS 에이징여부
          ,PMMH.AgingCount AS 에이징횟수
          ,PMMH.ProductMoistureValue AS 제품수분측정값
          ,PMMH.ActionContents AS 조치사항
	  FROM STB_MoistureMeasureHist MMH
	  INNER JOIN STB_ProductMoistureMeasureHist PMMH
		ON MMH.MoistureMeasureHistNo = PMMH.MoistureMeasureHistNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
		ON BC1.ItemCode = MMH.TimeShiftCode
	   AND BC1.CodeGroup = 'TimeShiftCode'
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
		ON PWI.WorkerCode = MMH.InspWorkerCode
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON CI.CompanyCode = MMH.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
		ON WCI.WorkCenterCode = MMH.WorkCenterCode
	  LEFT OUTER JOIN STB_LineInfo LI
		ON LI.LineCode = MMH.LineCode
	  LEFT OUTER JOIN STB_MachineMaster MM
		ON MM.MachineCode = MMH.MachineCode
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON MM2.MaterialCode = PMMH.MaterialCode
	 WHERE MMH.MeasureDate BETWEEN @FromDate AND @ToDate
	 ORDER BY MMH.MoistureMeasureHistNo
END