
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-15
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_CompetitiveCompanySpec_iud
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
  DECLARE @OldCompetitiveCompanySpecNo VARCHAR(20)
  DECLARE @CompetitiveCompanySpecNo VARCHAR(20)
  DECLARE @BaseDate DATE
  DECLARE @CompetitiveCompanyCode VARCHAR(20)
  DECLARE @ProductSize VARCHAR(10)
  DECLARE @ProductSpec VARCHAR(20)
  DECLARE @ProductType VARCHAR(20)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CompetitiveCompanySpec',
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
									OldCompetitiveCompanySpecNo,
									CompetitiveCompanySpecNo,
									BaseDate,
									CompetitiveCompanyCode,
									ProductSize,
									ProductSpec,
									ProductType,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompetitiveCompanySpecNo VARCHAR(20),
											 CompetitiveCompanySpecNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CompetitiveCompanyCode VARCHAR(20),
											 ProductSize VARCHAR(10),
											 ProductSpec VARCHAR(20),
											 ProductType VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCompetitiveCompanySpecNo IS NULL THEN CompetitiveCompanySpecNo
										ELSE OldCompetitiveCompanySpecNo
									END AS OldCompetitiveCompanySpecNo,
									CompetitiveCompanySpecNo,
									BaseDate,
									CompetitiveCompanyCode,
									ProductSize,
									ProductSpec,
									ProductType,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompetitiveCompanySpecNo VARCHAR(20),
											 CompetitiveCompanySpecNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CompetitiveCompanyCode VARCHAR(20),
											 ProductSize VARCHAR(10),
											 ProductSpec VARCHAR(20),
											 ProductType VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCompetitiveCompanySpecNo IS NULL THEN CompetitiveCompanySpecNo
										ELSE OldCompetitiveCompanySpecNo
									END AS OldCompetitiveCompanySpecNo,
									CompetitiveCompanySpecNo,
									BaseDate,
									CompetitiveCompanyCode,
									ProductSize,
									ProductSpec,
									ProductType,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompetitiveCompanySpecNo VARCHAR(20),
											 CompetitiveCompanySpecNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CompetitiveCompanyCode VARCHAR(20),
											 ProductSize VARCHAR(10),
											 ProductSpec VARCHAR(20),
											 ProductType VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompetitiveCompanySpecNo,
								 @CompetitiveCompanySpecNo,
								 @BaseDate,
								 @CompetitiveCompanyCode,
								 @ProductSize,
								 @ProductSpec,
								 @ProductType,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CompetitiveCompanySpec WHERE CompetitiveCompanySpecNo = @CompetitiveCompanySpecNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CompetitiveCompanySpecNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_CompetitiveCompanySpec',@CompetitiveCompanySpecNo OUTPUT
                    END

                    INSERT INTO STB_CompetitiveCompanySpec
						(
						    CompetitiveCompanySpecNo,
						    BaseDate,
						    CompetitiveCompanyCode,
						    ProductSize,
						    ProductSpec,
						    ProductType,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CompetitiveCompanySpecNo,
						    @BaseDate,
						    @CompetitiveCompanyCode,
						    @ProductSize,
						    @ProductSpec,
						    @ProductType,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CompetitiveCompanySpec
						SET
						    CompetitiveCompanySpecNo =   ISNULL(@CompetitiveCompanySpecNo,CompetitiveCompanySpecNo),
						    BaseDate =   ISNULL(@BaseDate,BaseDate),
						    CompetitiveCompanyCode =   ISNULL(@CompetitiveCompanyCode,CompetitiveCompanyCode),
						    ProductSize =   ISNULL(@ProductSize,ProductSize),
						    ProductSpec =   ISNULL(@ProductSpec,ProductSpec),
						    ProductType =   ISNULL(@ProductType,ProductType),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CompetitiveCompanySpecNo = @OldCompetitiveCompanySpecNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CompetitiveCompanySpec
						WHERE
						    CompetitiveCompanySpecNo = @OldCompetitiveCompanySpecNo
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
