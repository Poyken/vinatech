
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true

-- =============================================   usp_VVT_MaterialQcSampleResult_powerBi_get '','','','','2022-01-01','2022-01-31'
CREATE PROCEDURE [dbo].[usp_VVT_MaterialQcSampleResult_powerBi_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialQcNo VARCHAR(20) = NULL,
    @pMaterialQcDetailNo VARCHAR(20) = NULL,
									@pFromDate  datetime =null,
								@pToDate  datetime =null
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	DECLARE @MaterialQcDetailNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcDetailNo,'') = '' THEN '*' ELSE @pMaterialQcDetailNo END
	
   DECLARE @MaterialCode VARCHAR(60)='';
   	SELECT 
			@MaterialCode = MaterialCode
	  FROM STB_MaterialQcInfo
	 WHERE MaterialQcNo = @MaterialQcNo

	SELECT
	        MQSR.MaterialQcNo AS OldMaterialIqcNo,
	        MQSR.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
	        MQSR.MaterialQcSampleNo AS OldMaterialIqcSampleNo,
	        MQSR.MaterialQcNo,
	        MQSR.MaterialQcDetailNo,
	        MQSR.MaterialQcSampleNo,
	        MQSR.SampleSerialNo,
	        MQSR.TestUserID,
	        MQSR.TestDateTime,
	        MQSR.TestValue,
	        MQSR.TestResult,
	        MQSR.CreateDateTime,
	        MQSR.CreateUserID,
	        MQSR.ChangeDateTime,
	        MQSR.ChangeUserID,
			MQD.LSL,
			MQD.USL,
			MQD.QcInspectionItemDesc           --2020.02.15 추가
			,mqi.MaterialCode

	FROM STB_MaterialQcSampleResult MQSR WITH(NOLOCK)
	left outer JOIN STB_MaterialQcDetail MQD WITH(NOLOCK) ON MQSR.MaterialQcNo = MQD.MaterialQcNo	--AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	left outer join STB_MaterialQcInfo mqi WITH(NOLOCK) on MQD.MaterialQcNo=mqi.MaterialQcNo
	
	WHERE --((@pMaterialQcNo = '*') OR (MQSR.MaterialQcNo = @pMaterialQcNo)) 
	 -- AND ((@pMaterialQcDetailNo = '*') OR (MQSR.MaterialQcDetailNo = @pMaterialQcDetailNo)) 
	   MQSR.CreateDateTime between @pFromDate and @pToDate
	  and mqi.InspectionDocType='IQC'
	   and mqi.CompanyCode='VVT'
   -- ORDER BY MQSR.MaterialQcSampleNo

END

