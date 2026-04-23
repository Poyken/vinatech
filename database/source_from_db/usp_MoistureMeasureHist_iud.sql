
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-07-01
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoistureMeasureHist_iud]
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
  DECLARE @OldMoistureMeasureHistNo VARCHAR(20)
  DECLARE @MoistureMeasureHistNo VARCHAR(20)
  DECLARE @MeasureDate DATE
  DECLARE @TimeShiftCode INT
  DECLARE @InspWorkerCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @SpecificComment NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  -- 시료무게 추가 2021-03-17 이미정 차장님 요청 by jackaroe
  DECLARE @SampleWeight NUMERIC(20,5)

  -- Image File Upload Columns
  DECLARE @KarlFischerImageFileID BIGINT
  DECLARE @OldKarlFischerImageFileID BIGINT
  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoistureMeasureHist',
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
									OldMoistureMeasureHistNo,
									MoistureMeasureHistNo,
									MeasureDate,
									TimeShiftCode,
									InspWorkerCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									MachineCode,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									SampleWeight,
									FileName,
									FileSize,
									dbo.fnBase64ToBinary(FileData),
									KarlFischerImageFileID,
									OldKarlFischerImageFileID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoistureMeasureHistNo VARCHAR(20),
											 MoistureMeasureHistNo VARCHAR(20),
											 MeasureDate DATETIMEOFFSET,
											 TimeShiftCode INT,
											 InspWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 SpecificComment NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 SampleWeight NUMERIC(20,5),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 KarlFischerImageFileID BIGINT,
											 OldKarlFischerImageFileID BIGINT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMoistureMeasureHistNo IS NULL THEN MoistureMeasureHistNo
										ELSE OldMoistureMeasureHistNo
									END AS OldMoistureMeasureHistNo,
									MoistureMeasureHistNo,
									MeasureDate,
									TimeShiftCode,
									InspWorkerCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									MachineCode,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									SampleWeight,
									FileName,
									FileSize,
									dbo.fnBase64ToBinary(FileData),
									KarlFischerImageFileID,
									OldKarlFischerImageFileID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoistureMeasureHistNo VARCHAR(20),
											 MoistureMeasureHistNo VARCHAR(20),
											 MeasureDate DATETIMEOFFSET,
											 TimeShiftCode INT,
											 InspWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 SpecificComment NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 SampleWeight NUMERIC(20,5),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 KarlFischerImageFileID BIGINT,
											 OldKarlFischerImageFileID BIGINT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMoistureMeasureHistNo IS NULL THEN MoistureMeasureHistNo
										ELSE OldMoistureMeasureHistNo
									END AS OldMoistureMeasureHistNo,
									MoistureMeasureHistNo,
									MeasureDate,
									TimeShiftCode,
									InspWorkerCode,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									MachineCode,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									SampleWeight,
									FileName,
									FileSize,
									dbo.fnBase64ToBinary(FileData),
									KarlFischerImageFileID,
									OldKarlFischerImageFileID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoistureMeasureHistNo VARCHAR(20),
											 MoistureMeasureHistNo VARCHAR(20),
											 MeasureDate DATETIMEOFFSET,
											 TimeShiftCode INT,
											 InspWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 SpecificComment NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 SampleWeight NUMERIC(20,5),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 KarlFischerImageFileID BIGINT,
											 OldKarlFischerImageFileID BIGINT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoistureMeasureHistNo,
								 @MoistureMeasureHistNo,
								 @MeasureDate,
								 @TimeShiftCode,
								 @InspWorkerCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineCode,
								 @MachineCode,
								 @SpecificComment,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @SampleWeight,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @KarlFischerImageFileID,
								 @OldKarlFischerImageFileID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoistureMeasureHist WHERE MoistureMeasureHistNo = @MoistureMeasureHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoistureMeasureHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MoistureMeasureHist',@MoistureMeasureHistNo OUTPUT

						INSERT INTO #PRIMARYKEY_TEMP VALUES (@MoistureMeasureHistNo)
                    END

					-- 파일업로드
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_MoistureMeasureHist',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @KarlFischerImageFileID OUTPUT

                    INSERT INTO STB_MoistureMeasureHist
						(
						    MoistureMeasureHistNo,
						    MeasureDate,
						    TimeShiftCode,
						    InspWorkerCode,
						    CompanyCode,
						    WorkCenterCode,
						    LineCode,
						    MachineCode,
						    SpecificComment,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							SampleWeight,
							KarlFischerImageFileID
						)
						VALUES
						(
						    @MoistureMeasureHistNo,
						    @MeasureDate,
						    @TimeShiftCode,
						    @InspWorkerCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @LineCode,
						    @MachineCode,
						    @SpecificComment,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@SampleWeight,
							@KarlFischerImageFileID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					IF @FileName IS NOT NULL BEGIN
						EXEC SmartFramework.dbo.usp_DoSaveFile 
								@pSystemName = 'STB_MoistureMeasureHist',
								@pFileContents = @FileData,
								@pFileName = @FileName,
								@pFileSize = @FileSize,
								@pUserID = @ProcessUserID,
								@pFileID = @KarlFischerImageFileID OUTPUT
					END ELSE BEGIN
						EXEC SmartFramework.dbo.usp_DoSaveFile 
								@pSystemName = 'STB_MoistureMeasureHist',
								@pFileContents = @FileData,
								@pFileName = @FileName,
								@pFileSize = @FileSize,
								@pUserID = @ProcessUserID,
								@pFileID = @OldKarlFischerImageFileID OUTPUT
					END

                    UPDATE STB_MoistureMeasureHist
						SET
						    MoistureMeasureHistNo =   ISNULL(@MoistureMeasureHistNo,MoistureMeasureHistNo),
						    MeasureDate =   ISNULL(@MeasureDate,MeasureDate),
						    TimeShiftCode =   ISNULL(@TimeShiftCode,TimeShiftCode),
						    InspWorkerCode =   ISNULL(@InspWorkerCode,InspWorkerCode),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    SpecificComment =   ISNULL(@SpecificComment,SpecificComment),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							SampleWeight = @SampleWeight,
							KarlFischerImageFileID =   ISNULL(@KarlFischerImageFileID,KarlFischerImageFileID)
						WHERE
						    MoistureMeasureHistNo = @OldMoistureMeasureHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoistureMeasureHist
						WHERE
						    MoistureMeasureHistNo = @OldMoistureMeasureHistNo
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
