
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2021-02-14
-- Browsable : True
-- Group : Power-BI용 
-- Description:	노점온도 조회 프로시저
-- Modified:
-- 프로시저 실행 : Exec usp_GetDewpointInfo_Dashboard '', '', '2021-01-01', '2021-12-31', ''
-- ============================================================================

Create PROC [dbo].[usp_GetDewpointInfo_DashboardTotal]
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE = NULL
   ,@pToDate DATE = NULL
   ,@pLineCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
		   ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END

	SELECT DD.ID
	      ,DD.LineCode
		  ,LI.LineDesc AS LineName
		  ,DD.Dewpoint 
		  ,DD.CreateDateTime
		  , GetDate()
	  FROM STB_DewpointData DD
	           LEFT OUTER JOIN STB_LineInfo LI	    ON DD.LineCode = LI.LineCode
	 WHERE (@LineCode = '*' OR DD.LineCode = @LineCode)
	   --AND DD.CreateDateTime > dateadd(day,-1,getdate())

END