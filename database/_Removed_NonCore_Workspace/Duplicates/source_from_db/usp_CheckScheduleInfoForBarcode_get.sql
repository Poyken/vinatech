-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-08-02
-- Description : 일상점검스케줄 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckScheduleInfoForBarcode_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20)
AS

BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@FromDateTime DATETIME
		   ,@ToDateTime DATETIME
		   ,@LineCode VARCHAR(20)

	SELECT @FromDateTime = DATEADD(day, -1, ISNULL(InputDateTime, InputJobDate))
	      ,@ToDateTime = DATEADD(day, 1, ISNULL(InputDateTime, InputJobDate))
		  ,@LineCode = InputLineCode
	  FROM STB_SetInfo
	 WHERE Barcode = @Barcode

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
	  LEFT OUTER JOIN STB_MachineMaster MM
	     ON CSI2.MachineCode = MM.MachineCode
	  INNER JOIN STB_LineInfo LI
	     ON CSI2.LineCode = LI.LineCode
	 WHERE CONVERT(VARCHAR(10), CSI.CheckDate, 121) + ' ' + CONVERT(VARCHAR(8), CSI2.CheckTime, 108) BETWEEN @FromDateTime AND @ToDateTime
	   AND CSI2.LineCode LIKE @LineCode
	   AND CSI.CheckYn IS NOT NULL
	 ORDER BY CSI.CheckDate, CONVERT(VARCHAR(8), CSI2.CheckTime, 108), CPI.DisplayIndex
END