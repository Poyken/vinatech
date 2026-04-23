-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형체크시트마스터 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldCheckSheetMaster_iud]
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
  DECLARE @OldMoldCheckSheetCode VARCHAR(20)
  DECLARE @MoldCheckSheetCode VARCHAR(20)
  DECLARE @MoldCheckTypeCode VARCHAR(20)
  DECLARE @MoldCheckSheetName NVARCHAR(100)
  DECLARE @CheckDesc NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  
  DECLARE @MoldImage BIGINT
  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldCheckSheetMaster',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldCheckSheetMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
							    ELSE XMLData.OldMoldCheckSheetCode
							END AS OldMoldCheckSheetCode,
							XMLData.MoldCheckSheetCode,
							XMLData.MoldCheckTypeCode,
							XMLData.MoldCheckSheetName,
							dbo.fnBase64ToBinary(XMLData.MoldImage) as MoldImage,
							XMLData.CheckDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldCheckSheetCode VARCHAR(20),
										MoldCheckSheetCode VARCHAR(20),
										MoldCheckTypeCode VARCHAR(20),
										MoldCheckSheetName NVARCHAR(100),
										MoldImage BIGINT,
										CheckDesc NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckSheetCode = SourceTable.MoldCheckSheetCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldCheckSheetCode = SourceTable.MoldCheckSheetCode,
					MoldCheckTypeCode = SourceTable.MoldCheckTypeCode,
					MoldCheckSheetName = SourceTable.MoldCheckSheetName,
					MoldImage = SourceTable.MoldImage,
					CheckDesc = SourceTable.CheckDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldCheckSheetCode,
						MoldCheckTypeCode,
						MoldCheckSheetName,
						MoldImage,
						CheckDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldCheckSheetCode,
							SourceTable.MoldCheckTypeCode,
							SourceTable.MoldCheckSheetName,
							SourceTable.MoldImage,
							SourceTable.CheckDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldCheckSheetMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
							    ELSE XMLData.OldMoldCheckSheetCode
							END AS OldMoldCheckSheetCode,
							XMLData.MoldCheckSheetCode,
							XMLData.MoldCheckTypeCode,
							XMLData.MoldCheckSheetName,
							dbo.fnBase64ToBinary(XMLData.MoldImage) as MoldImage,
							XMLData.CheckDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldCheckSheetCode VARCHAR(20),
										MoldCheckSheetCode VARCHAR(20),
										MoldCheckTypeCode VARCHAR(20),
										MoldCheckSheetName NVARCHAR(100),
										MoldImage BIGINT,
										CheckDesc NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckSheetCode = SourceTable.OldMoldCheckSheetCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldCheckSheetCode = SourceTable.MoldCheckSheetCode,
					MoldCheckTypeCode = SourceTable.MoldCheckTypeCode,
					MoldCheckSheetName = SourceTable.MoldCheckSheetName,
					MoldImage = SourceTable.MoldImage,
					CheckDesc = SourceTable.CheckDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldCheckSheetCode,
						MoldCheckTypeCode,
						MoldCheckSheetName,
						MoldImage,
						CheckDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldCheckSheetCode,
							SourceTable.MoldCheckTypeCode,
							SourceTable.MoldCheckSheetName,
							SourceTable.MoldImage,
							SourceTable.CheckDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
			
			MERGE STB_MoldCheckSheetItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
							    ELSE XMLData.OldMoldCheckSheetCode
							END AS OldMoldCheckSheetCode,
							XMLData.MoldCheckSheetCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldCheckSheetCode VARCHAR(20),
										MoldCheckSheetCode VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckSheetCode = SourceTable.MoldCheckSheetCode
				)

			WHEN MATCHED THEN
				DELETE;

			
			
            MERGE STB_MoldCheckSheetMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
							    ELSE XMLData.OldMoldCheckSheetCode
							END AS OldMoldCheckSheetCode,
							XMLData.MoldCheckSheetCode,
							XMLData.MoldCheckTypeCode,
							XMLData.MoldCheckSheetName,
							dbo.fnBase64ToBinary(XMLData.MoldImage) as MoldImage,
							XMLData.CheckDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldCheckSheetCode VARCHAR(20),
										MoldCheckSheetCode VARCHAR(20),
										MoldCheckTypeCode VARCHAR(20),
										MoldCheckSheetName NVARCHAR(100),
										MoldImage BIGINT,
										CheckDesc NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckSheetCode = SourceTable.MoldCheckSheetCode
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
									XMLData.OldMoldCheckSheetCode,
									XMLData.MoldCheckSheetCode,
									XMLData.MoldCheckTypeCode,
									XMLData.MoldCheckSheetName,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.MoldImage,
									XMLData.CheckDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldCheckSheetCode VARCHAR(20),
											 MoldCheckSheetCode VARCHAR(20),
											 MoldCheckTypeCode VARCHAR(20),
											 MoldCheckSheetName NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 MoldImage BIGINT,
											 CheckDesc NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
										ELSE XMLData.OldMoldCheckSheetCode
									END AS OldMoldCheckSheetCode,
									XMLData.MoldCheckSheetCode,
									XMLData.MoldCheckTypeCode,
									XMLData.MoldCheckSheetName,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.MoldImage,
									XMLData.CheckDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldCheckSheetCode VARCHAR(20),
											 MoldCheckSheetCode VARCHAR(20),
											 MoldCheckTypeCode VARCHAR(20),
											 MoldCheckSheetName NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 MoldImage BIGINT,
											 CheckDesc NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
										ELSE XMLData.OldMoldCheckSheetCode
									END AS OldMoldCheckSheetCode,
									XMLData.MoldCheckSheetCode,
									XMLData.MoldCheckTypeCode,
									XMLData.MoldCheckSheetName,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.MoldImage,
									XMLData.CheckDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldCheckSheetCode VARCHAR(20),
											 MoldCheckSheetCode VARCHAR(20),
											 MoldCheckTypeCode VARCHAR(20),
											 MoldCheckSheetName NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 MoldImage BIGINT,
											 CheckDesc NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldCheckSheetCode,
								 @MoldCheckSheetCode,
								 @MoldCheckTypeCode,
								 @MoldCheckSheetName,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @MoldImage,
								 @CheckDesc,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldCheckSheetMaster WHERE MoldCheckSheetCode = @MoldCheckSheetCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldCheckSheetCode)
					END

                    IF @IsAutoKey = 1 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldCheckSheetMaster',
																	@MoldCheckSheetCode OUTPUT
                    END
                    
                    EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldCheckSheetMaster',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @MoldImage OUTPUT

                    INSERT INTO STB_MoldCheckSheetMaster
						(
						    MoldCheckSheetCode,
						    MoldCheckTypeCode,
						    MoldCheckSheetName,
						    MoldImage,
						    CheckDesc,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldCheckSheetCode,
						    @MoldCheckTypeCode,
						    @MoldCheckSheetName,
						    @MoldImage,
						    @CheckDesc,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldCheckSheetMaster',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @MoldImage OUTPUT

					
					
                    UPDATE STB_MoldCheckSheetMaster
						SET
						    MoldCheckSheetCode =   CASE
						                WHEN @MoldCheckSheetCode IS NOT NULL THEN @MoldCheckSheetCode
						                ELSE MoldCheckSheetCode
						            END,
						    MoldCheckTypeCode =   CASE
						                WHEN @MoldCheckTypeCode IS NOT NULL THEN @MoldCheckTypeCode
						                ELSE MoldCheckTypeCode
						            END,
						    MoldCheckSheetName =   CASE
						                WHEN @MoldCheckSheetName IS NOT NULL THEN @MoldCheckSheetName
						                ELSE MoldCheckSheetName
						            END,
						    MoldImage =   CASE
						                WHEN @MoldImage IS NOT NULL THEN @MoldImage
						                ELSE MoldImage
						            END,
						    CheckDesc =   CASE
						                WHEN @CheckDesc IS NOT NULL THEN @CheckDesc
						                ELSE CheckDesc
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
						    MoldCheckSheetCode = @OldMoldCheckSheetCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
					WHERE
							FileID = @MoldImage
					
					DELETE FROM STB_MoldCheckSheetItem
					WHERE
							MoldCheckSheetCode = @MoldCheckSheetCode
					
					
                    DELETE FROM STB_MoldCheckSheetMaster
					WHERE
						    MoldCheckSheetCode = @MoldCheckSheetCode
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



