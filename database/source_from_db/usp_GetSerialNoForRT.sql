CREATE PROC [dbo].[usp_GetSerialNoForRT]
	@pRTSampleNo VARCHAR(20) = NULL,
	@pTestClassCode VARCHAR(10) = NULL,
	@pTestItemCode VARCHAR(10) = NULL,
	@pVoltSpec VARCHAR(10) = NULL,
	@pFaradSpec VARCHAR(10) = NULL,
	@pSerialNo VARCHAR(20) OUTPUT
AS
BEGIN
	Declare @RTSampleNo VARCHAR(20) = @pRTSampleNo
	       ,@TestClassCode VARCHAR(10) = @pTestClassCode
		   ,@Header VARCHAR(20)
	       ,@PrefixCode VARCHAR(10) = 'VR'
		   ,@TestItemCode VARCHAR(10) = @pTestItemCode
		   ,@YearCode VARCHAR(10)
		   ,@MonthCode VARCHAR(10)
		   ,@DayCode VARCHAR(10)
		   ,@VoltSpec VARCHAR(10) = @pVoltSpec
		   ,@FaradSpec VARCHAR(10) = @pFaradSpec
		   ,@MaxNo INT
		   ,@SampleQty INT

	-- 년도
    SELECT @YearCode = YearCode
	  FROM STB_YearInfo
	 WHERE Year = CONVERT(CHAR(4), GETDATE(), 121)

	-- 월
	SELECT @MonthCode = CHAR(CONVERT(INT, RIGHT(CONVERT(CHAR(7), GETDATE(), 121), 2)) + 73)

	-- 일
	SELECT @DayCode = RIGHT(CONVERT(CHAR(10), GETDATE(), 121), 2)

	SET @Header = @PrefixCode + @TestItemCode + @TestClassCode + @YearCode + @MonthCode + @DayCode

	SELECT @MaxNo = ISNULL(MAX(SUBSTRING(RTReceptionNo, 15, 2)) + 1, 1)
	  FROM STB_ReliabilityTestManagementInfo
	 WHERE RTReceptionNo LIKE @Header + '%'

	 SET @pSerialNo = @Header + @VoltSpec + @FaradSpec + RIGHT('0' + CONVERT(VARCHAR(10), @MaxNo), 2)
END