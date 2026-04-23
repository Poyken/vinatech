-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-02-20
-- Browsable : true
-- Group : 생산관리
-- Description:	셀7호기 함침수위 정보(이후 라인 전개에 따라 수정)
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_ImpregnationLevel_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT CONVERT(VARCHAR(19), CRT_YMS, 121) AS DataCollectionDateTime
	      ,CASE WHEN ELELVL > 100 THEN 100 WHEN ELELVL < -20 THEN -20 ELSE ELELVL END / 10.0 AS ImpregnationLevel
		  ,2.00 AS LSL
		  ,8 AS USL
	  FROM ERPSVR.VINATech.dbo.PLC_셀7_조립
	 WHERE CRT_YMS > DATEADD(day, -3, GETDATE())
	 ORDER BY ID ASC
END