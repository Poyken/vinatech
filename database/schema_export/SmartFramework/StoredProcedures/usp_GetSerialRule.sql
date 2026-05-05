-- Procedure: usp_GetSerialRule






-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.01.18
-- Description:	Serial 번호 생성 규칙정보를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSerialRule]
	@pTableName VARCHAR(50),
	@pIsAutoKey BIT = NULL OUTPUT,
	@pIsLoopIUD BIT = NULL OUTPUT,
	@pPrefixData VARCHAR(12) = NULL OUTPUT,
	@pSerialLen INT = NULL OUTPUT,
	@pNewSerialNo INT = NULL OUTPUT,
	@pIsIncSerial BIT = NULL
AS
BEGIN
	
	DECLARE @TableName VARCHAR(50) = @pTableName,
			@IsAutoKey BIT,
			@IsLoopIUD BIT,
			@PrefixData VARCHAR(12),
			@SerialLen INT
	DECLARE @CurrentDate DATE,
			@CurrentDayString VARCHAR(8),
			@FourYearString VARCHAR(4),
			@TwoYearString VARCHAR(4),
			@MonthString VARCHAR(2),
			@DayString VARCHAR(2),
			@LastPrefixData VARCHAR(20),
			@LastSerialNo INT,
			@IsIncSerial BIT = ISNULL(@pIsIncSerial,0)
			
	SET @CurrentDate = GETDATE()
	
	SET @CurrentDayString = CONVERT(VARCHAR, @CurrentDate, 112)
	
	SET @FourYearString = SUBSTRING(@CurrentDayString, 1, 4)
	SET @TwoYearString = SUBSTRING(@CurrentDayString, 3, 2)
	SET @MonthString = SUBSTRING(@CurrentDayString, 5, 2)
	SET @DayString = SUBSTRING(@CurrentDayString, 7, 2)
	
	SELECT
			@IsAutoKey = SR.IsAutoKey,
			@IsLoopIUD = SR.IsLoopIUD,
			@PrefixData = SR.PrefixData,
			@SerialLen = SR.SerialLen,
			@LastPrefixData = SR.LastPrefixData,
			@LastSerialNo = SR.LastSerialNo
	FROM
			STB_SerialRule SR
	WHERE
			SR.TableName = @pTableName

	IF ISNULL(@IsAutoKey, 0) = 1
	BEGIN
			IF @IsIncSerial = 1 BEGIN
					SET @PrefixData = REPLACE(@PrefixData, 'YYYY', @FourYearString)
					SET @PrefixData = REPLACE(@PrefixData, 'YY',    @TwoYearString)
					SET @PrefixData = REPLACE(@PrefixData, 'MM',  @MonthString)
					SET @PrefixData = REPLACE(@PrefixData, 'DD',   @DayString)

			
					IF @PrefixData = ISNULL(@LastPrefixData,'') BEGIN
							UPDATE STB_SerialRule
							SET
									LastSerialNo = LastSerialNo + 1
							WHERE
									TableName = @pTableName

							SET @LastSerialNo = @LastSerialNo + 1

					END ELSE BEGIN
							UPDATE STB_SerialRule
							SET
									LastPrefixData = @PrefixData,
									LastSerialNo = 1
							WHERE
									TableName = @pTableName

							SET @LastSerialNo = 1
					END
			END
	END ELSE BEGIN
			SET @IsAutoKey = 0
	END
	
	SET @pIsLoopIUD = ISNULL(@IsLoopIUD, 0)
	
	SET @pIsAutoKey = @IsAutoKey
	SET @pPrefixData = @PrefixData
	SET @pSerialLen = @SerialLen
	SET @pNewSerialNo = @LastSerialNo
	
END







GO

