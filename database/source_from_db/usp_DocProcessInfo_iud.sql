
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-10-08
-- Browsable : true
-- Group : 기록물관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocProcessInfo_iud]
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
  DECLARE @OldProcessCode VARCHAR(10)
  DECLARE @ProcessCode VARCHAR(10)
  DECLARE @ProcessName NVARCHAR(100)
  DECLARE @Remark VARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DocProcessInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DocProcessInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProcessCode IS NULL THEN ProcessCode
							    ELSE OldProcessCode
							END AS OldProcessCode,
							ProcessCode,
							ProcessName,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProcessCode VARCHAR(10),
										ProcessCode VARCHAR(10),
										ProcessName NVARCHAR(100),
										Remark VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProcessCode = SourceTable.ProcessCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProcessName = ISNULL(SourceTable.ProcessName,TargetTable.ProcessName),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProcessCode,
						ProcessName,
						Remark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProcessCode,
							SourceTable.ProcessName,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_DocProcessInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProcessCode IS NULL THEN ProcessCode
							    ELSE OldProcessCode
							END AS OldProcessCode,
							ProcessCode,
							ProcessName,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProcessCode VARCHAR(10),
										ProcessCode VARCHAR(10),
										ProcessName NVARCHAR(100),
										Remark VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProcessCode = SourceTable.OldProcessCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProcessName = ISNULL(SourceTable.ProcessName,TargetTable.ProcessName),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProcessCode,
						ProcessName,
						Remark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProcessCode,
							SourceTable.ProcessName,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DocProcessInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProcessCode IS NULL THEN ProcessCode
							    ELSE OldProcessCode
							END AS OldProcessCode,
							ProcessCode,
							ProcessName,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProcessCode VARCHAR(10),
										ProcessCode VARCHAR(10),
										ProcessName NVARCHAR(100),
										Remark VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProcessCode = SourceTable.ProcessCode
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
									OldProcessCode,
									ProcessCode,
									ProcessName,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProcessCode VARCHAR(10),
											 ProcessCode VARCHAR(10),
											 ProcessName NVARCHAR(100),
											 Remark VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProcessCode IS NULL THEN ProcessCode
										ELSE OldProcessCode
									END AS OldProcessCode,
									ProcessCode,
									ProcessName,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProcessCode VARCHAR(10),
											 ProcessCode VARCHAR(10),
											 ProcessName NVARCHAR(100),
											 Remark VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProcessCode IS NULL THEN ProcessCode
										ELSE OldProcessCode
									END AS OldProcessCode,
									ProcessCode,
									ProcessName,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProcessCode VARCHAR(10),
											 ProcessCode VARCHAR(10),
											 ProcessName NVARCHAR(100),
											 Remark VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProcessCode,
								 @ProcessCode,
								 @ProcessName,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DocProcessInfo WHERE ProcessCode = @ProcessCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProcessCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DocProcessInfo',@ProcessCode OUTPUT
                    END

                    INSERT INTO STB_DocProcessInfo
						(
						    ProcessCode,
						    ProcessName,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ProcessCode,
						    @ProcessName,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DocProcessInfo
						SET
						    ProcessName =   ISNULL(@ProcessName,ProcessName),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ProcessCode = @OldProcessCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DocProcessInfo
						WHERE
						    ProcessCode = @OldProcessCode
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
