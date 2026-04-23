
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-11-03
-- Browsable : true
-- Group : 품질관리
-- Description:	IoT검교정 이력을 등합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_IoTCalibrationHist_iud
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
  DECLARE @OldDeviceID VARCHAR(20)
  DECLARE @OldCalibrationDate DATE
  DECLARE @DeviceID VARCHAR(20)
  DECLARE @CalibrationDate DATE
  DECLARE @StandardTemperature NUMERIC(10,3)
  DECLARE @MeasureTemperature NUMERIC(10,3)
  DECLARE @StandardHumidity NUMERIC(10,3)
  DECLARE @MeasureHumidity NUMERIC(10,3)
  DECLARE @InspectionWorkerCode VARCHAR(20)
  DECLARE @IsCalibration BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_IoTCalibrationHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_IoTCalibrationHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDeviceID IS NULL THEN DeviceID
							    ELSE OldDeviceID
							END AS OldDeviceID,
							CASE
							    WHEN OldCalibrationDate IS NULL THEN CalibrationDate
							    ELSE OldCalibrationDate
							END AS OldCalibrationDate,
							DeviceID,
							CalibrationDate,
							StandardTemperature,
							MeasureTemperature,
							StandardHumidity,
							MeasureHumidity,
							InspectionWorkerCode,
							IsCalibration,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDeviceID VARCHAR(20),
										OldCalibrationDate DATETIMEOFFSET,
										DeviceID VARCHAR(20),
										CalibrationDate DATETIMEOFFSET,
										StandardTemperature NUMERIC(10,3),
										MeasureTemperature NUMERIC(10,3),
										StandardHumidity NUMERIC(10,3),
										MeasureHumidity NUMERIC(10,3),
										InspectionWorkerCode VARCHAR(20),
										IsCalibration BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DeviceID = SourceTable.DeviceID AND
					TargetTable.CalibrationDate = SourceTable.CalibrationDate
				)

			WHEN MATCHED THEN
				UPDATE SET
					DeviceID = ISNULL(SourceTable.DeviceID,TargetTable.DeviceID),
					CalibrationDate = ISNULL(SourceTable.CalibrationDate,TargetTable.CalibrationDate),
					StandardTemperature = ISNULL(SourceTable.StandardTemperature,TargetTable.StandardTemperature),
					MeasureTemperature = ISNULL(SourceTable.MeasureTemperature,TargetTable.MeasureTemperature),
					StandardHumidity = ISNULL(SourceTable.StandardHumidity,TargetTable.StandardHumidity),
					MeasureHumidity = ISNULL(SourceTable.MeasureHumidity,TargetTable.MeasureHumidity),
					InspectionWorkerCode = ISNULL(SourceTable.InspectionWorkerCode,TargetTable.InspectionWorkerCode),
					IsCalibration = ISNULL(SourceTable.IsCalibration,TargetTable.IsCalibration),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DeviceID,
						CalibrationDate,
						StandardTemperature,
						MeasureTemperature,
						StandardHumidity,
						MeasureHumidity,
						InspectionWorkerCode,
						IsCalibration,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DeviceID,
							SourceTable.CalibrationDate,
							SourceTable.StandardTemperature,
							SourceTable.MeasureTemperature,
							SourceTable.StandardHumidity,
							SourceTable.MeasureHumidity,
							SourceTable.InspectionWorkerCode,
							SourceTable.IsCalibration,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_IoTCalibrationHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDeviceID IS NULL THEN DeviceID
							    ELSE OldDeviceID
							END AS OldDeviceID,
							CASE
							    WHEN OldCalibrationDate IS NULL THEN CalibrationDate
							    ELSE OldCalibrationDate
							END AS OldCalibrationDate,
							DeviceID,
							CalibrationDate,
							StandardTemperature,
							MeasureTemperature,
							StandardHumidity,
							MeasureHumidity,
							InspectionWorkerCode,
							IsCalibration,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDeviceID VARCHAR(20),
										OldCalibrationDate DATETIMEOFFSET,
										DeviceID VARCHAR(20),
										CalibrationDate DATETIMEOFFSET,
										StandardTemperature NUMERIC(10,3),
										MeasureTemperature NUMERIC(10,3),
										StandardHumidity NUMERIC(10,3),
										MeasureHumidity NUMERIC(10,3),
										InspectionWorkerCode VARCHAR(20),
										IsCalibration BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DeviceID = SourceTable.OldDeviceID AND
					TargetTable.CalibrationDate = SourceTable.OldCalibrationDate
				)

			WHEN MATCHED THEN
				UPDATE SET
					DeviceID = ISNULL(SourceTable.DeviceID,TargetTable.DeviceID),
					CalibrationDate = ISNULL(SourceTable.CalibrationDate,TargetTable.CalibrationDate),
					StandardTemperature = ISNULL(SourceTable.StandardTemperature,TargetTable.StandardTemperature),
					MeasureTemperature = ISNULL(SourceTable.MeasureTemperature,TargetTable.MeasureTemperature),
					StandardHumidity = ISNULL(SourceTable.StandardHumidity,TargetTable.StandardHumidity),
					MeasureHumidity = ISNULL(SourceTable.MeasureHumidity,TargetTable.MeasureHumidity),
					InspectionWorkerCode = ISNULL(SourceTable.InspectionWorkerCode,TargetTable.InspectionWorkerCode),
					IsCalibration = ISNULL(SourceTable.IsCalibration,TargetTable.IsCalibration),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DeviceID,
						CalibrationDate,
						StandardTemperature,
						MeasureTemperature,
						StandardHumidity,
						MeasureHumidity,
						InspectionWorkerCode,
						IsCalibration,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DeviceID,
							SourceTable.CalibrationDate,
							SourceTable.StandardTemperature,
							SourceTable.MeasureTemperature,
							SourceTable.StandardHumidity,
							SourceTable.MeasureHumidity,
							SourceTable.InspectionWorkerCode,
							SourceTable.IsCalibration,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_IoTCalibrationHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDeviceID IS NULL THEN DeviceID
							    ELSE OldDeviceID
							END AS OldDeviceID,
							CASE
							    WHEN OldCalibrationDate IS NULL THEN CalibrationDate
							    ELSE OldCalibrationDate
							END AS OldCalibrationDate,
							DeviceID,
							CalibrationDate
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDeviceID VARCHAR(20),
										OldCalibrationDate DATETIMEOFFSET,
										DeviceID VARCHAR(20),
										CalibrationDate DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DeviceID = SourceTable.DeviceID AND
					TargetTable.CalibrationDate = SourceTable.CalibrationDate
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
									OldDeviceID,
									OldCalibrationDate,
									DeviceID,
									CalibrationDate,
									StandardTemperature,
									MeasureTemperature,
									StandardHumidity,
									MeasureHumidity,
									InspectionWorkerCode,
									IsCalibration,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDeviceID VARCHAR(20),
											 OldCalibrationDate DATETIMEOFFSET,
											 DeviceID VARCHAR(20),
											 CalibrationDate DATETIMEOFFSET,
											 StandardTemperature NUMERIC(10,3),
											 MeasureTemperature NUMERIC(10,3),
											 StandardHumidity NUMERIC(10,3),
											 MeasureHumidity NUMERIC(10,3),
											 InspectionWorkerCode VARCHAR(20),
											 IsCalibration BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDeviceID IS NULL THEN DeviceID
										ELSE OldDeviceID
									END AS OldDeviceID,
									CASE 
										WHEN OldCalibrationDate IS NULL THEN CalibrationDate
										ELSE OldCalibrationDate
									END AS OldCalibrationDate,
									DeviceID,
									CalibrationDate,
									StandardTemperature,
									MeasureTemperature,
									StandardHumidity,
									MeasureHumidity,
									InspectionWorkerCode,
									IsCalibration,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDeviceID VARCHAR(20),
											 OldCalibrationDate DATETIMEOFFSET,
											 DeviceID VARCHAR(20),
											 CalibrationDate DATETIMEOFFSET,
											 StandardTemperature NUMERIC(10,3),
											 MeasureTemperature NUMERIC(10,3),
											 StandardHumidity NUMERIC(10,3),
											 MeasureHumidity NUMERIC(10,3),
											 InspectionWorkerCode VARCHAR(20),
											 IsCalibration BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDeviceID IS NULL THEN DeviceID
										ELSE OldDeviceID
									END AS OldDeviceID,
									CASE 
										WHEN OldCalibrationDate IS NULL THEN CalibrationDate
										ELSE OldCalibrationDate
									END AS OldCalibrationDate,
									DeviceID,
									CalibrationDate,
									StandardTemperature,
									MeasureTemperature,
									StandardHumidity,
									MeasureHumidity,
									InspectionWorkerCode,
									IsCalibration,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDeviceID VARCHAR(20),
											 OldCalibrationDate DATETIMEOFFSET,
											 DeviceID VARCHAR(20),
											 CalibrationDate DATETIMEOFFSET,
											 StandardTemperature NUMERIC(10,3),
											 MeasureTemperature NUMERIC(10,3),
											 StandardHumidity NUMERIC(10,3),
											 MeasureHumidity NUMERIC(10,3),
											 InspectionWorkerCode VARCHAR(20),
											 IsCalibration BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDeviceID,
								 @OldCalibrationDate,
								 @DeviceID,
								 @CalibrationDate,
								 @StandardTemperature,
								 @MeasureTemperature,
								 @StandardHumidity,
								 @MeasureHumidity,
								 @InspectionWorkerCode,
								 @IsCalibration,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_IoTCalibrationHist WHERE DeviceID = @DeviceID AND CalibrationDate = @CalibrationDate) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DeviceID)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_IoTCalibrationHist',@DeviceID OUTPUT
                    END

                    INSERT INTO STB_IoTCalibrationHist
						(
						    DeviceID,
						    CalibrationDate,
						    StandardTemperature,
						    MeasureTemperature,
						    StandardHumidity,
						    MeasureHumidity,
						    InspectionWorkerCode,
						    IsCalibration,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DeviceID,
						    @CalibrationDate,
						    @StandardTemperature,
						    @MeasureTemperature,
						    @StandardHumidity,
						    @MeasureHumidity,
						    @InspectionWorkerCode,
						    @IsCalibration,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_IoTCalibrationHist
						SET
						    DeviceID =   ISNULL(@DeviceID,DeviceID),
						    CalibrationDate =   ISNULL(@CalibrationDate,CalibrationDate),
						    StandardTemperature =   ISNULL(@StandardTemperature,StandardTemperature),
						    MeasureTemperature =   ISNULL(@MeasureTemperature,MeasureTemperature),
						    StandardHumidity =   ISNULL(@StandardHumidity,StandardHumidity),
						    MeasureHumidity =   ISNULL(@MeasureHumidity,MeasureHumidity),
						    InspectionWorkerCode =   ISNULL(@InspectionWorkerCode,InspectionWorkerCode),
						    IsCalibration =   ISNULL(@IsCalibration,IsCalibration),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    DeviceID = @OldDeviceID AND
						    CalibrationDate = @OldCalibrationDate
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_IoTCalibrationHist
						WHERE
						    DeviceID = @OldDeviceID AND
						    CalibrationDate = @OldCalibrationDate
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
