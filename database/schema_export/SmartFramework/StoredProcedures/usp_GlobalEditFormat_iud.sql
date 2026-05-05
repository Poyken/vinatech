-- Procedure: usp_GlobalEditFormat_iud





-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-27
-- Browsable : true
-- Group : 공통
-- Description:	전역 편집 포맷규칙을 INSERT/UPDATE/DELETE 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GlobalEditFormat_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldFieldName NVARCHAR(50)
  DECLARE @FieldName NVARCHAR(50)
  DECLARE @DisplayFormatType VARCHAR(20)
  DECLARE @DisplayFormatString NVARCHAR(50)
  DECLARE @EditFormatType VARCHAR(20)
  DECLARE @EditFormatString NVARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_GlobalEditFormat',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_GlobalEditFormat AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldFieldName IS NULL THEN FieldName
							    ELSE OldFieldName
							END AS OldFieldName,
							FieldName,
							DisplayFormatType,
							DisplayFormatString,
							EditFormatType,
							EditFormatString,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldFieldName NVARCHAR(50),
										FieldName NVARCHAR(50),
										DisplayFormatType VARCHAR(20),
										DisplayFormatString NVARCHAR(50),
										EditFormatType VARCHAR(20),
										EditFormatString NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.FieldName = SourceTable.FieldName
				)

			WHEN MATCHED THEN
				UPDATE SET
					FieldName = ISNULL(SourceTable.FieldName,TargetTable.FieldName),
					DisplayFormatType = ISNULL(SourceTable.DisplayFormatType,TargetTable.DisplayFormatType),
					DisplayFormatString = ISNULL(SourceTable.DisplayFormatString,TargetTable.DisplayFormatString),
					EditFormatType = ISNULL(SourceTable.EditFormatType,TargetTable.EditFormatType),
					EditFormatString = ISNULL(SourceTable.EditFormatString,TargetTable.EditFormatString),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						FieldName,
						DisplayFormatType,
						DisplayFormatString,
						EditFormatType,
						EditFormatString,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.FieldName,
							SourceTable.DisplayFormatType,
							SourceTable.DisplayFormatString,
							SourceTable.EditFormatType,
							SourceTable.EditFormatString,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_GlobalEditFormat AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldFieldName IS NULL THEN FieldName
							    ELSE OldFieldName
							END AS OldFieldName,
							FieldName,
							DisplayFormatType,
							DisplayFormatString,
							EditFormatType,
							EditFormatString,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldFieldName NVARCHAR(50),
										FieldName NVARCHAR(50),
										DisplayFormatType VARCHAR(20),
										DisplayFormatString NVARCHAR(50),
										EditFormatType VARCHAR(20),
										EditFormatString NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.FieldName = SourceTable.OldFieldName
				)

			WHEN MATCHED THEN
				UPDATE SET
					FieldName = ISNULL(SourceTable.FieldName,TargetTable.FieldName),
					DisplayFormatType = ISNULL(SourceTable.DisplayFormatType,TargetTable.DisplayFormatType),
					DisplayFormatString = ISNULL(SourceTable.DisplayFormatString,TargetTable.DisplayFormatString),
					EditFormatType = ISNULL(SourceTable.EditFormatType,TargetTable.EditFormatType),
					EditFormatString = ISNULL(SourceTable.EditFormatString,TargetTable.EditFormatString),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						FieldName,
						DisplayFormatType,
						DisplayFormatString,
						EditFormatType,
						EditFormatString,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.FieldName,
							SourceTable.DisplayFormatType,
							SourceTable.DisplayFormatString,
							SourceTable.EditFormatType,
							SourceTable.EditFormatString,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_GlobalEditFormat AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldFieldName IS NULL THEN FieldName
							    ELSE OldFieldName
							END AS OldFieldName,
							FieldName,
							DisplayFormatType,
							DisplayFormatString,
							EditFormatType,
							EditFormatString,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldFieldName NVARCHAR(50),
										FieldName NVARCHAR(50),
										DisplayFormatType VARCHAR(20),
										DisplayFormatString NVARCHAR(50),
										EditFormatType VARCHAR(20),
										EditFormatString NVARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.FieldName = SourceTable.FieldName
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
									OldFieldName,
									FieldName,
									DisplayFormatType,
									DisplayFormatString,
									EditFormatType,
									EditFormatString,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldFieldName NVARCHAR(50),
											 FieldName NVARCHAR(50),
											 DisplayFormatType VARCHAR(20),
											 DisplayFormatString NVARCHAR(50),
											 EditFormatType VARCHAR(20),
											 EditFormatString NVARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldFieldName IS NULL THEN FieldName
										ELSE OldFieldName
									END AS OldFieldName,
									FieldName,
									DisplayFormatType,
									DisplayFormatString,
									EditFormatType,
									EditFormatString,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldFieldName NVARCHAR(50),
											 FieldName NVARCHAR(50),
											 DisplayFormatType VARCHAR(20),
											 DisplayFormatString NVARCHAR(50),
											 EditFormatType VARCHAR(20),
											 EditFormatString NVARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldFieldName IS NULL THEN FieldName
										ELSE OldFieldName
									END AS OldFieldName,
									FieldName,
									DisplayFormatType,
									DisplayFormatString,
									EditFormatType,
									EditFormatString,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldFieldName NVARCHAR(50),
											 FieldName NVARCHAR(50),
											 DisplayFormatType VARCHAR(20),
											 DisplayFormatString NVARCHAR(50),
											 EditFormatType VARCHAR(20),
											 EditFormatString NVARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldFieldName,
								 @FieldName,
								 @DisplayFormatType,
								 @DisplayFormatString,
								 @EditFormatType,
								 @EditFormatString,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_GlobalEditFormat WHERE FieldName = @FieldName) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @FieldName)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(FieldName)
						FROM
								STB_GlobalEditFormat 
						WHERE
								FieldName LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @FieldName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @FieldName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_GlobalEditFormat
						(
						    FieldName,
						    DisplayFormatType,
						    DisplayFormatString,
						    EditFormatType,
						    EditFormatString,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @FieldName,
						    @DisplayFormatType,
						    @DisplayFormatString,
						    @EditFormatType,
						    @EditFormatString,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_GlobalEditFormat
						SET
						    FieldName =   ISNULL(@FieldName,FieldName),
						    DisplayFormatType =   ISNULL(@DisplayFormatType,DisplayFormatType),
						    DisplayFormatString =   ISNULL(@DisplayFormatString,DisplayFormatString),
						    EditFormatType =   ISNULL(@EditFormatType,EditFormatType),
						    EditFormatString =   ISNULL(@EditFormatString,EditFormatString),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    FieldName = @OldFieldName
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_GlobalEditFormat
						WHERE
						    FieldName = @FieldName
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





GO

