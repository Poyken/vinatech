-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-05-29
-- Browsable : true
-- Group : 지지체
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_RotaryKilnItemSpecInfo_iud
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldRotaryKilnItemSpecNo VARCHAR(20)
  DECLARE @RotaryKilnItemSpecNo VARCHAR(20)
  DECLARE @BaseDate DATE
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @KilnTemperature NUMERIC(20,5)
  DECLARE @RunTime NUMERIC(20,5)
  DECLARE @SteamTemperature NUMERIC(20,5)
  DECLARE @SpinSpeed NUMERIC(20,5)
  DECLARE @WaterVaporPressure NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_RotaryKilnItemSpecInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldRotaryKilnItemSpecNo,
									RotaryKilnItemSpecNo,
									BaseDate,
									MachineCode,
									KilnTemperature,
									RunTime,
									SteamTemperature,
									SpinSpeed,
									WaterVaporPressure,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRotaryKilnItemSpecNo VARCHAR(20),
											 RotaryKilnItemSpecNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 MachineCode VARCHAR(20),
											 KilnTemperature NUMERIC(20,5),
											 RunTime NUMERIC(20,5),
											 SteamTemperature NUMERIC(20,5),
											 SpinSpeed NUMERIC(20,5),
											 WaterVaporPressure NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRotaryKilnItemSpecNo IS NULL THEN RotaryKilnItemSpecNo
										ELSE OldRotaryKilnItemSpecNo
									END AS OldRotaryKilnItemSpecNo,
									RotaryKilnItemSpecNo,
									BaseDate,
									MachineCode,
									KilnTemperature,
									RunTime,
									SteamTemperature,
									SpinSpeed,
									WaterVaporPressure,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRotaryKilnItemSpecNo VARCHAR(20),
											 RotaryKilnItemSpecNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 MachineCode VARCHAR(20),
											 KilnTemperature NUMERIC(20,5),
											 RunTime NUMERIC(20,5),
											 SteamTemperature NUMERIC(20,5),
											 SpinSpeed NUMERIC(20,5),
											 WaterVaporPressure NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRotaryKilnItemSpecNo IS NULL THEN RotaryKilnItemSpecNo
										ELSE OldRotaryKilnItemSpecNo
									END AS OldRotaryKilnItemSpecNo,
									RotaryKilnItemSpecNo,
									BaseDate,
									MachineCode,
									KilnTemperature,
									RunTime,
									SteamTemperature,
									SpinSpeed,
									WaterVaporPressure,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRotaryKilnItemSpecNo VARCHAR(20),
											 RotaryKilnItemSpecNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 MachineCode VARCHAR(20),
											 KilnTemperature NUMERIC(20,5),
											 RunTime NUMERIC(20,5),
											 SteamTemperature NUMERIC(20,5),
											 SpinSpeed NUMERIC(20,5),
											 WaterVaporPressure NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRotaryKilnItemSpecNo,
								 @RotaryKilnItemSpecNo,
								 @BaseDate,
								 @MachineCode,
								 @KilnTemperature,
								 @RunTime,
								 @SteamTemperature,
								 @SpinSpeed,
								 @WaterVaporPressure,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_RotaryKilnItemSpecInfo WHERE RotaryKilnItemSpecNo = @RotaryKilnItemSpecNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RotaryKilnItemSpecNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_RotaryKilnItemSpecInfo',@RotaryKilnItemSpecNo OUTPUT
                    END

                    INSERT INTO STB_RotaryKilnItemSpecInfo
						(
						    RotaryKilnItemSpecNo,
						    BaseDate,
						    MachineCode,
						    KilnTemperature,
						    RunTime,
						    SteamTemperature,
						    SpinSpeed,
						    WaterVaporPressure,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @RotaryKilnItemSpecNo,
						    @BaseDate,
						    @MachineCode,
						    @KilnTemperature,
						    @RunTime,
						    @SteamTemperature,
						    @SpinSpeed,
						    @WaterVaporPressure,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_RotaryKilnItemSpecInfo
						SET
						    BaseDate =   ISNULL(@BaseDate,BaseDate),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    KilnTemperature =   ISNULL(@KilnTemperature,KilnTemperature),
						    RunTime =   ISNULL(@RunTime,RunTime),
						    SteamTemperature =   ISNULL(@SteamTemperature,SteamTemperature),
						    SpinSpeed =   ISNULL(@SpinSpeed,SpinSpeed),
						    WaterVaporPressure =   ISNULL(@WaterVaporPressure,WaterVaporPressure),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    RotaryKilnItemSpecNo = @OldRotaryKilnItemSpecNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_RotaryKilnItemSpecInfo
						WHERE
						    RotaryKilnItemSpecNo = @OldRotaryKilnItemSpecNo
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	

    END
END