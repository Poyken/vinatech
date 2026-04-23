-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-10-30
-- Browsable : true
-- Group : 품질관리
-- Description:	VPC 제품검사 이력
-- Modified: 1,652,711 : 35,079
-- =================================================================================================================================
CREATE PROCEDURE usp_ProdInspectionHistQc_Dashboard
	@pFromDate          DATETIME,
	@pToDate			  DATETIME,
	@pCompanyCode    VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate VARCHAR(10) = @pFromDate
		   ,@ToDate VARCHAR(10) = @pToDate
		   ,@CompanyCode VARCHAR(20) = @pCompanyCode
		   ,@RowCnt BIGINT

	PRINT 'Start : ' + CONVERT(VARCHAR(20), GETDATE(), 121) 
	
	SELECT * 
	  INTO #MaterialQcInfo
	  FROM STB_MaterialQcInfo with(nolock) 
	 WHERE InspectionDocType = 'OQC'
	   AND BasicDate BETWEEN @FromDate AND @ToDate

	CREATE INDEX XS_MaterialQcInfo_Temp ON #MaterialQcInfo (MaterialQcNo)

	SELECT @RowCnt = COUNT(*)
	  FROM #MaterialQcInfo

	PRINT CONVERT(VARCHAR(10), @RowCnt)

	PRINT 'Chk1 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

	SELECT * 
	  INTO #MaterialQcDetail
	  FROM STB_MaterialQcDetail  with(nolock) 
     WHERE QcInspectionItemCode IN ('PQC_V01_01', 'PQC_V01_07','PQC_V01_08','PQC_V01_09')
	   AND MaterialQcNo IN (SELECT MaterialQcNo FROM #MaterialQcInfo)

	CREATE INDEX XS_MaterialQcDetail_Temp ON #MaterialQcDetail (MaterialQcNo)
	CREATE INDEX XS_MaterialQcDetail_Temp2 ON #MaterialQcDetail (MaterialQcNo, MaterialQcDetailNo)

	SELECT @RowCnt = COUNT(*)
	  FROM #MaterialQcDetail

	PRINT CONVERT(VARCHAR(10), @RowCnt)

	PRINT 'Chk2 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

	SELECT MQR.MaterialQcNo, MQR.MaterialQcDetailNo, MaterialQcSampleNo, TestValue 
	  INTO #MaterialQcSampleResult
	  FROM STB_MaterialQcSampleResult MQR with(nolock) 
	  INNER JOIN #MaterialQcDetail MQD
	    ON MQD.MaterialQcNo = MQR.MaterialQcNo
	   AND MQD.MaterialQcDetailNo = MQR.MaterialQcDetailNo

	 CREATE INDEX XS_MaterialQcSampleResult_Temp ON #MaterialQcSampleResult (MaterialQcNo, MaterialQcDetailNo)

	 SELECT @RowCnt = COUNT(*)
	  FROM #MaterialQcSampleResult

	 PRINT CONVERT(VARCHAR(10), @RowCnt)

	 PRINT 'Chk3 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

	SELECT MQI.BasicDate AS 기준일자
		  ,MQI.MaterialCode AS 품목코드
		  ,MBI.ModelName AS 품목명
		  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) as  PartNo
		  ,CASE WHEN MBI.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS Size
		  ,MQI.MaterialQcNo AS ProdQcNo
		  ,MQI.DecisionResult AS 판정결과
		  ,MQI.DescText AS 판정내용
		  ,MQI.MIIExtText01 AS 검사자코드
		  ,'' AS 검사자명
		  ,MQD.QcInspectionItemName AS 검사항목
		  ,MQSR.MaterialQcSampleNo AS 검사순번
		  ,MQSR.TestValue AS 검사값
		  ,'' AS LineCode --#200903
		  ,'' AS LineName --#200903
		  ,'' AS Classify
		  ,'' AS LotID_list
		  ,'' as Holding_Hist

	  FROM #MaterialQcInfo MQI 
			  LEFT OUTER JOIN STB_ModelBasicInfo MBI with(nolock) 		ON MQI.MaterialCode = MBI.ModelCode
			  LEFT OUTER JOIN #MaterialQcDetail MQD ON MQI.MaterialQcNo = MQD.MaterialQcNo
			  LEFT OUTER JOIN #MaterialQcSampleResult MQSR 	 
			    ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
			   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	 WHERE 1=1
	   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   
	   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
	   AND MQI.InspectionDocType = 'OQC'
	   AND MQD.QcInspectionItemCode IN ('PQC_V01_01', 'PQC_V01_07','PQC_V01_08','PQC_V01_09')
	 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo

	 PRINT 'End : ' + CONVERT(VARCHAR(20), GETDATE(), 121)
END