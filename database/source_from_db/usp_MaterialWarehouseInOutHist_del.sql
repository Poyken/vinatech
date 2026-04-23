
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-02-14
-- Browsable : true
-- Group : 자재관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_del]
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
  DECLARE @OldMaterialWarehouseInOutHistNo VARCHAR(20)
  DECLARE @MaterialWarehouseInOutHistNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @SourceMaterialWarehouseCode VARCHAR(20)
  DECLARE @TargetMaterialWarehouseCode VARCHAR(20)
  DECLARE @WarehouseInOutCode VARCHAR(1)
  DECLARE @LotID VARCHAR(20)
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialWarehouseInOutHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialWarehouseInOutHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialWarehouseInOutHistNo IS NULL THEN MaterialWarehouseInOutHistNo
							    ELSE OldMaterialWarehouseInOutHistNo
							END AS OldMaterialWarehouseInOutHistNo,
							MaterialWarehouseInOutHistNo,
							CompanyCode,
							WorkCenterCode,
							SourceMaterialWarehouseCode,
							TargetMaterialWarehouseCode,
							WarehouseInOutCode,
							LotID,
							WorkerCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialWarehouseInOutHistNo VARCHAR(20),
										MaterialWarehouseInOutHistNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										SourceMaterialWarehouseCode VARCHAR(20),
										TargetMaterialWarehouseCode VARCHAR(20),
										WarehouseInOutCode VARCHAR(1),
										LotID VARCHAR(20),
										WorkerCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialWarehouseInOutHistNo = SourceTable.MaterialWarehouseInOutHistNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialWarehouseInOutHistNo = ISNULL(SourceTable.MaterialWarehouseInOutHistNo,TargetTable.MaterialWarehouseInOutHistNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					SourceMaterialWarehouseCode = ISNULL(SourceTable.SourceMaterialWarehouseCode,TargetTable.SourceMaterialWarehouseCode),
					TargetMaterialWarehouseCode = ISNULL(SourceTable.TargetMaterialWarehouseCode,TargetTable.TargetMaterialWarehouseCode),
					WarehouseInOutCode = ISNULL(SourceTable.WarehouseInOutCode,TargetTable.WarehouseInOutCode),
					LotID = ISNULL(SourceTable.LotID,TargetTable.LotID),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialWarehouseInOutHistNo,
						CompanyCode,
						WorkCenterCode,
						SourceMaterialWarehouseCode,
						TargetMaterialWarehouseCode,
						WarehouseInOutCode,
						LotID,
						WorkerCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialWarehouseInOutHistNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.SourceMaterialWarehouseCode,
							SourceTable.TargetMaterialWarehouseCode,
							SourceTable.WarehouseInOutCode,
							SourceTable.LotID,
							SourceTable.WorkerCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialWarehouseInOutHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialWarehouseInOutHistNo IS NULL THEN MaterialWarehouseInOutHistNo
							    ELSE OldMaterialWarehouseInOutHistNo
							END AS OldMaterialWarehouseInOutHistNo,
							MaterialWarehouseInOutHistNo,
							CompanyCode,
							WorkCenterCode,
							SourceMaterialWarehouseCode,
							TargetMaterialWarehouseCode,
							WarehouseInOutCode,
							LotID,
							WorkerCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialWarehouseInOutHistNo VARCHAR(20),
										MaterialWarehouseInOutHistNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										SourceMaterialWarehouseCode VARCHAR(20),
										TargetMaterialWarehouseCode VARCHAR(20),
										WarehouseInOutCode VARCHAR(1),
										LotID VARCHAR(20),
										WorkerCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialWarehouseInOutHistNo = SourceTable.OldMaterialWarehouseInOutHistNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialWarehouseInOutHistNo = ISNULL(SourceTable.MaterialWarehouseInOutHistNo,TargetTable.MaterialWarehouseInOutHistNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					SourceMaterialWarehouseCode = ISNULL(SourceTable.SourceMaterialWarehouseCode,TargetTable.SourceMaterialWarehouseCode),
					TargetMaterialWarehouseCode = ISNULL(SourceTable.TargetMaterialWarehouseCode,TargetTable.TargetMaterialWarehouseCode),
					WarehouseInOutCode = ISNULL(SourceTable.WarehouseInOutCode,TargetTable.WarehouseInOutCode),
					LotID = ISNULL(SourceTable.LotID,TargetTable.LotID),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialWarehouseInOutHistNo,
						CompanyCode,
						WorkCenterCode,
						SourceMaterialWarehouseCode,
						TargetMaterialWarehouseCode,
						WarehouseInOutCode,
						LotID,
						WorkerCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialWarehouseInOutHistNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.SourceMaterialWarehouseCode,
							SourceTable.TargetMaterialWarehouseCode,
							SourceTable.WarehouseInOutCode,
							SourceTable.LotID,
							SourceTable.WorkerCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialWarehouseInOutHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialWarehouseInOutHistNo IS NULL THEN MaterialWarehouseInOutHistNo
							    ELSE OldMaterialWarehouseInOutHistNo
							END AS OldMaterialWarehouseInOutHistNo,
							MaterialWarehouseInOutHistNo,
							CompanyCode,
							WorkCenterCode,
							SourceMaterialWarehouseCode,
							TargetMaterialWarehouseCode,
							WarehouseInOutCode,
							LotID,
							WorkerCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialWarehouseInOutHistNo VARCHAR(20),
										MaterialWarehouseInOutHistNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										SourceMaterialWarehouseCode VARCHAR(20),
										TargetMaterialWarehouseCode VARCHAR(20),
										WarehouseInOutCode VARCHAR(1),
										LotID VARCHAR(20),
										WorkerCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialWarehouseInOutHistNo = SourceTable.MaterialWarehouseInOutHistNo
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
									OldMaterialWarehouseInOutHistNo,
									MaterialWarehouseInOutHistNo,
									CompanyCode,
									WorkCenterCode,
									SourceMaterialWarehouseCode,
									TargetMaterialWarehouseCode,
									WarehouseInOutCode,
									LotID,
									WorkerCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialWarehouseInOutHistNo VARCHAR(20),
											 MaterialWarehouseInOutHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SourceMaterialWarehouseCode VARCHAR(20),
											 TargetMaterialWarehouseCode VARCHAR(20),
											 WarehouseInOutCode VARCHAR(1),
											 LotID VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialWarehouseInOutHistNo IS NULL THEN MaterialWarehouseInOutHistNo
										ELSE OldMaterialWarehouseInOutHistNo
									END AS OldMaterialWarehouseInOutHistNo,
									MaterialWarehouseInOutHistNo,
									CompanyCode,
									WorkCenterCode,
									SourceMaterialWarehouseCode,
									TargetMaterialWarehouseCode,
									WarehouseInOutCode,
									LotID,
									WorkerCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialWarehouseInOutHistNo VARCHAR(20),
											 MaterialWarehouseInOutHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SourceMaterialWarehouseCode VARCHAR(20),
											 TargetMaterialWarehouseCode VARCHAR(20),
											 WarehouseInOutCode VARCHAR(1),
											 LotID VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialWarehouseInOutHistNo IS NULL THEN MaterialWarehouseInOutHistNo
										ELSE OldMaterialWarehouseInOutHistNo
									END AS OldMaterialWarehouseInOutHistNo,
									MaterialWarehouseInOutHistNo,
									CompanyCode,
									WorkCenterCode,
									SourceMaterialWarehouseCode,
									TargetMaterialWarehouseCode,
									WarehouseInOutCode,
									LotID,
									WorkerCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialWarehouseInOutHistNo VARCHAR(20),
											 MaterialWarehouseInOutHistNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SourceMaterialWarehouseCode VARCHAR(20),
											 TargetMaterialWarehouseCode VARCHAR(20),
											 WarehouseInOutCode VARCHAR(1),
											 LotID VARCHAR(20),
											 WorkerCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialWarehouseInOutHistNo,
								 @MaterialWarehouseInOutHistNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @SourceMaterialWarehouseCode,
								 @TargetMaterialWarehouseCode,
								 @WarehouseInOutCode,
								 @LotID,
								 @WorkerCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialWarehouseInOutHist WHERE MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialWarehouseInOutHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT
                    END

                    INSERT INTO STB_MaterialWarehouseInOutHist
						(
						    MaterialWarehouseInOutHistNo,
						    CompanyCode,
						    WorkCenterCode,
						    SourceMaterialWarehouseCode,
						    TargetMaterialWarehouseCode,
						    WarehouseInOutCode,
						    LotID,
						    WorkerCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialWarehouseInOutHistNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @SourceMaterialWarehouseCode,
						    @TargetMaterialWarehouseCode,
						    @WarehouseInOutCode,
						    @LotID,
						    @WorkerCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialWarehouseInOutHist
						SET
						    MaterialWarehouseInOutHistNo =   ISNULL(@MaterialWarehouseInOutHistNo,MaterialWarehouseInOutHistNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    SourceMaterialWarehouseCode =   ISNULL(@SourceMaterialWarehouseCode,SourceMaterialWarehouseCode),
						    TargetMaterialWarehouseCode =   ISNULL(@TargetMaterialWarehouseCode,TargetMaterialWarehouseCode),
						    WarehouseInOutCode =   ISNULL(@WarehouseInOutCode,WarehouseInOutCode),
						    LotID =   ISNULL(@LotID,LotID),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialWarehouseInOutHistNo = @OldMaterialWarehouseInOutHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialWarehouseInOutHist
						WHERE
						    MaterialWarehouseInOutHistNo = @OldMaterialWarehouseInOutHistNo
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
