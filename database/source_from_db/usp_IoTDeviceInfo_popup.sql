-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-25
-- Browsable : true
-- Group : 스마트팩토리 > [S120]Iot측정이력 > 디바이스ID 콤보박스 Popup
-- Description:	IoTMeasureHist
-- Modified: 
-- Exec usp_IoTDeviceInfo_popup '',''
-- =============================================

CREATE PROCEDURE [dbo].[usp_IoTDeviceInfo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN

	SELECT IDI.DeviceID
			  ,IDI.DeviceClassCode
			  ,BC2.Remark           AS DeviceClassName
			  ,IDI.DeviceLocationCode
			  ,BC.Description             AS DeviceLocationName
			  ,BC.Remark                  AS DeviceLocationDetail
		  FROM                 STB_IoTDeviceInfo IDI
		  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	    ON IDI.DeviceLocationCode = BC.ItemCode	AND BC.CodeGroup = 'DeviceLocationCode'
		  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON IDI.DeviceClassCode = BC2.ItemCode	    AND BC2.CodeGroup = 'DeviceClassCode'
	 WHERE 1=1
		 AND IDI.IsUsed = CONVERT(BIT, 1)
	 ORDER BY IDI.DeviceLocationCode

END