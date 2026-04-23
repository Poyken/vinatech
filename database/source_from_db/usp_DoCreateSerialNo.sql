CREATE PROC usp_DoCreateSerialNo
	@pBaseDate DATE
AS
BEGIN
	Declare @BaseDate DATE = @pBaseDate
	       ,@NextSerialNo INT 

	SELECT @NextSerialNo = ISNULL(MAX(SerialNo), 0) + 1
	  FROM STB_SerialNo_Test
	 WHERE BaseDate = @BaseDate

	INSERT INTO STB_SerialNo_Test VALUES (@BaseDate, @NextSerialNo)
END