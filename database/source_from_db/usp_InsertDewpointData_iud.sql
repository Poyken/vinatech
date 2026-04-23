CREATE PROC usp_InsertDewpointData_iud
	@pLineCode VARCHAR(20) = NULL
   ,@pDewpoint NUMERIC(20,5) = NULL
AS
BEGIN
	Declare @LineCode VARCHAR(20) = @pLineCode
	       ,@Dewpoint NUMERIC(20,5) = @pDewpoint

	INSERT INTO STB_DewpointData (LineCode, Dewpoint) VALUES (@LineCode, @Dewpoint)
END