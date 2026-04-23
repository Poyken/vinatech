-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-12-13
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_OccasionalCheckScheduleInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pLineCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate DATETIME = @pFromDate
	       ,@ToDate DATETIME = @pToDate
		   ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END

	SELECT OCSI.LineCode
		  ,LI.LineName
		  ,OCSI.CheckDate
		  ,OCSI.CreateDateTime AS CheckTime
		  ,OCSI.OccasionalCheckItemName
		  ,CASE WHEN CheckYn IS NULL THEN '미점검'
				WHEN CheckYn = 1 THEN 'OK'
				WHEN CheckYn = 0 THEN 'NG' END AS CheckResult
	  FROM STB_OccasionalCheckScheduleInfo OCSI
	  LEFT OUTER JOIN STB_LineInfo LI
		ON OCSI.LineCode = LI.LineCode
	 WHERE OCSI.CheckDate BETWEEN @FromDate AND @ToDate
	   AND (@LineCode = '*' OR OCSI.LineCode = @LineCode)
	 ORDER BY OCSI.LineCode, OCSI.CheckDate, OCSI.CreateDateTime
END