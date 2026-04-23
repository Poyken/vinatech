
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-07-10
-- Browsable : true
-- Group : 공통
-- Description:	작업장정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkCenterInfo_iud]
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
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @WorkCenterName NVARCHAR(50)
  DECLARE @WorkCenterNameL VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterDesc NVARCHAR(200)
  DECLARE @WorkCenterDescL NVARCHAR(200)
  DECLARE @WorkCenterBarcode VARCHAR(10)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_WorkCenterInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_WorkCenterInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							WorkCenterCode,
							WorkCenterName,
							WorkCenterNameL,
							CompanyCode,
							WorkCenterDesc,
							WorkCenterDescL,
							WorkCenterBarcode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldWorkCenterCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										WorkCenterName NVARCHAR(50),
										WorkCenterNameL VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterDesc NVARCHAR(200),
										WorkCenterDescL NVARCHAR(200),
										WorkCenterBarcode VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					WorkCenterName = ISNULL(SourceTable.WorkCenterName,TargetTable.WorkCenterName),
					WorkCenterNameL = ISNULL(SourceTable.WorkCenterNameL,TargetTable.WorkCenterNameL),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterDesc = ISNULL(SourceTable.WorkCenterDesc,TargetTable.WorkCenterDesc),
					WorkCenterDescL = ISNULL(SourceTable.WorkCenterDescL,TargetTable.WorkCenterDescL),
					WorkCenterBarcode = ISNULL(SourceTable.WorkCenterBarcode,TargetTable.WorkCenterBarcode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						WorkCenterCode,
						WorkCenterName,
						WorkCenterNameL,
						CompanyCode,
						WorkCenterDesc,
						WorkCenterDescL,
						WorkCenterBarcode,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.WorkCenterCode,
							SourceTable.WorkCenterName,
							SourceTable.WorkCenterNameL,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterDesc,
							SourceTable.WorkCenterDescL,
							SourceTable.WorkCenterBarcode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_WorkCenterInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							WorkCenterCode,
							WorkCenterName,
							WorkCenterNameL,
							CompanyCode,
							WorkCenterDesc,
							WorkCenterDescL,
							WorkCenterBarcode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldWorkCenterCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										WorkCenterName NVARCHAR(50),
										WorkCenterNameL VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterDesc NVARCHAR(200),
										WorkCenterDescL NVARCHAR(200),
										WorkCenterBarcode VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.WorkCenterCode = SourceTable.OldWorkCenterCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					WorkCenterName = ISNULL(SourceTable.WorkCenterName,TargetTable.WorkCenterName),
					WorkCenterNameL = ISNULL(SourceTable.WorkCenterNameL,TargetTable.WorkCenterNameL),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterDesc = ISNULL(SourceTable.WorkCenterDesc,TargetTable.WorkCenterDesc),
					WorkCenterDescL = ISNULL(SourceTable.WorkCenterDescL,TargetTable.WorkCenterDescL),
					WorkCenterBarcode = ISNULL(SourceTable.WorkCenterBarcode,TargetTable.WorkCenterBarcode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						WorkCenterCode,
						WorkCenterName,
						WorkCenterNameL,
						CompanyCode,
						WorkCenterDesc,
						WorkCenterDescL,
						WorkCenterBarcode,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.WorkCenterCode,
							SourceTable.WorkCenterName,
							SourceTable.WorkCenterNameL,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterDesc,
							SourceTable.WorkCenterDescL,
							SourceTable.WorkCenterBarcode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_WorkCenterInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							WorkCenterCode,
							WorkCenterName,
							WorkCenterNameL,
							CompanyCode,
							WorkCenterDesc,
							WorkCenterDescL,
							WorkCenterBarcode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldWorkCenterCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										WorkCenterName NVARCHAR(50),
										WorkCenterNameL VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterDesc NVARCHAR(200),
										WorkCenterDescL NVARCHAR(200),
										WorkCenterBarcode VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode
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
									OldWorkCenterCode,
									WorkCenterCode,
									WorkCenterName,
									WorkCenterNameL,
									CompanyCode,
									WorkCenterDesc,
									WorkCenterDescL,
									WorkCenterBarcode,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldWorkCenterCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 WorkCenterName NVARCHAR(50),
											 WorkCenterNameL VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterDesc NVARCHAR(200),
											 WorkCenterDescL NVARCHAR(200),
											 WorkCenterBarcode VARCHAR(10),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									WorkCenterCode,
									WorkCenterName,
									WorkCenterNameL,
									CompanyCode,
									WorkCenterDesc,
									WorkCenterDescL,
									WorkCenterBarcode,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldWorkCenterCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 WorkCenterName NVARCHAR(50),
											 WorkCenterNameL VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterDesc NVARCHAR(200),
											 WorkCenterDescL NVARCHAR(200),
											 WorkCenterBarcode VARCHAR(10),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									WorkCenterCode,
									WorkCenterName,
									WorkCenterNameL,
									CompanyCode,
									WorkCenterDesc,
									WorkCenterDescL,
									WorkCenterBarcode,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldWorkCenterCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 WorkCenterName NVARCHAR(50),
											 WorkCenterNameL VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterDesc NVARCHAR(200),
											 WorkCenterDescL NVARCHAR(200),
											 WorkCenterBarcode VARCHAR(10),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldWorkCenterCode,
								 @WorkCenterCode,
								 @WorkCenterName,
								 @WorkCenterNameL,
								 @CompanyCode,
								 @WorkCenterDesc,
								 @WorkCenterDescL,
								 @WorkCenterBarcode,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_WorkCenterInfo WHERE WorkCenterCode = @WorkCenterCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @WorkCenterCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_WorkCenterInfo', @WorkCenterCode OUTPUT
                    END

                    INSERT INTO STB_WorkCenterInfo
						(
						    WorkCenterCode,
						    WorkCenterName,
						    WorkCenterNameL,
						    CompanyCode,
						    WorkCenterDesc,
						    WorkCenterDescL,
						    WorkCenterBarcode,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @WorkCenterCode,
						    @WorkCenterName,
						    @WorkCenterNameL,
						    @CompanyCode,
						    @WorkCenterDesc,
						    @WorkCenterDescL,
						    @WorkCenterBarcode,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_WorkCenterInfo
						SET
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    WorkCenterName =   ISNULL(@WorkCenterName,WorkCenterName),
						    WorkCenterNameL =   ISNULL(@WorkCenterNameL,WorkCenterNameL),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterDesc =   ISNULL(@WorkCenterDesc,WorkCenterDesc),
						    WorkCenterDescL =   ISNULL(@WorkCenterDescL,WorkCenterDescL),
						    WorkCenterBarcode =   ISNULL(@WorkCenterBarcode,WorkCenterBarcode),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    WorkCenterCode = @OldWorkCenterCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_WorkCenterInfo
						WHERE
						    WorkCenterCode = @WorkCenterCode
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
