
-- =============================================
-- Author: kilee
-- Create date: 2019-08-23
-- Browsable : true
-- Group : 팝업
-- Description:	 재선별 - 팝업
--                    2019.08.23 품질 이미정차장 요청사항 
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReSelectionResult_popup]
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
			'선별' AS DecisionResultText,
			'Selection' AS DecisionResult
	UNION ALL
	SELECT
			'폐기' AS DecisionResultText,
			'Disposal'
	UNION ALL
	SELECT
			'재작업' AS DecisionResultText,
			'rework' AS DecisionResult
	UNION ALL
	SELECT
			'특채' AS DecisionResultText,
			'Bond' AS DecisionResult

END
-- 2019.08.19 kilee 변경 (미검 -> 검사대기)
 --SELECT * FROM VW_DecisionResult  

 --Begin tran
 ---- commit
 ---- rollback
 --update VW_DecisionResult
 --set DecisionResultText = '검사대기'
 --where DecisionResult = 'None'