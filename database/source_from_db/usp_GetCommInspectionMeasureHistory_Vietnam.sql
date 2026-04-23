
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리 > 공용검사관리 >  공정검사이력조회
-- Description:	3번째 Grid 공용검사시료이력
-- Modified:
-- 프로시저 실행문 :  usp_GetCommInspectionMeasureHistory 'kilee','kilee','20200119001945'     --(맨끝의 숫자는 "공용검사항목이력번호" 임)
--                        usp_GetCommInspectionMeasureHistory 'kilee','kilee','20200622001647'
-- =============================================
create PROCEDURE [dbo].[usp_GetCommInspectionMeasureHistory_Vietnam]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspDocItemNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CommInspDocItemNo VARCHAR(20) = CASE WHEN ISNULL(@pCommInspDocItemNo,'') = '' THEN '%' ELSE @pCommInspDocItemNo END

    
	SELECT
			CIMH.CommInspMeasureNo AS OldCommInspMeasureNo,
			CIMH.CommInspMeasureNo,
			CIMH.CommInspDocItemNo,
			CIMH.MeasureSeq,
			CIMH.TextMeasure,
			CIMH.NumericMeasure,
		  --CIMH.MeasureResult,
		  
		  CASE WHEN CIMH.MeasureResult = 'OK' THEN 'OK'  WHEN CIMH.MeasureResult = 'NG' THEN 'NG' 	ELSE '' END  AS MeasureResult,          -- 원본백업
			--CASE WHEN CIMH.MeasureResult = '1' THEN 'OK'        WHEN CIMH.MeasureResult = '0' THEN 'NG' 
			--        WHEN CIMH.MeasureResult = 'NG' THEN 'NG'  	 WHEN CIMH.MeasureResult = 'OK' THEN 'OK' 
			--        WHEN  CIMH.MeasureResult = '0'  And CIMH.NumericMeasure <> 0 THEN 'OK' 
			--        WHEN  CIMH.MeasureResult = '0'  And CIMH.NumericMeasure = 0   THEN '미진행' 
			--        WHEN CIMH.MeasureResult = '1'  Or CIMH.NumericMeasure = 0    THEN 'OK' 
			--        WHEN CIMH.MeasureResult = '0'  Or CIMH.NumericMeasure = 0     THEN 'NG'  ELSE '' END  AS MeasureResult,                        -- 이미정 요청 (2020.04.17)

			CIMH.MeasureDateTime,
			CIMH.MeasureUserID,
			UI.UserName AS MeasureUserName,
			CIMH.ErrorField
			--CASE WHEN CIMH.MeasureResult = '1' THEN 'OK' ELSE 'NG' END  AS ErrorField

	FROM
			STB_CommInspMeasureHist CIMH WITH(NOLOCK)
			LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)				ON	CIMH.MeasureUserID = UI.UserID
	WHERE
			(CIMH.CommInspDocItemNo LIKE @CommInspDocItemNo) 

END


-- SELECT MeasureResult, * FROM STB_CommInspMeasureHist WHERE CommInspMeasureNo = '20200622001347'