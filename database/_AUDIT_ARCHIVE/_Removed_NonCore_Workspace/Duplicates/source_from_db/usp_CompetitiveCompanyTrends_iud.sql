-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-16
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_CompetitiveCompanyTrends_iud
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
  DECLARE @OldCompetitiveCompanyTrendsNo VARCHAR(20)
  DECLARE @CompetitiveCompanyTrendsNo VARCHAR(20)
  DECLARE @BaseDate DATE
  DECLARE @CompetitiveCompanyCode VARCHAR(20)
  DECLARE @InternetIssue NVARCHAR(MAX)
  DECLARE @HomepageIssue NVARCHAR(MAX)
  DECLARE @MainCustomers NVARCHAR(MAX)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @ContactWorkerName NVARCHAR(100)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_CompetitiveCompanyTrends',
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
									OldCompetitiveCompanyTrendsNo,
									CompetitiveCompanyTrendsNo,
									BaseDate,
									CompetitiveCompanyCode,
									InternetIssue,
									HomepageIssue,
									MainCustomers,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ContactWorkerName
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompetitiveCompanyTrendsNo VARCHAR(20),
											 CompetitiveCompanyTrendsNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CompetitiveCompanyCode VARCHAR(20),
											 InternetIssue NVARCHAR(MAX),
											 HomepageIssue NVARCHAR(MAX),
											 MainCustomers NVARCHAR(MAX),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ContactWorkerName NVARCHAR(100)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCompetitiveCompanyTrendsNo IS NULL THEN CompetitiveCompanyTrendsNo
										ELSE OldCompetitiveCompanyTrendsNo
									END AS OldCompetitiveCompanyTrendsNo,
									CompetitiveCompanyTrendsNo,
									BaseDate,
									CompetitiveCompanyCode,
									InternetIssue,
									HomepageIssue,
									MainCustomers,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ContactWorkerName
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompetitiveCompanyTrendsNo VARCHAR(20),
											 CompetitiveCompanyTrendsNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CompetitiveCompanyCode VARCHAR(20),
											 InternetIssue NVARCHAR(MAX),
											 HomepageIssue NVARCHAR(MAX),
											 MainCustomers NVARCHAR(MAX),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ContactWorkerName NVARCHAR(100)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCompetitiveCompanyTrendsNo IS NULL THEN CompetitiveCompanyTrendsNo
										ELSE OldCompetitiveCompanyTrendsNo
									END AS OldCompetitiveCompanyTrendsNo,
									CompetitiveCompanyTrendsNo,
									BaseDate,
									CompetitiveCompanyCode,
									InternetIssue,
									HomepageIssue,
									MainCustomers,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ContactWorkerName
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompetitiveCompanyTrendsNo VARCHAR(20),
											 CompetitiveCompanyTrendsNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CompetitiveCompanyCode VARCHAR(20),
											 InternetIssue NVARCHAR(MAX),
											 HomepageIssue NVARCHAR(MAX),
											 MainCustomers NVARCHAR(MAX),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ContactWorkerName NVARCHAR(100)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompetitiveCompanyTrendsNo,
								 @CompetitiveCompanyTrendsNo,
								 @BaseDate,
								 @CompetitiveCompanyCode,
								 @InternetIssue,
								 @HomepageIssue,
								 @MainCustomers,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @ContactWorkerName


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CompetitiveCompanyTrends WHERE CompetitiveCompanyTrendsNo = @CompetitiveCompanyTrendsNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CompetitiveCompanyTrendsNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_CompetitiveCompanyTrends',@CompetitiveCompanyTrendsNo OUTPUT
                    END

                    INSERT INTO STB_CompetitiveCompanyTrends
						(
						    CompetitiveCompanyTrendsNo,
						    BaseDate,
						    CompetitiveCompanyCode,
						    InternetIssue,
						    HomepageIssue,
						    MainCustomers,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							ContactWorkerName
						)
						VALUES
						(
						    @CompetitiveCompanyTrendsNo,
						    @BaseDate,
						    @CompetitiveCompanyCode,
						    @InternetIssue,
						    @HomepageIssue,
						    @MainCustomers,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@ContactWorkerName
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CompetitiveCompanyTrends
						SET
						    CompetitiveCompanyTrendsNo =   ISNULL(@CompetitiveCompanyTrendsNo,CompetitiveCompanyTrendsNo),
						    BaseDate =   ISNULL(@BaseDate,BaseDate),
						    CompetitiveCompanyCode =   ISNULL(@CompetitiveCompanyCode,CompetitiveCompanyCode),
						    InternetIssue =   ISNULL(@InternetIssue,InternetIssue),
						    HomepageIssue =   ISNULL(@HomepageIssue,HomepageIssue),
						    MainCustomers =   ISNULL(@MainCustomers,MainCustomers),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							ContactWorkerName = @ContactWorkerName
						WHERE
						    CompetitiveCompanyTrendsNo = @OldCompetitiveCompanyTrendsNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CompetitiveCompanyTrends
						WHERE
						    CompetitiveCompanyTrendsNo = @OldCompetitiveCompanyTrendsNo
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