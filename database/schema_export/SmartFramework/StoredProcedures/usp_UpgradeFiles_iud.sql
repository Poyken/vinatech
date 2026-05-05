-- Procedure: usp_UpgradeFiles_iud


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2017-07-19
-- Browsable : true
-- Group : System
-- Description:	업그레이드 파일을 INSERT/UPDATE/DELETE 합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpgradeFiles_iud]
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
  DECLARE @OldProgramName NVARCHAR(50)
  DECLARE @OldFileName NVARCHAR(255)
  DECLARE @OldPlatform VARCHAR(10)
  DECLARE @ProgramName NVARCHAR(50)
  DECLARE @FileName NVARCHAR(255)
  DECLARE @Platform VARCHAR(10)
  DECLARE @Version INT
  DECLARE @FileData VARBINARY(MAX)
  DECLARE @TargetPath NVARCHAR(255)
  DECLARE @ExtractZip BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_UpgradeFiles',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_UpgradeFiles AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProgramName IS NULL THEN ProgramName
							    ELSE OldProgramName
							END AS OldProgramName,
							CASE
							    WHEN OldFileName IS NULL THEN FileName
							    ELSE OldFileName
							END AS OldFileName,
							CASE
							    WHEN OldPlatform IS NULL THEN Platform
							    ELSE OldPlatform
							END AS OldPlatform,
							ProgramName,
							FileName,
							Platform,
							Version,
							dbo.fnBase64ToBinary(FileData) as FileData,
							TargetPath,
							ExtractZip,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProgramName NVARCHAR(50),
										OldFileName NVARCHAR(255),
										OldPlatform VARCHAR(10),
										ProgramName NVARCHAR(50),
										FileName NVARCHAR(255),
										Platform VARCHAR(10),
										Version INT,
										FileData NVARCHAR(MAX),
										TargetPath NVARCHAR(255),
										ExtractZip BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProgramName = SourceTable.ProgramName AND
					TargetTable.FileName = SourceTable.FileName AND
					TargetTable.Platform = SourceTable.Platform
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProgramName = ISNULL(SourceTable.ProgramName,TargetTable.ProgramName),
					FileName = ISNULL(SourceTable.FileName,TargetTable.FileName),
					Platform = ISNULL(SourceTable.Platform,TargetTable.Platform),
					Version = ISNULL(SourceTable.Version,TargetTable.Version) + 1,
					FileData = ISNULL(SourceTable.FileData,TargetTable.FileData),
					TargetPath = ISNULL(SourceTable.TargetPath,TargetTable.TargetPath),
					ExtractZip = ISNULL(SourceTable.ExtractZip,TargetTable.ExtractZip),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProgramName,
						FileName,
						Platform,
						Version,
						FileData,
						TargetPath,
						ExtractZip,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProgramName,
							SourceTable.FileName,
							SourceTable.Platform,
							SourceTable.Version,
							SourceTable.FileData,
							SourceTable.TargetPath,
							SourceTable.ExtractZip,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_UpgradeFiles AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProgramName IS NULL THEN ProgramName
							    ELSE OldProgramName
							END AS OldProgramName,
							CASE
							    WHEN OldFileName IS NULL THEN FileName
							    ELSE OldFileName
							END AS OldFileName,
							CASE
							    WHEN OldPlatform IS NULL THEN Platform
							    ELSE OldPlatform
							END AS OldPlatform,
							ProgramName,
							FileName,
							Platform,
							Version,
							dbo.fnBase64ToBinary(FileData) as FileData,
							TargetPath,
							ExtractZip,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProgramName NVARCHAR(50),
										OldFileName NVARCHAR(255),
										OldPlatform VARCHAR(10),
										ProgramName NVARCHAR(50),
										FileName NVARCHAR(255),
										Platform VARCHAR(10),
										Version INT,
										FileData NVARCHAR(MAX),
										TargetPath NVARCHAR(255),
										ExtractZip BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProgramName = SourceTable.OldProgramName AND
					TargetTable.FileName = SourceTable.OldFileName AND
					TargetTable.Platform = SourceTable.OldPlatform
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProgramName = ISNULL(SourceTable.ProgramName,TargetTable.ProgramName),
					FileName = ISNULL(SourceTable.FileName,TargetTable.FileName),
					Platform = ISNULL(SourceTable.Platform,TargetTable.Platform),
					Version = ISNULL(SourceTable.Version,TargetTable.Version) + 1,
					FileData = ISNULL(SourceTable.FileData,TargetTable.FileData),
					TargetPath = ISNULL(SourceTable.TargetPath,TargetTable.TargetPath),
					ExtractZip = ISNULL(SourceTable.ExtractZip,TargetTable.ExtractZip),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProgramName,
						FileName,
						Platform,
						Version,
						FileData,
						TargetPath,
						ExtractZip,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProgramName,
							SourceTable.FileName,
							SourceTable.Platform,
							SourceTable.Version,
							SourceTable.FileData,
							SourceTable.TargetPath,
							SourceTable.ExtractZip,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_UpgradeFiles AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProgramName IS NULL THEN ProgramName
							    ELSE OldProgramName
							END AS OldProgramName,
							CASE
							    WHEN OldFileName IS NULL THEN FileName
							    ELSE OldFileName
							END AS OldFileName,
							CASE
							    WHEN OldPlatform IS NULL THEN Platform
							    ELSE OldPlatform
							END AS OldPlatform,
							ProgramName,
							FileName,
							Platform,
							Version,
							dbo.fnBase64ToBinary(FileData) as FileData,
							TargetPath,
							ExtractZip,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProgramName NVARCHAR(50),
										OldFileName NVARCHAR(255),
										OldPlatform VARCHAR(10),
										ProgramName NVARCHAR(50),
										FileName NVARCHAR(255),
										Platform VARCHAR(10),
										Version INT,
										FileData NVARCHAR(MAX),
										TargetPath NVARCHAR(255),
										ExtractZip BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProgramName = SourceTable.ProgramName AND
					TargetTable.FileName = SourceTable.FileName AND
					TargetTable.Platform = SourceTable.Platform
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
									OldProgramName,
									OldFileName,
									OldPlatform,
									ProgramName,
									FileName,
									Platform,
									Version,
									dbo.fnBase64ToBinary(FileData) as FileData,
									TargetPath,
									ExtractZip,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProgramName NVARCHAR(50),
											 OldFileName NVARCHAR(255),
											 OldPlatform VARCHAR(10),
											 ProgramName NVARCHAR(50),
											 FileName NVARCHAR(255),
											 Platform VARCHAR(10),
											 Version INT,
											 FileData NVARCHAR(MAX),
											 TargetPath NVARCHAR(255),
											 ExtractZip BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProgramName IS NULL THEN ProgramName
										ELSE OldProgramName
									END AS OldProgramName,
									CASE 
										WHEN OldFileName IS NULL THEN FileName
										ELSE OldFileName
									END AS OldFileName,
									CASE 
										WHEN OldPlatform IS NULL THEN Platform
										ELSE OldPlatform
									END AS OldPlatform,
									ProgramName,
									FileName,
									Platform,
									Version,
									dbo.fnBase64ToBinary(FileData) as FileData,
									TargetPath,
									ExtractZip,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProgramName NVARCHAR(50),
											 OldFileName NVARCHAR(255),
											 OldPlatform VARCHAR(10),
											 ProgramName NVARCHAR(50),
											 FileName NVARCHAR(255),
											 Platform VARCHAR(10),
											 Version INT,
											 FileData NVARCHAR(MAX),
											 TargetPath NVARCHAR(255),
											 ExtractZip BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProgramName IS NULL THEN ProgramName
										ELSE OldProgramName
									END AS OldProgramName,
									CASE 
										WHEN OldFileName IS NULL THEN FileName
										ELSE OldFileName
									END AS OldFileName,
									CASE 
										WHEN OldPlatform IS NULL THEN Platform
										ELSE OldPlatform
									END AS OldPlatform,
									ProgramName,
									FileName,
									Platform,
									Version,
									dbo.fnBase64ToBinary(FileData) as FileData,
									TargetPath,
									ExtractZip,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProgramName NVARCHAR(50),
											 OldFileName NVARCHAR(255),
											 OldPlatform VARCHAR(10),
											 ProgramName NVARCHAR(50),
											 FileName NVARCHAR(255),
											 Platform VARCHAR(10),
											 Version INT,
											 FileData NVARCHAR(MAX),
											 TargetPath NVARCHAR(255),
											 ExtractZip BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProgramName,
								 @OldFileName,
								 @OldPlatform,
								 @ProgramName,
								 @FileName,
								 @Platform,
								 @Version,
								 @FileData,
								 @TargetPath,
								 @ExtractZip,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_UpgradeFiles WHERE ProgramName = @ProgramName AND FileName = @FileName AND Platform = @Platform) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProgramName)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(ProgramName)
						FROM
								STB_UpgradeFiles 
						WHERE
								ProgramName LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @ProgramName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @ProgramName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_UpgradeFiles
						(
						    ProgramName,
						    FileName,
						    Platform,
						    Version,
						    FileData,
						    TargetPath,
						    ExtractZip,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ProgramName,
						    @FileName,
						    @Platform,
						    @Version,
						    @FileData,
						    @TargetPath,
						    @ExtractZip,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_UpgradeFiles
						SET
						    ProgramName =   ISNULL(@ProgramName,ProgramName),
						    FileName =   ISNULL(@FileName,FileName),
						    Platform =   ISNULL(@Platform,Platform),
						    Version =   ISNULL(@Version,Version) + 1,
						    FileData =   ISNULL(@FileData,FileData),
						    TargetPath =   ISNULL(@TargetPath,TargetPath),
						    ExtractZip =   ISNULL(@ExtractZip,ExtractZip),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ProgramName = @OldProgramName AND
						    FileName = @OldFileName AND
						    Platform = @OldPlatform
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_UpgradeFiles
						WHERE
						    ProgramName = @ProgramName AND
						    FileName = @FileName AND
						    Platform = @Platform
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

