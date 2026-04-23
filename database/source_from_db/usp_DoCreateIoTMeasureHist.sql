CREATE PROC usp_DoCreateIoTMeasureHist
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDeviceID VARCHAR(20),
	@pMeasureItemCode VARCHAR(20),
	@pMeasureValue NUMERIC(20,3)
AS
BEGIN
	Declare @DeviceID VARCHAR(20) = @pDeviceID
	       ,@MeasureItemCode VARCHAR(20) = @pMeasureItemCode
		   ,@MeasureValue NUMERIC(20,3) = @pMeasureValue
		   ,@MeasureNo VARCHAR(20)

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_IoTMeasureHist',@MeasureNo OUTPUT

	INSERT INTO STB_IoTMeasureHist (MeasureNo, DeviceID, MeasureItemCode, MeasureValue)
		VALUES (@MeasureNo, @DeviceID, @MeasureItemCode, @MeasureValue)
END