-- Procedure: usp_PaperTypeInfo_iud



-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-30
-- Browsable : true
-- Group : 용지유형정보
-- Description:	용지유형정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PaperTypeInfo_iud]
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
  DECLARE @OldPaperType NVARCHAR(30)
  DECLARE @PaperType NVARCHAR(30)
  DECLARE @PaperTypeName NVARCHAR(100)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_PaperTypeInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_PaperTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPaperType IS NULL THEN PaperType
							    ELSE OldPaperType
							END AS OldPaperType,
							PaperType,
							PaperTypeName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldPaperType NVARCHAR(30),
										PaperType NVARCHAR(30),
										PaperTypeName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PaperType = SourceTable.PaperType
				)

			WHEN MATCHED THEN
				UPDATE SET
					PaperType = SourceTable.PaperType,
					PaperTypeName = SourceTable.PaperTypeName,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						PaperType,
						PaperTypeName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PaperType,
							SourceTable.PaperTypeName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_PaperTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPaperType IS NULL THEN PaperType
							    ELSE OldPaperType
							END AS OldPaperType,
							PaperType,
							PaperTypeName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldPaperType NVARCHAR(30),
										PaperType NVARCHAR(30),
										PaperTypeName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PaperType = SourceTable.OldPaperType
				)

			WHEN MATCHED THEN
				UPDATE SET
					PaperType = SourceTable.PaperType,
					PaperTypeName = SourceTable.PaperTypeName,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						PaperType,
						PaperTypeName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PaperType,
							SourceTable.PaperTypeName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_PaperTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPaperType IS NULL THEN PaperType
							    ELSE OldPaperType
							END AS OldPaperType,
							PaperType,
							PaperTypeName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldPaperType NVARCHAR(30),
										PaperType NVARCHAR(30),
										PaperTypeName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PaperType = SourceTable.PaperType
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
									OldPaperType,
									PaperType,
									PaperTypeName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldPaperType NVARCHAR(30),
											 PaperType NVARCHAR(30),
											 PaperTypeName NVARCHAR(100),
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
										WHEN OldPaperType IS NULL THEN PaperType
										ELSE OldPaperType
									END AS OldPaperType,
									PaperType,
									PaperTypeName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldPaperType NVARCHAR(30),
											 PaperType NVARCHAR(30),
											 PaperTypeName NVARCHAR(100),
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
										WHEN OldPaperType IS NULL THEN PaperType
										ELSE OldPaperType
									END AS OldPaperType,
									PaperType,
									PaperTypeName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldPaperType NVARCHAR(30),
											 PaperType NVARCHAR(30),
											 PaperTypeName NVARCHAR(100),
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
								 @OldPaperType,
								 @PaperType,
								 @PaperTypeName,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PaperTypeInfo WHERE PaperType = @PaperType) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PaperType)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(PaperType)
						FROM
								STB_PaperTypeInfo 
						WHERE
								PaperType LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @PaperType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @PaperType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_PaperTypeInfo
						(
						    PaperType,
						    PaperTypeName,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @PaperType,
						    @PaperTypeName,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_PaperTypeInfo
						SET
						    PaperType =   CASE
						                WHEN @PaperType IS NOT NULL THEN @PaperType
						                ELSE PaperType
						            END,
						    PaperTypeName =   CASE
						                WHEN @PaperTypeName IS NOT NULL THEN @PaperTypeName
						                ELSE PaperTypeName
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    PaperType = @OldPaperType
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_PaperTypeInfo
						WHERE
						    PaperType = @PaperType
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

