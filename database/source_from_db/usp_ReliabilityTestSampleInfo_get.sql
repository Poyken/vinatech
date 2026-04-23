-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 신뢰성
-- Browsable : true
-- Create date : 2019-11-07
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReliabilityTestSampleInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRTRequestNo VARCHAR(50) = NULL
AS

BEGIN
	Declare @RTRequestNo VARCHAR(50) = @pRTRequestNo

	SELECT RTSI.RTSampleNo
	      ,RTSI.RTRequestNo
          ,RTSI.SampleLotNo
          ,RTSI.TestItemCode
		  ,BC2.Description AS TestItemName
		  ,RTSI.VoltSpec
		  ,RTSI.FaradSpec
          ,RTSI.VoltCondition
          ,RTSI.TemperatureCondition
          ,RTSI.HumidityCondition
          ,RTSI.SampleQty
		  ,BC.Description AS SampleQtyName
          ,RTSI.IsCapacity
          ,RTSI.IsACEsr
          ,RTSI.IsDCEsr
          ,RTSI.IsSD
          ,RTSI.IsLC
		  ,RTSI.IsLength
		  ,RTSI.IsWeight
          ,RTSI.IsETC
          ,RTSI.CreateDateTime
          ,RTSI.CreateUserID
          ,RTSI.ChangeDateTime
          ,RTSI.ChangeUserID
	  FROM STB_ReliabilityTestSampleInfo RTSI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON RTSI.SampleQty = BC.ItemCode
	   AND BC.CodeGroup = 'SampleQty'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON RTSI.TestItemCode = BC2.ItemCode
	   AND BC2.CodeGroup = 'TestItemCode'
	 WHERE RTRequestNo = @RTRequestNo
	 ORDER BY RTSampleNo
END
