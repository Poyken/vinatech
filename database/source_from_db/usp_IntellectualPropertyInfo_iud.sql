-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-04-01
-- Browsable : true
-- Group : 인사관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_IntellectualPropertyInfo_iud
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
  DECLARE @OldIntellectualPropertyNo VARCHAR(20)
  DECLARE @IntellectualPropertyNo VARCHAR(20)
  DECLARE @IsDomestic BIT
  DECLARE @NationCode VARCHAR(20)
  DECLARE @InventionName NVARCHAR(500)
  DECLARE @ApplicationNo VARCHAR(30)
  DECLARE @TechnologyClass VARCHAR(20)
  DECLARE @TechnologyDetailClass VARCHAR(20)
  DECLARE @IsCore BIT
  DECLARE @ApplicationDate DATE
  DECLARE @RegistrationNo VARCHAR(20)
  DECLARE @RegistrationDate DATE
  DECLARE @PatentStatus NVARCHAR(20)
  DECLARE @LegalStatus NVARCHAR(20)
  DECLARE @ApplicationOwner NVARCHAR(50)
  DECLARE @InventorNames NVARCHAR(100)
  DECLARE @RightStatus NVARCHAR(50)
  DECLARE @ClaimNumber INT
  DECLARE @ExaminationProgressStatus NVARCHAR(50)
  DECLARE @ExtinctionReason NVARCHAR(50)
  DECLARE @PublicNo VARCHAR(20)
  DECLARE @PublicDate DATE
  DECLARE @SurvivalExpirationDate DATE
  DECLARE @PublicRegistrationNo VARCHAR(20)
  DECLARE @PublicRegistrationDate DATE
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_IntellectualPropertyInfo',
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
									OldIntellectualPropertyNo,
									IntellectualPropertyNo,
									IsDomestic,
									NationCode,
									InventionName,
									ApplicationNo,
									TechnologyClass,
									TechnologyDetailClass,
									IsCore,
									ApplicationDate,
									RegistrationNo,
									RegistrationDate,
									PatentStatus,
									LegalStatus,
									ApplicationOwner,
									InventorNames,
									RightStatus,
									ClaimNumber,
									ExaminationProgressStatus,
									ExtinctionReason,
									PublicNo,
									PublicDate,
									SurvivalExpirationDate,
									PublicRegistrationNo,
									PublicRegistrationDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldIntellectualPropertyNo VARCHAR(20),
											 IntellectualPropertyNo VARCHAR(20),
											 IsDomestic BIT,
											 NationCode VARCHAR(20),
											 InventionName NVARCHAR(500),
											 ApplicationNo VARCHAR(30),
											 TechnologyClass VARCHAR(20),
											 TechnologyDetailClass VARCHAR(20),
											 IsCore BIT,
											 ApplicationDate DATETIMEOFFSET,
											 RegistrationNo VARCHAR(20),
											 RegistrationDate DATETIMEOFFSET,
											 PatentStatus NVARCHAR(20),
											 LegalStatus NVARCHAR(20),
											 ApplicationOwner NVARCHAR(50),
											 InventorNames NVARCHAR(100),
											 RightStatus NVARCHAR(50),
											 ClaimNumber INT,
											 ExaminationProgressStatus NVARCHAR(50),
											 ExtinctionReason NVARCHAR(50),
											 PublicNo VARCHAR(20),
											 PublicDate DATETIMEOFFSET,
											 SurvivalExpirationDate DATETIMEOFFSET,
											 PublicRegistrationNo VARCHAR(20),
											 PublicRegistrationDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldIntellectualPropertyNo IS NULL THEN IntellectualPropertyNo
										ELSE OldIntellectualPropertyNo
									END AS OldIntellectualPropertyNo,
									IntellectualPropertyNo,
									IsDomestic,
									NationCode,
									InventionName,
									ApplicationNo,
									TechnologyClass,
									TechnologyDetailClass,
									IsCore,
									ApplicationDate,
									RegistrationNo,
									RegistrationDate,
									PatentStatus,
									LegalStatus,
									ApplicationOwner,
									InventorNames,
									RightStatus,
									ClaimNumber,
									ExaminationProgressStatus,
									ExtinctionReason,
									PublicNo,
									PublicDate,
									SurvivalExpirationDate,
									PublicRegistrationNo,
									PublicRegistrationDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldIntellectualPropertyNo VARCHAR(20),
											 IntellectualPropertyNo VARCHAR(20),
											 IsDomestic BIT,
											 NationCode VARCHAR(20),
											 InventionName NVARCHAR(500),
											 ApplicationNo VARCHAR(30),
											 TechnologyClass VARCHAR(20),
											 TechnologyDetailClass VARCHAR(20),
											 IsCore BIT,
											 ApplicationDate DATETIMEOFFSET,
											 RegistrationNo VARCHAR(20),
											 RegistrationDate DATETIMEOFFSET,
											 PatentStatus NVARCHAR(20),
											 LegalStatus NVARCHAR(20),
											 ApplicationOwner NVARCHAR(50),
											 InventorNames NVARCHAR(100),
											 RightStatus NVARCHAR(50),
											 ClaimNumber INT,
											 ExaminationProgressStatus NVARCHAR(50),
											 ExtinctionReason NVARCHAR(50),
											 PublicNo VARCHAR(20),
											 PublicDate DATETIMEOFFSET,
											 SurvivalExpirationDate DATETIMEOFFSET,
											 PublicRegistrationNo VARCHAR(20),
											 PublicRegistrationDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldIntellectualPropertyNo IS NULL THEN IntellectualPropertyNo
										ELSE OldIntellectualPropertyNo
									END AS OldIntellectualPropertyNo,
									IntellectualPropertyNo,
									IsDomestic,
									NationCode,
									InventionName,
									ApplicationNo,
									TechnologyClass,
									TechnologyDetailClass,
									IsCore,
									ApplicationDate,
									RegistrationNo,
									RegistrationDate,
									PatentStatus,
									LegalStatus,
									ApplicationOwner,
									InventorNames,
									RightStatus,
									ClaimNumber,
									ExaminationProgressStatus,
									ExtinctionReason,
									PublicNo,
									PublicDate,
									SurvivalExpirationDate,
									PublicRegistrationNo,
									PublicRegistrationDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldIntellectualPropertyNo VARCHAR(20),
											 IntellectualPropertyNo VARCHAR(20),
											 IsDomestic BIT,
											 NationCode VARCHAR(20),
											 InventionName NVARCHAR(500),
											 ApplicationNo VARCHAR(30),
											 TechnologyClass VARCHAR(20),
											 TechnologyDetailClass VARCHAR(20),
											 IsCore BIT,
											 ApplicationDate DATETIMEOFFSET,
											 RegistrationNo VARCHAR(20),
											 RegistrationDate DATETIMEOFFSET,
											 PatentStatus NVARCHAR(20),
											 LegalStatus NVARCHAR(20),
											 ApplicationOwner NVARCHAR(50),
											 InventorNames NVARCHAR(100),
											 RightStatus NVARCHAR(50),
											 ClaimNumber INT,
											 ExaminationProgressStatus NVARCHAR(50),
											 ExtinctionReason NVARCHAR(50),
											 PublicNo VARCHAR(20),
											 PublicDate DATETIMEOFFSET,
											 SurvivalExpirationDate DATETIMEOFFSET,
											 PublicRegistrationNo VARCHAR(20),
											 PublicRegistrationDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldIntellectualPropertyNo,
								 @IntellectualPropertyNo,
								 @IsDomestic,
								 @NationCode,
								 @InventionName,
								 @ApplicationNo,
								 @TechnologyClass,
								 @TechnologyDetailClass,
								 @IsCore,
								 @ApplicationDate,
								 @RegistrationNo,
								 @RegistrationDate,
								 @PatentStatus,
								 @LegalStatus,
								 @ApplicationOwner,
								 @InventorNames,
								 @RightStatus,
								 @ClaimNumber,
								 @ExaminationProgressStatus,
								 @ExtinctionReason,
								 @PublicNo,
								 @PublicDate,
								 @SurvivalExpirationDate,
								 @PublicRegistrationNo,
								 @PublicRegistrationDate,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_IntellectualPropertyInfo WHERE IntellectualPropertyNo = @IntellectualPropertyNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @IntellectualPropertyNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_IntellectualPropertyInfo',@IntellectualPropertyNo OUTPUT
                    END

                    INSERT INTO STB_IntellectualPropertyInfo
						(
						    IntellectualPropertyNo,
						    IsDomestic,
						    NationCode,
						    InventionName,
						    ApplicationNo,
						    TechnologyClass,
						    TechnologyDetailClass,
						    IsCore,
						    ApplicationDate,
						    RegistrationNo,
						    RegistrationDate,
						    PatentStatus,
						    LegalStatus,
						    ApplicationOwner,
						    InventorNames,
						    RightStatus,
						    ClaimNumber,
						    ExaminationProgressStatus,
						    ExtinctionReason,
						    PublicNo,
						    PublicDate,
						    SurvivalExpirationDate,
						    PublicRegistrationNo,
						    PublicRegistrationDate,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @IntellectualPropertyNo,
						    @IsDomestic,
						    @NationCode,
						    @InventionName,
						    @ApplicationNo,
						    @TechnologyClass,
						    @TechnologyDetailClass,
						    @IsCore,
						    @ApplicationDate,
						    @RegistrationNo,
						    @RegistrationDate,
						    @PatentStatus,
						    @LegalStatus,
						    @ApplicationOwner,
						    @InventorNames,
						    @RightStatus,
						    @ClaimNumber,
						    @ExaminationProgressStatus,
						    @ExtinctionReason,
						    @PublicNo,
						    @PublicDate,
						    @SurvivalExpirationDate,
						    @PublicRegistrationNo,
						    @PublicRegistrationDate,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_IntellectualPropertyInfo
						SET
						    IsDomestic =   ISNULL(@IsDomestic,IsDomestic),
						    NationCode =   ISNULL(@NationCode,NationCode),
						    InventionName =   ISNULL(@InventionName,InventionName),
						    ApplicationNo =   ISNULL(@ApplicationNo,ApplicationNo),
						    TechnologyClass =   ISNULL(@TechnologyClass,TechnologyClass),
						    TechnologyDetailClass =   ISNULL(@TechnologyDetailClass,TechnologyDetailClass),
						    IsCore =   ISNULL(@IsCore,IsCore),
						    ApplicationDate =   ISNULL(@ApplicationDate,ApplicationDate),
						    RegistrationNo =   ISNULL(@RegistrationNo,RegistrationNo),
						    RegistrationDate =   ISNULL(@RegistrationDate,RegistrationDate),
						    PatentStatus =   ISNULL(@PatentStatus,PatentStatus),
						    LegalStatus =   ISNULL(@LegalStatus,LegalStatus),
						    ApplicationOwner =   ISNULL(@ApplicationOwner,ApplicationOwner),
						    InventorNames =   ISNULL(@InventorNames,InventorNames),
						    RightStatus =   ISNULL(@RightStatus,RightStatus),
						    ClaimNumber =   ISNULL(@ClaimNumber,ClaimNumber),
						    ExaminationProgressStatus =   ISNULL(@ExaminationProgressStatus,ExaminationProgressStatus),
						    ExtinctionReason =   ISNULL(@ExtinctionReason,ExtinctionReason),
						    PublicNo =   ISNULL(@PublicNo,PublicNo),
						    PublicDate =   ISNULL(@PublicDate,PublicDate),
						    SurvivalExpirationDate =   ISNULL(@SurvivalExpirationDate,SurvivalExpirationDate),
						    PublicRegistrationNo =   ISNULL(@PublicRegistrationNo,PublicRegistrationNo),
						    PublicRegistrationDate =   ISNULL(@PublicRegistrationDate,PublicRegistrationDate),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    IntellectualPropertyNo = @OldIntellectualPropertyNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_IntellectualPropertyInfo
						WHERE
						    IntellectualPropertyNo = @OldIntellectualPropertyNo
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
