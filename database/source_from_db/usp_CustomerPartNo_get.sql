-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-06-24
-- Browsable : true
-- Group : 비나에너솔
-- Description:	Customer Part No 조회
-- =============================================
CREATE PROC usp_CustomerPartNo_get
		@pProcessLanguage VARCHAR(20)
	   ,@pProcessUserID VARCHAR(20)
	   ,@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

	SELECT CPNI.MaterialCode
	      ,MM.MaterialName
          ,CPNI.CustomerName
		  ,CPNI.CustomerPartNo
		  ,CPNI.CreateDateTime
		  ,CPNI.CreateUserID
		  ,CPNI.MaterialCode AS OldMaterialCode
		  ,CPNI.CustomerPartNo AS OldCustomerPartNo
	  FROM STB_CustomerPartNoInfo CPNI
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = CPNI.MaterialCode
	 WHERE 1=1
	   AND (@MaterialCode = '*' OR CPNI.MaterialCode = @MaterialCode)
END
