-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-04-22
-- Browsable : true
-- Group : 인사관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_IPCreateHist_iud]
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
  DECLARE @OldIPCreateHistNo VARCHAR(20)
  DECLARE @IPCreateHistNo VARCHAR(20)
  DECLARE @EmployeeNo VARCHAR(20)
  DECLARE @IPClassCode VARCHAR(20)
  DECLARE @IPCreateDate DATE
  DECLARE @IPTitle NVARCHAR(500)
  DECLARE @ApplicationNo VARCHAR(30)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_IPCreateHist',
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
									OldIPCreateHistNo,
									IPCreateHistNo,
									EmployeeNo,
									IPClassCode,
									IPCreateDate,
									IPTitle,
									ApplicationNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldIPCreateHistNo VARCHAR(20),
											 IPCreateHistNo VARCHAR(20),
											 EmployeeNo VARCHAR(20),
											 IPClassCode VARCHAR(20),
											 IPCreateDate DATETIMEOFFSET,
											 IPTitle NVARCHAR(500),
											 ApplicationNo VARCHAR(30),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldIPCreateHistNo IS NULL THEN IPCreateHistNo
										ELSE OldIPCreateHistNo
									END AS OldIPCreateHistNo,
									IPCreateHistNo,
									EmployeeNo,
									IPClassCode,
									IPCreateDate,
									IPTitle,
									ApplicationNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldIPCreateHistNo VARCHAR(20),
											 IPCreateHistNo VARCHAR(20),
											 EmployeeNo VARCHAR(20),
											 IPClassCode VARCHAR(20),
											 IPCreateDate DATETIMEOFFSET,
											 IPTitle NVARCHAR(500),
											 ApplicationNo VARCHAR(30),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldIPCreateHistNo IS NULL THEN IPCreateHistNo
										ELSE OldIPCreateHistNo
									END AS OldIPCreateHistNo,
									IPCreateHistNo,
									EmployeeNo,
									IPClassCode,
									IPCreateDate,
									IPTitle,
									ApplicationNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldIPCreateHistNo VARCHAR(20),
											 IPCreateHistNo VARCHAR(20),
											 EmployeeNo VARCHAR(20),
											 IPClassCode VARCHAR(20),
											 IPCreateDate DATETIMEOFFSET,
											 IPTitle NVARCHAR(500),
											 ApplicationNo VARCHAR(30),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldIPCreateHistNo,
								 @IPCreateHistNo,
								 @EmployeeNo,
								 @IPClassCode,
								 @IPCreateDate,
								 @IPTitle,
								 @ApplicationNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_IPCreateHist WHERE IPCreateHistNo = @IPCreateHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @IPCreateHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_IPCreateHist',@IPCreateHistNo OUTPUT
                    END

                    INSERT INTO STB_IPCreateHist
						(
						    IPCreateHistNo,
						    EmployeeNo,
						    IPClassCode,
						    IPCreateDate,
						    IPTitle,
						    ApplicationNo,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @IPCreateHistNo,
						    @EmployeeNo,
						    @IPClassCode,
						    @IPCreateDate,
						    @IPTitle,
						    @ApplicationNo,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					IF @IPCreateHistNo IS NULL BEGIN 
						IF EXISTS (SELECT 1 FROM STB_IPCreateHist WHERE IPCreateHistNo = @IPCreateHistNo) BEGIN
							RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @IPCreateHistNo)
						END

						IF @IsAutoKey = 1 BEGIN
							EXEC usp_DoCreateSerial 'STB_IPCreateHist',@IPCreateHistNo OUTPUT
						END

						INSERT INTO STB_IPCreateHist
							(
								IPCreateHistNo,
								EmployeeNo,
								IPClassCode,
								IPCreateDate,
								IPTitle,
								ApplicationNo,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
							)
							VALUES
							(
								@IPCreateHistNo,
								@EmployeeNo,
								@IPClassCode,
								@IPCreateDate,
								@IPTitle,
								@ApplicationNo,
								GETDATE(),
								@pProcessUserID,
								@ChangeDateTime,
								@ChangeUserID
							)
					END ELSE BEGIN

						UPDATE STB_IPCreateHist
							SET
								EmployeeNo =   ISNULL(@EmployeeNo,EmployeeNo),
								IPClassCode =   ISNULL(@IPClassCode,IPClassCode),
								IPCreateDate =   ISNULL(@IPCreateDate,IPCreateDate),
								IPTitle =   ISNULL(@IPTitle,IPTitle),
								ApplicationNo =   ISNULL(@ApplicationNo,ApplicationNo),
								CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
								CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
								ChangeDateTime = GETDATE(),
								ChangeUserID = @pProcessUserID
							WHERE
								IPCreateHistNo = @OldIPCreateHistNo
					END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_IPCreateHist
						WHERE
						    IPCreateHistNo = @OldIPCreateHistNo
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
