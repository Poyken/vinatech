-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-11
-- Browsable : true
-- Group : MEA > 도면관리 > MEA원자재정보
-- Description:
-- ================================================================================================
CREATE PROCEDURE usp_MEARawMaterialInfo_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMEAClassCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @MEAClassCode VARCHAR(20) = CASE WHEN ISNULL(@pMEAClassCode, '') = '' THEN '*' ELSE @pMEAClassCode END

	SELECT MRMI.MEAClassCode AS OldMEAClassCode
          ,MRMI.MEARawMaterialClassCode AS OldMEARawMaterialClassCode
		  ,MRMI.MEARawMaterialCode AS OldMEARawMaterialCode
		  ,MRMI.MEAClassCode
	      ,MCI.MEAClassName
          ,MRMI.MEARawMaterialClassCode
		  ,BC.Description AS MEARawMaterialClassName
          ,MRMI.MEARawMaterialCode
          ,MRMI.MEARawMaterialName
          ,MRMI.CreateDateTime
          ,MRMI.CreateUserID
          ,MRMI.ChangeDateTime
          ,MRMI.ChangeUserID
	  FROM STB_MEARawMaterialInfo MRMI
	  LEFT OUTER JOIN STB_MEAClassInfo MCI
	    ON MRMI.MEAClassCode = MCI.MEAClassCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'MEARawMaterialClassCode'
	   AND BC.ItemCode = MRMI.MEARawMaterialClassCode
	 WHERE (@MEAClassCode = '*' OR MRMI.MEAClassCode = @MEAClassCode)
	 ORDER BY MEAClassCode, MEARawMaterialClassCode, MEARawMaterialCode
END