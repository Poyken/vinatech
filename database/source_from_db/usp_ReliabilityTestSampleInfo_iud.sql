
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-06
-- Browsable : true
-- Group : 신뢰성시험
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReliabilityTestSampleInfo_iud]
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
  DECLARE @OldRTSampleNo VARCHAR(20)
  DECLARE @RTSampleNo VARCHAR(20)
  DECLARE @RTRequestNo VARCHAR(20)
  DECLARE @SampleLotNo VARCHAR(20)
  DECLARE @TestItemCode VARCHAR(20)
  DECLARE @VoltCondition NUMERIC(5,1)
  DECLARE @TemperatureCondition NUMERIC(5,1)
  DECLARE @HumidityCondition NUMERIC(5,1)
  DECLARE @SampleQty INT
  DECLARE @IsCapacity BIT
  DECLARE @IsACEsr BIT
  DECLARE @IsDCEsr BIT
  DECLARE @IsSD BIT
  DECLARE @IsLC BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @VoltSpec VARCHAR(10)
  DECLARE @FaradSpec VARCHAR(10)
  DECLARE @IsWeight BIT
  DECLARE @IsLength BIT
  DECLARE @IsETC VARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ReliabilityTestSampleInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ReliabilityTestSampleInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTSampleNo IS NULL THEN RTSampleNo
							    ELSE OldRTSampleNo
							END AS OldRTSampleNo,
							RTSampleNo,
							RTRequestNo,
							SampleLotNo,
							TestItemCode,
							VoltCondition,
							TemperatureCondition,
							HumidityCondition,
							SampleQty,
							IsCapacity,
							IsACEsr,
							IsDCEsr,
							IsSD,
							IsLC,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							VoltSpec,
							FaradSpec,
							IsWeight,
							IsLength,
							IsETC
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRTSampleNo VARCHAR(20),
										RTSampleNo VARCHAR(20),
										RTRequestNo VARCHAR(20),
										SampleLotNo VARCHAR(20),
										TestItemCode VARCHAR(20),
										VoltCondition NUMERIC(5,1),
										TemperatureCondition NUMERIC(5,1),
										HumidityCondition NUMERIC(5,1),
										SampleQty INT,
										IsCapacity BIT,
										IsACEsr BIT,
										IsDCEsr BIT,
										IsSD BIT,
										IsLC BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										VoltSpec VARCHAR(10),
										FaradSpec VARCHAR(10),
										IsWeight BIT,
										IsLength BIT,
										IsETC VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTSampleNo = SourceTable.RTSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RTRequestNo = ISNULL(SourceTable.RTRequestNo,TargetTable.RTRequestNo),
					SampleLotNo = ISNULL(SourceTable.SampleLotNo,TargetTable.SampleLotNo),
					TestItemCode = ISNULL(SourceTable.TestItemCode,TargetTable.TestItemCode),
					VoltCondition = ISNULL(SourceTable.VoltCondition,TargetTable.VoltCondition),
					TemperatureCondition = ISNULL(SourceTable.TemperatureCondition,TargetTable.TemperatureCondition),
					HumidityCondition = ISNULL(SourceTable.HumidityCondition,TargetTable.HumidityCondition),
					SampleQty = ISNULL(SourceTable.SampleQty,TargetTable.SampleQty),
					IsCapacity = ISNULL(SourceTable.IsCapacity,TargetTable.IsCapacity),
					IsACEsr = ISNULL(SourceTable.IsACEsr,TargetTable.IsACEsr),
					IsDCEsr = ISNULL(SourceTable.IsDCEsr,TargetTable.IsDCEsr),
					IsSD = ISNULL(SourceTable.IsSD,TargetTable.IsSD),
					IsLC = ISNULL(SourceTable.IsLC,TargetTable.IsLC),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					VoltSpec = ISNULL(SourceTable.VoltSpec,TargetTable.VoltSpec),
					FaradSpec = ISNULL(SourceTable.FaradSpec,TargetTable.FaradSpec),
					IsWeight = ISNULL(SourceTable.IsWeight,TargetTable.IsWeight),
					IsLength = ISNULL(SourceTable.IsLength,TargetTable.IsLength),
					IsETC = ISNULL(SourceTable.IsETC,TargetTable.IsETC)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RTSampleNo,
						RTRequestNo,
						SampleLotNo,
						TestItemCode,
						VoltCondition,
						TemperatureCondition,
						HumidityCondition,
						SampleQty,
						IsCapacity,
						IsACEsr,
						IsDCEsr,
						IsSD,
						IsLC,
						CreateDateTime,
						CreateUserID,
						VoltSpec,
						FaradSpec,
						IsWeight,
						IsLength,
						IsETC
					)
				VALUES
					(
							SourceTable.RTSampleNo,
							SourceTable.RTRequestNo,
							SourceTable.SampleLotNo,
							SourceTable.TestItemCode,
							SourceTable.VoltCondition,
							SourceTable.TemperatureCondition,
							SourceTable.HumidityCondition,
							SourceTable.SampleQty,
							SourceTable.IsCapacity,
							SourceTable.IsACEsr,
							SourceTable.IsDCEsr,
							SourceTable.IsSD,
							SourceTable.IsLC,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.VoltSpec,
							SourceTable.FaradSpec,
							SourceTable.IsWeight,
							SourceTable.IsLength,
							SourceTable.IsETC
					);


			-- Process Update Table
            MERGE STB_ReliabilityTestSampleInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTSampleNo IS NULL THEN RTSampleNo
							    ELSE OldRTSampleNo
							END AS OldRTSampleNo,
							RTSampleNo,
							RTRequestNo,
							SampleLotNo,
							TestItemCode,
							VoltCondition,
							TemperatureCondition,
							HumidityCondition,
							SampleQty,
							IsCapacity,
							IsACEsr,
							IsDCEsr,
							IsSD,
							IsLC,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							VoltSpec,
							FaradSpec,
							IsWeight,
							IsLength,
							IsETC
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRTSampleNo VARCHAR(20),
										RTSampleNo VARCHAR(20),
										RTRequestNo VARCHAR(20),
										SampleLotNo VARCHAR(20),
										TestItemCode VARCHAR(20),
										VoltCondition NUMERIC(5,1),
										TemperatureCondition NUMERIC(5,1),
										HumidityCondition NUMERIC(5,1),
										SampleQty INT,
										IsCapacity BIT,
										IsACEsr BIT,
										IsDCEsr BIT,
										IsSD BIT,
										IsLC BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										VoltSpec VARCHAR(10),
										FaradSpec VARCHAR(10),
										IsWeight BIT,
										IsLength BIT,
										IsETC VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTSampleNo = SourceTable.OldRTSampleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RTRequestNo = ISNULL(SourceTable.RTRequestNo,TargetTable.RTRequestNo),
					SampleLotNo = ISNULL(SourceTable.SampleLotNo,TargetTable.SampleLotNo),
					TestItemCode = ISNULL(SourceTable.TestItemCode,TargetTable.TestItemCode),
					VoltCondition = ISNULL(SourceTable.VoltCondition,TargetTable.VoltCondition),
					TemperatureCondition = ISNULL(SourceTable.TemperatureCondition,TargetTable.TemperatureCondition),
					HumidityCondition = ISNULL(SourceTable.HumidityCondition,TargetTable.HumidityCondition),
					SampleQty = ISNULL(SourceTable.SampleQty,TargetTable.SampleQty),
					IsCapacity = ISNULL(SourceTable.IsCapacity,TargetTable.IsCapacity),
					IsACEsr = ISNULL(SourceTable.IsACEsr,TargetTable.IsACEsr),
					IsDCEsr = ISNULL(SourceTable.IsDCEsr,TargetTable.IsDCEsr),
					IsSD = ISNULL(SourceTable.IsSD,TargetTable.IsSD),
					IsLC = ISNULL(SourceTable.IsLC,TargetTable.IsLC),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					VoltSpec = ISNULL(SourceTable.VoltSpec,TargetTable.VoltSpec),
					FaradSpec = ISNULL(SourceTable.FaradSpec,TargetTable.FaradSpec),
					IsWeight = ISNULL(SourceTable.IsWeight,TargetTable.IsWeight),
					IsLength = ISNULL(SourceTable.IsLength,TargetTable.IsLength),
					IsETC = ISNULL(SourceTable.IsETC,TargetTable.IsETC)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RTSampleNo,
						RTRequestNo,
						SampleLotNo,
						TestItemCode,
						VoltCondition,
						TemperatureCondition,
						HumidityCondition,
						SampleQty,
						IsCapacity,
						IsACEsr,
						IsDCEsr,
						IsSD,
						IsLC,
						CreateDateTime,
						CreateUserID,
						VoltSpec,
						FaradSpec,
						IsWeight,
						IsLength,
						IsETC
					)
				VALUES
					(
							SourceTable.RTSampleNo,
							SourceTable.RTRequestNo,
							SourceTable.SampleLotNo,
							SourceTable.TestItemCode,
							SourceTable.VoltCondition,
							SourceTable.TemperatureCondition,
							SourceTable.HumidityCondition,
							SourceTable.SampleQty,
							SourceTable.IsCapacity,
							SourceTable.IsACEsr,
							SourceTable.IsDCEsr,
							SourceTable.IsSD,
							SourceTable.IsLC,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.VoltSpec,
							SourceTable.FaradSpec,
							SourceTable.IsWeight,
							SourceTable.IsLength,
							SourceTable.IsETC
					);


			-- Process Delete Table
            MERGE STB_ReliabilityTestSampleInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTSampleNo IS NULL THEN RTSampleNo
							    ELSE OldRTSampleNo
							END AS OldRTSampleNo,
							RTSampleNo,
							RTRequestNo,
							SampleLotNo,
							TestItemCode,
							VoltCondition,
							TemperatureCondition,
							HumidityCondition,
							SampleQty,
							IsCapacity,
							IsACEsr,
							IsDCEsr,
							IsSD,
							IsLC,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							VoltSpec,
							FaradSpec,
							IsWeight,
							IsLength,
							IsETC
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRTSampleNo VARCHAR(20),
										RTSampleNo VARCHAR(20),
										RTRequestNo VARCHAR(20),
										SampleLotNo VARCHAR(20),
										TestItemCode VARCHAR(20),
										VoltCondition NUMERIC(5,1),
										TemperatureCondition NUMERIC(5,1),
										HumidityCondition NUMERIC(5,1),
										SampleQty INT,
										IsCapacity BIT,
										IsACEsr BIT,
										IsDCEsr BIT,
										IsSD BIT,
										IsLC BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										VoltSpec VARCHAR(10),
										FaradSpec VARCHAR(10),
										IsWeight BIT,
										IsLength BIT,
										IsETC VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTSampleNo = SourceTable.RTSampleNo
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldRTSampleNo,
									RTSampleNo,
									RTRequestNo,
									SampleLotNo,
									TestItemCode,
									VoltCondition,
									TemperatureCondition,
									HumidityCondition,
									SampleQty,
									IsCapacity,
									IsACEsr,
									IsDCEsr,
									IsSD,
									IsLC,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									VoltSpec,
									FaradSpec,
									IsWeight,
									IsLength,
									IsETC
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRTSampleNo VARCHAR(20),
											 RTSampleNo VARCHAR(20),
											 RTRequestNo VARCHAR(20),
											 SampleLotNo VARCHAR(20),
											 TestItemCode VARCHAR(20),
											 VoltCondition NUMERIC(5,1),
											 TemperatureCondition NUMERIC(5,1),
											 HumidityCondition NUMERIC(5,1),
											 SampleQty INT,
											 IsCapacity BIT,
											 IsACEsr BIT,
											 IsDCEsr BIT,
											 IsSD BIT,
											 IsLC BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 VoltSpec VARCHAR(10),
											 FaradSpec VARCHAR(10),
											 IsWeight BIT,
											 IsLength BIT,
											 IsETC VARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRTSampleNo IS NULL THEN RTSampleNo
										ELSE OldRTSampleNo
									END AS OldRTSampleNo,
									RTSampleNo,
									RTRequestNo,
									SampleLotNo,
									TestItemCode,
									VoltCondition,
									TemperatureCondition,
									HumidityCondition,
									SampleQty,
									IsCapacity,
									IsACEsr,
									IsDCEsr,
									IsSD,
									IsLC,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									VoltSpec,
									FaradSpec,
									IsWeight,
									IsLength,
									IsETC
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRTSampleNo VARCHAR(20),
											 RTSampleNo VARCHAR(20),
											 RTRequestNo VARCHAR(20),
											 SampleLotNo VARCHAR(20),
											 TestItemCode VARCHAR(20),
											 VoltCondition NUMERIC(5,1),
											 TemperatureCondition NUMERIC(5,1),
											 HumidityCondition NUMERIC(5,1),
											 SampleQty INT,
											 IsCapacity BIT,
											 IsACEsr BIT,
											 IsDCEsr BIT,
											 IsSD BIT,
											 IsLC BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 VoltSpec VARCHAR(10),
											 FaradSpec VARCHAR(10),
											 IsWeight BIT,
											 IsLength BIT,
											 IsETC VARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRTSampleNo IS NULL THEN RTSampleNo
										ELSE OldRTSampleNo
									END AS OldRTSampleNo,
									RTSampleNo,
									RTRequestNo,
									SampleLotNo,
									TestItemCode,
									VoltCondition,
									TemperatureCondition,
									HumidityCondition,
									SampleQty,
									IsCapacity,
									IsACEsr,
									IsDCEsr,
									IsSD,
									IsLC,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									VoltSpec,
									FaradSpec,
									IsWeight,
									IsLength,
									IsETC
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRTSampleNo VARCHAR(20),
											 RTSampleNo VARCHAR(20),
											 RTRequestNo VARCHAR(20),
											 SampleLotNo VARCHAR(20),
											 TestItemCode VARCHAR(20),
											 VoltCondition NUMERIC(5,1),
											 TemperatureCondition NUMERIC(5,1),
											 HumidityCondition NUMERIC(5,1),
											 SampleQty INT,
											 IsCapacity BIT,
											 IsACEsr BIT,
											 IsDCEsr BIT,
											 IsSD BIT,
											 IsLC BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 VoltSpec VARCHAR(10),
											 FaradSpec VARCHAR(10),
											 IsWeight BIT,
											 IsLength BIT,
											 IsETC VARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRTSampleNo,
								 @RTSampleNo,
								 @RTRequestNo,
								 @SampleLotNo,
								 @TestItemCode,
								 @VoltCondition,
								 @TemperatureCondition,
								 @HumidityCondition,
								 @SampleQty,
								 @IsCapacity,
								 @IsACEsr,
								 @IsDCEsr,
								 @IsSD,
								 @IsLC,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @VoltSpec,
								 @FaradSpec,
								 @IsWeight,
								 @IsLength,
								 @IsETC


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ReliabilityTestSampleInfo WHERE RTSampleNo = @RTSampleNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RTSampleNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ReliabilityTestSampleInfo',@RTSampleNo OUTPUT
                    END

                    INSERT INTO STB_ReliabilityTestSampleInfo
						(
						    RTSampleNo,
						    RTRequestNo,
						    SampleLotNo,
						    TestItemCode,
						    VoltCondition,
						    TemperatureCondition,
						    HumidityCondition,
						    SampleQty,
						    IsCapacity,
						    IsACEsr,
						    IsDCEsr,
						    IsSD,
						    IsLC,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    VoltSpec,
						    FaradSpec,
						    IsWeight,
						    IsLength,
						    IsETC
						)
						VALUES
						(
						    @RTSampleNo,
						    @RTRequestNo,
						    @SampleLotNo,
						    @TestItemCode,
						    @VoltCondition,
						    @TemperatureCondition,
						    @HumidityCondition,
						    @SampleQty,
						    @IsCapacity,
						    @IsACEsr,
						    @IsDCEsr,
						    @IsSD,
						    @IsLC,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @VoltSpec,
						    @FaradSpec,
						    @IsWeight,
						    @IsLength,
						    @IsETC
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ReliabilityTestSampleInfo
						SET
						    RTRequestNo =   ISNULL(@RTRequestNo,RTRequestNo),
						    SampleLotNo =   ISNULL(@SampleLotNo,SampleLotNo),
						    TestItemCode =   ISNULL(@TestItemCode,TestItemCode),
						    VoltCondition =   ISNULL(@VoltCondition,VoltCondition),
						    TemperatureCondition =   ISNULL(@TemperatureCondition,TemperatureCondition),
						    HumidityCondition =   ISNULL(@HumidityCondition,HumidityCondition),
						    SampleQty =   ISNULL(@SampleQty,SampleQty),
						    IsCapacity =   ISNULL(@IsCapacity,IsCapacity),
						    IsACEsr =   ISNULL(@IsACEsr,IsACEsr),
						    IsDCEsr =   ISNULL(@IsDCEsr,IsDCEsr),
						    IsSD =   ISNULL(@IsSD,IsSD),
						    IsLC =   ISNULL(@IsLC,IsLC),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    VoltSpec =   ISNULL(@VoltSpec,VoltSpec),
						    FaradSpec =   ISNULL(@FaradSpec,FaradSpec),
						    IsWeight =   ISNULL(@IsWeight,IsWeight),
						    IsLength =   ISNULL(@IsLength,IsLength),
						    IsETC =   ISNULL(@IsETC,IsETC)
						WHERE
						    RTSampleNo = @OldRTSampleNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ReliabilityTestSampleInfo
						WHERE
						    RTSampleNo = @OldRTSampleNo
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
