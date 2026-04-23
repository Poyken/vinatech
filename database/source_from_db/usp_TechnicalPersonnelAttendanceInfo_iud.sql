
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-12-31
-- Browsable : true
-- Group : 시스템관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_TechnicalPersonnelAttendanceInfo_iud]
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
  DECLARE @OldAttendanceDate DATE
  DECLARE @OldWorkerCode VARCHAR(20)
  DECLARE @AttendanceDate DATE
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @AttendanceDateTime DATETIME
  DECLARE @LeavingDateTime DATETIME
  DECLARE @IsConfirm BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @ChangeDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_TechnicalPersonnelAttendanceInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_TechnicalPersonnelAttendanceInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAttendanceDate IS NULL THEN AttendanceDate
							    ELSE OldAttendanceDate
							END AS OldAttendanceDate,
							CASE
							    WHEN OldWorkerCode IS NULL THEN WorkerCode
							    ELSE OldWorkerCode
							END AS OldWorkerCode,
							AttendanceDate,
							WorkerCode,
							AttendanceDateTime,
							LeavingDateTime,
							IsConfirm,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldAttendanceDate DATETIMEOFFSET,
										OldWorkerCode VARCHAR(20),
										AttendanceDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										AttendanceDateTime DATETIMEOFFSET,
										LeavingDateTime DATETIMEOFFSET,
										IsConfirm BIT,
										CreateDateTime DATETIMEOFFSET,
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AttendanceDate = SourceTable.AttendanceDate AND
					TargetTable.WorkerCode = SourceTable.WorkerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					AttendanceDateTime = ISNULL(SourceTable.AttendanceDateTime,TargetTable.AttendanceDateTime),
					LeavingDateTime = ISNULL(SourceTable.LeavingDateTime,TargetTable.LeavingDateTime),
					IsConfirm = ISNULL(SourceTable.IsConfirm,TargetTable.IsConfirm),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime)
			WHEN NOT MATCHED THEN
				INSERT
					(
						AttendanceDate,
						WorkerCode,
						AttendanceDateTime,
						LeavingDateTime,
						IsConfirm,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.AttendanceDate,
							SourceTable.WorkerCode,
							SourceTable.AttendanceDateTime,
							SourceTable.LeavingDateTime,
							SourceTable.IsConfirm,
							SourceTable.CreateDateTime
					);


			-- Process Update Table
            MERGE STB_TechnicalPersonnelAttendanceInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAttendanceDate IS NULL THEN AttendanceDate
							    ELSE OldAttendanceDate
							END AS OldAttendanceDate,
							CASE
							    WHEN OldWorkerCode IS NULL THEN WorkerCode
							    ELSE OldWorkerCode
							END AS OldWorkerCode,
							AttendanceDate,
							WorkerCode,
							AttendanceDateTime,
							LeavingDateTime,
							IsConfirm,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldAttendanceDate DATETIMEOFFSET,
										OldWorkerCode VARCHAR(20),
										AttendanceDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										AttendanceDateTime DATETIMEOFFSET,
										LeavingDateTime DATETIMEOFFSET,
										IsConfirm BIT,
										CreateDateTime DATETIMEOFFSET,
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AttendanceDate = SourceTable.OldAttendanceDate AND
					TargetTable.WorkerCode = SourceTable.OldWorkerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					AttendanceDateTime = ISNULL(SourceTable.AttendanceDateTime,TargetTable.AttendanceDateTime),
					LeavingDateTime = ISNULL(SourceTable.LeavingDateTime,TargetTable.LeavingDateTime),
					IsConfirm = ISNULL(SourceTable.IsConfirm,TargetTable.IsConfirm),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime)
			WHEN NOT MATCHED THEN
				INSERT
					(
						AttendanceDate,
						WorkerCode,
						AttendanceDateTime,
						LeavingDateTime,
						IsConfirm,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.AttendanceDate,
							SourceTable.WorkerCode,
							SourceTable.AttendanceDateTime,
							SourceTable.LeavingDateTime,
							SourceTable.IsConfirm,
							SourceTable.CreateDateTime
					);


			-- Process Delete Table
            MERGE STB_TechnicalPersonnelAttendanceInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAttendanceDate IS NULL THEN AttendanceDate
							    ELSE OldAttendanceDate
							END AS OldAttendanceDate,
							CASE
							    WHEN OldWorkerCode IS NULL THEN WorkerCode
							    ELSE OldWorkerCode
							END AS OldWorkerCode,
							AttendanceDate,
							WorkerCode,
							AttendanceDateTime,
							LeavingDateTime,
							IsConfirm,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldAttendanceDate DATETIMEOFFSET,
										OldWorkerCode VARCHAR(20),
										AttendanceDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										AttendanceDateTime DATETIMEOFFSET,
										LeavingDateTime DATETIMEOFFSET,
										IsConfirm BIT,
										CreateDateTime DATETIMEOFFSET,
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AttendanceDate = SourceTable.AttendanceDate AND
					TargetTable.WorkerCode = SourceTable.WorkerCode
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
									OldAttendanceDate,
									OldWorkerCode,
									AttendanceDate,
									WorkerCode,
									AttendanceDateTime,
									LeavingDateTime,
									IsConfirm,
									CreateDateTime,
									ChangeDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldAttendanceDate DATETIMEOFFSET,
											 OldWorkerCode VARCHAR(20),
											 AttendanceDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 AttendanceDateTime DATETIMEOFFSET,
											 LeavingDateTime DATETIMEOFFSET,
											 IsConfirm BIT,
											 CreateDateTime DATETIMEOFFSET,
											 ChangeDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldAttendanceDate IS NULL THEN AttendanceDate
										ELSE OldAttendanceDate
									END AS OldAttendanceDate,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									AttendanceDate,
									WorkerCode,
									AttendanceDateTime,
									LeavingDateTime,
									IsConfirm,
									CreateDateTime,
									ChangeDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldAttendanceDate DATETIMEOFFSET,
											 OldWorkerCode VARCHAR(20),
											 AttendanceDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 AttendanceDateTime DATETIMEOFFSET,
											 LeavingDateTime DATETIMEOFFSET,
											 IsConfirm BIT,
											 CreateDateTime DATETIMEOFFSET,
											 ChangeDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldAttendanceDate IS NULL THEN AttendanceDate
										ELSE OldAttendanceDate
									END AS OldAttendanceDate,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									AttendanceDate,
									WorkerCode,
									AttendanceDateTime,
									LeavingDateTime,
									IsConfirm,
									CreateDateTime,
									ChangeDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldAttendanceDate DATETIMEOFFSET,
											 OldWorkerCode VARCHAR(20),
											 AttendanceDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 AttendanceDateTime DATETIMEOFFSET,
											 LeavingDateTime DATETIMEOFFSET,
											 IsConfirm BIT,
											 CreateDateTime DATETIMEOFFSET,
											 ChangeDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldAttendanceDate,
								 @OldWorkerCode,
								 @AttendanceDate,
								 @WorkerCode,
								 @AttendanceDateTime,
								 @LeavingDateTime,
								 @IsConfirm,
								 @CreateDateTime,
								 @ChangeDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
                    INSERT INTO STB_TechnicalPersonnelAttendanceInfo
						(
						    AttendanceDate,
						    WorkerCode,
						    AttendanceDateTime,
						    LeavingDateTime,
						    IsConfirm,
						    CreateDateTime,
						    ChangeDateTime
						)
						VALUES
						(
						    @AttendanceDate,
						    @WorkerCode,
						    @AttendanceDateTime,
						    @LeavingDateTime,
						    @IsConfirm,
						    GETDATE(),
						    @ChangeDateTime
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_TechnicalPersonnelAttendanceInfo
						SET
						    AttendanceDateTime =   ISNULL(@AttendanceDateTime,AttendanceDateTime),
						    LeavingDateTime =   ISNULL(@LeavingDateTime,LeavingDateTime),
						    IsConfirm =   ISNULL(@IsConfirm,IsConfirm),
						    ChangeDateTime = GETDATE()
						WHERE
						    AttendanceDate = @OldAttendanceDate AND
						    WorkerCode = @OldWorkerCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_TechnicalPersonnelAttendanceInfo
						WHERE
						    AttendanceDate = @OldAttendanceDate AND
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
