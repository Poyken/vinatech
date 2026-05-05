-- Procedure: usp_ConditionalFormattingTest_get
-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 연습용
-- Description:	조건부 서식 적용
-- Modified:
-- =============================================
CREATE PROC usp_ConditionalFormattingTest_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT 1 AS LSL
	      ,3 AS USL
		  ,NULL AS TestValue
	UNION ALL
	SELECT 2, 4, NULL
	UNION ALL
	SELECT 3, 3.3, NULL
	UNION ALL
	SELECT 2.55, 3, NULL
END
GO

