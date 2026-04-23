-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 신뢰성관리
-- Browsable : true
-- Create date : 2021-03-23
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_RTInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pRTStatusCode VARCHAR(20) = NULL,
	@pIsLastSeq BIT = NULL
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
		   ,@ToDate DATE = @pToDate
		   ,@RTStatusCode VARCHAR(20) = CASE WHEN ISNULL(@pRTStatusCode, '') = '' THEN '*' ELSE @pRTStatusCode END
		   ,@IsLastSeq BIT = CASE WHEN ISNULL(@pIsLastSeq, 0) = 0 THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END

	SELECT RI.RTNo AS OldRTNo
	      ,RI.Seq AS OldSeq
	      ,RI.RTNo
          ,RI.Seq
          ,RI.TestClassCode
		  ,BC1.Description AS TestClassName
          ,RI.TestItemCode
		  ,BC2.Description AS TestItemName
          ,RI.TestName
		  ,RI.ModelCode
		  ,ISNULL(MBI.ModelName, RI.ModelName) AS ModelName
          ,ISNULL(RI.ModelType, MBI.MBIExtText03) AS ModelType
		  ,ISNULL(RI.Volt, CONVERT(NUMERIC(7,2), MBI.MBIExtText04)) AS Volt
		  ,ISNULL(RI.Farad, CONVERT(NUMERIC(7,2), MBI.MBIExtText05)) AS Farad
		  ,ISNULL(RI.ProdSize, RIGHT('0'+CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2) 
		                          + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH)) 
								  + CASE WHEN CHARINDEX('-L', MBI.ModelName, 10) > 0 THEN 'L' 
										 WHEN CHARINDEX('-B', MBI.ModelName, 10) > 0 THEN 'B' 
										 WHEN CHARINDEX('-C', MBI.ModelName, 10) > 0 THEN 'C' 
								         ELSE '' END) AS ProdSize
          ,RI.AppliedVoltage
          ,RI.Temperature
          ,RI.Humidity
          ,RI.RequestDeptCode
		  ,BC3.Description AS RequestDeptName
          ,RI.RequestWorkerCode
		  ,EI.EmployeeName AS RequestWorkerName
          ,RI.RequestDate
          ,RI.TestStartDate
          ,RI.MeasureDate
          ,RI.TestRestartDate
		  ,DATEADD(day, RI.MeasureCycle / 24.0, RI.TestRestartDate) AS MeasureExpectedDate
          ,RI.MeasureCycle
          ,RI.CumulativeTime
          ,RI.TestEndTime
          ,RI.ChamberCode
		  ,BC4.Description AS ChamberName
          ,RI.CDMachineChannel
          ,RI.JigNo
          ,RI.SampleQty
          ,RI.RTStatusCode
		  ,BC5.Description AS RTStatusName
		  ,RI.Remark
          ,RI.CreateDateTime
          ,RI.CreateUserID
          ,RI.ChangeDateTime
          ,RI.ChangeUserID
	  FROM STB_RTInfo RI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON BC1.CodeGroup = 'TestClassCode'
	   AND BC1.ItemCode = RI.TestClassCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.CodeGroup = 'TestItemCode'
	   AND BC2.ItemCode = RI.TestItemCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON BC3.CodeGroup = 'RequestDept'
	   AND BC3.ItemCode = RI.RequestDeptCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4
	    ON BC4.CodeGroup = 'ChamberCode'
	   AND BC4.ItemCode = RI.ChamberCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5
	    ON BC5.CodeGroup = 'RTStatusCode'
	   AND BC5.ItemCode = RI.RTStatusCode
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
	    ON EI.EmployeeNo = RI.RequestWorkerCode
	  LEFT OUTER JOIN VW_ModelBasicInfo MBI
	    ON MBI.ModelCode = RI.ModelCode
	  LEFT OUTER JOIN (SELECT RTNo, MAX(Seq) AS Seq
	                     FROM STB_RTInfo
						GROUP BY RTNo) RIMAX
		ON RI.RTNo = RIMAX.RTNo
	   AND RI.Seq = RIMAX.Seq
	 WHERE 1=1
	   AND RI.RequestDate BETWEEN @FromDate AND @ToDate
	   AND (@RTStatusCode = '*' OR RI.RTStatusCode = @RTStatusCode)
	   AND (@IsLastSeq = CONVERT(BIT, 0) OR RIMAX.Seq IS NOT NULL)

END