
-- =============================================
-- Author: Jeon Gyeong Ho (khjun@awoo.co.kr)
-- Create date: 2016-07-20
-- Browsable : true
-- Group : 팝업
-- Description:	 수입검사의뢰 - 팝업
--                    2019.08.23 품질 이미정차장 요청사항 : 검사결과 3가지로 간추림
-- =============================================
CREATE PROCEDURE [dbo].[usp_DecisionResult_popup]
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
			DR.DecisionResultText,
			DR.DecisionResult
	FROM
			VW_DecisionResult DR WITH(NOLOCK)
END


-- 2019.08.19 kilee 변경 (미검 -> 검사대기)
 --SELECT * FROM VW_DecisionResult  

 --Begin tran
 ---- commit
 ---- rollback
 --update VW_DecisionResult
 --set DecisionResultText = '검사대기'
 --where DecisionResult = 'None'