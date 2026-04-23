
-- =============================================
-- Author: Mr.Tung(nguyentung@vina.co.kr)
-- Create date: 2021-11-05
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodCoatingInfo_Viscosity_VVT_iud]
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
  DECLARE @ViscosityValue float
  DECLARE @ViscosityResult varchar(50)
  declare @TocDo_Coating float


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeCoatingInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
     BEGIN

   
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
							CohesionResult
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
										CohesionResult NUMERIC(20,1)
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
					CohesionResult = ISNULL(SourceTable.CohesionResult,TargetTable.CohesionResult)
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
						CohesionResult
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
							SourceTable.CohesionResult
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
							CohesionResult
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
										CohesionResult NUMERIC(20,1)
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
					CohesionResult = ISNULL(SourceTable.CohesionResult,TargetTable.CohesionResult)
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
						CohesionResult
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
							SourceTable.CohesionResult
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
							CohesionResult
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
										CohesionResult NUMERIC(20,1)
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
		
	  



	  ---process 2 step for ViscosityValue
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
									ViscosityValue ,
									ViscosityResult,
									TocDo_Coating

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
											 ViscosityValue float,
											 ViscosityResult varchar(50),
											TocDo_Coating float
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
									ViscosityValue ,
									ViscosityResult,
									TocDo_Coating

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
											ViscosityValue float,
											ViscosityResult varchar(50),
											TocDo_Coating float
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
									ViscosityValue ,
											ViscosityResult ,
									TocDo_Coating
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
											 ViscosityValue float,
											ViscosityResult varchar(50),
									TocDo_Coating float
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
								 @ViscosityValue ,
											@ViscosityResult ,
									@TocDo_Coating


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				declare @tmpElectrodeMaterialCode varchar(250) = substring(rtrim(ltrim(@ElectrodeMaterialCode)),1,12);
				declare @tmpElectrodeLotNumber varchar(50) = @ElectrodeLotNumber;

			;with checkTblElectrodeMaterialType as (
				select 'CREYK85' as coating, 'SREYK85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFYK85' as coating, 'SRFYK85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'CREYO85' as coating, 'SREYO85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFYO85' as coating, 'SRFYO85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'CRECL85' as coating, 'SRECL85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFCL85' as coating, 'SRFCL85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'CRECO85' as coating, 'SRECO85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFCO85' as coating, 'SRFCO85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'CREML83' as coating, 'SREML83' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFML83' as coating, 'SRFML83' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'CREMO83' as coating, 'SREMO83' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFMO83' as coating, 'SRFMO83' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'CREMM75' as coating, 'SREMM75' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CREMO75' as coating, 'SREMO75' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCREYK85' as coating, 'HSREYK85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCRFYK85' as coating, 'HSRFYK85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'HCREYO85' as coating, 'HSREYO85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCRFYO85' as coating, 'HSRFYO85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'HCRECL85' as coating, 'HSRECL85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCRFCL85' as coating, 'HSRFCL85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'HCRECO85' as coating, 'HSRECO85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCRFCO85' as coating, 'HSRFCO85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'HCREML83' as coating, 'HSREML83' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCRFML83' as coating, 'HSRFML83' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'HCREMO83' as coating, 'HSREMO83' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCRFMO83' as coating, 'HSRFMO83' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'HCREMM75' as coating, 'HSREMM75' as slitting, 'CS200' as childmaterialcode  union all 
				select 'HCREMO75' as coating, 'HSREMO75' as slitting, 'CS200' as childmaterialcode  union all 
				select 'ECREYK85' as coating, 'ESREYK85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'ECRFYK85' as coating, 'ESRFYK85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'ECREYO85' as coating, 'ESREYO85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'ECRFYO85' as coating, 'ESRFYO85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'ECRECL85' as coating, 'ESRECL85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'ECRFCL85' as coating, 'ESRFCL85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'ECRECO85' as coating, 'ESRECO85' as slitting, 'CS200' as childmaterialcode  union all 
				select 'ECRFCO85' as coating, 'ESRFCO85' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'ECREML83' as coating, 'ESREML83' as slitting, 'CS200' as childmaterialcode  union all 
				select 'ECRFML83' as coating, 'ESRFML83' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'ECREMO83' as coating, 'ESREMO83' as slitting, 'CS200' as childmaterialcode  union all 
				select 'ECRFMO83' as coating, 'ESRFMO83' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'ECREMM75' as coating, 'ESREMM75' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CREYK85A200' as coating, 'SREYK85A200' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFYK85A200' as coating, 'SRFYK85A200' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all 
				select 'CREYO85A200' as coating, 'SREYO85A200' as slitting, 'CS200' as childmaterialcode  union all 
				select 'CRFYO85A200' as coating, 'SRFYO85A200' as slitting, 'CF200F-2.0VF' as childmaterialcode  union all
				select '%Forming%' as coating, '%Forming%' as slitting, 'CF200F-2.0VF' as childmaterialcode   union all
				select '%Etching%' as coating, '%Etching%' as slitting, 'CS200' as childmaterialcode   union all
				select '%Coat%(-)%' as coating, '%Slit%(-)%' as slitting, 'CF200F-2.0VF' as childmaterialcode   union all
				select '%Coat%(+)%' as coating, '%Slit%(+)%' as slitting, 'CS200' as childmaterialcode  
			)
			select * from STB_SetInfo si  with(nolock) 
			left outer join stb_materialmaster mm with(nolock) on si.MaterialCode = mm.MaterialCode
			join checkTblElectrodeMaterialType ctem on (ctem.coating = si.MaterialCode or mm.MaterialName like coating )
			where ctem.childmaterialcode = @tmpElectrodeMaterialCode
			and si.Barcode=@tmpElectrodeLotNumber

				if(@@ROWCOUNT=0) 
				begin
					select @tmpElectrodeMaterialCode = 'Ma Code AL Foil sai Cuc Am, Cuc Duong: ' + @tmpElectrodeMaterialCode + ' . Vui long kiem tra lai.';
					raiserror (@tmpElectrodeMaterialCode,16,1);
					break;
					return;
				end


			select @ElectrodeMaterialCode=  upper(@ElectrodeMaterialCode) +
						case when @ElectrodeMaterialCode='CS200' then ' (+) ' when @ElectrodeMaterialCode='CF200F-2.0VF' then ' (-) ' end ;

			
			declare @ViscosityMin int = 2400
			declare @ViscosityMax int = 3600
			select*from STB_ElectrodeMixStepInfo
			where ElectrodeMaterialCode like '%GAHSCB-001' and ElectrodeLotNumber=@ElectrodeLotNumber
			if(@@ROWCOUNT>0)begin
				select @ViscosityMin  = 1800
				select @ViscosityMax  = 2200
			end


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
							CohesionResult
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @MachineCode,
						    dateadd(hour,2,@WorkDate),
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
							@CohesionResult
						)

						--select @ViscosityResult = convert(varchar(200),@ViscosityValue)
						--raiserror (@ViscosityResult,16,1)
						--return;
					

						insert into STB_Viscosity_ElectrodCoatingInfo_VVT(ElectrodeLotNumber,ViscosityValue,ViscosityResult,TocDo_Coating,CreateDateTime,CreateUserId)
						values (@ElectrodeLotNumber,@ViscosityValue,(case when @ViscosityValue>=(@ViscosityMin) AND @ViscosityValue<=(@ViscosityMax) then 'OK' else 'NG' end),@TocDo_Coating,@CreateDateTime,@CreateUserId)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

                    UPDATE STB_ElectrodeCoatingInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    WorkDate =   ISNULL(dateadd(hour,2,@WorkDate),WorkDate),
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
							CohesionResult =   ISNULL(@CohesionResult,CohesionResult)
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber

						--				select @ViscosityResult = convert(varchar(200),@ViscosityValue)
						--		raiserror (@ViscosityResult,16,1)
						--return;

						update STB_Viscosity_ElectrodCoatingInfo_VVT
						set 
						--ElectrodeLotNumber=@ElectrodeLotNumber,
						ViscosityValue=@ViscosityValue,
						ViscosityResult=(case when @ViscosityValue>=(@ViscosityMin) AND @ViscosityValue<=(@ViscosityMax) then 'OK' else 'NG' end),
						TocDo_Coating = @TocDo_Coating
						--,CreateDateTime=@CreateDateTime,CreateUserId=@CreateUserId
						where ElectrodeLotNumber = @OldElectrodeLotNumber

						declare @ccccount INT=0
						select @ccccount=count(*) from STB_Viscosity_ElectrodCoatingInfo_VVT where ElectrodeLotNumber = @OldElectrodeLotNumber or ElectrodeLotNumber = @ElectrodeLotNumber

						if(@ccccount=0)
									insert into STB_Viscosity_ElectrodCoatingInfo_VVT(ElectrodeLotNumber,ViscosityValue,ViscosityResult,TocDo_Coating,CreateDateTime,CreateUserId)
									values (@ElectrodeLotNumber,@ViscosityValue,(case when @ViscosityValue>=(@ViscosityMin) AND @ViscosityValue<=(@ViscosityMax) then 'OK' else 'NG' end),@TocDo_Coating,@CreateDateTime,@CreateUserId)


                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

                    DELETE FROM STB_ElectrodeCoatingInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber

                    DELETE FROM STB_Viscosity_ElectrodCoatingInfo_VVT
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
