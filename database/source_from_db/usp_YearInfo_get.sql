-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-20
-- Browsable : true
-- Group : 생산관리
-- Description:	년도코드를 등록합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_YearInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pYear INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Year INT = @pYear

	SELECT
			YI.Year AS OldYear,
			YI.Year,
			YearCode,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID
	FROM
			STB_YearInfo YI WITH(NOLOCK)
	WHERE
			((@Year IS NULL) OR (YI.Year = @Year))

END
