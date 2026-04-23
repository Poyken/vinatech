-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-11
-- Browsable : true
-- Group : MEA > 도면관리 > MEA구성코드(팝업)
-- Description:
-- ================================================================================================
CREATE PROCEDURE usp_MEARawMaterialInfo_popup
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMEAClassCode VARCHAR(20),
						@pMEARawMaterialClassCode VARCHAR(20)
AS
BEGIN
	Declare @MEAClassCode VARCHAR(20) = CASE WHEN ISNULL(@pMEAClassCode, '') = '' THEN '*' ELSE @pMEAClassCode END
	       ,@MEARawMaterialClassCode VARCHAR(20) = CASE WHEN ISNULL(@pMEARawMaterialClassCode, '') = '' THEN '*' ELSE @pMEARawMaterialClassCode END

	SELECT MRMI.MEARawMaterialCode
          ,MRMI.MEARawMaterialName
	  FROM STB_MEARawMaterialInfo MRMI
	  LEFT OUTER JOIN STB_MEAClassInfo MCI
	    ON MRMI.MEAClassCode = MCI.MEAClassCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'MEARawMaterialClassCode'
	   AND BC.ItemCode = MRMI.MEARawMaterialClassCode
	 WHERE (@MEAClassCode = '*' OR MRMI.MEAClassCode = @MEAClassCode)
	   AND (@MEARawMaterialClassCode = '*' OR MRMI.MEARawMaterialClassCode = @MEARawMaterialClassCode)
	 ORDER BY MEARawMaterialCode
END