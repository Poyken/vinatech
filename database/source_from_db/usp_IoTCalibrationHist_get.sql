-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-01
-- Browsable : true
-- Group : 품질관리
-- Description:	IoT검교정 이력을 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_IoTCalibrationHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDeviceID VARCHAR(20) = NULL
AS
BEGIN
	Declare @DeviceID VARCHAR(20) = CASE WHEN ISNULL(@pDeviceID, '') = '' THEN '*' ELSE @pDeviceID END

	SELECT ICH.DeviceID
	      ,BC.Remark AS DeviceLocationDetail
		  ,ICH.CalibrationDate
		  ,ICH.StandardTemperature
		  ,ICH.MeasureTemperature
		  ,ICH.StandardHumidity
		  ,ICH.MeasureHumidity
		  ,ICH.InspectionWorkerCode
		  ,PWI.WorkerName AS InspectionWorkerName
		  ,ICH.IsCalibration
		  ,ICH.CreateDateTime
		  ,ICH.CreateUserID
		  ,ICH.ChangeDateTime
		  ,ICH.ChangeUserID
	  FROM STB_IoTCalibrationHist ICH
	  LEFT OUTER JOIN STB_IoTDeviceInfo IDI
	    ON IDI.DeviceID = ICH.DeviceID
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'DeviceLocationCode'
	   AND BC.ItemCode = IDI.DeviceLocationCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON PWI.WorkerCode = ICH.InspectionWorkerCode
	WHERE (@DeviceID = '*' OR ICH.DeviceID = @DeviceID)
	  AND ICH.StandardTemperature IS NOT NULL
	  AND ICH.StandardHumidity IS NOT NULL
END