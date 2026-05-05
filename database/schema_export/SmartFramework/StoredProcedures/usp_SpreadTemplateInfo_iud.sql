-- Procedure: usp_SpreadTemplateInfo_iud







-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-16
-- Browsable : true
-- Group : 시스템
-- Description:	Spread 템플릿용 데이터를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpreadTemplateInfo_iud]
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
  DECLARE @OldTemplateName NVARCHAR(100)
  DECLARE @TemplateName NVARCHAR(100)
  DECLARE @TemplateDescription NVARCHAR(MAX)
  DECLARE @FileID BIGINT
  DECLARE @FileName VARCHAR(255)
  DECLARE @FileExt VARCHAR(20)
  DECLARE @FileSize BIGINT
  DECLARE @FileContents VARBINARY(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SpreadTemplateInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
		
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE SmartFramework_File.dbo.STB_SpreadTemplateInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldTemplateName IS NULL THEN XMLData.TemplateName
							    ELSE XMLData.OldTemplateName
							END AS OldTemplateName,
							XMLData.TemplateName,
							XMLData.TemplateDescription,
							XMLData.FileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldTemplateName NVARCHAR(100),
										TemplateName NVARCHAR(100),
										TemplateDescription NVARCHAR(MAX),
										FileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.TemplateName = SourceTable.TemplateName
				)

			WHEN MATCHED THEN
				UPDATE SET
					TemplateName = SourceTable.TemplateName,
					TemplateDescription = SourceTable.TemplateDescription,
					FileID = SourceTable.FileID,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						TemplateName,
						TemplateDescription,
						FileID,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.TemplateName,
							SourceTable.TemplateDescription,
							SourceTable.FileID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE SmartFramework_File.dbo.STB_SpreadTemplateInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldTemplateName IS NULL THEN XMLData.TemplateName
							    ELSE XMLData.OldTemplateName
							END AS OldTemplateName,
							XMLData.TemplateName,
							XMLData.TemplateDescription,
							XMLData.FileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldTemplateName NVARCHAR(100),
										TemplateName NVARCHAR(100),
										TemplateDescription NVARCHAR(MAX),
										FileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.TemplateName = SourceTable.OldTemplateName
				)

			WHEN MATCHED THEN
				UPDATE SET
					TemplateName = SourceTable.TemplateName,
					TemplateDescription = SourceTable.TemplateDescription,
					FileID = SourceTable.FileID,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						TemplateName,
						TemplateDescription,
						FileID,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.TemplateName,
							SourceTable.TemplateDescription,
							SourceTable.FileID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE SmartFramework_File.dbo.STB_SpreadTemplateInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldTemplateName IS NULL THEN XMLData.TemplateName
							    ELSE XMLData.OldTemplateName
							END AS OldTemplateName,
							XMLData.TemplateName,
							XMLData.TemplateDescription,
							XMLData.FileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldTemplateName NVARCHAR(100),
										TemplateName NVARCHAR(100),
										TemplateDescription NVARCHAR(MAX),
										FileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.TemplateName = SourceTable.TemplateName
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
									XMLData.OldTemplateName,
									XMLData.TemplateName,
									XMLData.TemplateDescription,
									XMLData.FileID,
									XMLData.FileName,
									XMLData.FileExt,
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileContents) AS FileContents,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldTemplateName NVARCHAR(100),
											 TemplateName NVARCHAR(100),
											 TemplateDescription NVARCHAR(MAX),
											 FileID BIGINT,
											 FileName NVARCHAR(255),
											 FileExt VARCHAR(20),
											 FileSize BIGINT,
											 FileContents VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldTemplateName IS NULL THEN XMLData.TemplateName
										ELSE XMLData.OldTemplateName
									END AS OldTemplateName,
									XMLData.TemplateName,
									XMLData.TemplateDescription,
									XMLData.FileID,
									XMLData.FileName,
									XMLData.FileExt,
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileContents) AS FileContents,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldTemplateName NVARCHAR(100),
											 TemplateName NVARCHAR(100),
											 TemplateDescription NVARCHAR(MAX),
											 FileID BIGINT,
											 FileName NVARCHAR(255),
											 FileExt VARCHAR(20),
											 FileSize BIGINT,
											 FileContents VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldTemplateName IS NULL THEN XMLData.TemplateName
										ELSE XMLData.OldTemplateName
									END AS OldTemplateName,
									XMLData.TemplateName,
									XMLData.TemplateDescription,
									XMLData.FileID,
									XMLData.FileName,
									XMLData.FileExt,
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileContents) AS FileContents,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldTemplateName NVARCHAR(100),
											 TemplateName NVARCHAR(100),
											 TemplateDescription NVARCHAR(MAX),
											 FileID BIGINT,
											 FileName NVARCHAR(255),
											 FileExt VARCHAR(20),
											 FileSize BIGINT,
											 FileContents VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldTemplateName,
								 @TemplateName,
								 @TemplateDescription,
								 @FileID,
								 @FileName,
								 @FileExt,
								 @FileSize,
								 @FileContents,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				
				
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM SmartFramework_File.dbo.STB_SpreadTemplateInfo WHERE TemplateName = @TemplateName) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @TemplateName)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(TemplateName)
						FROM
								SmartFramework_File.dbo.STB_SpreadTemplateInfo 
						WHERE
								TemplateName LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @TemplateName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @TemplateName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END
                    
                    
                    
                    EXEC usp_DoSaveFile 
						@pSystemName = 'SPREAD TEMPLATE',
						@pFileContents = @FileContents,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @pProcessUserID,
						@pFileID = @FileID OUTPUT

                    INSERT INTO SmartFramework_File.dbo.STB_SpreadTemplateInfo
						(
						    TemplateName,
						    TemplateDescription,
						    FileID,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @TemplateName,
						    @TemplateDescription,
						    @FileID,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    EXEC usp_DoSaveFile 
						@pSystemName = 'SPREAD TEMPLATE',
						@pFileContents = @FileContents,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @pProcessUserID,
						@pFileID = @FileID OUTPUT
										
				
                    UPDATE SmartFramework_File.dbo.STB_SpreadTemplateInfo
						SET
						    TemplateName =   CASE
						                WHEN @TemplateName IS NOT NULL THEN @TemplateName
						                ELSE TemplateName
						            END,
						    TemplateDescription =   CASE
						                WHEN @TemplateDescription IS NOT NULL THEN @TemplateDescription
						                ELSE TemplateDescription
						            END,
						    FileID =   CASE
						                WHEN @FileID IS NOT NULL THEN @FileID
						                ELSE FileID
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
						    TemplateName = @OldTemplateName
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
					WHERE
							FileID = @FileID
					
                    DELETE FROM SmartFramework_File.dbo.STB_SpreadTemplateInfo
						WHERE
						    TemplateName = @TemplateName
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

