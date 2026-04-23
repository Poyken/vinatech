
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극코팅정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingInfo_iud]
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
  DECLARE @ElectrodeMaterialCode VARCHAR(20)
  DECLARE @MaterialLotNumber VARCHAR(20)
  DECLARE @OneSideHeadGapLeft NUMERIC(20,5)
  DECLARE @OneSideHeadGapRight NUMERIC(20,5)
  DECLARE @BothSideHeadGapLeft NUMERIC(20,5)
  DECLARE @BothSideHeadGapRight NUMERIC(20,5)
  DECLARE @OneSideCoatingWidth NUMERIC(20,5)
  DECLARE @BothSideCoatingWidth NUMERIC(20,5)
  DECLARE @UnwindingValue NUMERIC(20,5)
  DECLARE @RewindingValue NUMERIC(20,5)
  DECLARE @ProductionQty NUMERIC(20,5)
  DECLARE @GoodQty NUMERIC(20,5)
  DECLARE @BadQty NUMERIC(20,5)
  DECLARE @Remark VARCHAR(1000)
  DECLARE @SpecificComment1 VARCHAR(1000)
  DECLARE @SpecificComment2 VARCHAR(1000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  -- 결착력검사결과 추가 주영진 부장님 요청 2020.10.29 By Jackaroe
  DECLARE @CohesionResult NUMERIC(20,1)
  -- 집전체 두께 추가 2022.02.25 By Jackaroe
  DECLARE @CurrentCollectorThickness NUMERIC(20,2)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeCoatingInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeCoatingInfo AS TargetTable
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
							ElectrodeMaterialCode,
							MaterialLotNumber,
							OneSideHeadGapLeft,
							OneSideHeadGapRight,
							BothSideHeadGapLeft,
							BothSideHeadGapRight,
							OneSideCoatingWidth,
							BothSideCoatingWidth,
							UnwindingValue,
							RewindingValue,
							ProductionQty,
							GoodQty,
							BadQty,
							Remark,
							SpecificComment1,
							SpecificComment2,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CohesionResult,
							CurrentCollectorThickness
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
										ElectrodeMaterialCode VARCHAR(20),
										MaterialLotNumber VARCHAR(20),
										OneSideHeadGapLeft NUMERIC(20,5),
										OneSideHeadGapRight NUMERIC(20,5),
										BothSideHeadGapLeft NUMERIC(20,5),
										BothSideHeadGapRight NUMERIC(20,5),
										OneSideCoatingWidth NUMERIC(20,5),
										BothSideCoatingWidth NUMERIC(20,5),
										UnwindingValue NUMERIC(20,5),
										RewindingValue NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQty NUMERIC(20,5),
										BadQty NUMERIC(20,5),
										Remark VARCHAR(1000),
										SpecificComment1 VARCHAR(1000),
										SpecificComment2 VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CohesionResult NUMERIC(20,1),
										CurrentCollectorThickness NUMERIC(20,2)
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
					ElectrodeMaterialCode = ISNULL(SourceTable.ElectrodeMaterialCode,TargetTable.ElectrodeMaterialCode),
					MaterialLotNumber = ISNULL(SourceTable.MaterialLotNumber,TargetTable.MaterialLotNumber),
					OneSideHeadGapLeft = ISNULL(SourceTable.OneSideHeadGapLeft,TargetTable.OneSideHeadGapLeft),
					OneSideHeadGapRight = ISNULL(SourceTable.OneSideHeadGapRight,TargetTable.OneSideHeadGapRight),
					BothSideHeadGapLeft = ISNULL(SourceTable.BothSideHeadGapLeft,TargetTable.BothSideHeadGapLeft),
					BothSideHeadGapRight = ISNULL(SourceTable.BothSideHeadGapRight,TargetTable.BothSideHeadGapRight),
					OneSideCoatingWidth = ISNULL(SourceTable.OneSideCoatingWidth,TargetTable.OneSideCoatingWidth),
					BothSideCoatingWidth = ISNULL(SourceTable.BothSideCoatingWidth,TargetTable.BothSideCoatingWidth),
					UnwindingValue = ISNULL(SourceTable.UnwindingValue,TargetTable.UnwindingValue),
					RewindingValue = ISNULL(SourceTable.RewindingValue,TargetTable.RewindingValue),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQty = ISNULL(SourceTable.GoodQty,TargetTable.GoodQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					SpecificComment1 = ISNULL(SourceTable.SpecificComment1,TargetTable.SpecificComment1),
					SpecificComment2 = ISNULL(SourceTable.SpecificComment2,TargetTable.SpecificComment2),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CohesionResult = ISNULL(SourceTable.CohesionResult,TargetTable.CohesionResult),
					CurrentCollectorThickness = ISNULL(SourceTable.CurrentCollectorThickness,TargetTable.CurrentCollectorThickness)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						ElectrodeMaterialCode,
						MaterialLotNumber,
						OneSideHeadGapLeft,
						OneSideHeadGapRight,
						BothSideHeadGapLeft,
						BothSideHeadGapRight,
						OneSideCoatingWidth,
						BothSideCoatingWidth,
						UnwindingValue,
						RewindingValue,
						ProductionQty,
						GoodQty,
						BadQty,
						Remark,
						SpecificComment1,
						SpecificComment2,
						CreateDateTime,
						CreateUserID,
						CohesionResult,
						CurrentCollectorThickness
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.ElectrodeMaterialCode,
							SourceTable.MaterialLotNumber,
							SourceTable.OneSideHeadGapLeft,
							SourceTable.OneSideHeadGapRight,
							SourceTable.BothSideHeadGapLeft,
							SourceTable.BothSideHeadGapRight,
							SourceTable.OneSideCoatingWidth,
							SourceTable.BothSideCoatingWidth,
							SourceTable.UnwindingValue,
							SourceTable.RewindingValue,
							SourceTable.ProductionQty,
							SourceTable.GoodQty,
							SourceTable.BadQty,
							SourceTable.Remark,
							SourceTable.SpecificComment1,
							SourceTable.SpecificComment2,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CohesionResult,
							SourceTable.CurrentCollectorThickness
					);


			-- Process Update Table
            MERGE STB_ElectrodeCoatingInfo AS TargetTable
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
							ElectrodeMaterialCode,
							MaterialLotNumber,
							OneSideHeadGapLeft,
							OneSideHeadGapRight,
							BothSideHeadGapLeft,
							BothSideHeadGapRight,
							OneSideCoatingWidth,
							BothSideCoatingWidth,
							UnwindingValue,
							RewindingValue,
							ProductionQty,
							GoodQty,
							BadQty,
							Remark,
							SpecificComment1,
							SpecificComment2,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CohesionResult,
							CurrentCollectorThickness
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
										ElectrodeMaterialCode VARCHAR(20),
										MaterialLotNumber VARCHAR(20),
										OneSideHeadGapLeft NUMERIC(20,5),
										OneSideHeadGapRight NUMERIC(20,5),
										BothSideHeadGapLeft NUMERIC(20,5),
										BothSideHeadGapRight NUMERIC(20,5),
										OneSideCoatingWidth NUMERIC(20,5),
										BothSideCoatingWidth NUMERIC(20,5),
										UnwindingValue NUMERIC(20,5),
										RewindingValue NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQty NUMERIC(20,5),
										BadQty NUMERIC(20,5),
										Remark VARCHAR(1000),
										SpecificComment1 VARCHAR(1000),
										SpecificComment2 VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CohesionResult NUMERIC(20,1),
										CurrentCollectorThickness NUMERIC(20,2)
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
					ElectrodeMaterialCode = ISNULL(SourceTable.ElectrodeMaterialCode,TargetTable.ElectrodeMaterialCode),
					MaterialLotNumber = ISNULL(SourceTable.MaterialLotNumber,TargetTable.MaterialLotNumber),
					OneSideHeadGapLeft = ISNULL(SourceTable.OneSideHeadGapLeft,TargetTable.OneSideHeadGapLeft),
					OneSideHeadGapRight = ISNULL(SourceTable.OneSideHeadGapRight,TargetTable.OneSideHeadGapRight),
					BothSideHeadGapLeft = ISNULL(SourceTable.BothSideHeadGapLeft,TargetTable.BothSideHeadGapLeft),
					BothSideHeadGapRight = ISNULL(SourceTable.BothSideHeadGapRight,TargetTable.BothSideHeadGapRight),
					OneSideCoatingWidth = ISNULL(SourceTable.OneSideCoatingWidth,TargetTable.OneSideCoatingWidth),
					BothSideCoatingWidth = ISNULL(SourceTable.BothSideCoatingWidth,TargetTable.BothSideCoatingWidth),
					UnwindingValue = ISNULL(SourceTable.UnwindingValue,TargetTable.UnwindingValue),
					RewindingValue = ISNULL(SourceTable.RewindingValue,TargetTable.RewindingValue),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQty = ISNULL(SourceTable.GoodQty,TargetTable.GoodQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					SpecificComment1 = ISNULL(SourceTable.SpecificComment1,TargetTable.SpecificComment1),
					SpecificComment2 = ISNULL(SourceTable.SpecificComment2,TargetTable.SpecificComment2),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CohesionResult = ISNULL(SourceTable.CohesionResult,TargetTable.CohesionResult),
					CurrentCollectorThickness = ISNULL(SourceTable.CurrentCollectorThickness,TargetTable.CurrentCollectorThickness)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						ElectrodeMaterialCode,
						MaterialLotNumber,
						OneSideHeadGapLeft,
						OneSideHeadGapRight,
						BothSideHeadGapLeft,
						BothSideHeadGapRight,
						OneSideCoatingWidth,
						BothSideCoatingWidth,
						UnwindingValue,
						RewindingValue,
						ProductionQty,
						GoodQty,
						BadQty,
						Remark,
						SpecificComment1,
						SpecificComment2,
						CreateDateTime,
						CreateUserID,
						CohesionResult,
						CurrentCollectorThickness
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.ElectrodeMaterialCode,
							SourceTable.MaterialLotNumber,
							SourceTable.OneSideHeadGapLeft,
							SourceTable.OneSideHeadGapRight,
							SourceTable.BothSideHeadGapLeft,
							SourceTable.BothSideHeadGapRight,
							SourceTable.OneSideCoatingWidth,
							SourceTable.BothSideCoatingWidth,
							SourceTable.UnwindingValue,
							SourceTable.RewindingValue,
							SourceTable.ProductionQty,
							SourceTable.GoodQty,
							SourceTable.BadQty,
							SourceTable.Remark,
							SourceTable.SpecificComment1,
							SourceTable.SpecificComment2,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CohesionResult,
							SourceTable.CurrentCollectorThickness
					);


			-- Process Delete Table
            MERGE STB_ElectrodeCoatingInfo AS TargetTable
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
							ElectrodeMaterialCode,
							MaterialLotNumber,
							OneSideHeadGapLeft,
							OneSideHeadGapRight,
							BothSideHeadGapLeft,
							BothSideHeadGapRight,
							OneSideCoatingWidth,
							BothSideCoatingWidth,
							UnwindingValue,
							RewindingValue,
							ProductionQty,
							GoodQty,
							BadQty,
							Remark,
							SpecificComment1,
							SpecificComment2,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CohesionResult,
							CurrentCollectorThickness
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
										ElectrodeMaterialCode VARCHAR(20),
										MaterialLotNumber VARCHAR(20),
										OneSideHeadGapLeft NUMERIC(20,5),
										OneSideHeadGapRight NUMERIC(20,5),
										BothSideHeadGapLeft NUMERIC(20,5),
										BothSideHeadGapRight NUMERIC(20,5),
										OneSideCoatingWidth NUMERIC(20,5),
										BothSideCoatingWidth NUMERIC(20,5),
										UnwindingValue NUMERIC(20,5),
										RewindingValue NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQty NUMERIC(20,5),
										BadQty NUMERIC(20,5),
										Remark VARCHAR(1000),
										SpecificComment1 VARCHAR(1000),
										SpecificComment2 VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CohesionResult NUMERIC(20,1),
										CurrentCollectorThickness NUMERIC(20,2)
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
									ElectrodeMaterialCode,
									MaterialLotNumber,
									OneSideHeadGapLeft,
									OneSideHeadGapRight,
									BothSideHeadGapLeft,
									BothSideHeadGapRight,
									OneSideCoatingWidth,
									BothSideCoatingWidth,
									UnwindingValue,
									RewindingValue,
									ProductionQty,
									GoodQty,
									BadQty,
									Remark,
									SpecificComment1,
									SpecificComment2,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CohesionResult,
									CurrentCollectorThickness
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
											 ElectrodeMaterialCode VARCHAR(20),
											 MaterialLotNumber VARCHAR(20),
											 OneSideHeadGapLeft NUMERIC(20,5),
											 OneSideHeadGapRight NUMERIC(20,5),
											 BothSideHeadGapLeft NUMERIC(20,5),
											 BothSideHeadGapRight NUMERIC(20,5),
											 OneSideCoatingWidth NUMERIC(20,5),
											 BothSideCoatingWidth NUMERIC(20,5),
											 UnwindingValue NUMERIC(20,5),
											 RewindingValue NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQty NUMERIC(20,5),
											 BadQty NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 SpecificComment1 VARCHAR(1000),
											 SpecificComment2 VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CohesionResult NUMERIC(20,1),
											 CurrentCollectorThickness NUMERIC(20,2)
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
									ElectrodeMaterialCode,
									MaterialLotNumber,
									OneSideHeadGapLeft,
									OneSideHeadGapRight,
									BothSideHeadGapLeft,
									BothSideHeadGapRight,
									OneSideCoatingWidth,
									BothSideCoatingWidth,
									UnwindingValue,
									RewindingValue,
									ProductionQty,
									GoodQty,
									BadQty,
									Remark,
									SpecificComment1,
									SpecificComment2,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CohesionResult,
									CurrentCollectorThickness
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
											 ElectrodeMaterialCode VARCHAR(20),
											 MaterialLotNumber VARCHAR(20),
											 OneSideHeadGapLeft NUMERIC(20,5),
											 OneSideHeadGapRight NUMERIC(20,5),
											 BothSideHeadGapLeft NUMERIC(20,5),
											 BothSideHeadGapRight NUMERIC(20,5),
											 OneSideCoatingWidth NUMERIC(20,5),
											 BothSideCoatingWidth NUMERIC(20,5),
											 UnwindingValue NUMERIC(20,5),
											 RewindingValue NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQty NUMERIC(20,5),
											 BadQty NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 SpecificComment1 VARCHAR(1000),
											 SpecificComment2 VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CohesionResult NUMERIC(20,1),
											 CurrentCollectorThickness NUMERIC(20,2)
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
									ElectrodeMaterialCode,
									MaterialLotNumber,
									OneSideHeadGapLeft,
									OneSideHeadGapRight,
									BothSideHeadGapLeft,
									BothSideHeadGapRight,
									OneSideCoatingWidth,
									BothSideCoatingWidth,
									UnwindingValue,
									RewindingValue,
									ProductionQty,
									GoodQty,
									BadQty,
									Remark,
									SpecificComment1,
									SpecificComment2,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CohesionResult,
									CurrentCollectorThickness
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
											 ElectrodeMaterialCode VARCHAR(20),
											 MaterialLotNumber VARCHAR(20),
											 OneSideHeadGapLeft NUMERIC(20,5),
											 OneSideHeadGapRight NUMERIC(20,5),
											 BothSideHeadGapLeft NUMERIC(20,5),
											 BothSideHeadGapRight NUMERIC(20,5),
											 OneSideCoatingWidth NUMERIC(20,5),
											 BothSideCoatingWidth NUMERIC(20,5),
											 UnwindingValue NUMERIC(20,5),
											 RewindingValue NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQty NUMERIC(20,5),
											 BadQty NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 SpecificComment1 VARCHAR(1000),
											 SpecificComment2 VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CohesionResult NUMERIC(20,1),
											 CurrentCollectorThickness NUMERIC(20,2)
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
								 @ElectrodeMaterialCode,
								 @MaterialLotNumber,
								 @OneSideHeadGapLeft,
								 @OneSideHeadGapRight,
								 @BothSideHeadGapLeft,
								 @BothSideHeadGapRight,
								 @OneSideCoatingWidth,
								 @BothSideCoatingWidth,
								 @UnwindingValue,
								 @RewindingValue,
								 @ProductionQty,
								 @GoodQty,
								 @BadQty,
								 @Remark,
								 @SpecificComment1,
								 @SpecificComment2,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @CohesionResult,
								 @CurrentCollectorThickness


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeCoatingInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeCoatingInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeCoatingInfo
						(
						    ElectrodeLotNumber,
						    MachineCode,
						    WorkDate,
						    WorkerCode,
						    Temperature,
						    Humidity,
						    ElectrodeMaterialCode,
						    MaterialLotNumber,
						    OneSideHeadGapLeft,
						    OneSideHeadGapRight,
						    BothSideHeadGapLeft,
						    BothSideHeadGapRight,
						    OneSideCoatingWidth,
						    BothSideCoatingWidth,
						    UnwindingValue,
						    RewindingValue,
						    ProductionQty,
						    GoodQty,
						    BadQty,
						    Remark,
						    SpecificComment1,
						    SpecificComment2,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							CohesionResult,
							CurrentCollectorThickness
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @MachineCode,
						    @WorkDate,
						    @WorkerCode,
						    @Temperature,
						    @Humidity,
						    @ElectrodeMaterialCode,
						    @MaterialLotNumber,
						    @OneSideHeadGapLeft,
						    @OneSideHeadGapRight,
						    @BothSideHeadGapLeft,
						    @BothSideHeadGapRight,
						    @OneSideCoatingWidth,
						    @BothSideCoatingWidth,
						    @UnwindingValue,
						    @RewindingValue,
						    @ProductionQty,
						    @GoodQty,
						    @BadQty,
						    @Remark,
						    @SpecificComment1,
						    @SpecificComment2,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@CohesionResult,
							@CurrentCollectorThickness
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeCoatingInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    WorkDate =   ISNULL(@WorkDate,WorkDate),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    Temperature =   ISNULL(@Temperature,Temperature),
						    Humidity =   ISNULL(@Humidity,Humidity),
						    ElectrodeMaterialCode =   ISNULL(@ElectrodeMaterialCode,ElectrodeMaterialCode),
						    MaterialLotNumber =   ISNULL(@MaterialLotNumber,MaterialLotNumber),
						    OneSideHeadGapLeft =   ISNULL(@OneSideHeadGapLeft,OneSideHeadGapLeft),
						    OneSideHeadGapRight =   ISNULL(@OneSideHeadGapRight,OneSideHeadGapRight),
						    BothSideHeadGapLeft =   ISNULL(@BothSideHeadGapLeft,BothSideHeadGapLeft),
						    BothSideHeadGapRight =   ISNULL(@BothSideHeadGapRight,BothSideHeadGapRight),
						    OneSideCoatingWidth =   ISNULL(@OneSideCoatingWidth,OneSideCoatingWidth),
						    BothSideCoatingWidth =   ISNULL(@BothSideCoatingWidth,BothSideCoatingWidth),
						    UnwindingValue =   ISNULL(@UnwindingValue,UnwindingValue),
						    RewindingValue =   ISNULL(@RewindingValue,RewindingValue),
						    ProductionQty =   ISNULL(@ProductionQty,ProductionQty),
						    GoodQty =   ISNULL(@GoodQty,GoodQty),
						    BadQty =   ISNULL(@BadQty,BadQty),
						    Remark =   ISNULL(@Remark,Remark),
						    SpecificComment1 =   ISNULL(@SpecificComment1,SpecificComment1),
						    SpecificComment2 =   ISNULL(@SpecificComment2,SpecificComment2),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							CohesionResult =   ISNULL(@CohesionResult,CohesionResult),
							CurrentCollectorThickness =   ISNULL(@CurrentCollectorThickness,CurrentCollectorThickness)
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeCoatingInfo
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
