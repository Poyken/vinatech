-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-22
-- Browsable : true
-- Group : 생산관리
-- Description:	작업표준서 정보 저장
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_WorkStandardDocInfo_iud
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
  DECLARE @OldWorkStandardDocNo VARCHAR(20)
  DECLARE @WorkStandardDocNo VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @DocFileNo INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  --FileUpload 관련 변수 추가 
  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_WorkStandardDocInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldWorkStandardDocNo,
									WorkStandardDocNo,
									LineCode,
									MachineCode,
									DocFileNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData)
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldWorkStandardDocNo VARCHAR(20),
											 WorkStandardDocNo VARCHAR(20),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DocFileNo INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldWorkStandardDocNo IS NULL THEN WorkStandardDocNo
										ELSE OldWorkStandardDocNo
									END AS OldWorkStandardDocNo,
									WorkStandardDocNo,
									LineCode,
									MachineCode,
									DocFileNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData)
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldWorkStandardDocNo VARCHAR(20),
											 WorkStandardDocNo VARCHAR(20),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DocFileNo INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldWorkStandardDocNo IS NULL THEN WorkStandardDocNo
										ELSE OldWorkStandardDocNo
									END AS OldWorkStandardDocNo,
									WorkStandardDocNo,
									LineCode,
									MachineCode,
									DocFileNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData)
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldWorkStandardDocNo VARCHAR(20),
											 WorkStandardDocNo VARCHAR(20),
											 LineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DocFileNo INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldWorkStandardDocNo,
								 @WorkStandardDocNo,
								 @LineCode,
								 @MachineCode,
								 @DocFileNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @FileName,
								 @FileSize,
								 @FileData


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_WorkStandardDocInfo WHERE WorkStandardDocNo = @WorkStandardDocNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @WorkStandardDocNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_WorkStandardDocInfo',@WorkStandardDocNo OUTPUT
                    END

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_WorkStandardDocInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @DocFileNo OUTPUT

                    INSERT INTO STB_WorkStandardDocInfo
						(
						    WorkStandardDocNo,
						    LineCode,
						    MachineCode,
						    DocFileNo,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @WorkStandardDocNo,
						    @LineCode,
						    @MachineCode,
						    @DocFileNo,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_WorkStandardDocInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @DocFileNo OUTPUT

                    UPDATE STB_WorkStandardDocInfo
						SET
						    LineCode =   ISNULL(@LineCode,LineCode),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    DocFileNo =   ISNULL(@DocFileNo,DocFileNo),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    WorkStandardDocNo = @OldWorkStandardDocNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_WorkStandardDocInfo
						WHERE
						    WorkStandardDocNo = @OldWorkStandardDocNo
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