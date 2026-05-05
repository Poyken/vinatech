-- Procedure: usp_LabelInfo_iud



-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-31
-- Browsable : true
-- Group : 라벨정보
-- Description:	라벨정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelInfo_iud]
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
  DECLARE @OldLabelType NVARCHAR(30)
  DECLARE @OldFormatName NVARCHAR(30)
  DECLARE @OldFormatVersion INT
  DECLARE @LabelType NVARCHAR(30)
  DECLARE @FormatName NVARCHAR(30)
  DECLARE @FormatVersion INT
  DECLARE @PaperType NVARCHAR(30)
  DECLARE @CommandType VARCHAR(20)
  DECLARE @Dpi VARCHAR(20)
  DECLARE @Format NVARCHAR(MAX)
  DECLARE @PartitionQty INT
  DECLARE @ProdSnType NVARCHAR(50)
  DECLARE @BarcodeModel VARCHAR(20)
  DECLARE @LabelImageFileID BIGINT
  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)
  DECLARE @ApplyDate DATE
  DECLARE @IsApproval BIT
  DECLARE @ApprovalUserID VARCHAR(20)
  DECLARE @ApprovalDatetime DATETIME
  DECLARE @LabelRemark NVARCHAR(MAX)
  DECLARE @DataSourceViewName VARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

   -- EXEC SmartFramework.dbo.usp_GetSerialRule 
			--@pTableName = 'STB_LabelInfo',
			--@pIsAutoKey = @IsAutoKey OUTPUT,
			--@pIsLoopIUD = @IsLoopIUD OUTPUT,
			--@pPrefixData = @PrefixString OUTPUT,
			--@pSerialLen = @SerialLen OUTPUT
	SET @IsAutoKey = 0
	SET @IsLoopIUD = 1
		
    

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldLabelType,
									OldFormatName,
									OldFormatVersion,
									LabelType,
									FormatName,
									FormatVersion,
									PaperType,
									CommandType,
									Dpi,
									Format,
									PartitionQty,
									ProdSnType,
									BarcodeModel,
									LabelImageFileID,
									ApplyDate,
									IsApproval,
									ApprovalUserID,
									ApprovalDatetime,
									LabelRemark,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DataSourceViewName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 OldFormatName NVARCHAR(30),
											 OldFormatVersion INT,
											 LabelType NVARCHAR(30),
											 FormatName NVARCHAR(30),
											 FormatVersion INT,
											 PaperType NVARCHAR(30),
											 CommandType VARCHAR(20),
											 Dpi VARCHAR(20),
											 Format NVARCHAR(MAX),
											 PartitionQty INT,
											 ProdSnType NVARCHAR(50),
											 BarcodeModel VARCHAR(20),
											 LabelImageFileID BIGINT,
											 ApplyDate DATETIMEOFFSET,
											 IsApproval BIT,
											 ApprovalUserID VARCHAR(20),
											 ApprovalDatetime DATETIMEOFFSET,
											 LabelRemark NVARCHAR(MAX),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 DataSourceViewName VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLabelType IS NULL THEN LabelType
										ELSE OldLabelType
									END AS OldLabelType,
									CASE 
										WHEN OldFormatName IS NULL THEN FormatName
										ELSE OldFormatName
									END AS OldFormatName,
									CASE 
										WHEN OldFormatVersion IS NULL THEN FormatVersion
										ELSE OldFormatVersion
									END AS OldFormatVersion,
									LabelType,
									FormatName,
									FormatVersion,
									PaperType,
									CommandType,
									Dpi,
									Format,
									PartitionQty,
									ProdSnType,
									BarcodeModel,
									LabelImageFileID,
									ApplyDate,
									IsApproval,
									ApprovalUserID,
									ApprovalDatetime,
									LabelRemark,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DataSourceViewName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 OldFormatName NVARCHAR(30),
											 OldFormatVersion INT,
											 LabelType NVARCHAR(30),
											 FormatName NVARCHAR(30),
											 FormatVersion INT,
											 PaperType NVARCHAR(30),
											 CommandType VARCHAR(20),
											 Dpi VARCHAR(20),
											 Format NVARCHAR(MAX),
											 PartitionQty INT,
											 ProdSnType NVARCHAR(50),
											 BarcodeModel VARCHAR(20),
											 LabelImageFileID BIGINT,
											 ApplyDate DATETIMEOFFSET,
											 IsApproval BIT,
											 ApprovalUserID VARCHAR(20),
											 ApprovalDatetime DATETIMEOFFSET,
											 LabelRemark NVARCHAR(MAX),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 DataSourceViewName VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLabelType IS NULL THEN LabelType
										ELSE OldLabelType
									END AS OldLabelType,
									CASE 
										WHEN OldFormatName IS NULL THEN FormatName
										ELSE OldFormatName
									END AS OldFormatName,
									CASE 
										WHEN OldFormatVersion IS NULL THEN FormatVersion
										ELSE OldFormatVersion
									END AS OldFormatVersion,
									LabelType,
									FormatName,
									FormatVersion,
									PaperType,
									CommandType,
									Dpi,
									Format,
									PartitionQty,
									ProdSnType,
									BarcodeModel,
									LabelImageFileID,
									ApplyDate,
									IsApproval,
									ApprovalUserID,
									ApprovalDatetime,
									LabelRemark,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DataSourceViewName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 OldFormatName NVARCHAR(30),
											 OldFormatVersion INT,
											 LabelType NVARCHAR(30),
											 FormatName NVARCHAR(30),
											 FormatVersion INT,
											 PaperType NVARCHAR(30),
											 CommandType VARCHAR(20),
											 Dpi VARCHAR(20),
											 Format NVARCHAR(MAX),
											 PartitionQty INT,
											 ProdSnType NVARCHAR(50),
											 BarcodeModel VARCHAR(20),
											 LabelImageFileID BIGINT,
											 ApplyDate DATETIMEOFFSET,
											 IsApproval BIT,
											 ApprovalUserID VARCHAR(20),
											 ApprovalDatetime DATETIMEOFFSET,
											 LabelRemark NVARCHAR(MAX),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 DataSourceViewName VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLabelType,
								 @OldFormatName,
								 @OldFormatVersion,
								 @LabelType,
								 @FormatName,
								 @FormatVersion,
								 @PaperType,
								 @CommandType,
								 @Dpi,
								 @Format,
								 @PartitionQty,
								 @ProdSnType,
								 @BarcodeModel,
								 @LabelImageFileID,
								 @ApplyDate,
								 @IsApproval,
								 @ApprovalUserID,
								 @ApprovalDatetime,
								 @LabelRemark,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @DataSourceViewName,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_LabelInfo WHERE LabelType = @LabelType AND FormatName = @FormatName AND FormatVersion = @FormatVersion) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s / %s / %d', 16, 1, @LabelType, @FormatName, @FormatVersion)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(LabelType)
						FROM
								STB_LabelInfo 
						WHERE
								LabelType LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @LabelType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @LabelType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

					EXEC usp_DoSaveFile 
							@pSystemName = 'STB_LabelInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @LabelImageFileID OUTPUT

                    INSERT INTO STB_LabelInfo
						(
						    LabelType,
						    FormatName,
						    FormatVersion,
						    PaperType,
						    CommandType,
						    Dpi,
						    Format,
							PartitionQty,
						    ProdSnType,
						    BarcodeModel,
						    LabelImageFileID,
						    ApplyDate,
						    IsApproval,
						    ApprovalUserID,
						    ApprovalDatetime,
						    LabelRemark,
							DataSourceViewName,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LabelType,
						    @FormatName,
						    @FormatVersion,
						    @PaperType,
						    @CommandType,
						    @Dpi,
						    @Format,
							@PartitionQty,
						    @ProdSnType,
						    @BarcodeModel,
						    @LabelImageFileID,
						    @ApplyDate,
						    @IsApproval,
						    @ApprovalUserID,
						    @ApprovalDatetime,
						    @LabelRemark,
							@DataSourceViewName,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					
					EXEC usp_DoSaveFile 
							@pSystemName = 'STB_LabelInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @LabelImageFileID OUTPUT
							
					--RAISERROR ('%s %s %s %s', 16, 1, @OldLabelType, @OldFormatName, @LabelType, @FormatName)
					--RETURN
                    UPDATE STB_LabelInfo
						SET
						    LabelType =   CASE
						                WHEN @LabelType IS NOT NULL THEN @LabelType
						                ELSE LabelType
						            END,
						    FormatName =   CASE
						                WHEN @FormatName IS NOT NULL THEN @FormatName
						                ELSE FormatName
						            END,
						    PaperType =   CASE
						                WHEN @PaperType IS NOT NULL THEN @PaperType
						                ELSE PaperType
						            END,
						    CommandType =   CASE
						                WHEN @CommandType IS NOT NULL THEN @CommandType
						                ELSE CommandType
						            END,
						    Dpi =   CASE
						                WHEN @Dpi IS NOT NULL THEN @Dpi
						                ELSE Dpi
						            END,
						    Format =   CASE
						                WHEN @Format IS NOT NULL THEN @Format
						                ELSE Format
						            END,
						    PartitionQty =   CASE
						                WHEN @PartitionQty IS NOT NULL THEN @PartitionQty
						                ELSE PartitionQty
						            END,
						    ProdSnType =   CASE
						                WHEN @ProdSnType IS NOT NULL THEN @ProdSnType
						                ELSE ProdSnType
						            END,
						    BarcodeModel =   CASE
						                WHEN @BarcodeModel IS NOT NULL THEN @BarcodeModel
						                ELSE BarcodeModel
						            END,
						    LabelImageFileID =   CASE
						                WHEN @LabelImageFileID IS NOT NULL THEN @LabelImageFileID
						                ELSE LabelImageFileID
						            END,
							DataSourceViewName =   CASE
						                WHEN @DataSourceViewName IS NOT NULL THEN @DataSourceViewName
						                ELSE DataSourceViewName
						            END,
						    ApplyDate =   ISNULL(@ApplyDate,ApplyDate),
						    IsApproval =   ISNULL(@IsApproval,IsApproval),
						    ApprovalUserID =   ISNULL(@ApprovalUserID,ApprovalUserID),
						    ApprovalDatetime =   ISNULL(@ApprovalDatetime,ApprovalDatetime),
						    LabelRemark =   ISNULL(@LabelRemark,LabelRemark),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    LabelType = @OldLabelType AND
						    FormatName = @OldFormatName AND
							FormatVersion = @OldFormatVersion
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
					WHERE
							FileID = @LabelImageFileID
				
				
                    DELETE FROM STB_LabelInfo
						WHERE
						    LabelType = @LabelType AND
						    FormatName = @FormatName AND
							FormatVersion = @OldFormatVersion
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



GO

