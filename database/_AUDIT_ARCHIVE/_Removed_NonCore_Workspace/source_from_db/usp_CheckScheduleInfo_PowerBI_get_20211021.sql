-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-08-02
-- Description : 일상점검스케줄 조회
-- Modified :

-- 프로시저 실행 :   usp_CheckScheduleInfo_PowerBI_get '2020-08-01 08:30:00','2020-08-11 08:29:29','1'
-- =============================================
CREATE PROCEDURE usp_CheckScheduleInfo_PowerBI_get_20211021
	@pFromDate DATE,
	@pToDate DATE
AS

BEGIN
	 Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'

	IF @FromDate = '1900-01-01 08:30:00' OR @ToDate = '1900-01-01 08:30:00' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

	SELECT CSI2.CheckStandardNo
	      ,CSI2.LineCode
		  ,LI.LineName
	      ,CSI2.CheckClassNo
		  ,CCI.CheckClassName
		  ,CSI2.MachineCode
		  ,MM.MachineName
		  ,CSI2.CheckPartNo
		  ,CPI.CheckPartName
		  ,CSI.CheckDate
		  ,CONVERT(DATETIME, CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108)) AS CheckScheduledTime
		  ,CSI.CheckTime AS CheckExecutionTime
		  ,CSI.CheckYn
		  ,CASE WHEN CSI.CheckYn = 0 THEN 'NG'
				WHEN CSI.CheckYn = 1 THEN 'OK'
				WHEN (SELECT CheckScheduleExceptionDate 
				        FROM STB_CheckScheduleExceptionHist 
					   WHERE LineCode = CSI2.LineCode
					     AND CheckScheduleExceptionDate = dbo.fnGetShiftDate(CONVERT(VARCHAR(10), CSI.CheckDate, 121) 
						                                         + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108))) IS NOT NULL THEN '계획정지'
				WHEN CSI.CheckYn IS NULL AND CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108) 
												> CONVERT(VARCHAR(19), GETDATE(), 121) THEN '점검전'
				WHEN CSI.CheckYn IS NULL AND CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108) 
												<= CONVERT(VARCHAR(19), GETDATE(), 121) THEN '미점검'
				END AS CheckResult
		  ,CSI.IsUsed
		  ,CSI2.CheckPartContent
		  ,CSI2.CheckStandard
		  ,CSI2.CheckMethod
		  ,CSI.CSIExtReal01
		  ,CSI.CSIExtReal02
		  ,CSI.CSIExtReal03
		  ,CSI.CSIExtReal04 
	  FROM STB_CheckScheduleInfo CSI
	  INNER JOIN STB_CheckStandardInfo CSI2	     ON CSI.CheckStandardNo = CSI2.CheckStandardNo
	  INNER JOIN STB_CheckClassInfo CCI	     ON CSI2.CheckClassNo = CCI.CheckClassNo
	  INNER JOIN STB_CheckPartInfo CPI	     ON CSI2.CheckPartNo = CPI.CheckPartNo
	  LEFT OUTER JOIN STB_MachineMaster MM	     ON CSI2.MachineCode = MM.MachineCode
	  INNER JOIN STB_LineInfo LI	     ON CSI2.LineCode = LI.LineCode
	  LEFT OUTER JOIN STB_CheckScheduleExceptionHist CSEH 
	    ON CSEH.LineCode = CSI2.LineCode
	   AND CSEH.CheckScheduleExceptionDate = CSI.CheckDate
	 WHERE 1=1
	   AND CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108) BETWEEN @FromDate AND @ToDate
	 ORDER BY CSI.CheckDate, CONVERT(VARCHAR(8), CSI2.CheckTime, 108), CPI.DisplayIndex
END