-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-16
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_MainCustomerTrends_iud
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
  DECLARE @OldMainCustomerTrendsNo VARCHAR(20)
  DECLARE @MainCustomerTrendsNo VARCHAR(20)
  DECLARE @BaseDate DATE
  DECLARE @CustomerName NVARCHAR(100)
  DECLARE @ContactWorkerName NVARCHAR(100)
  DECLARE @StockPrice NUMERIC(20,4)
  DECLARE @SalesPrice NUMERIC(20,4)
  DECLARE @InternetIssue NVARCHAR(MAX)
  DECLARE @HomepageIssue NVARCHAR(MAX)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MainCustomerTrends',
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
									OldMainCustomerTrendsNo,
									MainCustomerTrendsNo,
									BaseDate,
									CustomerName,
									ContactWorkerName,
									StockPrice,
									SalesPrice,
									InternetIssue,
									HomepageIssue,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMainCustomerTrendsNo VARCHAR(20),
											 MainCustomerTrendsNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CustomerName NVARCHAR(100),
											 ContactWorkerName NVARCHAR(100),
											 StockPrice NUMERIC(20,4),
											 SalesPrice NUMERIC(20,4),
											 InternetIssue NVARCHAR(MAX),
											 HomepageIssue NVARCHAR(MAX),
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
										WHEN OldMainCustomerTrendsNo IS NULL THEN MainCustomerTrendsNo
										ELSE OldMainCustomerTrendsNo
									END AS OldMainCustomerTrendsNo,
									MainCustomerTrendsNo,
									BaseDate,
									CustomerName,
									ContactWorkerName,
									StockPrice,
									SalesPrice,
									InternetIssue,
									HomepageIssue,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMainCustomerTrendsNo VARCHAR(20),
											 MainCustomerTrendsNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CustomerName NVARCHAR(100),
											 ContactWorkerName NVARCHAR(100),
											 StockPrice NUMERIC(20,4),
											 SalesPrice NUMERIC(20,4),
											 InternetIssue NVARCHAR(MAX),
											 HomepageIssue NVARCHAR(MAX),
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
										WHEN OldMainCustomerTrendsNo IS NULL THEN MainCustomerTrendsNo
										ELSE OldMainCustomerTrendsNo
									END AS OldMainCustomerTrendsNo,
									MainCustomerTrendsNo,
									BaseDate,
									CustomerName,
									ContactWorkerName,
									StockPrice,
									SalesPrice,
									InternetIssue,
									HomepageIssue,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMainCustomerTrendsNo VARCHAR(20),
											 MainCustomerTrendsNo VARCHAR(20),
											 BaseDate DATETIMEOFFSET,
											 CustomerName NVARCHAR(100),
											 ContactWorkerName NVARCHAR(100),
											 StockPrice NUMERIC(20,4),
											 SalesPrice NUMERIC(20,4),
											 InternetIssue NVARCHAR(MAX),
											 HomepageIssue NVARCHAR(MAX),
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
								 @OldMainCustomerTrendsNo,
								 @MainCustomerTrendsNo,
								 @BaseDate,
								 @CustomerName,
								 @ContactWorkerName,
								 @StockPrice,
								 @SalesPrice,
								 @InternetIssue,
								 @HomepageIssue,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MainCustomerTrends WHERE MainCustomerTrendsNo = @MainCustomerTrendsNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MainCustomerTrendsNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MainCustomerTrends',@MainCustomerTrendsNo OUTPUT
                    END

                    INSERT INTO STB_MainCustomerTrends
						(
						    MainCustomerTrendsNo,
						    BaseDate,
						    CustomerName,
						    ContactWorkerName,
						    StockPrice,
						    SalesPrice,
						    InternetIssue,
						    HomepageIssue,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MainCustomerTrendsNo,
						    @BaseDate,
						    @CustomerName,
						    @ContactWorkerName,
						    @StockPrice,
						    @SalesPrice,
						    @InternetIssue,
						    @HomepageIssue,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MainCustomerTrends
						SET
						    MainCustomerTrendsNo =   ISNULL(@MainCustomerTrendsNo,MainCustomerTrendsNo),
						    BaseDate =   ISNULL(@BaseDate,BaseDate),
						    CustomerName =   ISNULL(@CustomerName,CustomerName),
						    ContactWorkerName =   ISNULL(@ContactWorkerName,ContactWorkerName),
						    StockPrice =   ISNULL(@StockPrice,StockPrice),
						    SalesPrice =   ISNULL(@SalesPrice,SalesPrice),
						    InternetIssue =   ISNULL(@InternetIssue,InternetIssue),
						    HomepageIssue =   ISNULL(@HomepageIssue,HomepageIssue),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MainCustomerTrendsNo = @OldMainCustomerTrendsNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MainCustomerTrends
						WHERE
						    MainCustomerTrendsNo = @OldMainCustomerTrendsNo
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
