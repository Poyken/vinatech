
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-11
-- Browsable : true
-- Group : 영업관리
-- Description:	Word to HTML 사이트를 접속합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_WebBrowserUrl_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUrl VARCHAR(500)
AS
BEGIN
	Declare @Url VARCHAR(500) = @pUrl

	SELECT @Url AS Url
END