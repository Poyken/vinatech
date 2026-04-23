
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-07-08
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineNonOperationHist_iud]
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
  DECLARE @OldLineNonOperationHistNo VARCHAR(20)
  DECLARE @LineNonOperationHistNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @LineStopDateTime DATETIME
  DECLARE @LineRestartDateTime DATETIME
  DECLARE @LineStopRemark NVARCHAR(MAX)
  DECLARE @LineRestartRemark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_LineNonOperationHist',
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
									OldLineNonOperationHistNo,
									LineNonOperationHistNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									LineStopDateTime,
									LineRestartDateTime,
									LineStopRemark,
									LineRestartRemark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLineNonOperationHistNo VARCHAR(20),
											 LineNonOperationHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 LineStopDateTime DATETIMEOFFSET,
											 LineRestartDateTime DATETIMEOFFSET,
											 LineStopRemark NVARCHAR(MAX),
											 LineRestartRemark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLineNonOperationHistNo IS NULL THEN LineNonOperationHistNo
										ELSE OldLineNonOperationHistNo
									END AS OldLineNonOperationHistNo,
									LineNonOperationHistNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									LineStopDateTime,
									LineRestartDateTime,
									LineStopRemark,
									LineRestartRemark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLineNonOperationHistNo VARCHAR(20),
											 LineNonOperationHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 LineStopDateTime DATETIMEOFFSET,
											 LineRestartDateTime DATETIMEOFFSET,
											 LineStopRemark NVARCHAR(MAX),
											 LineRestartRemark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLineNonOperationHistNo IS NULL THEN LineNonOperationHistNo
										ELSE OldLineNonOperationHistNo
									END AS OldLineNonOperationHistNo,
									LineNonOperationHistNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									LineStopDateTime,
									LineRestartDateTime,
									LineStopRemark,
									LineRestartRemark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLineNonOperationHistNo VARCHAR(20),
											 LineNonOperationHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 LineStopDateTime DATETIMEOFFSET,
											 LineRestartDateTime DATETIMEOFFSET,
											 LineStopRemark NVARCHAR(MAX),
											 LineRestartRemark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLineNonOperationHistNo,
								 @LineNonOperationHistNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineCode,
								 @LineStopDateTime,
								 @LineRestartDateTime,
								 @LineStopRemark,
								 @LineRestartRemark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_LineNonOperationHist WHERE LineNonOperationHistNo = @LineNonOperationHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LineNonOperationHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_LineNonOperationHist',@LineNonOperationHistNo OUTPUT
                    END

                    INSERT INTO STB_LineNonOperationHist
						(
						    LineNonOperationHistNo,
						    CompanyCode,
						    WorkCenterCode,
						    LineCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LineNonOperationHistNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @LineCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_LineNonOperationHist
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    LineNonOperationHistNo = @OldLineNonOperationHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_LineNonOperationHist
						WHERE
						    LineNonOperationHistNo = @OldLineNonOperationHistNo
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
