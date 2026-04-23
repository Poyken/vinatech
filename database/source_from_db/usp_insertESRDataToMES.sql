
CREATE PROC usp_insertESRDataToMES
	@pLineCode VARCHAR(20)
   ,@pESRValue NUMERIC(20,5)
AS
BEGIN
	Declare @LineCode VARCHAR(20) = @pLineCode
	       ,@ESRValue NUMERIC(20,5) = @pESRValue
		   ,@MaterialCode VARCHAR(20)

	SELECT TOP 1 @MaterialCode = MaterialCode
	  FROM STB_DayProdPlan
	 WHERE LineCode = @LineCode
	 ORDER BY CreateDateTime DESC

	INSERT INTO STB_ESRInspectionData (LineCode, InspectionDateTime, InspectionValue, MaterialCode)
			VALUES (@LineCode, GETDATE(), @ESRValue, @MaterialCode)
END