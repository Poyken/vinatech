
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProdWorkerInfo_iud_Test]
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
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @OldWorkerCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @WorkerName NVARCHAR(50)
  DECLARE @LanguageCode VARCHAR(20)
  DECLARE @OrgWorkerName NVARCHAR(50)
  DECLARE @Nationality NVARCHAR(50)
  DECLARE @EmpNo VARCHAR(20)
  DECLARE @WorkerImage VARBINARY(MAX)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsProdWorker BIT
  DECLARE @LineCode VARCHAR(50)
  DECLARE @DATEJOIN DATETIME
  --#210719
  DECLARE @WorkerGroupCode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProdWorkerInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ProdWorkerInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldWorkerCode IS NULL THEN WorkerCode
							    ELSE OldWorkerCode
							END AS OldWorkerCode,
							CompanyCode,
							WorkCenterCode,
							WorkerCode,
							WorkerName,
							LanguageCode,
							OrgWorkerName,
							Nationality,
							EmpNo,
							dbo.fnBase64ToBinary(WorkerImage) as WorkerImage,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsProdWorker,
							WorkerGroupCode,
							LineCode,
							DATEJOIN
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldWorkerCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										WorkerCode VARCHAR(20),
										WorkerName NVARCHAR(50),
										LanguageCode VARCHAR(20),
										OrgWorkerName NVARCHAR(50),
										Nationality NVARCHAR(50),
										EmpNo VARCHAR(20),
										WorkerImage NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsProdWorker BIT,
										WorkerGroupCode VARCHAR(20),
										LineCode VARCHAR(50),
										DATEJOIN DATETIME
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode AND
					TargetTable.WorkerCode = SourceTable.WorkerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					WorkerName = ISNULL(SourceTable.WorkerName,TargetTable.WorkerName),
					LanguageCode = ISNULL(SourceTable.LanguageCode,TargetTable.LanguageCode),
					OrgWorkerName = ISNULL(SourceTable.OrgWorkerName,TargetTable.OrgWorkerName),
					Nationality = ISNULL(SourceTable.Nationality,TargetTable.Nationality),
					EmpNo = ISNULL(SourceTable.EmpNo,TargetTable.EmpNo),
					--WorkerImage = ISNULL(SourceTable.WorkerImage,TargetTable.WorkerImage),
					WorkerImage = SourceTable.WorkerImage,
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsProdWorker = ISNULL(SourceTable.IsProdWorker,TargetTable.IsProdWorker),
					WorkerGroupCode = ISNULL(SourceTable.WorkerGroupCode,TargetTable.WorkerGroupCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					DATEJOIN = ISNULL(SourceTable.DATEJOIN,TargetTable.DATEJOIN)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						WorkCenterCode,
						WorkerCode,
						WorkerName,
						LanguageCode,
						OrgWorkerName,
						Nationality,
						EmpNo,
						WorkerImage,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsProdWorker,
						WorkerGroupCode,
						LineCode,
						DATEJOIN
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.WorkerCode,
							SourceTable.WorkerName,
							SourceTable.LanguageCode,
							SourceTable.OrgWorkerName,
							SourceTable.Nationality,
							SourceTable.EmpNo,
							SourceTable.WorkerImage,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsProdWorker,
							SourceTable.WorkerGroupCode,
							SourceTable.LineCode,
							SourceTable.DATEJOIN
					);


			-- Process Update Table
            MERGE STB_ProdWorkerInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldWorkerCode IS NULL THEN WorkerCode
							    ELSE OldWorkerCode
							END AS OldWorkerCode,
							CompanyCode,
							WorkCenterCode,
							WorkerCode,
							WorkerName,
							LanguageCode,
							OrgWorkerName,
							Nationality,
							EmpNo,
							dbo.fnBase64ToBinary(WorkerImage) as WorkerImage,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsProdWorker,
							WorkerGroupCode,
							LineCode,
							DATEJOIN
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldWorkerCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										WorkerCode VARCHAR(20),
										WorkerName NVARCHAR(50),
										LanguageCode VARCHAR(20),
										OrgWorkerName NVARCHAR(50),
										Nationality NVARCHAR(50),
										EmpNo VARCHAR(20),
										WorkerImage NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsProdWorker BIT,
										WorkerGroupCode VARCHAR(20),
										LineCode VARCHAR(50),
										DATEJOIN DATETIME
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.OldCompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.OldWorkCenterCode AND
					TargetTable.WorkerCode = SourceTable.OldWorkerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					WorkerName = ISNULL(SourceTable.WorkerName,TargetTable.WorkerName),
					LanguageCode = ISNULL(SourceTable.LanguageCode,TargetTable.LanguageCode),
					OrgWorkerName = ISNULL(SourceTable.OrgWorkerName,TargetTable.OrgWorkerName),
					Nationality = ISNULL(SourceTable.Nationality,TargetTable.Nationality),
					EmpNo = ISNULL(SourceTable.EmpNo,TargetTable.EmpNo),
					--WorkerImage = ISNULL(SourceTable.WorkerImage,TargetTable.WorkerImage),
					WorkerImage = SourceTable.WorkerImage,
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsProdWorker = ISNULL(SourceTable.IsProdWorker, TargetTable.IsProdWorker),
					WorkerGroupCode = ISNULL(SourceTable.WorkerGroupCode, TargetTable.WorkerGroupCode),
					LineCode = ISNULL(SourceTable.LineCode, TargetTable.LineCode),
					DATEJOIN = ISNULL(SourceTable.DATEJOIN, TargetTable.DATEJOIN)

			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						WorkCenterCode,
						WorkerCode,
						WorkerName,
						LanguageCode,
						OrgWorkerName,
						Nationality,
						EmpNo,
						WorkerImage,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsProdWorker,
						WorkerGroupCode,
						LineCode,
						DATEJOIN
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.WorkerCode,
							SourceTable.WorkerName,
							SourceTable.LanguageCode,
							SourceTable.OrgWorkerName,
							SourceTable.Nationality,
							SourceTable.EmpNo,
							SourceTable.WorkerImage,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsProdWorker,
							SourceTable.WorkerGroupCode,
							SourceTable.LineCode,
							SourceTable.DATEJOIN
					);


			-- Process Delete Table
            MERGE STB_ProdWorkerInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldWorkerCode IS NULL THEN WorkerCode
							    ELSE OldWorkerCode
							END AS OldWorkerCode,
							CompanyCode,
							WorkCenterCode,
							WorkerCode,
							WorkerName,
							LanguageCode,
							OrgWorkerName,
							Nationality,
							EmpNo,
							dbo.fnBase64ToBinary(WorkerImage) as WorkerImage,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsProdWorker,
							WorkerGroupCode,
							LineCode,
							DATEJOIN
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldWorkerCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										WorkerCode VARCHAR(20),
										WorkerName NVARCHAR(50),
										LanguageCode VARCHAR(20),
										OrgWorkerName NVARCHAR(50),
										Nationality NVARCHAR(50),
										EmpNo VARCHAR(20),
										WorkerImage NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsProdWorker BIT,
										WorkerGroupCode VARCHAR(20),
										LineCode VARCHAR(50),
										DATEJOIN DATETIME
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode AND
					TargetTable.WorkerCode = SourceTable.WorkerCode
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
									OldCompanyCode,
									OldWorkCenterCode,
									OldWorkerCode,
									CompanyCode,
									WorkCenterCode,
									WorkerCode,
									WorkerName,
									LanguageCode,
									OrgWorkerName,
									Nationality,
									EmpNo,
									dbo.fnBase64ToBinary(WorkerImage) as WorkerImage,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsProdWorker,
									WorkerGroupCode,
									LineCode,
									DATEJOIN
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 WorkerName NVARCHAR(50),
											 LanguageCode VARCHAR(20),
											 OrgWorkerName NVARCHAR(50),
											 Nationality NVARCHAR(50),
											 EmpNo VARCHAR(20),
											 WorkerImage NVARCHAR(MAX),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsProdWorker BIT,
											 WorkerGroupCode VARCHAR(20),
											 LineCode VARCHAR(50),
											 DATEJOIN DATETIME
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									CompanyCode,
									WorkCenterCode,
									WorkerCode,
									WorkerName,
									LanguageCode,
									OrgWorkerName,
									Nationality,
									EmpNo,
									dbo.fnBase64ToBinary(WorkerImage) as WorkerImage,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsProdWorker,
									WorkerGroupCode,
									LineCode,
									DATEJOIN
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 WorkerName NVARCHAR(50),
											 LanguageCode VARCHAR(20),
											 OrgWorkerName NVARCHAR(50),
											 Nationality NVARCHAR(50),
											 EmpNo VARCHAR(20),
											 WorkerImage NVARCHAR(MAX),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsProdWorker BIT,
											 WorkerGroupCode VARCHAR(20),
											 LineCode VARCHAR(50),
											 DATEJOIN DATETIME
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldWorkerCode IS NULL THEN WorkerCode
										ELSE OldWorkerCode
									END AS OldWorkerCode,
									CompanyCode,
									WorkCenterCode,
									WorkerCode,
									WorkerName,
									LanguageCode,
									OrgWorkerName,
									Nationality,
									EmpNo,
									dbo.fnBase64ToBinary(WorkerImage) as WorkerImage,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsProdWorker,
									WorkerGroupCode,
									LineCode,
									DATEJOIN
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldWorkerCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 WorkerName NVARCHAR(50),
											 LanguageCode VARCHAR(20),
											 OrgWorkerName NVARCHAR(50),
											 Nationality NVARCHAR(50),
											 EmpNo VARCHAR(20),
											 WorkerImage NVARCHAR(MAX),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsProdWorker BIT,
											 WorkerGroupCode VARCHAR(20),
											 LineCode VARCHAR(50),
											 DATEJOIN DATETIME
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @OldWorkCenterCode,
								 @OldWorkerCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @WorkerCode,
								 @WorkerName,
								 @LanguageCode,
								 @OrgWorkerName,
								 @Nationality,
								 @EmpNo,
								 @WorkerImage,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsProdWorker,
								 @WorkerGroupCode,
								 @LineCode,
								 @DATEJOIN


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ProdWorkerInfo WHERE --CompanyCode = @CompanyCode AND WorkCenterCode = @WorkCenterCode AND
					 WorkerCode = @WorkerCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CompanyCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdWorkerInfo',@CompanyCode OUTPUT
                    END

                    INSERT INTO STB_ProdWorkerInfo
						(
						    CompanyCode,
						    WorkCenterCode,
						    WorkerCode,
						    WorkerName,
						    LanguageCode,
						    OrgWorkerName,
						    Nationality,
						    EmpNo,
						    WorkerImage,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							IsProdWorker,
							WorkerGroupCode,
							LineCode,
							DATEJOIN
						)
						VALUES
						(
						    @CompanyCode,
						    @WorkCenterCode,
						    @WorkerCode,
						    @WorkerName,
						    @LanguageCode,
						    @OrgWorkerName,
						    @Nationality,
						    @EmpNo,
						    @WorkerImage,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@IsProdWorker,
							@WorkerGroupCode,
							@LineCode,
							@DATEJOIN
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ProdWorkerInfo
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    WorkerName =   ISNULL(@WorkerName,WorkerName),
						    LanguageCode =   ISNULL(@LanguageCode,LanguageCode),
						    OrgWorkerName =   ISNULL(@OrgWorkerName,OrgWorkerName),
						    Nationality =   ISNULL(@Nationality,Nationality),
						    EmpNo =   ISNULL(@EmpNo,EmpNo),
						    --WorkerImage =   ISNULL(@WorkerImage,WorkerImage),
							WorkerImage =   @WorkerImage,
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							IsProdWorker = ISNULL(@IsProdWorker,IsProdWorker),
							WorkerGroupCode = ISNULL(@WorkerGroupCode,WorkerGroupCode),
							LineCode = ISNULL(@LineCode,LineCode),
							DATEJOIN = ISNULL(@DATEJOIN,DATEJOIN)
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    WorkerCode = @OldWorkerCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ProdWorkerInfo
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    WorkerCode = @OldWorkerCode
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

--SELECT * FROM STB_ProdWorkerInfo WHERE DATEJOIN IS NOT NULL

--ALTER TABLE STB_ProdWorkerInfo
--ALTER COLUMN LineCode VARCHAR(50);