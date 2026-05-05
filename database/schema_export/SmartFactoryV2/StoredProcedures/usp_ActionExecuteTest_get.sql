-- Procedure: usp_ActionExecuteTest_get
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-20
-- Browsable : true
-- Group : 테스트
-- Description:	테스트
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ActionExecuteTest_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT 100  AS SetupValue1
	      ,500  AS SetupValue2
		  ,1000 AS SetupValue3
		  ,0    AS InputValue
END
GO

