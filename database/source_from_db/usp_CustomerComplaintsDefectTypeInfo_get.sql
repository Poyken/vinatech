-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Browsable : true
-- Create date: 2020.07.01
-- Description: 고객불만불량유형정보
-- =============================================
CREATE PROCEDURE usp_CustomerComplaintsDefectTypeInfo_get
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT CCDTI.CustomerComplaintsDefectCode
		  ,CCDTI.CustomerComplaintsDefectName
		  ,CCDTI.CustomerComplaintsDefectTypeCode
		  ,BC.Description AS CustomerComplaintDefectsTypeName
		  ,CCDTI.IsUsed
		  ,CCDTI.CreateDateTime
		  ,CCDTI.CreateUserID
		  ,CCDTI.ChangeDateTime
		  ,CCDTI.ChangeUserID
	  FROM STB_CustomerComplaintsDefectTypeInfo CCDTI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.ItemCode = CCDTI.CustomerComplaintsDefectTypeCode
	   AND BC.CodeGroup = 'CustomerComplaintDefectTypeCode'
	 ORDER BY CustomerComplaintsDefectCode
END