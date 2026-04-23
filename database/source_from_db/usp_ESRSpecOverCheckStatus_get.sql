-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-28
-- Browsable : true
-- Group : 생산관리
-- Description:	라인별 ESR 스펙오버 체크 현황
-- Modified:
-- =============================================
CREATE PROC usp_ESRSpecOverCheckStatus_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate

	SELECT ESOI.BaseDate
		  ,ESOI.LineCode
		  ,LI.LineName
		  ,ESOI.Seq
		  ,ESOI.CheckStartDateTime
		  ,ESOI.CheckEndDateTime
		  ,ESOI.SpecOverCount
		  ,ESOI.CreateDateTime
		  ,ESOI.LastCheckDateTime
	  FROM STB_ESRSpecOverInfo ESOI
	  LEFT OUTER JOIN STB_LineInfo LI
		ON ESOI.LineCode = LI.LineCode
	 WHERE ESOI.BaseDate BETWEEN @FromDate AND @ToDate
     ORDER BY ESOI.BaseDate, ESOI.LineCode, ESOI.Seq
END