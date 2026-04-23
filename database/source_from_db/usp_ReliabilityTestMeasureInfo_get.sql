-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReliabilityTestMeasureInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pRTNo VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@RTNo VARCHAR(20) = CASE WHEN ISNULL(@pRTNo, '') = '' THEN '*' ELSE @pRTNo END

	SELECT RTMI.RTMeasureNo
          ,RTMI.RTNo
          ,RTMI.RTItemCode
		  ,BC1.Description AS RTItemName
          ,RTMI.RTDate
          ,RTMI.RTClassCode
		  ,BC2.Description AS RTClassName
          ,RTMI.RequestDeptCode
		  ,BC3.Description AS RequestDeptName
          ,RTMI.RequestEmployeeNo
		  ,EI1.EmployeeName AS RequestEmployeeName
          ,RTMI.RequestDate
          ,RTMI.TestEndDate
          ,RTMI.ProductType
          ,RTMI.ModelType
          ,RTMI.Ocv
          ,RTMI.Temp
          ,RTMI.Humi
          ,RTMI.SampleCnt
          ,RTMI.MeasureCycle
          ,RTMI.CharacterizationCode
		  ,BC4.Description AS CharacterizationName
          ,RTMI.CharacterizationCode2
		  ,BC5.Description AS CharacterizationName2
          ,RTMI.SampleName
          ,RTMI.SampleSeqNo
          ,RTMI.MeasureValue
          ,RTMI.TestName
          ,RTMI.SampleLotNo
          ,RTMI.TestPurpose
          ,RTMI.CreateDateTime
          ,RTMI.CreateUserID
          ,RTMI.ChangeDateTime
          ,RTMI.ChangeUserID
	  FROM STB_ReliabilityTestMeasureInfo RTMI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON BC1.ItemCode = RTMI.RTItemCode
	   AND BC1.CodeGroup = 'TestItemCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.ItemCode = RTMI.RTClassCode
	   AND BC2.CodeGroup = 'TestClassCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON BC3.ItemCode = RTMI.RequestDeptCode
	   AND BC3.CodeGroup = 'TestRequestDeptCode'
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1
	    ON EI1.EmployeeNo = RTMI.RequestEmployeeNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4
	    ON BC4.ItemCode = RTMI.CharacterizationCode
	   AND BC4.CodeGroup = 'CharacterizationCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5
	    ON BC5.ItemCode = RTMI.CharacterizationCode2
	   AND BC5.CodeGroup = 'CharacterizationCode2'
	 WHERE RTMI.RTDate BETWEEN @FromDate AND @ToDate
	   AND (@RTNo = '*' OR RTMI.RTNo = @RTNo)
END