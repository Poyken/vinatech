-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	설비보수작업자정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairWorker_iud]
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
  DECLARE @OldMachineRepairWorkerCode VARCHAR(20)
  DECLARE @MachineRepairWorkerCode VARCHAR(20)
  DECLARE @MachineRepairWorkerName NVARCHAR(50)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @BasicCost NUMERIC(15,2)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineRepairWorker',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MachineRepairWorker AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineRepairWorkerCode IS NULL THEN XMLData.MachineRepairWorkerCode
							    ELSE XMLData.OldMachineRepairWorkerCode
							END AS OldMachineRepairWorkerCode,
							XMLData.MachineRepairWorkerCode,
							XMLData.MachineRepairWorkerName,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.BasicCost,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachineRepairWorkerCode VARCHAR(20),
										MachineRepairWorkerCode VARCHAR(20),
										MachineRepairWorkerName NVARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicCost NUMERIC(15,2),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineRepairWorkerCode = SourceTable.MachineRepairWorkerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineRepairWorkerCode = SourceTable.MachineRepairWorkerCode,
					MachineRepairWorkerName = SourceTable.MachineRepairWorkerName,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					BasicCost = SourceTable.BasicCost,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineRepairWorkerCode,
						MachineRepairWorkerName,
						CompanyCode,
						WorkCenterCode,
						BasicCost,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineRepairWorkerCode,
							SourceTable.MachineRepairWorkerName,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicCost,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MachineRepairWorker AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineRepairWorkerCode IS NULL THEN XMLData.MachineRepairWorkerCode
							    ELSE XMLData.OldMachineRepairWorkerCode
							END AS OldMachineRepairWorkerCode,
							XMLData.MachineRepairWorkerCode,
							XMLData.MachineRepairWorkerName,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.BasicCost,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachineRepairWorkerCode VARCHAR(20),
										MachineRepairWorkerCode VARCHAR(20),
										MachineRepairWorkerName NVARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicCost NUMERIC(15,2),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineRepairWorkerCode = SourceTable.OldMachineRepairWorkerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineRepairWorkerCode = SourceTable.MachineRepairWorkerCode,
					MachineRepairWorkerName = SourceTable.MachineRepairWorkerName,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					BasicCost = SourceTable.BasicCost,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineRepairWorkerCode,
						MachineRepairWorkerName,
						CompanyCode,
						WorkCenterCode,
						BasicCost,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineRepairWorkerCode,
							SourceTable.MachineRepairWorkerName,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicCost,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MachineRepairWorker AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineRepairWorkerCode IS NULL THEN XMLData.MachineRepairWorkerCode
							    ELSE XMLData.OldMachineRepairWorkerCode
							END AS OldMachineRepairWorkerCode,
							XMLData.MachineRepairWorkerCode,
							XMLData.MachineRepairWorkerName,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.BasicCost,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachineRepairWorkerCode VARCHAR(20),
										MachineRepairWorkerCode VARCHAR(20),
										MachineRepairWorkerName NVARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicCost NUMERIC(15,2),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineRepairWorkerCode = SourceTable.MachineRepairWorkerCode
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
									XMLData.OldMachineRepairWorkerCode,
									XMLData.MachineRepairWorkerCode,
									XMLData.MachineRepairWorkerName,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.BasicCost,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineRepairWorkerCode VARCHAR(20),
											 MachineRepairWorkerCode VARCHAR(20),
											 MachineRepairWorkerName NVARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicCost NUMERIC(15,2),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineRepairWorkerCode IS NULL THEN XMLData.MachineRepairWorkerCode
										ELSE XMLData.OldMachineRepairWorkerCode
									END AS OldMachineRepairWorkerCode,
									XMLData.MachineRepairWorkerCode,
									XMLData.MachineRepairWorkerName,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.BasicCost,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineRepairWorkerCode VARCHAR(20),
											 MachineRepairWorkerCode VARCHAR(20),
											 MachineRepairWorkerName NVARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicCost NUMERIC(15,2),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineRepairWorkerCode IS NULL THEN XMLData.MachineRepairWorkerCode
										ELSE XMLData.OldMachineRepairWorkerCode
									END AS OldMachineRepairWorkerCode,
									XMLData.MachineRepairWorkerCode,
									XMLData.MachineRepairWorkerName,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.BasicCost,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineRepairWorkerCode VARCHAR(20),
											 MachineRepairWorkerCode VARCHAR(20),
											 MachineRepairWorkerName NVARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicCost NUMERIC(15,2),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineRepairWorkerCode,
								 @MachineRepairWorkerCode,
								 @MachineRepairWorkerName,
								 @CompanyCode,
								 @WorkCenterCode,
								 @BasicCost,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MachineRepairWorker WHERE MachineRepairWorkerCode = @MachineRepairWorkerCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineRepairWorkerCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachineRepairWorker', @MachineRepairWorkerCode OUTPUT
                    END

                    INSERT INTO STB_MachineRepairWorker
						(
						    MachineRepairWorkerCode,
						    MachineRepairWorkerName,
						    CompanyCode,
						    WorkCenterCode,
						    BasicCost,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineRepairWorkerCode,
						    @MachineRepairWorkerName,
						    @CompanyCode,
						    @WorkCenterCode,
						    @BasicCost,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MachineRepairWorker
						SET
						    MachineRepairWorkerCode =   CASE
						                WHEN @MachineRepairWorkerCode IS NOT NULL THEN @MachineRepairWorkerCode
						                ELSE MachineRepairWorkerCode
						            END,
						    MachineRepairWorkerName =   CASE
						                WHEN @MachineRepairWorkerName IS NOT NULL THEN @MachineRepairWorkerName
						                ELSE MachineRepairWorkerName
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    BasicCost =   CASE
						                WHEN @BasicCost IS NOT NULL THEN @BasicCost
						                ELSE BasicCost
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MachineRepairWorkerCode = @OldMachineRepairWorkerCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MachineRepairWorker
						WHERE
						    MachineRepairWorkerCode = @MachineRepairWorkerCode
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

