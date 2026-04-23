
-- =============================================
-- Author : Kangs(kilee@vina.co.kr)
-- Create date: 2021-05-13
-- Browsable : true
-- Group : PowerBI용 (박진호 요청)
-- Description:	시료별수입검사 하단 검사항목과 측정값을 보여줍니다.

-- Modified: 상단의 수입검사번호와 시료별 수입검사항목의 QcDetailNo을 
-- Procedure :  usp_MaterialQcSampleResult_PowerBI
-- ==============================================================
CREATE PROCEDURE [dbo].[usp_MaterialQcSampleResult_PowerBI]
	--@pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20)
 --   @pMaterialQcNo VARCHAR(20) = NULL
  --  @pMaterialQcDetailNo VARCHAR(20) = NULL
AS


BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	--DECLARE @MaterialQcDetailNo VARCHAR(20) = @pMaterialQcDetailNo

   
   -- 이부분이 핵심
	SELECT
	         MQI.MaterialCode
			, SM.MaterialName
			, MQI.CompanyCode
			, Case When MQI.CompanyCode = 'VNT' Then '한국본사'
			        When MQI.CompanyCode = 'VVT' Then '베트남법인' Else '기타' End AS CompanyName 
	        --MQSR.MaterialQcNo AS OldMaterialIqcNo,
	        --MQSR.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
	        --MQSR.MaterialQcSampleNo AS OldMaterialIqcSampleNo,
		  , MQD.QcInspectionGroupCode
		  , MQD.QcInspectionGroupName
	      ,  MQSR.MaterialQcNo
	       --, MQSR.MaterialQcDetailNo
	       , MQSR.MaterialQcSampleNo
	       , MQSR.SampleSerialNo
	       , MQSR.TestUserID
	       , MQSR.TestDateTime
	       , MQSR.TestValue
	       , MQSR.TestResult
	       , MQSR.CreateDateTime
	       , MQSR.CreateUserID
	       , MQSR.ChangeDateTime
	       , MQSR.ChangeUserID
			,MQD.LSL
			,MQD.USL
			,MQD.QcInspectionItemDesc      
		   , MQD.QcInspectionItemCode 
	FROM                       STB_MaterialQcSampleResult MQSR WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK)	ON MQSR.MaterialQcNo = MQD.MaterialQcNo  AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	    	LEFT OUTER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)    ON MQI.MaterialQcNo = MQSR.MaterialQcNo 
		    LEFT OUTER JOIN STB_MaterialMaster SM WITH(NOLOCK)     ON SM.MaterialCode = MQI.MaterialCode 
	WHERE 1=1
	--   And ((@pMaterialQcNo = '*') OR (MQSR.MaterialQcNo = @pMaterialQcNo)) 
	--   And (MQSR.MaterialQcDetailNo = @pMaterialQcDetailNo)
	   And MQD.QcInspectionGroupCode in ('IQC_G01' ,'IQC_G02', 'IQC_G03', 'IQC_G05', 'IQC_G06', 'IQC_G09')
	--   And MQD.CreateDateTime > '2021-01-01 00:00:00'
	--   And MQI.CompanyCode = 'VNT'
    ORDER BY MQI.MaterialCode, MQSR.MaterialQcSampleNo 


END


/*
select QcInspectionGroupCode
      , QcInspectionGroupName
from STB_MaterialQcDetail
where 1=1
  and  QcInspectionGroupCode in ('IQC_G01' ,'IQC_G02', 'IQC_G03', 'IQC_G05', 'IQC_G06', 'IQC_G09')
Group by QcInspectionGroupCode
      , QcInspectionGroupName
	  Order by QcInspectionGroupCode




*/