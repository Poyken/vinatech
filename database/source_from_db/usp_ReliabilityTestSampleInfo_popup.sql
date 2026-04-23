-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 팝업
-- Browsable : true
-- Create date : 2020-01-06
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_ReliabilityTestSampleInfo_popup
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT RTSI.RTSampleNo
	      ,RTSI.SampleLotNo
		  ,RTSI.TestItemCode
		  ,BC.Description AS TestItemName
		  ,REPLACE(RTSI.VoltSpec, '.', 'R') AS VoltSpec
		  ,RTSI.FaradSpec
		  ,RTSI.IsCapacity
		  ,RTSI.IsACEsr
		  ,RTSI.IsDCEsr
		  ,RTSI.IsSD
		  ,RTSI.IsLC
		  ,RTSI.IsETC
	  FROM STB_ReliabilityTestSampleInfo RTSI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON RTSI.TestItemCode = BC.ItemCode
	   AND BC.CodeGroup = 'TestItemCode'
	 ORDER BY RTSampleNo
END