-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-20
-- Browsable : true
-- Group : 금형관리
-- Description:	금형문제점개선시트 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldImprovementSheet_iud]
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
    DECLARE @AllTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldImproveHistNo VARCHAR(20)
  DECLARE @ImproveHistNo VARCHAR(20)
  DECLARE @MoldNumber VARCHAR(50)
  DECLARE @MoldSeqNo VARCHAR(10)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @ImprovementStep VARCHAR(1)
  DECLARE @ImprovementType VARCHAR(100)
  DECLARE @MoldType VARCHAR(1)
  DECLARE @MoldGrade VARCHAR(1)
  DECLARE @MoldRoute VARCHAR(1)
  DECLARE @RegistDate DATE
  DECLARE @CompleteDate DATE
  DECLARE @DocFileID BIGINT
  DECLARE @FileData VARBINARY(MAX)
  DECLARE @DocFileName NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldImprovementSheet',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
   BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				
				
				SELECT
                        'ALL' AS IUD_FLAG,
									OldImproveHistNo,
									ImproveHistNo,
									MoldNumber,
									MoldSeqNo,
									WorkCenterCode,
									ImprovementStep,
									ImprovementType,
									MoldType,
									MoldGrade,
									MoldRoute,
									RegistDate,
									CompleteDate,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @AllTableName , 2)
							        WITH  (
											 OldImproveHistNo VARCHAR(20),
											 ImproveHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MoldSeqNo VARCHAR(10),
											 WorkCenterCode VARCHAR(20),
											 ImprovementStep VARCHAR(1),
											 ImprovementType VARCHAR(100),
											 MoldType VARCHAR(1),
											 MoldGrade VARCHAR(1),
											 MoldRoute VARCHAR(1),
											 RegistDate DATETIMEOFFSET,
											 CompleteDate DATETIMEOFFSET,
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
				UNION ALL
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldImproveHistNo,
									ImproveHistNo,
									MoldNumber,
									MoldSeqNo,
									WorkCenterCode,
									ImprovementStep,
									ImprovementType,
									MoldType,
									MoldGrade,
									MoldRoute,
									RegistDate,
									CompleteDate,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldImproveHistNo VARCHAR(20),
											 ImproveHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MoldSeqNo VARCHAR(10),
											 WorkCenterCode VARCHAR(20),
											 ImprovementStep VARCHAR(1),
											 ImprovementType VARCHAR(100),
											 MoldType VARCHAR(1),
											 MoldGrade VARCHAR(1),
											 MoldRoute VARCHAR(1),
											 RegistDate DATETIMEOFFSET,
											 CompleteDate DATETIMEOFFSET,
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldImproveHistNo IS NULL THEN ImproveHistNo
										ELSE OldImproveHistNo
									END AS OldImproveHistNo,
									ImproveHistNo,
									MoldNumber,
									MoldSeqNo,
									WorkCenterCode,
									ImprovementStep,
									ImprovementType,
									MoldType,
									MoldGrade,
									MoldRoute,
									RegistDate,
									CompleteDate,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldImproveHistNo VARCHAR(20),
											 ImproveHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MoldSeqNo VARCHAR(10),
											 WorkCenterCode VARCHAR(20),
											 ImprovementStep VARCHAR(1),
											 ImprovementType VARCHAR(100),
											 MoldType VARCHAR(1),
											 MoldGrade VARCHAR(1),
											 MoldRoute VARCHAR(1),
											 RegistDate DATETIMEOFFSET,
											 CompleteDate DATETIMEOFFSET,
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldImproveHistNo IS NULL THEN ImproveHistNo
										ELSE OldImproveHistNo
									END AS OldImproveHistNo,
									ImproveHistNo,
									MoldNumber,
									MoldSeqNo,
									WorkCenterCode,
									ImprovementStep,
									ImprovementType,
									MoldType,
									MoldGrade,
									MoldRoute,
									RegistDate,
									CompleteDate,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldImproveHistNo VARCHAR(20),
											 ImproveHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 MoldSeqNo VARCHAR(10),
											 WorkCenterCode VARCHAR(20),
											 ImprovementStep VARCHAR(1),
											 ImprovementType VARCHAR(100),
											 MoldType VARCHAR(1),
											 MoldGrade VARCHAR(1),
											 MoldRoute VARCHAR(1),
											 RegistDate DATETIMEOFFSET,
											 CompleteDate DATETIMEOFFSET,
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldImproveHistNo,
								 @ImproveHistNo,
								 @MoldNumber,
								 @MoldSeqNo,
								 @WorkCenterCode,
								 @ImprovementStep,
								 @ImprovementType,
								 @MoldType,
								 @MoldGrade,
								 @MoldRoute,
								 @RegistDate,
								 @CompleteDate,
								 @FileData,
								 @DocFileID,
								 @DocFileName,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'ALL' BEGIN
				
					EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldImprovementSheet',
							@pFileContents = @FileData,
							@pFileName = NULL,
							@pFileSize = NULL,
							@pUserID = @ProcessUserID,
							@pFileID = @DocFileID OUTPUT
					
					
					
					UPDATE STB_MoldImprovementSheet
					SET
						    ImproveHistNo =   CASE
						                WHEN @ImproveHistNo IS NOT NULL THEN @ImproveHistNo
						                ELSE ImproveHistNo
						            END,
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    MoldSeqNo =   CASE
						                WHEN @MoldSeqNo IS NOT NULL THEN @MoldSeqNo
						                ELSE MoldSeqNo
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    ImprovementStep =   CASE
						                WHEN @ImprovementStep IS NOT NULL THEN @ImprovementStep
						                ELSE ImprovementStep
						            END,
						    ImprovementType =   CASE
						                WHEN @ImprovementType IS NOT NULL THEN @ImprovementType
						                ELSE ImprovementType
						            END,
						    MoldType =   CASE
						                WHEN @MoldType IS NOT NULL THEN @MoldType
						                ELSE MoldType
						            END,
						    MoldGrade =   CASE
						                WHEN @MoldGrade IS NOT NULL THEN @MoldGrade
						                ELSE MoldGrade
						            END,
						    MoldRoute =   CASE
						                WHEN @MoldRoute IS NOT NULL THEN @MoldRoute
						                ELSE MoldRoute
						            END,
						    RegistDate =   CASE
						                WHEN @RegistDate IS NOT NULL THEN @RegistDate
						                ELSE RegistDate
						            END,
						    CompleteDate =   CASE
						                WHEN @CompleteDate IS NOT NULL THEN @CompleteDate
						                ELSE CompleteDate
						            END,
						    DocFileID =   CASE
						                WHEN @DocFileID IS NOT NULL THEN @DocFileID
						                ELSE DocFileID
						            END,
						    DocFileName =   CASE
						                WHEN @DocFileName IS NOT NULL THEN @DocFileName
						                ELSE DocFileName
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
						    ImproveHistNo = @OldImproveHistNo
							
					
				
                END ELSE IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldImprovementSheet WHERE ImproveHistNo = @ImproveHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ImproveHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldImprovementSheet',
																	@ImproveHistNo OUTPUT
                    END
                    
                    --MoldSeqNo 생성
					SELECT
							@MoldSeqNo = CONVERT(VARCHAR(10),MAX(MIS.MoldSeqNo))
					FROM
							STB_MoldImprovementSheet MIS
					WHERE
							MIS.MoldNumber = @MoldNumber
					
					IF @MoldSeqNo IS NULL BEGIN
						SET @MoldSeqNo = '1'
					END
					ELSE BEGIN
						SET @MoldSeqNo = CONVERT(VARCHAR(10),CONVERT(INT,@MoldSeqNo) + 1)
					END
					

                    INSERT INTO STB_MoldImprovementSheet
						(
						    ImproveHistNo,
						    MoldNumber,
						    MoldSeqNo,
						    WorkCenterCode,
						    ImprovementStep,
						    ImprovementType,
						    MoldType,
						    MoldGrade,
						    MoldRoute,
						    RegistDate,
						    CompleteDate,
						    DocFileID,
						    DocFileName,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ImproveHistNo,
						    @MoldNumber,
						    @MoldSeqNo,
						    @WorkCenterCode,
						    @ImprovementStep,
						    @ImprovementType,
						    @MoldType,
						    @MoldGrade,
						    @MoldRoute,
						    @RegistDate,
						    @CompleteDate,
						    @DocFileID,
						    @DocFileName,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldImprovementSheet
						SET
						    ImproveHistNo =   CASE
						                WHEN @ImproveHistNo IS NOT NULL THEN @ImproveHistNo
						                ELSE ImproveHistNo
						            END,
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    MoldSeqNo =   CASE
						                WHEN @MoldSeqNo IS NOT NULL THEN @MoldSeqNo
						                ELSE MoldSeqNo
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    ImprovementStep =   CASE
						                WHEN @ImprovementStep IS NOT NULL THEN @ImprovementStep
						                ELSE ImprovementStep
						            END,
						    ImprovementType =   CASE
						                WHEN @ImprovementType IS NOT NULL THEN @ImprovementType
						                ELSE ImprovementType
						            END,
						    MoldType =   CASE
						                WHEN @MoldType IS NOT NULL THEN @MoldType
						                ELSE MoldType
						            END,
						    MoldGrade =   CASE
						                WHEN @MoldGrade IS NOT NULL THEN @MoldGrade
						                ELSE MoldGrade
						            END,
						    MoldRoute =   CASE
						                WHEN @MoldRoute IS NOT NULL THEN @MoldRoute
						                ELSE MoldRoute
						            END,
						    RegistDate =   CASE
						                WHEN @RegistDate IS NOT NULL THEN @RegistDate
						                ELSE RegistDate
						            END,
						    CompleteDate =   CASE
						                WHEN @CompleteDate IS NOT NULL THEN @CompleteDate
						                ELSE CompleteDate
						            END,
						    DocFileID =   CASE
						                WHEN @DocFileID IS NOT NULL THEN @DocFileID
						                ELSE DocFileID
						            END,
						    DocFileName =   CASE
						                WHEN @DocFileName IS NOT NULL THEN @DocFileName
						                ELSE DocFileName
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
						    ImproveHistNo = @OldImproveHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldImprovementSheet
						WHERE
						    ImproveHistNo = @ImproveHistNo
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

