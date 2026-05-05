-- Procedure: usp_CheckScheduleInfo_get_test
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-08-02
-- Description : 일상점검스케줄 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckScheduleInfo_get_test]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCheckClassNo VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE,
	@pIsUsed BIT
AS

BEGIN
	Declare @CheckClassNo VARCHAR(20) = CASE WHEN @pCheckClassNo IS NULL THEN '%' ELSE @pCheckClassNo END
	       ,@LineCode VARCHAR(20) = CASE WHEN @pLineCode IS NULL THEN '%' ELSE @pLineCode END
	       ,@FromDate DATE = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATE = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
		   ,@IsUsed BIT = @pIsUsed

	SELECT @FromDate, @ToDate

	SELECT CSI.CheckDate
		  ,CONVERT(DATETIME, CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108)) AS CheckScheduledTime
		  ,CSI.CheckTime AS CheckExecutionTime
		  ,CSI.CheckYn
		  ,CASE WHEN CSI.CheckYn IS NULL THEN '점검전'
		        WHEN CSI.CheckYn = 0 THEN 'NG'
				WHEN CSI.CheckYn = 1 THEN 'OK'
				END AS CheckResult
		  ,CSI.IsUsed
		  ,CSI2.CheckPartContent
		  ,CSI2.CheckStandard
		  ,CSI2.CheckMethod
	  FROM STB_CheckScheduleInfo CSI
	  INNER JOIN STB_CheckStandardInfo CSI2
	     ON CSI.CheckStandardNo = CSI2.CheckStandardNo
	  INNER JOIN STB_CheckClassInfo CCI
	     ON CSI2.CheckClassNo = CCI.CheckClassNo
	  INNER JOIN STB_CheckPartInfo CPI
	     ON CSI2.CheckPartNo = CPI.CheckPartNo
	  INNER JOIN STB_MachineMaster MM
	     ON CSI2.MachineCode = MM.MachineCode
	  INNER JOIN STB_LineInfo LI
	     ON CSI2.LineCode = LI.LineCode
	 WHERE CSI2.CheckClassNo LIKE @CheckClassNo
	   AND CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108) BETWEEN @FromDate AND @ToDate
	   AND CSI2.LineCode LIKE @LineCode
	   AND ISNULL(CSI.IsUsed, 1) = @IsUsed
	 ORDER BY CSI.CheckDate, CONVERT(VARCHAR(8), CSI2.CheckTime, 108), CPI.DisplayIndex
END
GO

