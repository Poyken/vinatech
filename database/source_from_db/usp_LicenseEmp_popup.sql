-- =============================================
-- Author: 유영종 (yjyu@vina.co.kr)
-- Create date: 2018-07-06
-- Browsable : true
-- Group : 인사
-- Description:	자격증정보 조회(사원조회팝업)
-- Modified:
-- =============================================
create PROCEDURE [dbo].[usp_LicenseEmp_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pEmpCd VARCHAR(10) = NULL,
	@pEmpNm VARCHAR(10) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @empCd varchar(10), @empNm varchar(20)

	SET @empCd = isnull(@pEmpCd, '')
	SET @empNm = isnull(@pEmpNm, '')
    
	SELECT
			 EMP.EMPCD
			,EMP.EMPNM
	FROM    STB_EMPMST EMP
	WHERE	1=1
	  AND   EMP.EMPCD LIKE '%' + @empCd + '%'
	  AND   EMP.EMPNM LIKE '%' + @empNm + '%'
	ORDER BY EMP.EMPNM


END