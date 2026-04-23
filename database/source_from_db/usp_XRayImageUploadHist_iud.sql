-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-07-09
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_XRayImageUploadHist_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pSystemName VARCHAR(100) = 'STB_XRayImageUploadHist'
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
  DECLARE @OldXRayImageUploadHistNo VARCHAR(20)
  DECLARE @XRayImageUploadHistNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @XRayImageFileID INT
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
			@pTableName = 'STB_XRayImageUploadHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        PRINT '1'
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldXRayImageUploadHistNo,
									XRayImageUploadHistNo,
									CompanyCode,
									WorkCenterCode,
									Barcode,
									XRayImageFileID,
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
											 OldXRayImageUploadHistNo VARCHAR(20),
											 XRayImageUploadHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 Barcode VARCHAR(20),
											 XRayImageFileID INT,
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
										WHEN OldXRayImageUploadHistNo IS NULL THEN XRayImageUploadHistNo
										ELSE OldXRayImageUploadHistNo
									END AS OldXRayImageUploadHistNo,
									XRayImageUploadHistNo,
									CompanyCode,
									WorkCenterCode,
									Barcode,
									XRayImageFileID,
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
											 OldXRayImageUploadHistNo VARCHAR(20),
											 XRayImageUploadHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 Barcode VARCHAR(20),
											 XRayImageFileID INT,
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
										WHEN OldXRayImageUploadHistNo IS NULL THEN XRayImageUploadHistNo
										ELSE OldXRayImageUploadHistNo
									END AS OldXRayImageUploadHistNo,
									XRayImageUploadHistNo,
									CompanyCode,
									WorkCenterCode,
									Barcode,
									XRayImageFileID,
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
											 OldXRayImageUploadHistNo VARCHAR(20),
											 XRayImageUploadHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 Barcode VARCHAR(20),
											 XRayImageFileID INT,
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
								 @OldXRayImageUploadHistNo,
								 @XRayImageUploadHistNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @Barcode,
								 @XRayImageFileID,
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

                    IF EXISTS (SELECT 1 FROM STB_XRayImageUploadHist WHERE XRayImageUploadHistNo = @XRayImageUploadHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @XRayImageUploadHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_XRayImageUploadHist',@XRayImageUploadHistNo OUTPUT
                    END

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = @pSystemName,
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @XRayImageFileID OUTPUT

					--Barcode Update
					UPDATE SmartFramework_File.dbo.STB_AttachedFileMaster
					   SET Barcode = @Barcode
					 WHERE FileID = @XRayImageFileID

                    INSERT INTO STB_XRayImageUploadHist
						(
						    XRayImageUploadHistNo,
						    CompanyCode,
						    WorkCenterCode,
						    Barcode,
						    XRayImageFileID,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @XRayImageUploadHistNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @Barcode,
						    @XRayImageFileID,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = @pSystemName,
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @XRayImageFileID OUTPUT

					--Barcode Update
					UPDATE SmartFramework_File.dbo.STB_AttachedFileMaster
					   SET Barcode = @Barcode
					 WHERE FileID = @XRayImageFileID

                    UPDATE STB_XRayImageUploadHist
						SET
						    XRayImageUploadHistNo =   ISNULL(@XRayImageUploadHistNo,XRayImageUploadHistNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    XRayImageFileID =   ISNULL(@XRayImageFileID,XRayImageFileID),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    XRayImageUploadHistNo = @OldXRayImageUploadHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_XRayImageUploadHist
						WHERE
						    XRayImageUploadHistNo = @OldXRayImageUploadHistNo
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