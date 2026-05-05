-- Procedure: usp_DoCreateSerial


-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-29
-- Description:	시리얼번호를 채번합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateSerial]
	@pTableName VARCHAR(50),
	@pSerialNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PrefixData VARCHAR(12),
				@SerialLen INT,
				@NewSerialNo INT

    EXEC SmartFramework.dbo.usp_GetSerialRule	@pTableName = @pTableName,
												@pPrefixData = @PrefixData OUTPUT,
												@pSerialLen = @SerialLen OUTPUT,
												@pNewSerialNo = @NewSerialNo OUTPUT,
												@pIsIncSerial = 1

	IF @NewSerialNo IS NULL 
		BEGIN
			PRINT @PrefixData
			RAISERROR('Not Found Serial Rule : %s',16,1,@pTableName)
			RETURN
		END

	SET @pSerialNo = ISNULL(@PrefixData,'') + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR,@NewSerialNo),@SerialLen)

--	DECLARE @SQL NVARCHAR(MAX) = '
--SELECT
--		@NewSerial = ''{PREFIX}'' + RIGHT(REPLICATE(''0'', {SERIAL_LEN}) + CONVERT(VARCHAR,CONVERT(INT,RIGHT(ISNULL(MAX(T.{KEY}),''{PREFIX}'' + REPLICATE(''0'', {SERIAL_LEN})),{SERIAL_LEN})) + 1), {SERIAL_LEN})
--FROM
--		{TABLE} T
--WHERE
--		T.{KEY} LIKE ''{PREFIX}%'''

--	SET @SQL = REPLACE(@SQL, '{TABLE}',@pTableName)
--	SET @SQL = REPLACE(@SQL, '{PREFIX}', @PrefixData)
--	SET @SQL = REPLACE(@SQL, '{KEY}', @pKeyColumn) 
--	SET @SQL = REPLACE(@SQL, '{SERIAL_LEN}', @SerialLen)

	--EXEC sp_executesql @Query = @SQL,
	--					@Params = N'@NewSerial VARCHAR(20) OUTPUT',
	--					@NewSerial = @pSerialNo OUTPUT
END



GO

