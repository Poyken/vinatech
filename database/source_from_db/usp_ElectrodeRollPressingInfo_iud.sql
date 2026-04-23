
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극롤프레스정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingInfo_iud]
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
  DECLARE @OldElectrodeLotNumber VARCHAR(20)
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @WorkDate DATETIME
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @Temperature NUMERIC(20,5)
  DECLARE @Humidity NUMERIC(20,5)
  DECLARE @RollingDensityValue NUMERIC(20,5)
  DECLARE @RollingDensityResult VARCHAR(10)
  DECLARE @HeadGapInitLeft VARCHAR(10)
  DECLARE @HeadGapInitRight VARCHAR(10)
  DECLARE @ProdConTemp NUMERIC(20,5)
  DECLARE @ProdConSpeed NUMERIC(20,5)
  DECLARE @ProductionQty NUMERIC(20,5)
  DECLARE @GoodQty NUMERIC(20,5)
  DECLARE @BadQty NUMERIC(20,5)
  DECLARE @VisualInspectionResult VARCHAR(1000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeRollPressingInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeRollPressingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							ElectrodeLotNumber,
							MachineCode,
							WorkDate,
							WorkerCode,
							Temperature,
							Humidity,
							RollingDensityValue,
							RollingDensityResult,
							HeadGapInitLeft,
							HeadGapInitRight,
							ProdConTemp,
							ProdConSpeed,
							ProductionQty,
							GoodQty,
							BadQty,
							VisualInspectionResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										ElectrodeLotNumber VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										Temperature NUMERIC(20,5),
										Humidity NUMERIC(20,5),
										RollingDensityValue NUMERIC(20,5),
										RollingDensityResult VARCHAR(10),
										HeadGapInitLeft VARCHAR(10),
										HeadGapInitRight VARCHAR(10),
										ProdConTemp NUMERIC(20,5),
										ProdConSpeed NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQty NUMERIC(20,5),
										BadQty NUMERIC(20,5),
										VisualInspectionResult VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					WorkDate = ISNULL(SourceTable.WorkDate,TargetTable.WorkDate),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					Temperature = ISNULL(SourceTable.Temperature,TargetTable.Temperature),
					Humidity = ISNULL(SourceTable.Humidity,TargetTable.Humidity),
					RollingDensityValue = ISNULL(SourceTable.RollingDensityValue,TargetTable.RollingDensityValue),
					RollingDensityResult = ISNULL(SourceTable.RollingDensityResult,TargetTable.RollingDensityResult),
					HeadGapInitLeft = ISNULL(SourceTable.HeadGapInitLeft,TargetTable.HeadGapInitLeft),
					HeadGapInitRight = ISNULL(SourceTable.HeadGapInitRight,TargetTable.HeadGapInitRight),
					ProdConTemp = ISNULL(SourceTable.ProdConTemp,TargetTable.ProdConTemp),
					ProdConSpeed = ISNULL(SourceTable.ProdConSpeed,TargetTable.ProdConSpeed),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQty = ISNULL(SourceTable.GoodQty,TargetTable.GoodQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					VisualInspectionResult = ISNULL(SourceTable.VisualInspectionResult,TargetTable.VisualInspectionResult),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						RollingDensityValue,
						RollingDensityResult,
						HeadGapInitLeft,
						HeadGapInitRight,
						ProdConTemp,
						ProdConSpeed,
						ProductionQty,
						GoodQty,
						BadQty,
						VisualInspectionResult,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.RollingDensityValue,
							SourceTable.RollingDensityResult,
							SourceTable.HeadGapInitLeft,
							SourceTable.HeadGapInitRight,
							SourceTable.ProdConTemp,
							SourceTable.ProdConSpeed,
							SourceTable.ProductionQty,
							SourceTable.GoodQty,
							SourceTable.BadQty,
							SourceTable.VisualInspectionResult,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeRollPressingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							ElectrodeLotNumber,
							MachineCode,
							WorkDate,
							WorkerCode,
							Temperature,
							Humidity,
							RollingDensityValue,
							RollingDensityResult,
							HeadGapInitLeft,
							HeadGapInitRight,
							ProdConTemp,
							ProdConSpeed,
							ProductionQty,
							GoodQty,
							BadQty,
							VisualInspectionResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										ElectrodeLotNumber VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										Temperature NUMERIC(20,5),
										Humidity NUMERIC(20,5),
										RollingDensityValue NUMERIC(20,5),
										RollingDensityResult VARCHAR(10),
										HeadGapInitLeft VARCHAR(10),
										HeadGapInitRight VARCHAR(10),
										ProdConTemp NUMERIC(20,5),
										ProdConSpeed NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQty NUMERIC(20,5),
										BadQty NUMERIC(20,5),
										VisualInspectionResult VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					WorkDate = ISNULL(SourceTable.WorkDate,TargetTable.WorkDate),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					Temperature = ISNULL(SourceTable.Temperature,TargetTable.Temperature),
					Humidity = ISNULL(SourceTable.Humidity,TargetTable.Humidity),
					RollingDensityValue = ISNULL(SourceTable.RollingDensityValue,TargetTable.RollingDensityValue),
					RollingDensityResult = ISNULL(SourceTable.RollingDensityResult,TargetTable.RollingDensityResult),
					HeadGapInitLeft = ISNULL(SourceTable.HeadGapInitLeft,TargetTable.HeadGapInitLeft),
					HeadGapInitRight = ISNULL(SourceTable.HeadGapInitRight,TargetTable.HeadGapInitRight),
					ProdConTemp = ISNULL(SourceTable.ProdConTemp,TargetTable.ProdConTemp),
					ProdConSpeed = ISNULL(SourceTable.ProdConSpeed,TargetTable.ProdConSpeed),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQty = ISNULL(SourceTable.GoodQty,TargetTable.GoodQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					VisualInspectionResult = ISNULL(SourceTable.VisualInspectionResult,TargetTable.VisualInspectionResult),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						RollingDensityValue,
						RollingDensityResult,
						HeadGapInitLeft,
						HeadGapInitRight,
						ProdConTemp,
						ProdConSpeed,
						ProductionQty,
						GoodQty,
						BadQty,
						VisualInspectionResult,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.RollingDensityValue,
							SourceTable.RollingDensityResult,
							SourceTable.HeadGapInitLeft,
							SourceTable.HeadGapInitRight,
							SourceTable.ProdConTemp,
							SourceTable.ProdConSpeed,
							SourceTable.ProductionQty,
							SourceTable.GoodQty,
							SourceTable.BadQty,
							SourceTable.VisualInspectionResult,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeRollPressingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							ElectrodeLotNumber,
							MachineCode,
							WorkDate,
							WorkerCode,
							Temperature,
							Humidity,
							RollingDensityValue,
							RollingDensityResult,
							HeadGapInitLeft,
							HeadGapInitRight,
							ProdConTemp,
							ProdConSpeed,
							ProductionQty,
							GoodQty,
							BadQty,
							VisualInspectionResult,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										ElectrodeLotNumber VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										Temperature NUMERIC(20,5),
										Humidity NUMERIC(20,5),
										RollingDensityValue NUMERIC(20,5),
										RollingDensityResult VARCHAR(10),
										HeadGapInitLeft VARCHAR(10),
										HeadGapInitRight VARCHAR(10),
										ProdConTemp NUMERIC(20,5),
										ProdConSpeed NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQty NUMERIC(20,5),
										BadQty NUMERIC(20,5),
										VisualInspectionResult VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber
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
									OldElectrodeLotNumber,
									ElectrodeLotNumber,
									MachineCode,
									WorkDate,
									WorkerCode,
									Temperature,
									Humidity,
									RollingDensityValue,
									RollingDensityResult,
									HeadGapInitLeft,
									HeadGapInitRight,
									ProdConTemp,
									ProdConSpeed,
									ProductionQty,
									GoodQty,
									BadQty,
									VisualInspectionResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 ElectrodeLotNumber VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 RollingDensityValue NUMERIC(20,5),
											 RollingDensityResult VARCHAR(10),
											 HeadGapInitLeft VARCHAR(10),
											 HeadGapInitRight VARCHAR(10),
											 ProdConTemp NUMERIC(20,5),
											 ProdConSpeed NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQty NUMERIC(20,5),
											 BadQty NUMERIC(20,5),
											 VisualInspectionResult VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									ElectrodeLotNumber,
									MachineCode,
									WorkDate,
									WorkerCode,
									Temperature,
									Humidity,
									RollingDensityValue,
									RollingDensityResult,
									HeadGapInitLeft,
									HeadGapInitRight,
									ProdConTemp,
									ProdConSpeed,
									ProductionQty,
									GoodQty,
									BadQty,
									VisualInspectionResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 ElectrodeLotNumber VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 RollingDensityValue NUMERIC(20,5),
											 RollingDensityResult VARCHAR(10),
											 HeadGapInitLeft VARCHAR(10),
											 HeadGapInitRight VARCHAR(10),
											 ProdConTemp NUMERIC(20,5),
											 ProdConSpeed NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQty NUMERIC(20,5),
											 BadQty NUMERIC(20,5),
											 VisualInspectionResult VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									ElectrodeLotNumber,
									MachineCode,
									WorkDate,
									WorkerCode,
									Temperature,
									Humidity,
									RollingDensityValue,
									RollingDensityResult,
									HeadGapInitLeft,
									HeadGapInitRight,
									ProdConTemp,
									ProdConSpeed,
									ProductionQty,
									GoodQty,
									BadQty,
									VisualInspectionResult,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 ElectrodeLotNumber VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 RollingDensityValue NUMERIC(20,5),
											 RollingDensityResult VARCHAR(10),
											 HeadGapInitLeft VARCHAR(10),
											 HeadGapInitRight VARCHAR(10),
											 ProdConTemp NUMERIC(20,5),
											 ProdConSpeed NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQty NUMERIC(20,5),
											 BadQty NUMERIC(20,5),
											 VisualInspectionResult VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeLotNumber,
								 @ElectrodeLotNumber,
								 @MachineCode,
								 @WorkDate,
								 @WorkerCode,
								 @Temperature,
								 @Humidity,
								 @RollingDensityValue,
								 @RollingDensityResult,
								 @HeadGapInitLeft,
								 @HeadGapInitRight,
								 @ProdConTemp,
								 @ProdConSpeed,
								 @ProductionQty,
								 @GoodQty,
								 @BadQty,
								 @VisualInspectionResult,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeRollPressingInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeRollPressingInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeRollPressingInfo
						(
						    ElectrodeLotNumber,
						    MachineCode,
						    WorkDate,
						    WorkerCode,
						    Temperature,
						    Humidity,
						    RollingDensityValue,
						    RollingDensityResult,
						    HeadGapInitLeft,
						    HeadGapInitRight,
						    ProdConTemp,
						    ProdConSpeed,
						    ProductionQty,
						    GoodQty,
						    BadQty,
						    VisualInspectionResult,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @MachineCode,
						    @WorkDate,
						    @WorkerCode,
						    @Temperature,
						    @Humidity,
						    @RollingDensityValue,
						    @RollingDensityResult,
						    @HeadGapInitLeft,
						    @HeadGapInitRight,
						    @ProdConTemp,
						    @ProdConSpeed,
						    @ProductionQty,
						    @GoodQty,
						    @BadQty,
						    @VisualInspectionResult,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeRollPressingInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    WorkDate =   ISNULL(@WorkDate,WorkDate),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    Temperature =   ISNULL(@Temperature,Temperature),
						    Humidity =   ISNULL(@Humidity,Humidity),
						    RollingDensityValue =   ISNULL(@RollingDensityValue,RollingDensityValue),
						    RollingDensityResult =   ISNULL(@RollingDensityResult,RollingDensityResult),
						    HeadGapInitLeft =   ISNULL(@HeadGapInitLeft,HeadGapInitLeft),
						    HeadGapInitRight =   ISNULL(@HeadGapInitRight,HeadGapInitRight),
						    ProdConTemp =   ISNULL(@ProdConTemp,ProdConTemp),
						    ProdConSpeed =   ISNULL(@ProdConSpeed,ProdConSpeed),
						    ProductionQty =   ISNULL(@ProductionQty,ProductionQty),
						    GoodQty =   ISNULL(@GoodQty,GoodQty),
						    BadQty =   ISNULL(@BadQty,BadQty),
						    VisualInspectionResult =   ISNULL(@VisualInspectionResult,VisualInspectionResult),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeRollPressingInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber
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
