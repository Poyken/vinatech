-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2024-06-20
-- Description : 비나에너솔 포장라벨 Cst P/N 팝업
-- Modified :
-- =============================================
CREATE PROC usp_CustomerPartNoInfo_popup
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

	SELECT MaterialCode
	      ,CustomerName
		  ,CustomerPartNo
	  FROM STB_CustomerPartNoInfo
	 WHERE 1=1
	   AND (@MaterialCode = '*' OR MaterialCode = @MaterialCode)
	UNION ALL
	SELECT @MaterialCode
	      ,'없음'
		  ,'None'
END