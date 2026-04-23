
-- =============================================
-- Author:		Joo Su Hong
-- Create date: 2016-03-25
-- Description:	검사결과 팝업을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetTestResult_popup]
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
			ResultText,
			ResultValue 
	FROM
			VW_TestResult WITH(NOLOCK)
	
END

