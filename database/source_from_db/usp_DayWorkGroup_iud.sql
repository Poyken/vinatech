
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-02-15
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_DayWorkGroup_iud
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
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @OldJobDate DATE
  DECLARE @OldWorkerCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @JobDate DATE
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @WorkGroupCode VARCHAR(20)
  DECLARE @WorkGroupName VARCHAR(20)
  DECLARE @ShiftCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_DayWorkGroup',
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
									OldCompanyCode,
									OldWorkCenterCode,
									OldJobDate,
									OldWorkerCode,
									CompanyCode,
									WorkCenterCode,
									JobDate,
									WorkerCode,
									WorkGroupCode,
									WorkGroupName,
									ShiftCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldJobDate DATETIMEOFFSET,
											 OldWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 WorkGroupCode VARCHAR(20),
											 WorkGroupName VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldJobDate IS NULL THEN JobDate
										ELSE OldJobDate
									END AS OldJobDate,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									CompanyCode,
									WorkCenterCode,
									JobDate,
									WorkerCode,
									WorkGroupCode,
									WorkGroupName,
									ShiftCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldJobDate DATETIMEOFFSET,
											 OldWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 WorkGroupCode VARCHAR(20),
											 WorkGroupName VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldJobDate IS NULL THEN JobDate
										ELSE OldJobDate
									END AS OldJobDate,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									CompanyCode,
									WorkCenterCode,
									JobDate,
									WorkerCode,
									WorkGroupCode,
									WorkGroupName,
									ShiftCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldJobDate DATETIMEOFFSET,
											 OldWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 WorkGroupCode VARCHAR(20),
											 WorkGroupName VARCHAR(20),
											 ShiftCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @OldWorkCenterCode,
								 @OldJobDate,
								 @OldWorkerCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @JobDate,
								 @WorkerCode,
								 @WorkGroupCode,
								 @WorkGroupName,
								 @ShiftCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DayWorkGroup WHERE CompanyCode = @CompanyCode AND WorkCenterCode = @WorkCenterCode AND JobDate = @JobDate AND WorkerCode = @WorkerCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CompanyCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_DayWorkGroup',@CompanyCode OUTPUT
                    END

                    INSERT INTO STB_DayWorkGroup
						(
						    CompanyCode,
						    WorkCenterCode,
						    JobDate,
						    WorkerCode,
						    WorkGroupCode,
						    WorkGroupName,
						    ShiftCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CompanyCode,
						    @WorkCenterCode,
						    @JobDate,
						    @WorkerCode,
						    @WorkGroupCode,
						    @WorkGroupName,
						    @ShiftCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DayWorkGroup
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    WorkGroupCode =   ISNULL(@WorkGroupCode,WorkGroupCode),
						    WorkGroupName =   ISNULL(@WorkGroupName,WorkGroupName),
						    ShiftCode =   ISNULL(@ShiftCode,ShiftCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    JobDate = @OldJobDate AND
						    WorkerCode = @OldWorkerCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DayWorkGroup
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    JobDate = @OldJobDate AND
						    WorkerCode = @OldWorkerCode
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
