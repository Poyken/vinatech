-- =============================================
-- Author:  Jackaroe(yjyu@vina.co.kr
-- Create date: 2020-01-28
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineManagerEmailInfo_iud]
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
  DECLARE @OldLineCode VARCHAR(20)
  DECLARE @OldManagerID VARCHAR(20)
  DECLARE @OldManagerEmail VARCHAR(200)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @ManagerID VARCHAR(20)
  DECLARE @ManagerEmail VARCHAR(200)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_LineManagerEmailInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_LineManagerEmailInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							CASE
							    WHEN OldManagerID IS NULL THEN ManagerID
							    ELSE OldManagerID
							END AS OldManagerID,
							CASE
							    WHEN OldManagerEmail IS NULL THEN ManagerEmail
							    ELSE OldManagerEmail
							END AS OldManagerEmail,
							LineCode,
							ManagerID,
							ManagerEmail,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										OldManagerID VARCHAR(20),
										OldManagerEmail VARCHAR(200),
										LineCode VARCHAR(20),
										ManagerID VARCHAR(20),
										ManagerEmail VARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.LineCode AND
					TargetTable.ManagerID = SourceTable.ManagerID AND
					TargetTable.ManagerEmail = SourceTable.ManagerEmail
				)

			WHEN MATCHED THEN
				UPDATE SET
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					ManagerID = ISNULL(SourceTable.ManagerID,TargetTable.ManagerID),
					ManagerEmail = ISNULL(SourceTable.ManagerEmail,TargetTable.ManagerEmail),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						LineCode,
						ManagerID,
						ManagerEmail,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LineCode,
							SourceTable.ManagerID,
							SourceTable.ManagerEmail,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_LineManagerEmailInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							CASE
							    WHEN OldManagerID IS NULL THEN ManagerID
							    ELSE OldManagerID
							END AS OldManagerID,
							CASE
							    WHEN OldManagerEmail IS NULL THEN ManagerEmail
							    ELSE OldManagerEmail
							END AS OldManagerEmail,
							LineCode,
							ManagerID,
							ManagerEmail,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										OldManagerID VARCHAR(20),
										OldManagerEmail VARCHAR(200),
										LineCode VARCHAR(20),
										ManagerID VARCHAR(20),
										ManagerEmail VARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.OldLineCode AND
					TargetTable.ManagerID = SourceTable.OldManagerID AND
					TargetTable.ManagerEmail = SourceTable.OldManagerEmail
				)

			WHEN MATCHED THEN
				UPDATE SET
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					ManagerID = ISNULL(SourceTable.ManagerID,TargetTable.ManagerID),
					ManagerEmail = ISNULL(SourceTable.ManagerEmail,TargetTable.ManagerEmail),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						LineCode,
						ManagerID,
						ManagerEmail,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LineCode,
							SourceTable.ManagerID,
							SourceTable.ManagerEmail,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_LineManagerEmailInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							CASE
							    WHEN OldManagerID IS NULL THEN ManagerID
							    ELSE OldManagerID
							END AS OldManagerID,
							CASE
							    WHEN OldManagerEmail IS NULL THEN ManagerEmail
							    ELSE OldManagerEmail
							END AS OldManagerEmail,
							LineCode,
							ManagerID,
							ManagerEmail,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										OldManagerID VARCHAR(20),
										OldManagerEmail VARCHAR(200),
										LineCode VARCHAR(20),
										ManagerID VARCHAR(20),
										ManagerEmail VARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.LineCode AND
					TargetTable.ManagerID = SourceTable.ManagerID AND
					TargetTable.ManagerEmail = SourceTable.ManagerEmail
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
									OldLineCode,
									OldManagerID,
									OldManagerEmail,
									LineCode,
									ManagerID,
									ManagerEmail,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 OldManagerID VARCHAR(20),
											 OldManagerEmail VARCHAR(200),
											 LineCode VARCHAR(20),
											 ManagerID VARCHAR(20),
											 ManagerEmail VARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									CASE 
										WHEN OldManagerID IS NULL THEN ManagerID
										ELSE OldManagerID
									END AS OldManagerID,
									CASE 
										WHEN OldManagerEmail IS NULL THEN ManagerEmail
										ELSE OldManagerEmail
									END AS OldManagerEmail,
									LineCode,
									ManagerID,
									ManagerEmail,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 OldManagerID VARCHAR(20),
											 OldManagerEmail VARCHAR(200),
											 LineCode VARCHAR(20),
											 ManagerID VARCHAR(20),
											 ManagerEmail VARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									CASE 
										WHEN OldManagerID IS NULL THEN ManagerID
										ELSE OldManagerID
									END AS OldManagerID,
									CASE 
										WHEN OldManagerEmail IS NULL THEN ManagerEmail
										ELSE OldManagerEmail
									END AS OldManagerEmail,
									LineCode,
									ManagerID,
									ManagerEmail,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 OldManagerID VARCHAR(20),
											 OldManagerEmail VARCHAR(200),
											 LineCode VARCHAR(20),
											 ManagerID VARCHAR(20),
											 ManagerEmail VARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLineCode,
								 @OldManagerID,
								 @OldManagerEmail,
								 @LineCode,
								 @ManagerID,
								 @ManagerEmail,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_LineManagerEmailInfo WHERE LineCode = @LineCode AND ManagerID = @ManagerID AND ManagerEmail = @ManagerEmail) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_LineManagerEmailInfo',@LineCode OUTPUT
                    END

                    INSERT INTO STB_LineManagerEmailInfo
						(
						    LineCode,
						    ManagerID,
						    ManagerEmail,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LineCode,
						    @ManagerID,
						    @ManagerEmail,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_LineManagerEmailInfo
						SET
						    LineCode =   ISNULL(@LineCode,LineCode),
						    ManagerID =   ISNULL(@ManagerID,ManagerID),
						    ManagerEmail =   ISNULL(@ManagerEmail,ManagerEmail),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    LineCode = @OldLineCode AND
						    ManagerID = @OldManagerID AND
						    ManagerEmail = @OldManagerEmail
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_LineManagerEmailInfo
						WHERE
						    LineCode = @OldLineCode AND
						    ManagerID = @OldManagerID AND
						    ManagerEmail = @OldManagerEmail
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
