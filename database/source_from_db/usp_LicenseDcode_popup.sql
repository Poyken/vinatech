-- =============================================
-- Author: 유영종 (yjyu@vina.co.kr)
-- Create date: 2018-07-06
-- Browsable : true
-- Group : 인사
-- Description:	자격증정보 조회(소분류팝업)
-- Modified:
-- =============================================
create PROCEDURE [dbo].[usp_LicenseDcode_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLcode VARCHAR(10) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @lcode varchar(10)

	SET @lcode = isnull(@pLcode, '')

	SELECT
			 LCD.DCODE
			,LCD.DNAME
	FROM    STB_LICENSE_CODE_DETAIL LCD
	WHERE   LCD.LCODE = @lcode
	ORDER BY LCD.DCODE


END