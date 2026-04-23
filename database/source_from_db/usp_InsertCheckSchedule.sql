CREATE PROC [dbo].[usp_InsertCheckSchedule]
	@pCheckStandardNo VARCHAR(20)
   ,@pCheckDate VARCHAR(20)
   ,@pOccasionalCheckItemName VARCHAR(100)
   ,@pCheckYn VARCHAR(10)
   ,@pLineCode VARCHAR(20)
AS
BEGIN
	Declare @CheckStandardNo VARCHAR(20) = @pCheckStandardNo
		   ,@CheckDate DATE = CONVERT(DATE, @pCheckDate, 121)
		   ,@OccasionalCheckItemName VARCHAR(100) = @pOccasionalCheckItemName
		   ,@CheckYn VARCHAR(10) = @pCheckYn
		   ,@Seq INT
		   ,@LineCode VARCHAR(20) = @pLineCode

	/*
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CheckScheduleInfo',@CheckScheduleNo OUTPUT

	INSERT INTO STB_CheckScheduleInfo
		SELECT @CheckScheduleNo, @CheckStandardNo, @CheckDate, GETDATE(), CONVERT(BIT, @CheckYn)
		     , GETDATE(), 'eai', NULL, NULL, 1, @OccasionalCheckItemName
	*/

	SELECT @Seq = ISNULL(MAX(Seq), 0) + 1
	  FROM STB_OccasionalCheckScheduleInfo
	 WHERE LineCode = @LineCode
	   AND CheckDate = @CheckDate

	INSERT INTO STB_OccasionalCheckScheduleInfo (LineCode, CheckDate, Seq, OccasionalCheckItemName, CheckYn)
		SELECT @LineCode, @CheckDate, @Seq, @OccasionalCheckItemName, @CheckYn
END