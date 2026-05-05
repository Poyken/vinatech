
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-07-22
-- Browsable : true
-- Group : 시스템관리
-- Description:	
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_DailyTaskInfo_iud_backup]
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
  DECLARE @OldUserID VARCHAR(20)
  DECLARE @OldTaskDate DATETIME
  DECLARE @OldTaskIndex INT
  DECLARE @UserID VARCHAR(20)
  DECLARE @TaskDate DATETIME
  DECLARE @TaskIndex INT
  DECLARE @TaskContent VARCHAR(2000)
  DECLARE @CompletionDate DATETIME
  DECLARE @FinishedDate DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DailyTaskInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DailyTaskInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							CASE
							    WHEN OldTaskDate IS NULL THEN TaskDate
							    ELSE OldTaskDate
							END AS OldTaskDate,
							CASE
							    WHEN OldTaskIndex IS NULL THEN TaskIndex
							    ELSE OldTaskIndex
							END AS OldTaskIndex,
							UserID,
							TaskDate,
							TaskIndex,
							TaskContent,
							CompletionDate,
							FinishedDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										OldTaskDate DATETIMEOFFSET,
										OldTaskIndex INT,
										UserID VARCHAR(20),
										TaskDate DATETIMEOFFSET,
										TaskIndex INT,
										TaskContent VARCHAR(2000),
										CompletionDate DATETIMEOFFSET,
										FinishedDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID AND
					TargetTable.TaskDate = SourceTable.TaskDate AND
					TargetTable.TaskIndex = SourceTable.TaskIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					TaskContent = ISNULL(SourceTable.TaskContent,TargetTable.TaskContent),
					CompletionDate = ISNULL(SourceTable.CompletionDate,TargetTable.CompletionDate),
					FinishedDate = ISNULL(SourceTable.FinishedDate,TargetTable.FinishedDate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						TaskContent,
						CompletionDate,
						FinishedDate,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.TaskContent,
							SourceTable.CompletionDate,
							SourceTable.FinishedDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_DailyTaskInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							CASE
							    WHEN OldTaskDate IS NULL THEN TaskDate
							    ELSE OldTaskDate
							END AS OldTaskDate,
							CASE
							    WHEN OldTaskIndex IS NULL THEN TaskIndex
							    ELSE OldTaskIndex
							END AS OldTaskIndex,
							UserID,
							TaskDate,
							TaskIndex,
							TaskContent,
							CompletionDate,
							FinishedDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										OldTaskDate DATETIMEOFFSET,
										OldTaskIndex INT,
										UserID VARCHAR(20),
										TaskDate DATETIMEOFFSET,
										TaskIndex INT,
										TaskContent VARCHAR(2000),
										CompletionDate DATETIMEOFFSET,
										FinishedDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.OldUserID AND
					TargetTable.TaskDate = SourceTable.OldTaskDate AND
					TargetTable.TaskIndex = SourceTable.OldTaskIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					TaskContent = ISNULL(SourceTable.TaskContent,TargetTable.TaskContent),
					CompletionDate = ISNULL(SourceTable.CompletionDate,TargetTable.CompletionDate),
					FinishedDate = ISNULL(SourceTable.FinishedDate,TargetTable.FinishedDate),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						TaskContent,
						CompletionDate,
						FinishedDate,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.TaskContent,
							SourceTable.CompletionDate,
							SourceTable.FinishedDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DailyTaskInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							CASE
							    WHEN OldTaskDate IS NULL THEN TaskDate
							    ELSE OldTaskDate
							END AS OldTaskDate,
							CASE
							    WHEN OldTaskIndex IS NULL THEN TaskIndex
							    ELSE OldTaskIndex
							END AS OldTaskIndex,
							UserID,
							TaskDate,
							TaskIndex,
							TaskContent,
							CompletionDate,
							FinishedDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										OldTaskDate DATETIMEOFFSET,
										OldTaskIndex INT,
										UserID VARCHAR(20),
										TaskDate DATETIMEOFFSET,
										TaskIndex INT,
										TaskContent VARCHAR(2000),
										CompletionDate DATETIMEOFFSET,
										FinishedDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID AND
					TargetTable.TaskDate = SourceTable.TaskDate AND
					TargetTable.TaskIndex = SourceTable.TaskIndex
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
									OldUserID,
									OldTaskDate,
									OldTaskIndex,
									UserID,
									TaskDate,
									TaskIndex,
									TaskContent,
									CompletionDate,
									FinishedDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 OldTaskDate DATETIMEOFFSET,
											 OldTaskIndex INT,
											 UserID VARCHAR(20),
											 TaskDate DATETIMEOFFSET,
											 TaskIndex INT,
											 TaskContent VARCHAR(2000),
											 CompletionDate DATETIMEOFFSET,
											 FinishedDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldUserID IS NULL THEN UserID
										ELSE OldUserID
									END AS OldUserID,
									CASE 
										WHEN OldTaskDate IS NULL THEN TaskDate
										ELSE OldTaskDate
									END AS OldTaskDate,
									CASE 
										WHEN OldTaskIndex IS NULL THEN TaskIndex
										ELSE OldTaskIndex
									END AS OldTaskIndex,
									UserID,
									TaskDate,
									TaskIndex,
									TaskContent,
									CompletionDate,
									FinishedDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 OldTaskDate DATETIMEOFFSET,
											 OldTaskIndex INT,
											 UserID VARCHAR(20),
											 TaskDate DATETIMEOFFSET,
											 TaskIndex INT,
											 TaskContent VARCHAR(2000),
											 CompletionDate DATETIMEOFFSET,
											 FinishedDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldUserID IS NULL THEN UserID
										ELSE OldUserID
									END AS OldUserID,
									CASE 
										WHEN OldTaskDate IS NULL THEN TaskDate
										ELSE OldTaskDate
									END AS OldTaskDate,
									CASE 
										WHEN OldTaskIndex IS NULL THEN TaskIndex
										ELSE OldTaskIndex
									END AS OldTaskIndex,
									UserID,
									TaskDate,
									TaskIndex,
									TaskContent,
									CompletionDate,
									FinishedDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 OldTaskDate DATETIMEOFFSET,
											 OldTaskIndex INT,
											 UserID VARCHAR(20),
											 TaskDate DATETIMEOFFSET,
											 TaskIndex INT,
											 TaskContent VARCHAR(2000),
											 CompletionDate DATETIMEOFFSET,
											 FinishedDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldUserID,
								 @OldTaskDate,
								 @OldTaskIndex,
								 @UserID,
								 @TaskDate,
								 @TaskIndex,
								 @TaskContent,
								 @CompletionDate,
								 @FinishedDate,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' OR @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DailyTaskInfo
						SET
						    TaskContent =   ISNULL(@TaskContent,TaskContent),
						    CompletionDate =   @CompletionDate,
						    FinishedDate =   @FinishedDate,
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    UserID = @OldUserID AND
						    TaskDate = @OldTaskDate AND
						    TaskIndex = @OldTaskIndex
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DailyTaskInfo
						WHERE
						    UserID = @OldUserID AND
						    TaskDate = @OldTaskDate AND
						    TaskIndex = @OldTaskIndex
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
