-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2020-11-04
-- Description : URLCall
-- =============================================
CREATE PROCEDURE usp_PageUrl_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFirstPageUrl VARCHAR(500),
						@pSecondPageUrl VARCHAR(500)
AS

BEGIN
	SELECT @pFirstPageUrl AS FirstPageUrl
	      ,@pSecondPageUrl AS SecondPageUrl
END