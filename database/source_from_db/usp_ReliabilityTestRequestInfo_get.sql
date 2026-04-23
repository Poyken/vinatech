-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 신뢰성
-- Browsable : true
-- Create date : 2019-11-07
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReliabilityTestRequestInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRequestFromDate DATETIME,
	@pRequestToDate DATETIME
AS

BEGIN
	Declare @RequestFromDate DATETIME = @pRequestFromDate
	       ,@RequestToDate DATETIME = @pRequestToDate

	SELECT RTRI.RTRequestNo
          ,RTRI.RequestDate
          ,RTRI.RequestDeptCode
		  ,BC.Description AS RequestDeptName
          ,RTRI.RequesterID
		  ,EI.EmployeeName AS RequesterName
		  ,RTRI.TestClassCode
		  ,BC2.Description AS TestClassName
          ,RTRI.MassProductionLotNo
		  ,SI.MaterialCode
		  ,MBI.MBIExtText04 AS Volt
		  ,MBI.MBIExtText05 AS Farad
		  ,RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH)) AS Size
          ,RTRI.TestPurposeComment
          ,RTRI.CapacityCondition
          ,RTRI.ACEsrCondition
          ,RTRI.DCEsrCondition
          ,RTRI.SDCondition
          ,RTRI.LCCondition
		  ,RTRI.LengthCondition
		  ,RTRI.WeightCondition
          ,RTRI.ETCCondition
          ,RTRI.RequestRemark
          ,RTRI.RecipientID
		  ,EI2.EmployeeName AS RecipientName
          ,RTRI.ReceptionDate
          ,RTRI.ReceptionNo
          ,RTRI.CreateDateTime
          ,RTRI.CreateUserID
          ,RTRI.ChangeDateTime
          ,RTRI.ChangeUserID
	  FROM STB_ReliabilityTestRequestInfo RTRI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON RTRI.RequestDeptCode = BC.ItemCode
	   AND BC.CodeGroup = 'RequestDept'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON RTRI.TestClassCode = BC2.ItemCode
	   AND BC2.CodeGroup = 'TestClassCode'
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
	    ON RTRI.RequesterID = EI.EmployeeNo
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2
	    ON RTRI.RecipientID = EI2.EmployeeNo
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON SI.Barcode = RTRI.MassProductionLotNo
	  LEFT OUTER JOIN STB_ModelBasicInfo MBI
	    ON MBI.ModelCode = SI.MaterialCode
	 WHERE 1=1
	   AND RTRI.RequestDate BETWEEN @RequestFromDate AND @RequestToDate
END