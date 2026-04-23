-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-08-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사이력
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_RawMaterialInspectionHistQC_get]
	@pCompanyCode    VARCHAR(20) = NULL,
	@pFromDate          DATETIME,
	@pToDate			  DATETIME
	
AS
BEGIN

   Declare @CompanyCode        VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
   Declare @FromDate               DATETIME     = @pFromDate
	    	 ,@ToDate                   DATETIME     = @pToDate

	SELECT MQI.BasicDate AS 검사일자
		  ,MQI.MaterialCode AS 품목코드
		  ,MM.MaterialName AS 품목명
		  ,MQI.MaterialQcNo AS 수입검사번호
		  ,MQI.DecisionResult AS 검사결과
		  ,MQI.DescText AS 비고
		  ,MQD.QcInspectionItemName AS 검사항목
		  ,MQSR.MaterialQcSampleNo AS 샘플일련번호
		  ,MQSR.TestValue AS 측정결과
		  ,MQI.CompanyCode AS 사업장코드
		  ,MonthlyCount.MonthlyCount
	  FROM STB_MaterialQcInfo MQI
			  LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MQI.MaterialCode = MBI.ModelCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		ON MQI.MIIExtText01 = PWI.WorkerCode
			  LEFT OUTER JOIN STB_MaterialQcDetail MQD		ON MQI.MaterialQcNo = MQD.MaterialQcNo
			  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR		 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
			  LEFT OUTER JOIN STB_MaterialMaster MM ON MM.MaterialCode = MQI.MaterialCode
			  LEFT OUTER JOIN (
					SELECT LEFT(MaterialQcNo, 4) AS YearMonth, COUNT(*) AS MonthlyCount
					  FROM STB_MaterialQcInfo
					 WHERE InspectionDocType = 'IQC'
					   AND BasicDate BETWEEN @FromDate AND @ToDate
					   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   
					 GROUP BY LEFT(MaterialQcNo, 4)
			  ) MonthlyCount
			  ON MonthlyCount.YearMonth = LEFT(MQI.MaterialQcNo, 4)
	 WHERE 1=1
	   AND MQI.InspectionDocType = 'IQC'
	   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
	   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   
	 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo

END