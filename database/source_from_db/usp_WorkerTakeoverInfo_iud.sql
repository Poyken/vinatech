-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-10-18
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkerTakeoverInfo_iud]
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
  DECLARE @OldWorkerTakeoverNo VARCHAR(20)
  DECLARE @WorkerTakeoverNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @JobDate DATE
  DECLARE @TimeShiftCode VARCHAR(10)
  DECLARE @TakeoverLineCode VARCHAR(20)
  DECLARE @TakeoverContent NVARCHAR(MAX)
  DECLARE @WriteWorkerCode VARCHAR(20)
  DECLARE @WriteDateTime DATETIME
  DECLARE @IsConfirm BIT
  DECLARE @ConfirmWorkerCode VARCHAR(20)
  DECLARE @ConfirmDateTime DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_WorkerTakeoverInfo',
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
									OldWorkerTakeoverNo,
									WorkerTakeoverNo,
									CompanyCode,
									WorkCenterCode,
									JobDate,
									TimeShiftCode,
									TakeoverLineCode,
									TakeoverContent,
									WriteWorkerCode,
									WriteDateTime,
									IsConfirm,
									ConfirmWorkerCode,
									ConfirmDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldWorkerTakeoverNo VARCHAR(20),
											 WorkerTakeoverNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 TimeShiftCode VARCHAR(10),
											 TakeoverLineCode VARCHAR(20),
											 TakeoverContent NVARCHAR(MAX),
											 WriteWorkerCode VARCHAR(20),
											 WriteDateTime DATETIMEOFFSET,
											 IsConfirm BIT,
											 ConfirmWorkerCode VARCHAR(20),
											 ConfirmDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldWorkerTakeoverNo IS NULL THEN WorkerTakeoverNo
										ELSE OldWorkerTakeoverNo
									END AS OldWorkerTakeoverNo,
									WorkerTakeoverNo,
									CompanyCode,
									WorkCenterCode,
									JobDate,
									TimeShiftCode,
									TakeoverLineCode,
									TakeoverContent,
									WriteWorkerCode,
									WriteDateTime,
									IsConfirm,
									ConfirmWorkerCode,
									ConfirmDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldWorkerTakeoverNo VARCHAR(20),
											 WorkerTakeoverNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 TimeShiftCode VARCHAR(10),
											 TakeoverLineCode VARCHAR(20),
											 TakeoverContent NVARCHAR(MAX),
											 WriteWorkerCode VARCHAR(20),
											 WriteDateTime DATETIMEOFFSET,
											 IsConfirm BIT,
											 ConfirmWorkerCode VARCHAR(20),
											 ConfirmDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldWorkerTakeoverNo IS NULL THEN WorkerTakeoverNo
										ELSE OldWorkerTakeoverNo
									END AS OldWorkerTakeoverNo,
									WorkerTakeoverNo,
									CompanyCode,
									WorkCenterCode,
									JobDate,
									TimeShiftCode,
									TakeoverLineCode,
									TakeoverContent,
									WriteWorkerCode,
									WriteDateTime,
									IsConfirm,
									ConfirmWorkerCode,
									ConfirmDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldWorkerTakeoverNo VARCHAR(20),
											 WorkerTakeoverNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 TimeShiftCode VARCHAR(10),
											 TakeoverLineCode VARCHAR(20),
											 TakeoverContent NVARCHAR(MAX),
											 WriteWorkerCode VARCHAR(20),
											 WriteDateTime DATETIMEOFFSET,
											 IsConfirm BIT,
											 ConfirmWorkerCode VARCHAR(20),
											 ConfirmDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldWorkerTakeoverNo,
								 @WorkerTakeoverNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @JobDate,
								 @TimeShiftCode,
								 @TakeoverLineCode,
								 @TakeoverContent,
								 @WriteWorkerCode,
								 @WriteDateTime,
								 @IsConfirm,
								 @ConfirmWorkerCode,
								 @ConfirmDateTime,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_WorkerTakeoverInfo WHERE WorkerTakeoverNo = @WorkerTakeoverNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @WorkerTakeoverNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_WorkerTakeoverInfo',@WorkerTakeoverNo OUTPUT
                    END

                    INSERT INTO STB_WorkerTakeoverInfo
						(
						    WorkerTakeoverNo,
						    CompanyCode,
						    WorkCenterCode,
						    JobDate,
						    TimeShiftCode,
							TakeoverLineCode,
						    TakeoverContent,
						    WriteWorkerCode,
						    WriteDateTime,
						    IsConfirm,
						    ConfirmWorkerCode,
						    ConfirmDateTime,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @WorkerTakeoverNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @JobDate,
						    @TimeShiftCode,
							@TakeoverLineCode,
						    @TakeoverContent,
						    @WriteWorkerCode,
						    GETDATE(),
						    CONVERT(BIT, 0),
						    @ConfirmWorkerCode,
						    @ConfirmDateTime,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_WorkerTakeoverInfo
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    TimeShiftCode =   ISNULL(@TimeShiftCode,TimeShiftCode),
							TakeoverLineCode = ISNULL(@TakeoverLineCode,TakeoverLineCode),
						    TakeoverContent =   ISNULL(@TakeoverContent,TakeoverContent),
						    WriteWorkerCode =   ISNULL(@WriteWorkerCode,WriteWorkerCode),
						    WriteDateTime =   ISNULL(@WriteDateTime,WriteDateTime),
						    IsConfirm =   ISNULL(@IsConfirm,IsConfirm),
						    ConfirmWorkerCode =   ISNULL(@ConfirmWorkerCode,ConfirmWorkerCode),
						    ConfirmDateTime =   ISNULL(@ConfirmDateTime,ConfirmDateTime),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    WorkerTakeoverNo = @OldWorkerTakeoverNo

					IF @IsConfirm = CONVERT(BIT, 1) BEGIN
						UPDATE STB_WorkerTakeoverInfo
						   SET ConfirmDateTime = GETDATE()
						 WHERE WorkerTakeoverNo = @OldWorkerTakeoverNo
					END ELSE BEGIN
						UPDATE STB_WorkerTakeoverInfo
						   SET ConfirmDateTime = NULL
						      ,ConfirmWorkerCode = NULL
						 WHERE WorkerTakeoverNo = @OldWorkerTakeoverNo
					END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_WorkerTakeoverInfo
						WHERE
						    WorkerTakeoverNo = @OldWorkerTakeoverNo
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
