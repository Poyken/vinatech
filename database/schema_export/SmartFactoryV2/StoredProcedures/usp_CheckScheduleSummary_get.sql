-- Procedure: usp_CheckScheduleSummary_get
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-06-01
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================

CREATE PROCEDURE usp_CheckScheduleSummary_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATETIME,
						@pToDate DATETIME,
						@pLineCode VARCHAR(20)
AS

BEGIN
Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
	   ,@LineCode VARCHAR(20) = @pLineCode

Declare @CheckTimeList TABLE (
			CheckDateTime DATETIME
		   ,MachineName VARCHAR(50)
        ) ;


INSERT INTO @CheckTimeList
SELECT CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108) AS CheckDateTime
      ,CASE WHEN ISNULL(CSI2.MachineCode, '') = '' THEN '기타' ELSE MM.MachineName END  AS MachineName
  FROM STB_CheckScheduleInfo CSI
  INNER JOIN STB_CheckStandardInfo CSI2
    ON CSI.CheckStandardNo = CSI2.CheckStandardNo
   AND CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108) BETWEEN @FromDate AND @ToDate
   AND CSI2.IsUsed = CONVERT(BIT, 1)
   AND CSI.IsUsed = CONVERT(BIT, 1)
  LEFT OUTER JOIN STB_MachineMaster MM
    ON CSI2.MachineCode = MM.MachineCode
 WHERE CSI2.LineCode = @LineCode
 ORDER BY CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108)
         ,CASE WHEN ISNULL(CSI2.MachineCode, '') = '' THEN '기타' ELSE MM.MachineName END

SELECT CTL2.CheckDateTime
      ,STUFF((
			SELECT ', ' + CTL.MachineName + '(' + CONVERT(VARCHAR, COUNT(*)) + ')'
			  FROM @CheckTimeList CTL
			 WHERE CTL.CheckDateTime = CTL2.CheckDateTime
			 GROUP BY CTL.MachineName
			 ORDER BY ', ' + CTL.MachineName
			 FOR XML PATH('')
		),1,1,'') AS CheckMachineList
  FROM @CheckTimeList CTL2
  GROUP BY CTL2.CheckDateTime

END
GO

