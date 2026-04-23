-- =============================================
-- Author: 유영종 (yjyu@vina.co.kr)
-- Create date: 2018-07-06
-- Browsable : true
-- Group : 인사
-- Description:	자격증정보 조회(대분류팝업)
-- Modified:
-- =============================================
create PROCEDURE [dbo].[usp_LicenseLcode_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			 CD.LCODE
			,CD.LNAME
	FROM    STB_LICENSE_CODE CD
	ORDER BY CD.LCODE


END