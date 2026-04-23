
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-24
-- Browsable : true
-- Group : 공통
-- Description:	설비정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineMaster_iud]
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
  DECLARE @OldMachineCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MachineName NVARCHAR(100)
  DECLARE @MachineNumber VARCHAR(50)    -- DinhManh update 2025-01-14
  DECLARE @IsProdMachine BIT
  DECLARE @MachineTypeCode VARCHAR(20)
  DECLARE @IsUsed BIT
  DECLARE @IsMonitoring BIT
  DECLARE @MonitoringGroup NVARCHAR(50)
  DECLARE @MachineRunStatus VARCHAR(10)
  DECLARE @LossCode VARCHAR(20)
  DECLARE @LossStartDateTime DATETIME
  DECLARE @LossHistNo VARCHAR(20)
  DECLARE @IsAlarm BIT
  DECLARE @RunStartDateTime DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineMaster',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MachineMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							MachineCode,
							CompanyCode,
							WorkCenterCode,
							MachineName,
							IsProdMachine,
							MachineTypeCode,
							IsUsed,
							IsMonitoring,
							MonitoringGroup,
							MachineRunStatus,
							LossCode,
							LossStartDateTime,
							LossHistNo,
							IsAlarm,
							RunStartDateTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MachineNumber		-- DinhManh update 2025-01-14
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineName NVARCHAR(100),
										IsProdMachine BIT,
										MachineTypeCode VARCHAR(20),
										IsUsed BIT,
										IsMonitoring BIT,
										MonitoringGroup NVARCHAR(50),
										MachineRunStatus VARCHAR(10),
										LossCode VARCHAR(20),
										LossStartDateTime DATETIMEOFFSET,
										LossHistNo VARCHAR(20),
										IsAlarm BIT,
										RunStartDateTime DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MachineNumber VARCHAR(50)	-- DinhManh update 2025-01-14
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					--MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MachineName = ISNULL(SourceTable.MachineName,TargetTable.MachineName),
					IsProdMachine = ISNULL(SourceTable.IsProdMachine,TargetTable.IsProdMachine),
					MachineTypeCode = ISNULL(SourceTable.MachineTypeCode,TargetTable.MachineTypeCode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					IsMonitoring = ISNULL(SourceTable.IsMonitoring,TargetTable.IsMonitoring),
					MonitoringGroup = ISNULL(SourceTable.MonitoringGroup,TargetTable.MonitoringGroup),
					MachineRunStatus = ISNULL(SourceTable.MachineRunStatus,TargetTable.MachineRunStatus),
					LossCode = ISNULL(SourceTable.LossCode,TargetTable.LossCode),
					LossStartDateTime = ISNULL(SourceTable.LossStartDateTime,TargetTable.LossStartDateTime),
					LossHistNo = ISNULL(SourceTable.LossHistNo,TargetTable.LossHistNo),
					IsAlarm = ISNULL(SourceTable.IsAlarm,TargetTable.IsAlarm),
					RunStartDateTime = ISNULL(SourceTable.RunStartDateTime,TargetTable.RunStartDateTime),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					MachineNumber = ISNULL(SourceTable.MachineNumber, TargetTable.MachineNumber)	-- DinhManh update 2025-01-14
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						CompanyCode,
						WorkCenterCode,
						MachineName,
						IsProdMachine,
						MachineTypeCode,
						IsUsed,
						IsMonitoring,
						MonitoringGroup,
						MachineRunStatus,
						LossCode,
						LossStartDateTime,
						LossHistNo,
						IsAlarm,
						RunStartDateTime,
						CreateDateTime,
						CreateUserID,
						MachineNumber	-- DinhManh update 2025-01-14
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MachineName,
							SourceTable.IsProdMachine,
							SourceTable.MachineTypeCode,
							SourceTable.IsUsed,
							SourceTable.IsMonitoring,
							SourceTable.MonitoringGroup,
							SourceTable.MachineRunStatus,
							SourceTable.LossCode,
							SourceTable.LossStartDateTime,
							SourceTable.LossHistNo,
							SourceTable.IsAlarm,
							SourceTable.RunStartDateTime,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MachineNumber -- DinhManh update 2025-01-14
					);

					
			-- Process Update Table
            MERGE STB_MachineMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							MachineCode,
							CompanyCode,
							WorkCenterCode,
							MachineName,
							IsProdMachine,
							MachineTypeCode,
							IsUsed,
							IsMonitoring,
							MonitoringGroup,
							MachineRunStatus,
							LossCode,
							LossStartDateTime,
							LossHistNo,
							IsAlarm,
							RunStartDateTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MachineNumber		-- DinhManh update 2025-01-14
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineName NVARCHAR(100),
										IsProdMachine BIT,
										MachineTypeCode VARCHAR(20),
										IsUsed BIT,
										IsMonitoring BIT,
										MonitoringGroup NVARCHAR(50),
										MachineRunStatus VARCHAR(10),
										LossCode VARCHAR(20),
										LossStartDateTime DATETIMEOFFSET,
										LossHistNo VARCHAR(20),
										IsAlarm BIT,
										RunStartDateTime DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MachineNumber VARCHAR(50)  -- DinhManh update 2025-01-14
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.OldMachineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					--MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MachineName = ISNULL(SourceTable.MachineName,TargetTable.MachineName),
					IsProdMachine = ISNULL(SourceTable.IsProdMachine,TargetTable.IsProdMachine),
					MachineTypeCode = ISNULL(SourceTable.MachineTypeCode,TargetTable.MachineTypeCode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					IsMonitoring = ISNULL(SourceTable.IsMonitoring,TargetTable.IsMonitoring),
					MonitoringGroup = ISNULL(SourceTable.MonitoringGroup,TargetTable.MonitoringGroup),
					MachineRunStatus = ISNULL(SourceTable.MachineRunStatus,TargetTable.MachineRunStatus),
					LossCode = ISNULL(SourceTable.LossCode,TargetTable.LossCode),
					LossStartDateTime = ISNULL(SourceTable.LossStartDateTime,TargetTable.LossStartDateTime),
					LossHistNo = ISNULL(SourceTable.LossHistNo,TargetTable.LossHistNo),
					IsAlarm = ISNULL(SourceTable.IsAlarm,TargetTable.IsAlarm),
					RunStartDateTime = ISNULL(SourceTable.RunStartDateTime,TargetTable.RunStartDateTime),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					MachineNumber = ISNULL(SourceTable.MachineNumber, TargetTable.MachineNumber)	-- DinhManh update 2025-01-14
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						CompanyCode,
						WorkCenterCode,
						MachineName,
						IsProdMachine,
						MachineTypeCode,
						IsUsed,
						IsMonitoring,
						MonitoringGroup,
						MachineRunStatus,
						LossCode,
						LossStartDateTime,
						LossHistNo,
						IsAlarm,
						RunStartDateTime,
						CreateDateTime,
						CreateUserID,
						MachineNumber	-- DinhManh update 2025-01-14
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MachineName,
							SourceTable.IsProdMachine,
							SourceTable.MachineTypeCode,
							SourceTable.IsUsed,
							SourceTable.IsMonitoring,
							SourceTable.MonitoringGroup,
							SourceTable.MachineRunStatus,
							SourceTable.LossCode,
							SourceTable.LossStartDateTime,
							SourceTable.LossHistNo,
							SourceTable.IsAlarm,
							SourceTable.RunStartDateTime,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MachineNumber	-- DinhManh update 2025-01-14
					);


			-- Process Delete Table
            MERGE STB_MachineMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							MachineCode,
							CompanyCode,
							WorkCenterCode,
							MachineName,
							IsProdMachine,
							MachineTypeCode,
							IsUsed,
							IsMonitoring,
							MonitoringGroup,
							MachineRunStatus,
							LossCode,
							LossStartDateTime,
							LossHistNo,
							IsAlarm,
							RunStartDateTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MachineNumber		-- DinhManh update 2025-01-14
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineName NVARCHAR(100),
										IsProdMachine BIT,
										MachineTypeCode VARCHAR(20),
										IsUsed BIT,
										IsMonitoring BIT,
										MonitoringGroup NVARCHAR(50),
										MachineRunStatus VARCHAR(10),
										LossCode VARCHAR(20),
										LossStartDateTime DATETIMEOFFSET,
										LossHistNo VARCHAR(20),
										IsAlarm BIT,
										RunStartDateTime DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MachineNumber VARCHAR(50)		-- DinhManh update 2025-01-14
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode
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
									OldMachineCode,
									MachineCode,
									CompanyCode,
									WorkCenterCode,
									MachineName,
									IsProdMachine,
									MachineTypeCode,
									IsUsed,
									IsMonitoring,
									MonitoringGroup,
									MachineRunStatus,
									LossCode,
									LossStartDateTime,
									LossHistNo,
									IsAlarm,
									RunStartDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MachineNumber		-- DinhManh update 2025-01-14
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineName NVARCHAR(100),
											 IsProdMachine BIT,
											 MachineTypeCode VARCHAR(20),
											 IsUsed BIT,
											 IsMonitoring BIT,
											 MonitoringGroup NVARCHAR(50),
											 MachineRunStatus VARCHAR(10),
											 LossCode VARCHAR(20),
											 LossStartDateTime DATETIMEOFFSET,
											 LossHistNo VARCHAR(20),
											 IsAlarm BIT,
											 RunStartDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MachineNumber VARCHAR(50)		-- DinhManh update 2025-01-14
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMachineCode IS NULL THEN MachineCode
										ELSE OldMachineCode
									END AS OldMachineCode,
									MachineCode,
									CompanyCode,
									WorkCenterCode,
									MachineName,
									IsProdMachine,
									MachineTypeCode,
									IsUsed,
									IsMonitoring,
									MonitoringGroup,
									MachineRunStatus,
									LossCode,
									LossStartDateTime,
									LossHistNo,
									IsAlarm,
									RunStartDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MachineNumber		-- DinhManh update 2025-01-14
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineName NVARCHAR(100),
											 IsProdMachine BIT,
											 MachineTypeCode VARCHAR(20),
											 IsUsed BIT,
											 IsMonitoring BIT,
											 MonitoringGroup NVARCHAR(50),
											 MachineRunStatus VARCHAR(10),
											 LossCode VARCHAR(20),
											 LossStartDateTime DATETIMEOFFSET,
											 LossHistNo VARCHAR(20),
											 IsAlarm BIT,
											 RunStartDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MachineNumber VARCHAR(50)		-- DinhManh update 2025-01-14
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMachineCode IS NULL THEN MachineCode
										ELSE OldMachineCode
									END AS OldMachineCode,
									MachineCode,
									CompanyCode,
									WorkCenterCode,
									MachineName,
									IsProdMachine,
									MachineTypeCode,
									IsUsed,
									IsMonitoring,
									MonitoringGroup,
									MachineRunStatus,
									LossCode,
									LossStartDateTime,
									LossHistNo,
									IsAlarm,
									RunStartDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MachineNumber		-- DinhManh update 2025-01-14
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineName NVARCHAR(100),
											 IsProdMachine BIT,
											 MachineTypeCode VARCHAR(20),
											 IsUsed BIT,
											 IsMonitoring BIT,
											 MonitoringGroup NVARCHAR(50),
											 MachineRunStatus VARCHAR(10),
											 LossCode VARCHAR(20),
											 LossStartDateTime DATETIMEOFFSET,
											 LossHistNo VARCHAR(20),
											 IsAlarm BIT,
											 RunStartDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MachineNumber VARCHAR(50)		-- DinhManh update 2025-01-14
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineCode,
								 @MachineCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MachineName,
								 @IsProdMachine,
								 @MachineTypeCode,
								 @IsUsed,
								 @IsMonitoring,
								 @MonitoringGroup,
								 @MachineRunStatus,
								 @LossCode,
								 @LossStartDateTime,
								 @LossHistNo,
								 @IsAlarm,
								 @RunStartDateTime,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @MachineNumber		-- DinhManh update 2025-01-14


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MachineMaster WHERE MachineCode = @MachineCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachineMaster',@MachineCode OUTPUT
                    END

                    INSERT INTO STB_MachineMaster
						(
						    MachineCode,
						    CompanyCode,
						    WorkCenterCode,
						    MachineName,
						    IsProdMachine,
						    MachineTypeCode,
						    IsUsed,
						    IsMonitoring,
						    MonitoringGroup,
						    MachineRunStatus,
						    LossCode,
						    LossStartDateTime,
						    LossHistNo,
						    IsAlarm,
						    RunStartDateTime,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							MachineNumber		-- DinhManh update 2025-01-14
						)
						VALUES
						(
						    @MachineCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MachineName,
						    @IsProdMachine,
						    @MachineTypeCode,
						    @IsUsed,
						    @IsMonitoring,
						    @MonitoringGroup,
						    @MachineRunStatus,
						    @LossCode,
						    @LossStartDateTime,
						    @LossHistNo,
						    @IsAlarm,
						    @RunStartDateTime,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@MachineNumber		-- DinhManh update 2025-01-14
						)

						IF @IsProdMachine = 1 BEGIN
								IF @MachineTypeCode = 'Injection' BEGIN
										INSERT INTO STB_MoldProductMachine
										(
											MachineCode,
											MachineName,
											WorkCenterCode,
											CreateDateTime,
											CreateUserID
										)
										VALUES
										(
											@MachineCode,
											@MachineName,
											@WorkCenterCode,
											GETDATE(),
											@ProcessUserID
										)
								END ELSE IF @MachineTypeCode = 'Processing' BEGIN
										INSERT INTO STB_ProductMachine
										(
											MachineCode,
											CreateDateTime,
											CreateUserID
										)
										VALUES
										(
											@MachineCode,
											GETDATE(),
											@ProcessUserID
										)
								END
						END

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MachineMaster
						SET
						    --MachineCode =   ISNULL(@MachineCode,MachineCode),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    MachineName =   ISNULL(@MachineName,MachineName),
						    IsProdMachine =   ISNULL(@IsProdMachine,IsProdMachine),
						    MachineTypeCode =   ISNULL(@MachineTypeCode,MachineTypeCode),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    IsMonitoring =   ISNULL(@IsMonitoring,IsMonitoring),
						    MonitoringGroup =   ISNULL(@MonitoringGroup,MonitoringGroup),
						    MachineRunStatus =   ISNULL(@MachineRunStatus,MachineRunStatus),
						    LossCode =   ISNULL(@LossCode,LossCode),
						    LossStartDateTime =   ISNULL(@LossStartDateTime,LossStartDateTime),
						    LossHistNo =   ISNULL(@LossHistNo,LossHistNo),
						    IsAlarm =   ISNULL(@IsAlarm,IsAlarm),
						    RunStartDateTime =   ISNULL(@RunStartDateTime,RunStartDateTime),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							MachineNumber = ISNULL(@MachineNumber, MachineNumber)		-- DinhManh update 2025-01-14
						WHERE
						    MachineCode = @OldMachineCode

						IF @IsProdMachine = 1 BEGIN
								IF @MachineTypeCode = 'Injection' BEGIN
										UPDATE	STB_MoldProductMachine
										SET
												MachineCode = @MachineCode,
												MachineName = @MachineName,
												WorkCenterCode = @WorkCenterCode,
												ChangeDateTime = GETDATE(),
												ChangeUserID = @ProcessUserID
										WHERE
												MachineCode = @OldMachineCode
								END ELSE IF @MachineTypeCode = 'Processing' BEGIN
										UPDATE	STB_ProductMachine
										SET
												MachineCode = @MachineCode,
												ChangeDateTime = GETDATE(),
												ChangeUserID = @ProcessUserID
										WHERE
												MachineCode = @OldMachineCode
								END
						END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MachineMaster
						WHERE
						    MachineCode = @OldMachineCode
					DELETE FROM STB_ProductMachine
					WHERE
							MachineCode = @OldMachineCode
					DELETE FROM	STB_MoldProductMachine
					WHERE
							MachineCode = @OldMachineCode
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
