


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-30
-- Browsable : true
-- Group : 금형관리
-- Description:	금형 타각 이미지관리 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMarkHistory_iud]
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
  DECLARE @OldMoldMarkHistNo VARCHAR(20)
  DECLARE @MoldMarkHistNo VARCHAR(20)
  DECLARE @MoldNumber VARCHAR(50)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @BasicDate DATE
  
  DECLARE @FileID BIGINT
  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)
  
  DECLARE @DescText VARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldMarkHistory',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldMarkHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMoldMarkHistNo IS NULL THEN MoldMarkHistNo
							    ELSE OldMoldMarkHistNo
							END AS OldMoldMarkHistNo,
							MoldMarkHistNo,
							MoldNumber,
							CompanyCode,
							WorkCenterCode,
							BasicDate,
							--FileID,
							dbo.fnBase64ToBinary(FileID) as FileID,
							DescText,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldMarkHistNo VARCHAR(20),
										MoldMarkHistNo VARCHAR(20),
										MoldNumber VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										FileID BIGINT,
										DescText VARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MoldMarkHistNo = SourceTable.MoldMarkHistNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldMarkHistNo = SourceTable.MoldMarkHistNo,
					MoldNumber = SourceTable.MoldNumber,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					BasicDate = SourceTable.BasicDate,
					FileID = SourceTable.FileID,
					DescText = SourceTable.DescText,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldMarkHistNo,
						MoldNumber,
						CompanyCode,
						WorkCenterCode,
						BasicDate,
						FileID,
						DescText,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldMarkHistNo,
							SourceTable.MoldNumber,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicDate,
							SourceTable.FileID,
							SourceTable.DescText,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldMarkHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMoldMarkHistNo IS NULL THEN MoldMarkHistNo
							    ELSE OldMoldMarkHistNo
							END AS OldMoldMarkHistNo,
							MoldMarkHistNo,
							MoldNumber,
							CompanyCode,
							WorkCenterCode,
							BasicDate,
							--FileID,
							dbo.fnBase64ToBinary(FileID) as FileID,
							DescText,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldMarkHistNo VARCHAR(20),
										MoldMarkHistNo VARCHAR(20),
										MoldNumber VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										FileID BIGINT,
										DescText VARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MoldMarkHistNo = SourceTable.OldMoldMarkHistNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldMarkHistNo = SourceTable.MoldMarkHistNo,
					MoldNumber = SourceTable.MoldNumber,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					BasicDate = SourceTable.BasicDate,
					FileID = SourceTable.FileID,
					DescText = SourceTable.DescText,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldMarkHistNo,
						MoldNumber,
						CompanyCode,
						WorkCenterCode,
						BasicDate,
						FileID,
						DescText,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldMarkHistNo,
							SourceTable.MoldNumber,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicDate,
							SourceTable.FileID,
							SourceTable.DescText,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldMarkHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMoldMarkHistNo IS NULL THEN MoldMarkHistNo
							    ELSE OldMoldMarkHistNo
							END AS OldMoldMarkHistNo,
							MoldMarkHistNo,
							MoldNumber,
							CompanyCode,
							WorkCenterCode,
							BasicDate,
							--FileID,
							dbo.fnBase64ToBinary(FileID) as FileID,
							DescText,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldMarkHistNo VARCHAR(20),
										MoldMarkHistNo VARCHAR(20),
										MoldNumber VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										FileID BIGINT,
										DescText VARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MoldMarkHistNo = SourceTable.MoldMarkHistNo
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
									OldMoldMarkHistNo,
									MoldMarkHistNo,
									MoldNumber,
									CompanyCode,
									WorkCenterCode,
									BasicDate,
									
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									FileID,
									
									DescText,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldMarkHistNo VARCHAR(20),
											 MoldMarkHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 FileID BIGINT,
											 DescText VARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMoldMarkHistNo IS NULL THEN MoldMarkHistNo
										ELSE OldMoldMarkHistNo
									END AS OldMoldMarkHistNo,
									MoldMarkHistNo,
									MoldNumber,
									CompanyCode,
									WorkCenterCode,
									BasicDate,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									FileID,
									DescText,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldMarkHistNo VARCHAR(20),
											 MoldMarkHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),	
											 FileID BIGINT,
											 DescText VARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMoldMarkHistNo IS NULL THEN MoldMarkHistNo
										ELSE OldMoldMarkHistNo
									END AS OldMoldMarkHistNo,
									MoldMarkHistNo,
									MoldNumber,
									CompanyCode,
									WorkCenterCode,
									BasicDate,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									FileID,
									DescText,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldMarkHistNo VARCHAR(20),
											 MoldMarkHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),	
											 FileID BIGINT,
											 DescText VARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldMarkHistNo,
								 @MoldMarkHistNo,
								 @MoldNumber,
								 @CompanyCode,
								 @WorkCenterCode,
								 @BasicDate,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @FileID,
								 @DescText,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
					
					
					
                    IF EXISTS (SELECT 1 FROM STB_MoldMarkHistory WHERE MoldMarkHistNo = @MoldMarkHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldMarkHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldMarkHistory',
																	@MoldMarkHistNo OUTPUT
                    END
                    
                    EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldMarkHistory',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @FileID OUTPUT

                    INSERT INTO STB_MoldMarkHistory
						(
						    MoldMarkHistNo,
						    MoldNumber,
						    CompanyCode,
						    WorkCenterCode,
						    BasicDate,
						    FileID,
						    DescText,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldMarkHistNo,
						    @MoldNumber,
						    @CompanyCode,
						    @WorkCenterCode,
						    @BasicDate,
						    @FileID,
						    @DescText,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldMarkHistory',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @FileID OUTPUT	
					
					
                    UPDATE STB_MoldMarkHistory
						SET
						    MoldMarkHistNo =   CASE
						                WHEN @MoldMarkHistNo IS NOT NULL THEN @MoldMarkHistNo
						                ELSE MoldMarkHistNo
						            END,
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    BasicDate =   CASE
						                WHEN @BasicDate IS NOT NULL THEN @BasicDate
						                ELSE BasicDate
						            END,
						    FileID =   CASE
						                WHEN @FileID IS NOT NULL THEN @FileID
						                ELSE FileID
						            END,
						    DescText =   CASE
						                WHEN @DescText IS NOT NULL THEN @DescText
						                ELSE DescText
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
						    MoldMarkHistNo = @OldMoldMarkHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
					WHERE
							FileID = @FileID
					
					
                    DELETE FROM STB_MoldMarkHistory
						WHERE
						    MoldMarkHistNo = @MoldMarkHistNo
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



