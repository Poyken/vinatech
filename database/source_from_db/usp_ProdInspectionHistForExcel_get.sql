-- =============================================
-- Author: kilee
-- Create date: 2020-03-03
-- Browsable : true
-- Group : Power-BI > 품질부문
-- Description: 최우석대리 요청사항
-- Modified:
-- 2020.03.18 조회기간 변경 : 48시간에서 한달로    변경 (최우석)
-- 2020.03.18 조회기간 변경 : 48시간에서 -30D일로 변경 (최우석)
-- =============================================
-- 실행문  usp_ProdInspectionHistForExcel_get


CREATE PROCEDURE [dbo].[usp_ProdInspectionHistForExcel_get]	
AS
BEGIN

	SELECT MQI.BasicDate
		  ,MQI.MaterialCode
		  ,MBI.ModelName
		  ,SUBSTRING(MBI.ModelName, 8, (CHARINDEX('(', MBI.ModelName, 0) - 8)) AS PartNo
		  ,SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
		  ,MQI.MaterialQcNo AS ProdQcNo
		  ,MQI.DecisionResult
		  ,MQI.DescText
		  ,MQI.MIIExtText01 AS InspWorkerCode
		  ,PWI.WorkerName AS inspWorkerName
		  ,MQD.QcInspectionItemName
		  ,MQSR.MaterialQcSampleNo
		  ,MQSR.TestValue
	  FROM STB_MaterialQcInfo MQI
			  LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MQI.MaterialCode = MBI.ModelCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		ON MQI.MIIExtText01 = PWI.WorkerCode
			  LEFT OUTER JOIN STB_MaterialQcDetail MQD		ON MQI.MaterialQcNo = MQD.MaterialQcNo
			  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR		 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	 WHERE 1=1
	   AND MQI.InspectionDocType = 'OQC'	  
	   AND MQD.QcInspectionItemCode IN ('IQC_GPD_18', 'IQC_GPD_19', 'IQC_GPD_20')	   
	 --  AND MQI.BasicDate BETWEEN GetDate()-2 AND GetDate()	                                                          -- 기존 (48시간 전부터 지금)
	 --  AND MQI.BasicDate LIKE  SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8) + '%'	              -- 이번달 데이터 가져오는걸로 변경	 
	  AND MQI.BasicDate  BETWEEN GetDate()-7 AND  GetDate()                                                           -- 현재로 하여금 -30일

	 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo

	 
END