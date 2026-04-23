-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2019-11-15
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionSampleResultForBarcode_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = NULL
AS

BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode

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
	   AND MQI.MaterialQcNo = (SELECT Max(LotNumber) FROM STB_SetInfo WHERE Barcode = @Barcode)
	 ORDER BY MQSR.CreateDateTime ASC
END


select*from STB_VN_FINISHGOODS
where lotno='VVMR052R710612'