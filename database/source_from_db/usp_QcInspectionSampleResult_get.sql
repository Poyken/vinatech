-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2019-11-15
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_QcInspectionSampleResult_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialCode VARCHAR(20) = NULL,
	@pFromDate DATETIME,
	@pToDate DATETIME
AS

BEGIN
	Declare @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	       ,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	SELECT MQI.MaterialCode
	      ,MM.MaterialName
	      ,MQSR.TestValue
		  ,MQII.LSL
		  ,MQII.USL
		  ,MQSR.CreateDateTime
	  FROM STB_MaterialQcInfo MQI
	  LEFT OUTER JOIN STB_MaterialQcDetail MQD
		ON MQI.MaterialQcNo = MQD.MaterialQcNo
	  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
		ON MQSR.MaterialQcNo = MQI.MaterialQcNo
	   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	  LEFT OUTER JOIN STB_MaterialQcInspectionItem MQII
		ON MQII.MaterialCode = MQI.MaterialCode
	   AND MQII.QcInspectionItemCode = MQD.QcInspectionItemCode
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = MQI.MaterialCode
	 WHERE MQI.InspectionDocType = 'OQC'
	   AND MQD.QcInspectionItemCode = 'IQC_GPD_18'
	   AND MQSR.TestValue IS NOT NULL
	   AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode)
	   AND MQSR.CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY MQSR.CreateDateTime ASC
END