-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-19
-- Browsable : true
-- Group : Test
-- Description:	각종 뷰 테스트
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_TestViewAnything_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 1 AS col1
	      ,2 AS col2
		  ,3 AS col3
		  ,4 AS col4
		  ,5 AS col5
		  ,6 AS col6
		  ,7 AS col7
		  ,8 AS col8
END
