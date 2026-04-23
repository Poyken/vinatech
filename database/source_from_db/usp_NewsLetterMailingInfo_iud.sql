
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_NewsLetterMailingInfo_iud]
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
  DECLARE @OldNewsLetterMailingNo VARCHAR(20)
  DECLARE @NewsLetterMailingNo VARCHAR(20)
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @PersonName VARCHAR(100)
  DECLARE @Email VARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_NewsLetterMailingInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_NewsLetterMailingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNewsLetterMailingNo IS NULL THEN NewsLetterMailingNo
							    ELSE OldNewsLetterMailingNo
							END AS OldNewsLetterMailingNo,
							NewsLetterMailingNo,
							CustomerCode,
							PersonName,
							Email,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldNewsLetterMailingNo VARCHAR(20),
										NewsLetterMailingNo VARCHAR(20),
										CustomerCode VARCHAR(20),
										PersonName VARCHAR(100),
										Email VARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NewsLetterMailingNo = SourceTable.NewsLetterMailingNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					PersonName = ISNULL(SourceTable.PersonName,TargetTable.PersonName),
					Email = ISNULL(SourceTable.Email,TargetTable.Email),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						NewsLetterMailingNo,
						CustomerCode,
						PersonName,
						Email,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.NewsLetterMailingNo,
							SourceTable.CustomerCode,
							SourceTable.PersonName,
							SourceTable.Email,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_NewsLetterMailingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNewsLetterMailingNo IS NULL THEN NewsLetterMailingNo
							    ELSE OldNewsLetterMailingNo
							END AS OldNewsLetterMailingNo,
							NewsLetterMailingNo,
							CustomerCode,
							PersonName,
							Email,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldNewsLetterMailingNo VARCHAR(20),
										NewsLetterMailingNo VARCHAR(20),
										CustomerCode VARCHAR(20),
										PersonName VARCHAR(100),
										Email VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NewsLetterMailingNo = SourceTable.OldNewsLetterMailingNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					PersonName = ISNULL(SourceTable.PersonName,TargetTable.PersonName),
					Email = ISNULL(SourceTable.Email,TargetTable.Email),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						NewsLetterMailingNo,
						CustomerCode,
						PersonName,
						Email,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.NewsLetterMailingNo,
							SourceTable.CustomerCode,
							SourceTable.PersonName,
							SourceTable.Email,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_NewsLetterMailingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNewsLetterMailingNo IS NULL THEN NewsLetterMailingNo
							    ELSE OldNewsLetterMailingNo
							END AS OldNewsLetterMailingNo,
							NewsLetterMailingNo,
							CustomerCode,
							PersonName,
							Email,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldNewsLetterMailingNo VARCHAR(20),
										NewsLetterMailingNo VARCHAR(20),
										CustomerCode VARCHAR(20),
										PersonName VARCHAR(100),
										Email VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NewsLetterMailingNo = SourceTable.NewsLetterMailingNo
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
									OldNewsLetterMailingNo,
									NewsLetterMailingNo,
									CustomerCode,
									PersonName,
									Email,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldNewsLetterMailingNo VARCHAR(20),
											 NewsLetterMailingNo VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 PersonName VARCHAR(100),
											 Email VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldNewsLetterMailingNo IS NULL THEN NewsLetterMailingNo
										ELSE OldNewsLetterMailingNo
									END AS OldNewsLetterMailingNo,
									NewsLetterMailingNo,
									CustomerCode,
									PersonName,
									Email,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldNewsLetterMailingNo VARCHAR(20),
											 NewsLetterMailingNo VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 PersonName VARCHAR(100),
											 Email VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldNewsLetterMailingNo IS NULL THEN NewsLetterMailingNo
										ELSE OldNewsLetterMailingNo
									END AS OldNewsLetterMailingNo,
									NewsLetterMailingNo,
									CustomerCode,
									PersonName,
									Email,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldNewsLetterMailingNo VARCHAR(20),
											 NewsLetterMailingNo VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 PersonName VARCHAR(100),
											 Email VARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldNewsLetterMailingNo,
								 @NewsLetterMailingNo,
								 @CustomerCode,
								 @PersonName,
								 @Email,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_NewsLetterMailingInfo WHERE NewsLetterMailingNo = @NewsLetterMailingNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @NewsLetterMailingNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_NewsLetterMailingInfo',@NewsLetterMailingNo OUTPUT
                    END

                    INSERT INTO STB_NewsLetterMailingInfo
						(
						    NewsLetterMailingNo,
						    CustomerCode,
						    PersonName,
						    Email,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @NewsLetterMailingNo,
						    @CustomerCode,
						    @PersonName,
						    @Email,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_NewsLetterMailingInfo
						SET
						    CustomerCode =   ISNULL(@CustomerCode,CustomerCode),
						    PersonName =   ISNULL(@PersonName,PersonName),
						    Email =   ISNULL(@Email,Email),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    NewsLetterMailingNo = @OldNewsLetterMailingNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_NewsLetterMailingInfo
						WHERE
						    NewsLetterMailingNo = @OldNewsLetterMailingNo
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
