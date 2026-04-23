-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 신뢰성관리
-- Browsable : true
-- Create date : 2019-12-03
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReliabilityTestManagementInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pReceptionFromDate DATETIME,
	@pReceptionToDate DATETIME,
	@pRTStatusCode VARCHAR(10) = NULL
AS

BEGIN
	Declare @ReceptionFromDate DATETIME = CONVERT(CHAR(10), @pReceptionFromDate, 121) + ' 00:00:00'
	       ,@ReceptionToDate DATETIME = CONVERT(CHAR(10), @pReceptionToDate, 121) + ' 23:59:59'
		   ,@RTStatusCode VARCHAR(10) = CASE WHEN ISNULL(@pRTStatusCode, '') = '' THEN '*' ELSE @pRTStatusCode END

	SELECT RTSI.RTSampleNo
		  ,RTMI.RTReceptionNo
		  ,RTMI.RTStatusCode
		  ,BC3.Description AS RTStatusName
		  ,RTMI.RTReceptionDate
		  ,RTMI.RTFinishDate
		  ,RTRI.TestClassCode
		  ,BC.Description AS TestClassName
		  ,RTSI.TestItemCode
		  ,BC2.Description AS TestItemName
		  ,RTRI.RequesterID
		  ,EI.EmployeeName AS RequesterName
		  ,RTMI.TestName
		  ,RTSI.TemperatureCondition
		  ,RTSI.HumidityCondition
		  ,RTSI.VoltSpec
		  ,RTSI.FaradSpec
		  ,RTMI.RTSampleInfo
		  ,RTSI.IsCapacity
		  ,RTSI.IsACEsr
		  ,RTSI.IsDCEsr
		  ,RTSI.IsSD
		  ,RTSI.IsLC
		  ,RTSI.IsETC
		  ,RTMI.RTStatusDetail
		  ,RTMI.RTRemark
		  ,RTMI.RTFeedbackReport
		  ,RTMI.RTReportFile
		  ,RTMI.CreateDateTime
		  ,RTMI.CreateUserID
		  ,RTMI.ChangeDateTime
		  ,RTMI.ChangeUserID
	  FROM STB_ReliabilityTestSampleInfo RTSI
	  LEFT OUTER JOIN STB_ReliabilityTestManagementInfo RTMI
		ON RTSI.RTSampleNo = RTMI.RTSampleNo
	  LEFT OUTER JOIN STB_ReliabilityTestRequestInfo RTRI
	    ON RTRI.RTRequestNo = RTSI.RTRequestNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.ItemCode = RTRI.TestClassCode
	   AND BC.CodeGroup = 'TestClassCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.ItemCode = RTSI.TestItemCode
	   AND BC2.CodeGroup = 'TestItemCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON BC3.ItemCode = RTMI.RTStatusCode
	   AND BC3.CodeGroup = 'RTStatusCode'
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
	    ON EI.EmployeeNo = RTRI.RequesterID
	  WHERE (RTMI.RTReceptionDate IS NULL OR RTMI.RTReceptionDate BETWEEN @ReceptionFromDate AND @ReceptionToDate)
	    AND (@RTStatusCode = '*' OR RTMI.RTStatusCode = @RTStatusCode)
	  ORDER BY RTSI.RTSampleNo
END