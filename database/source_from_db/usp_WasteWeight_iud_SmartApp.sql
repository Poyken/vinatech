CREATE PROC usp_WasteWeight_iud_SmartApp
	@pLineCode VARCHAR(20)
   ,@pIpAddress VARCHAR(20)
   ,@pWasteWeight NUMERIC(10, 2)
AS
BEGIN
	Declare @LineCode VARCHAR(20) = @pLineCode
	       ,@IpAddress VARCHAR(20) = @pIpAddress
		   ,@WasteWeight NUMERIC(10, 2) = @pWasteWeight

	INSERT INTO STB_WasteWeight (LineCode, IpAddress, WasteWeight) VALUES (@LineCode, @IpAddress, @WasteWeight)
END
