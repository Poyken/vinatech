-- =============================================
-- Hotfix ID: 15_FIX_ELECTRODE_MEASURE_RESULT_HUNG_YEN_SPS
-- Target Object: usp_ElectrodeCoatingInfo_HY_get, usp_ElectrodeCoatingInfo_HY_iud, usp_ElectrodeCoatingVisualInspectionInfo_HY_get, usp_ElectrodeCoatingVisualInspectionInfo_HY_iud, usp_ElectrodeMixInfo_HY_get, usp_ElectrodeMixInfo_HY_iud, usp_ElectrodeMixStepInfo_HY_get, usp_ElectrodeMixStepInfo_HY_iud, usp_ElectrodeRollPressingInfo_HY_get, usp_ElectrodeRollPressingInfo_HY_iud, usp_ElectrodeRollPressingVisualInspectionInfo_HY_get, usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud, usp_ElectrodeSlittingInfo_HY_get, usp_ElectrodeSlittingInfo_HY_iud, usp_ElectrodeSlittingResult_HY_get, usp_ElectrodeSlittingResult_HY_iud, usp_ElectrodeWasteInfoNew_HY_iud, usp_ElectrodeWastePriceNewByBarcode_HY_get, usp_LocationElectric_HY, usp_test_check_expired_HY, usp_Vietnam_RollPressingSlitting_HY_get
-- Author: vanduc
-- Date: 2026-06-11
-- Description: Clone 21 stored procedures for Electrode Measure Result screen B552 for Hung Yen (_HY).
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 15_FIX_ELECTRODE_MEASURE_RESULT_HUNG_YEN_SPS...';
GO
-- =========================================================
-- 1. Stored Procedure: usp_ElectrodeCoatingInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeCoatingInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeCoatingInfo_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리 >
--            품질관리 > 
-- Description:	전극코딩공정정보
--                  2020.08.12 구형규요청

-- usp_ElectrodeCoatingInfo_get '','','VJKP1720001E01'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingInfo_HY_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pElectrodeLotNumber VARCHAR(20) = NULL
AS

BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber


		declare @company varchar(10)=''
	select @company=CompanyCode from STB_UserInfo
	where UserID=@pProcessUserID
	   



	SELECT   ISNULL(ECI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ECI.MachineCode
			,MM.MachineName
			,isnull(case when @company='VVT' then dateadd(hour,2,(ECI.WorkDate)) else (ECI.WorkDate) end, getdate() ) as WorkDate   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
			,ECI.WorkerCode 
			,PWI.WorkerName
			,ECI.Temperature
			,ECI.Humidity
			,ECI.ElectrodeMaterialCode
			,ECI.MaterialLotNumber
			,ECI.OneSideHeadGapLeft
			,ECI.OneSideHeadGapRight
			,ECI.BothSideHeadGapLeft
			,ECI.BothSideHeadGapRight
			,ECI.OneSideCoatingWidth
			,ECI.BothSideCoatingWidth
			,ECI.UnwindingValue
			,ECI.RewindingValue
			,ECI.ProductionQty
			,ECI.GoodQty
			,ECI.BadQty
			,ECI.Remark
			,ECI.SpecificComment1
			,ECI.SpecificComment2
			,ECI.CreateDateTime
			,ECI.CreateUserID
			,ECI.ChangeDateTime
			,ECI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,'Report' AS CommandType
			,'X'        AS IsRollPress				
			, Case When Right(MM2.MaterialName, 3) = '(+)'  Then '에칭' 
			         When Right(MM2.MaterialName, 3) = '(-)'  Then '화성'  Else '기타' End  AS ElectrodeDivision       -- 에칭/화성구분 (kilee추가-구형규요청, 2020-08-13)           
			,isnull(ECI.CohesionResult,0) as CohesionResult
			,veci.ViscosityValue --Mr.Tung add on 05-Nov-2021 as Vietnam Production request
			,veci.ViscosityResult --Mr.Tung add on 05-Nov-2021 as Vietnam Production request
			,veci.TocDo_Coating --Mr.Tung add on 25-May-2022 as Vietnam Production request
			,ECI.CurrentCollectorThickness
	  FROM STB_SetInfo SI
			  LEFT OUTER JOIN STB_MaterialMaster MM2	      ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	  ON SI.Barcode = ECI.ElectrodeLotNumber
			  LEFT OUTER JOIN STB_MachineMaster MM	      ON ECI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	      ON ECI.WorkerCode = PWI.WorkerCode
			  LEFT OUTER JOIN stb_Viscosity_ElectrodCoatingInfo_VVT veci on ECI.ElectrodeLotNumber = veci.ElectrodeLotNumber --Mr.Tung add on 05-Nov-2021 as Vietnam Production request
	 WHERE SI.Barcode = @ElectrodeLotNumber

END
GO

PRINT 'Procedure usp_ElectrodeCoatingInfo_HY_get created successfully.';
GO
-- =========================================================
-- 2. Stored Procedure: usp_ElectrodeCoatingInfo_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeCoatingInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeCoatingInfo_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극코팅정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingInfo_HY_iud]
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
GO

PRINT 'Procedure usp_ElectrodeCoatingInfo_HY_iud created successfully.';
GO
-- =========================================================
-- 3. Stored Procedure: usp_ElectrodeCoatingVisualInspectionInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeCoatingVisualInspectionInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeCoatingVisualInspectionInfo_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극코팅외관검사정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingVisualInspectionInfo_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	--declare @company varchar(10)='';
	--select @company= companycode
	--from STB_UserInfo
	--where UserID=@pProcessUserID



	--if(@company='VVT') begin   -- Mr.tung on 2022-sep-15 , for Hela Audit
	
	--;WITH DefaultList AS (
	--	SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	--SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	--SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	--SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	--UNION ALL
	--	SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--	UNION ALL
	--	SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	--)
	--SELECT   ISNULL(ECVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
	--		,ISNULL(ECVII.SideCode, DL.SideCode) AS SideCode
	--		, case when BC2.Description='단면' then BC2.Description+N' (1 mặt)'
	--				when BC2.Description='양면' then BC2.Description+N' (2 mặt)' 
	--				else BC2.Description end AS SideCodeName 

	--		,ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
	--		,BC.Description AS MeasureTimeCodeName
	--		,ISNULL(ECVII.Seq, DL.Seq) AS Seq
	--		,ECVII.LeftValue
	--		,ECVII.MiddleValue
	--		,ECVII.RightValue
	--		,ECVII.CreateDateTime
	--		,ECVII.CreateUserID
	--		,ECVII.ChangeDateTime
	--		,ECVII.ChangeUserID			
	--  FROM STB_SetInfo SI
	--  LEFT OUTER JOIN DefaultList DL	    ON 1=1
	--  LEFT OUTER JOIN STB_ElectrodeCoatingVisualInspectionInfo ECVII	    ON SI.Barcode = ECVII.ElectrodeLotNumber	   AND DL.SideCode = ECVII.SideCode	   AND DL.MeasureTimeCode = ECVII.MeasureTimeCode	   AND DL.Seq = ECVII.Seq
	--  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC    	            ON BC.CodeGroup = 'MeasureTime'    	           AND ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) = BC.ItemCode
	--  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2  	            ON ISNULL(ECVII.SideCode, DL.SideCode) = BC2.ItemCode	   AND BC2.CodeGroup = 'SideCode'
	-- WHERE SI.Barcode = @ElectrodeLotNumber
	-- ORDER BY CASE WHEN DL.SideCode = 'O' THEN 1
	--                      WHEN DL.SideCode = 'B' THEN 2	   ELSE DL.SideCode END
	--	     ,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	--		       --WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
	--			   WHEN DL.MeasureTimeCode = 'LAST' THEN 3	   ELSE 4 END
	--	     ,DL.Seq
	--	return;
	--end




	;WITH DefaultList AS (
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	)
	SELECT   ISNULL(ECVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ECVII.SideCode, DL.SideCode) AS SideCode
			, case when BC2.Description='단면' then BC2.Description+N' (1 mặt)'
					when BC2.Description='양면' then BC2.Description+N' (2 mặt)' 
					else BC2.Description end AS SideCodeName 

			,ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ECVII.Seq, DL.Seq) AS Seq
			,ECVII.LeftValue
			,ECVII.MiddleValue
			,ECVII.RightValue
			,ECVII.CreateDateTime
			,ECVII.CreateUserID
			,ECVII.ChangeDateTime
			,ECVII.ChangeUserID
			,EC.OneSideLowerTolerance
			,EC.OneSideUpperTolerance
			,EC.BothSideLowerTolerance
			,EC.BothSideUpperTolerance
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL	    ON 1=1
	  LEFT OUTER JOIN STB_ElectrodeCoatingVisualInspectionInfo ECVII	    ON SI.Barcode = ECVII.ElectrodeLotNumber	   AND DL.SideCode = ECVII.SideCode	   AND DL.MeasureTimeCode = ECVII.MeasureTimeCode	   AND DL.Seq = ECVII.Seq
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC    	            ON BC.CodeGroup = 'MeasureTime'    	           AND ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) = BC.ItemCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2  	            ON ISNULL(ECVII.SideCode, DL.SideCode) = BC2.ItemCode	   AND BC2.CodeGroup = 'SideCode'
	  LEFT OUTER JOIN STB_ElectrodeCommon EC ON EC.ProdCode = SI.MaterialCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
	 ORDER BY CASE WHEN DL.SideCode = 'O' THEN 1
	                      WHEN DL.SideCode = 'B' THEN 2	   ELSE DL.SideCode END
		     ,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
			       WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3	   ELSE 4 END
		     ,DL.Seq
END
GO

PRINT 'Procedure usp_ElectrodeCoatingVisualInspectionInfo_HY_get created successfully.';
GO
-- =========================================================
-- 4. Stored Procedure: usp_ElectrodeCoatingVisualInspectionInfo_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeCoatingVisualInspectionInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeCoatingVisualInspectionInfo_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극코팅외관검사정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingVisualInspectionInfo_HY_iud]
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
  DECLARE @OldSideCode VARCHAR(1)
  DECLARE @OldMeasureTimeCode VARCHAR(10)
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @SideCode VARCHAR(1)
  DECLARE @MeasureTimeCode VARCHAR(10)
  DECLARE @Seq INT
  DECLARE @LeftValue NUMERIC(20,5)
  DECLARE @MiddleValue NUMERIC(20,5)
  DECLARE @RightValue NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeCoatingVisualInspectionInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeCoatingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSideCode IS NULL THEN SideCode
							    ELSE OldSideCode
							END AS OldSideCode,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							SideCode,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSideCode VARCHAR(1),
										OldMeasureTimeCode VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										SideCode VARCHAR(1),
										MeasureTimeCode VARCHAR(10),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.SideCode = SourceTable.SideCode AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					SideCode = ISNULL(SourceTable.SideCode,TargetTable.SideCode),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					LeftValue = ISNULL(SourceTable.LeftValue,TargetTable.LeftValue),
					MiddleValue = ISNULL(SourceTable.MiddleValue,TargetTable.MiddleValue),
					RightValue = ISNULL(SourceTable.RightValue,TargetTable.RightValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						SideCode,
						MeasureTimeCode,
						Seq,
						LeftValue,
						MiddleValue,
						RightValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.SideCode,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.LeftValue,
							SourceTable.MiddleValue,
							SourceTable.RightValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeCoatingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSideCode IS NULL THEN SideCode
							    ELSE OldSideCode
							END AS OldSideCode,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							SideCode,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSideCode VARCHAR(1),
										OldMeasureTimeCode VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										SideCode VARCHAR(1),
										MeasureTimeCode VARCHAR(10),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.SideCode = SourceTable.OldSideCode AND
					TargetTable.MeasureTimeCode = SourceTable.OldMeasureTimeCode AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					SideCode = ISNULL(SourceTable.SideCode,TargetTable.SideCode),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					LeftValue = ISNULL(SourceTable.LeftValue,TargetTable.LeftValue),
					MiddleValue = ISNULL(SourceTable.MiddleValue,TargetTable.MiddleValue),
					RightValue = ISNULL(SourceTable.RightValue,TargetTable.RightValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						SideCode,
						MeasureTimeCode,
						Seq,
						LeftValue,
						MiddleValue,
						RightValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.SideCode,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.LeftValue,
							SourceTable.MiddleValue,
							SourceTable.RightValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeCoatingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSideCode IS NULL THEN SideCode
							    ELSE OldSideCode
							END AS OldSideCode,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							SideCode,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSideCode VARCHAR(1),
										OldMeasureTimeCode VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										SideCode VARCHAR(1),
										MeasureTimeCode VARCHAR(10),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.SideCode = SourceTable.SideCode AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
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
									OldSideCode,
									OldMeasureTimeCode,
									OldSeq,
									ElectrodeLotNumber,
									SideCode,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSideCode VARCHAR(1),
											 OldMeasureTimeCode VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 SideCode VARCHAR(1),
											 MeasureTimeCode VARCHAR(10),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
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
									CASE 
										WHEN OldSideCode IS NULL THEN SideCode
										ELSE OldSideCode
									END AS OldSideCode,
									CASE 
										WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
										ELSE OldMeasureTimeCode
									END AS OldMeasureTimeCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									SideCode,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSideCode VARCHAR(1),
											 OldMeasureTimeCode VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 SideCode VARCHAR(1),
											 MeasureTimeCode VARCHAR(10),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
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
									CASE 
										WHEN OldSideCode IS NULL THEN SideCode
										ELSE OldSideCode
									END AS OldSideCode,
									CASE 
										WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
										ELSE OldMeasureTimeCode
									END AS OldMeasureTimeCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									SideCode,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSideCode VARCHAR(1),
											 OldMeasureTimeCode VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 SideCode VARCHAR(1),
											 MeasureTimeCode VARCHAR(10),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
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
								 @OldSideCode,
								 @OldMeasureTimeCode,
								 @OldSeq,
								 @ElectrodeLotNumber,
								 @SideCode,
								 @MeasureTimeCode,
								 @Seq,
								 @LeftValue,
								 @MiddleValue,
								 @RightValue,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeCoatingVisualInspectionInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber AND SideCode = @SideCode AND MeasureTimeCode = @MeasureTimeCode AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeCoatingVisualInspectionInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeCoatingVisualInspectionInfo
						(
						    ElectrodeLotNumber,
						    SideCode,
						    MeasureTimeCode,
						    Seq,
						    LeftValue,
						    MiddleValue,
						    RightValue,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @SideCode,
						    @MeasureTimeCode,
						    @Seq,
						    @LeftValue,
						    @MiddleValue,
						    @RightValue,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeCoatingVisualInspectionInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    SideCode =   ISNULL(@SideCode,SideCode),
						    MeasureTimeCode =   ISNULL(@MeasureTimeCode,MeasureTimeCode),
						    Seq =   ISNULL(@Seq,Seq),
						    LeftValue =   ISNULL(@LeftValue,LeftValue),
						    MiddleValue =   ISNULL(@MiddleValue,MiddleValue),
						    RightValue =   ISNULL(@RightValue,RightValue),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    SideCode = @OldSideCode AND
						    MeasureTimeCode = @OldMeasureTimeCode AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeCoatingVisualInspectionInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    SideCode = @OldSideCode AND
						    MeasureTimeCode = @OldMeasureTimeCode AND
						    Seq = @OldSeq
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
GO

PRINT 'Procedure usp_ElectrodeCoatingVisualInspectionInfo_HY_iud created successfully.';
GO
-- =========================================================
-- 5. Stored Procedure: usp_ElectrodeMixInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeMixInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeMixInfo_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리 > [B550] 전극측정결과 > 믹싱첫번째 Tab화면
-- Description:	믹싱측정정보마스터
--                  2020.09.22 냉각수온도 추가 (안제헌)

-- Modify : #210304 @ElectrodeWasteList 와 @FoilWasteList를 폐기물 리스트에서 토탈 금액으로 변경 채민수 대리 요청
--          #210407 전극폐기무게, 호일폐기무게 추가 채민수 대리 요청
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixInfo_HY_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	DECLARE @RowCount INT
	DECLARE @ElectrodeWasteList NUMERIC(20,5) --전극 #210304
	DECLARE @FoilWasteList NUMERIC(20,5) --호일이음부 #210304
	DECLARE @JobDate DATE 
	DECLARE @ElectrodeWasteWeight NUMERIC(20,5) -- #210407
	DECLARE @FoilWasteWeight NUMERIC(20,5) --#210304
	

	SET @ElectrodeLotNumber = @pElectrodeLotNumber



			   
		   -- add by Mr.Tung on 2022-June-07  for  auto fill Empty Mixing in Vietnam, prepared for  Viscosity Software read automatically
		   DECLARE @ccount INT = 0
		   select @ccount = count(*) from STB_ElectrodeMixInfo where electrodelotnumber=@ElectrodeLotNumber
		   if(@ElectrodeLotNumber like 'VV%' and @ccount=0)  
		   begin
                    INSERT INTO STB_ElectrodeMixInfo ( ElectrodeLotNumber,  ViscosityValue )
						VALUES ( @ElectrodeLotNumber,  NULL );
		   end
		   -- end by Mr.Tung

	
	declare @company varchar(10)=''
	select @company=CompanyCode from STB_UserInfo
	where UserID=@pProcessUserID


	SELECT @RowCount = COUNT(*)
	      ,@JobDate = case when @company='VVT' then dateadd(hour,2,MAX(EM.WorkDate)) else MAX(EM.WorkDate) end   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_ElectrodeMixInfo EM	    ON SI.Barcode = EM.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON EM.MachineCode = MM.MachineCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON EM.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber

	SELECT @ElectrodeWasteList = SUM(EWIN.DefectWeight * EWPN.DefectUnitPrice)
	      ,@ElectrodeWasteWeight = SUM(EWIN.DefectWeight)
              FROM STB_ElectrodeWasteInfoNew EWIN with(nolock) 
			  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN with(nolock) 
				ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode
			   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
			   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
			   AND EWPN.CompanyCode = EWIN.CompanyCode
			   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
			   AND EWPN.RouteCode = EWIN.RouteCode
			   AND EWPN.DefectCode = EWIN.DefectCode
              WHERE JobDate = @JobDate
				AND EWIN.DefectCode NOT IN (SELECT DefectCode 
									     FROM STB_DefectInfo 
									    WHERE BasicDefectName = '호일 이음부')

	SELECT @FoilWasteList = SUM(EWIN.DefectWeight * EWPN.DefectUnitPrice)
	      ,@FoilWasteWeight = SUM(EWIN.DefectWeight)
              FROM STB_ElectrodeWasteInfoNew EWIN with(nolock) 
			  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN with(nolock) 
				ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode
			   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
			   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
			   AND EWPN.CompanyCode = EWIN.CompanyCode
			   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
			   AND EWPN.RouteCode = EWIN.RouteCode
			   AND EWPN.DefectCode = EWIN.DefectCode
              WHERE JobDate = @JobDate
				AND EWIN.DefectCode IN (SELECT DefectCode 
									     FROM STB_DefectInfo  with(nolock) 
									    WHERE BasicDefectName = '호일 이음부')

	IF @RowCount = 0 BEGIN
		RAISERROR('전극 바코드가 존재하지 않습니다.' ,16, 1)
		RETURN
	END
	ELSE BEGIN
		SELECT 	 ISNULL(EM.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
				,EM.MachineCode
				,MM.MachineName
				,isnull(case when @company='VVT' then dateadd(hour,2,(EM.WorkDate)) else (EM.WorkDate) end, getdate() ) WorkDate   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
				,EM.WorkerCode 
				,PWI.WorkerName
				,EM.Temperature 
				,EM.Humidity    
				--,EM.ProductionQty 
				,case when isnull(EM.ProductionQty,0)>0  then EM.ProductionQty 
						else (select sum(InputQty1) from STB_ElectrodeMixStepInfo with(nolock) where ElectrodeLotNumber=SI.Barcode) --add by Mr.Tung on 2022-05-05 by Production Request 
				 end as ProductionQty
				,EM.TankInsideTemp 
				,EM.ViscosityValue 
				,EM.SpecificGravityValue 
				,EM.MixingTemperature    
				,EM.SpecificComment      
				,EM.CreateDateTime       
				,EM.CreateUserID         
				,EM.ChangeDateTime       
				,EM.ChangeUserID
				,SI.MaterialCode
				,MM2.MaterialName
				,MM2.MaterialThickness
				,MM2.MaterialSource
				,dbo.fnGetCalendarCode() AS SystemCalendarCode
				,EM.CoolantTemperature AS CoolantTemperature                               -- 냉각수온도 추가 (안제헌, 2020.09.22)
				,EM.ViscosityResult
				,case   when ((select count(*) from STB_ElectrodeMixStepInfo where ElectrodeMaterialCode like '%GAHSCB-001' and ElectrodeLotNumber=SI.Barcode)) = 0    --if not use Hansol Binder     Mr.Tung modified on 2022-06-30, require by Electrode Dept in Vietnam
						then EM.ViscosityResult 
						else ((case when ViscosityValue>=1800 AND ViscosityValue<=2200 then 'OK' else 'NG' end)) end --if use Hansol binder

				,@ElectrodeWasteList AS ElectrodeWasteList
				,@FoilWasteList AS FoilWasteList
				,'Report' AS CommandType
				,dbo.fnGetCalendarName() AS CalendarName
				,@ElectrodeWasteWeight AS ElectrodeWasteWeight
				,@FoilWasteWeight AS FoilWasteWeight

		  FROM STB_SetInfo SI with(nolock) 
		  LEFT OUTER JOIN STB_MaterialMaster MM2	 with(nolock) 		ON SI.MaterialCode = MM2.MaterialCode
		  LEFT OUTER JOIN STB_ElectrodeMixInfo EM with(nolock) 			ON SI.Barcode = EM.ElectrodeLotNumber
		  LEFT OUTER JOIN STB_MachineMaster MM		 with(nolock)    	ON EM.MachineCode = MM.MachineCode
		  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	 with(nolock) 		ON EM.WorkerCode = PWI.WorkerCode 		 
		 WHERE SI.Barcode = @ElectrodeLotNumber
	END

END
GO

PRINT 'Procedure usp_ElectrodeMixInfo_HY_get created successfully.';
GO
-- =========================================================
-- 6. Stored Procedure: usp_ElectrodeMixInfo_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeMixInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeMixInfo_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리 > [B550] 전극측정결과 > 믹싱 첫번째 Tab화면  iud저장정보
-- Description:	전극믹싱정보
-- Modified: 2020.09.22 냉각수온도 추가 (안제헌)
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixInfo_HY_iud]
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
  DECLARE @ProductionQty NUMERIC(20,5)
  DECLARE @TankInsideTemp NUMERIC(20,5)
  DECLARE @ViscosityValue NUMERIC(20,5)
  DECLARE @SpecificGravityValue NUMERIC(20,5)
  DECLARE @MixingTemperature NUMERIC(20,5)
  DECLARE @SpecificComment VARCHAR(1000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  
  DECLARE @CoolantTemperature NUMERIC(20,5)    --추가

  	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeMixInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeMixInfo AS TargetTable
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
							ProductionQty,
							TankInsideTemp,
							ViscosityValue,
							SpecificGravityValue,
							MixingTemperature,
							SpecificComment,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							 CoolantTemperature                         --추가
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
										ProductionQty NUMERIC(20,5),
										TankInsideTemp NUMERIC(20,5),
										ViscosityValue NUMERIC(20,5),
										SpecificGravityValue NUMERIC(20,5),
										MixingTemperature NUMERIC(20,5),
										SpecificComment VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CoolantTemperature NUMERIC(20,5)  --추가
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
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					TankInsideTemp = ISNULL(SourceTable.TankInsideTemp,TargetTable.TankInsideTemp),
					ViscosityValue = ISNULL(SourceTable.ViscosityValue,TargetTable.ViscosityValue),
					SpecificGravityValue = ISNULL(SourceTable.SpecificGravityValue,TargetTable.SpecificGravityValue),
					MixingTemperature = ISNULL(SourceTable.MixingTemperature,TargetTable.MixingTemperature),
					SpecificComment = ISNULL(SourceTable.SpecificComment,TargetTable.SpecificComment),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CoolantTemperature  = ISNULL(SourceTable.CoolantTemperature,TargetTable.CoolantTemperature)     --추가
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						ProductionQty,
						TankInsideTemp,
						ViscosityValue,
						SpecificGravityValue,
						MixingTemperature,
						SpecificComment,
						CreateDateTime,
						CreateUserID,
						CoolantTemperature
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.ProductionQty,
							SourceTable.TankInsideTemp,
							SourceTable.ViscosityValue,
							SourceTable.SpecificGravityValue,
							SourceTable.MixingTemperature,
							SourceTable.SpecificComment,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CoolantTemperature							
					);


			-- Process Update Table
            MERGE STB_ElectrodeMixInfo AS TargetTable
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
							ProductionQty,
							TankInsideTemp,
							ViscosityValue,
							SpecificGravityValue,
							MixingTemperature,
							SpecificComment,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CoolantTemperature
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
										ProductionQty NUMERIC(20,5),
										TankInsideTemp NUMERIC(20,5),
										ViscosityValue NUMERIC(20,5),
										SpecificGravityValue NUMERIC(20,5),
										MixingTemperature NUMERIC(20,5),
										SpecificComment VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CoolantTemperature NUMERIC(20,5)
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
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					TankInsideTemp = ISNULL(SourceTable.TankInsideTemp,TargetTable.TankInsideTemp),
					ViscosityValue = ISNULL(SourceTable.ViscosityValue,TargetTable.ViscosityValue),
					SpecificGravityValue = ISNULL(SourceTable.SpecificGravityValue,TargetTable.SpecificGravityValue),
					MixingTemperature = ISNULL(SourceTable.MixingTemperature,TargetTable.MixingTemperature),
					SpecificComment = ISNULL(SourceTable.SpecificComment,TargetTable.SpecificComment),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CoolantTemperature = ISNULL(SourceTable.CoolantTemperature,TargetTable.CoolantTemperature)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						ProductionQty,
						TankInsideTemp,
						ViscosityValue,
						SpecificGravityValue,
						MixingTemperature,
						SpecificComment,
						CreateDateTime,
						CreateUserID,
						CoolantTemperature
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.ProductionQty,
							SourceTable.TankInsideTemp,
							SourceTable.ViscosityValue,
							SourceTable.SpecificGravityValue,
							SourceTable.MixingTemperature,
							SourceTable.SpecificComment,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CoolantTemperature
					);


			-- Process Delete Table
            MERGE STB_ElectrodeMixInfo AS TargetTable
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
							ProductionQty,
							TankInsideTemp,
							ViscosityValue,
							SpecificGravityValue,
							MixingTemperature,
							SpecificComment,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CoolantTemperature
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
										ProductionQty NUMERIC(20,5),
										TankInsideTemp NUMERIC(20,5),
										ViscosityValue NUMERIC(20,5),
										SpecificGravityValue NUMERIC(20,5),
										MixingTemperature NUMERIC(20,5),
										SpecificComment VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CoolantTemperature NUMERIC(20,5)
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
									ProductionQty,
									TankInsideTemp,
									ViscosityValue,
									SpecificGravityValue,
									MixingTemperature,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CoolantTemperature
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
											 ProductionQty NUMERIC(20,5),
											 TankInsideTemp NUMERIC(20,5),
											 ViscosityValue NUMERIC(20,5),
											 SpecificGravityValue NUMERIC(20,5),
											 MixingTemperature NUMERIC(20,5),
											 SpecificComment VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CoolantTemperature NUMERIC(20,5)
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
									ProductionQty,
									TankInsideTemp,
									ViscosityValue,
									SpecificGravityValue,
									MixingTemperature,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CoolantTemperature
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
											 ProductionQty NUMERIC(20,5),
											 TankInsideTemp NUMERIC(20,5),
											 ViscosityValue NUMERIC(20,5),
											 SpecificGravityValue NUMERIC(20,5),
											 MixingTemperature NUMERIC(20,5),
											 SpecificComment VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CoolantTemperature NUMERIC(20,5)
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
									ProductionQty,
									TankInsideTemp,
									ViscosityValue,
									SpecificGravityValue,
									MixingTemperature,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CoolantTemperature
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
											 ProductionQty NUMERIC(20,5),
											 TankInsideTemp NUMERIC(20,5),
											 ViscosityValue NUMERIC(20,5),
											 SpecificGravityValue NUMERIC(20,5),
											 MixingTemperature NUMERIC(20,5),
											 SpecificComment VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CoolantTemperature NUMERIC(20,5)
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
								 @ProductionQty,
								 @TankInsideTemp,
								 @ViscosityValue,
								 @SpecificGravityValue,
								 @MixingTemperature,
								 @SpecificComment,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @CoolantTemperature

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeMixInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeMixInfo
						(
						    ElectrodeLotNumber,
						    MachineCode,
						    WorkDate,
						    WorkerCode,
						    Temperature,
						    Humidity,
						    ProductionQty,
						    TankInsideTemp,
						    ViscosityValue,
						    SpecificGravityValue,
						    MixingTemperature,
						    SpecificComment,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							CoolantTemperature
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @MachineCode,
						    @WorkDate,
						    @WorkerCode,
						    @Temperature,
						    @Humidity,
						    @ProductionQty,
						    @TankInsideTemp,
						    @ViscosityValue,
						    @SpecificGravityValue,
						    @MixingTemperature,
						    @SpecificComment,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@CoolantTemperature
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeMixInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    WorkDate =   ISNULL(@WorkDate,WorkDate),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    Temperature =   ISNULL(@Temperature,Temperature),
						    Humidity =   ISNULL(@Humidity,Humidity),
						    ProductionQty =   ISNULL(@ProductionQty,ProductionQty),
						    TankInsideTemp =   ISNULL(@TankInsideTemp,TankInsideTemp),
						    ViscosityValue =   ISNULL(@ViscosityValue,ViscosityValue),
						    SpecificGravityValue =   ISNULL(@SpecificGravityValue,SpecificGravityValue),
						    MixingTemperature =   ISNULL(@MixingTemperature,MixingTemperature),
						    SpecificComment =   ISNULL(@SpecificComment,SpecificComment),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							CoolantTemperature = ISNULL(@CoolantTemperature,CoolantTemperature)
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeMixInfo
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
GO

PRINT 'Procedure usp_ElectrodeMixInfo_HY_iud created successfully.';
GO
-- =========================================================
-- 7. Stored Procedure: usp_ElectrodeMixStepInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeMixStepInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeMixStepInfo_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	믹싱혼합단계정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixStepInfo_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	SELECT 	 ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ES.ElectrodeStepCode, EMSI.ElectrodeStep) AS ElectrodeStep
			,ISNULL(ES.Seq, EMSI.Seq) AS Seq
			,ISNULL(ES.MaterialCode, EMSI.ElectrodeMaterialCode) AS ElectrodeMaterialCode
			,MM.MaterialName AS ElectrodeMaterialName
			,EMSI.InputQty1
			,EMSI.InputQty2
			,EMSI.MaterialLotNumber
			,EMSI.BinderInputTime
			,EMSI.BinderOutputTime
			,EMSI.MixingInputTime
			,EMSI.MixingOutputTime
			,EMSI.SpecInOut
			,EMSI.SpecOutQty
			,EMSI.CreateDateTime
			,EMSI.CreateUserID
			,EMSI.ChangeDateTime
			,EMSI.ChangeUserID
	  FROM STB_ElectrodeStep ES 
	 INNER JOIN STB_SetInfo SI	                               ON ES.ProdCode = SI.MaterialCode
     LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI	   ON SI.Barcode = EMSI.ElectrodeLotNumber	   AND EMSI.ElectrodeStep = ES.ElectrodeStepCode	   AND EMSI.Seq = ES.Seq
	 LEFT OUTER JOIN STB_MaterialMaster MM	           ON MM.MaterialCode = ISNULL(ES.MaterialCode, EMSI.ElectrodeMaterialCode)
	 WHERE SI.Barcode = @ElectrodeLotNumber
	 ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D'  THEN 1
	               WHEN ES.ElectrodeStepCode = 'G'  THEN 2
				   WHEN ES.ElectrodeStepCode = 'K'  THEN 3
				   WHEN ES.ElectrodeStepCode = 'P' THEN 4
				   WHEN ES.ElectrodeStepCode = 'S'  THEN 5
				   WHEN ES.ElectrodeStepCode = 'S1'  THEN 6
				   WHEN ES.ElectrodeStepCode = 'S2'  THEN 7
				   WHEN ES.ElectrodeStepCode = 'S3'  THEN 8
				   WHEN ES.ElectrodeStepCode = 'S4'  THEN 9
				   WHEN ES.ElectrodeStepCode = 'S5'  THEN 10
				   WHEN ES.ElectrodeStepCode = 'DA' THEN 11
				   ELSE 100 END
			,ES.Seq
END
GO

PRINT 'Procedure usp_ElectrodeMixStepInfo_HY_get created successfully.';
GO
-- =========================================================
-- 8. Stored Procedure: usp_ElectrodeMixStepInfo_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeMixStepInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeMixStepInfo_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극믹싱단계정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixStepInfo_HY_iud]
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
  DECLARE @OldElectrodeStep VARCHAR(10)
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @ElectrodeStep VARCHAR(10)
  DECLARE @Seq INT
  DECLARE @ElectrodeMaterialCode VARCHAR(20)
  DECLARE @InputQty1 NUMERIC(20,5)
  DECLARE @InputQty2 NUMERIC(20,5)
  DECLARE @MaterialLotNumber VARCHAR(20)
  DECLARE @BinderInputTime DATETIMEOFFSET
  DECLARE @BinderOutputTime DATETIMEOFFSET
  DECLARE @MixingInputTime DATETIMEOFFSET
  DECLARE @MixingOutputTime DATETIMEOFFSET
  DECLARE @SpecInOut VARCHAR(5)
  DECLARE @SpecOutQty NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeMixStepInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeMixStepInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
							    ELSE OldElectrodeStep
							END AS OldElectrodeStep,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							ElectrodeStep,
							Seq,
							ElectrodeMaterialCode,
							InputQty1,
							InputQty2,
							MaterialLotNumber,
							BinderInputTime,
							BinderOutputTime,
							MixingInputTime,
							MixingOutputTime,
							SpecInOut,
							SpecOutQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldElectrodeStep VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										ElectrodeStep VARCHAR(10),
										Seq INT,
										ElectrodeMaterialCode VARCHAR(20),
										InputQty1 NUMERIC(20,5),
										InputQty2 NUMERIC(20,5),
										MaterialLotNumber VARCHAR(20),
										BinderInputTime DATETIMEOFFSET,
										BinderOutputTime DATETIMEOFFSET,
										MixingInputTime DATETIMEOFFSET,
										MixingOutputTime DATETIMEOFFSET,
										SpecInOut VARCHAR(5),
										SpecOutQty NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.ElectrodeStep = SourceTable.ElectrodeStep AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					ElectrodeStep = ISNULL(SourceTable.ElectrodeStep,TargetTable.ElectrodeStep),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeMaterialCode = ISNULL(SourceTable.ElectrodeMaterialCode,TargetTable.ElectrodeMaterialCode),
					InputQty1 = ISNULL(SourceTable.InputQty1,TargetTable.InputQty1),
					InputQty2 = ISNULL(SourceTable.InputQty2,TargetTable.InputQty2),
					MaterialLotNumber = ISNULL(SourceTable.MaterialLotNumber,TargetTable.MaterialLotNumber),
					BinderInputTime = ISNULL(SourceTable.BinderInputTime,TargetTable.BinderInputTime),
					BinderOutputTime = ISNULL(SourceTable.BinderOutputTime,TargetTable.BinderOutputTime),
					MixingInputTime = ISNULL(SourceTable.MixingInputTime,TargetTable.MixingInputTime),
					MixingOutputTime = ISNULL(SourceTable.MixingOutputTime,TargetTable.MixingOutputTime),
					SpecInOut = ISNULL(SourceTable.SpecInOut,TargetTable.SpecInOut),
					SpecOutQty = ISNULL(SourceTable.SpecOutQty,TargetTable.SpecOutQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						ElectrodeStep,
						Seq,
						ElectrodeMaterialCode,
						InputQty1,
						InputQty2,
						MaterialLotNumber,
						BinderInputTime,
						BinderOutputTime,
						MixingInputTime,
						MixingOutputTime,
						SpecInOut,
						SpecOutQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.ElectrodeStep,
							SourceTable.Seq,
							SourceTable.ElectrodeMaterialCode,
							SourceTable.InputQty1,
							SourceTable.InputQty2,
							SourceTable.MaterialLotNumber,
							SourceTable.BinderInputTime,
							SourceTable.BinderOutputTime,
							SourceTable.MixingInputTime,
							SourceTable.MixingOutputTime,
							SourceTable.SpecInOut,
							SourceTable.SpecOutQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeMixStepInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
							    ELSE OldElectrodeStep
							END AS OldElectrodeStep,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							ElectrodeStep,
							Seq,
							ElectrodeMaterialCode,
							InputQty1,
							InputQty2,
							MaterialLotNumber,
							BinderInputTime,
							BinderOutputTime,
							MixingInputTime,
							MixingOutputTime,
							SpecInOut,
							SpecOutQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldElectrodeStep VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										ElectrodeStep VARCHAR(10),
										Seq INT,
										ElectrodeMaterialCode VARCHAR(20),
										InputQty1 NUMERIC(20,5),
										InputQty2 NUMERIC(20,5),
										MaterialLotNumber VARCHAR(20),
										BinderInputTime DATETIMEOFFSET,
										BinderOutputTime DATETIMEOFFSET,
										MixingInputTime DATETIMEOFFSET,
										MixingOutputTime DATETIMEOFFSET,
										SpecInOut VARCHAR(5),
										SpecOutQty NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.ElectrodeStep = SourceTable.OldElectrodeStep AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					ElectrodeStep = ISNULL(SourceTable.ElectrodeStep,TargetTable.ElectrodeStep),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeMaterialCode = ISNULL(SourceTable.ElectrodeMaterialCode,TargetTable.ElectrodeMaterialCode),
					InputQty1 = ISNULL(SourceTable.InputQty1,TargetTable.InputQty1),
					InputQty2 = ISNULL(SourceTable.InputQty2,TargetTable.InputQty2),
					MaterialLotNumber = ISNULL(SourceTable.MaterialLotNumber,TargetTable.MaterialLotNumber),
					BinderInputTime = ISNULL(SourceTable.BinderInputTime,TargetTable.BinderInputTime),
					BinderOutputTime = ISNULL(SourceTable.BinderOutputTime,TargetTable.BinderOutputTime),
					MixingInputTime = ISNULL(SourceTable.MixingInputTime,TargetTable.MixingInputTime),
					MixingOutputTime = ISNULL(SourceTable.MixingOutputTime,TargetTable.MixingOutputTime),
					SpecInOut = ISNULL(SourceTable.SpecInOut,TargetTable.SpecInOut),
					SpecOutQty = ISNULL(SourceTable.SpecOutQty,TargetTable.SpecOutQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						ElectrodeStep,
						Seq,
						ElectrodeMaterialCode,
						InputQty1,
						InputQty2,
						MaterialLotNumber,
						BinderInputTime,
						BinderOutputTime,
						MixingInputTime,
						MixingOutputTime,
						SpecInOut,
						SpecOutQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.ElectrodeStep,
							SourceTable.Seq,
							SourceTable.ElectrodeMaterialCode,
							SourceTable.InputQty1,
							SourceTable.InputQty2,
							SourceTable.MaterialLotNumber,
							SourceTable.BinderInputTime,
							SourceTable.BinderOutputTime,
							SourceTable.MixingInputTime,
							SourceTable.MixingOutputTime,
							SourceTable.SpecInOut,
							SourceTable.SpecOutQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeMixStepInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
							    ELSE OldElectrodeStep
							END AS OldElectrodeStep,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							ElectrodeStep,
							Seq,
							ElectrodeMaterialCode,
							InputQty1,
							InputQty2,
							MaterialLotNumber,
							BinderInputTime,
							BinderOutputTime,
							MixingInputTime,
							MixingOutputTime,
							SpecInOut,
							SpecOutQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldElectrodeStep VARCHAR(10),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										ElectrodeStep VARCHAR(10),
										Seq INT,
										ElectrodeMaterialCode VARCHAR(20),
										InputQty1 NUMERIC(20,5),
										InputQty2 NUMERIC(20,5),
										MaterialLotNumber VARCHAR(20),
										BinderInputTime DATETIMEOFFSET,
										BinderOutputTime DATETIMEOFFSET,
										MixingInputTime DATETIMEOFFSET,
										MixingOutputTime DATETIMEOFFSET,
										SpecInOut VARCHAR(1),
										SpecOutQty NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.ElectrodeStep = SourceTable.ElectrodeStep AND
					TargetTable.Seq = SourceTable.Seq
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
									OldElectrodeStep,
									OldSeq,
									ElectrodeLotNumber,
									ElectrodeStep,
									Seq,
									ElectrodeMaterialCode,
									InputQty1,
									InputQty2,
									MaterialLotNumber,
									BinderInputTime,
									BinderOutputTime,
									MixingInputTime,
									MixingOutputTime,
									SpecInOut,
									SpecOutQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldElectrodeStep VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 ElectrodeStep VARCHAR(10),
											 Seq INT,
											 ElectrodeMaterialCode VARCHAR(20),
											 InputQty1 NUMERIC(20,5),
											 InputQty2 NUMERIC(20,5),
											 MaterialLotNumber VARCHAR(20),
											 BinderInputTime DATETIMEOFFSET,
											 BinderOutputTime DATETIMEOFFSET,
											 MixingInputTime DATETIMEOFFSET,
											 MixingOutputTime DATETIMEOFFSET,
											 SpecInOut VARCHAR(5),
											 SpecOutQty NUMERIC(20,5),
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
									CASE 
										WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
										ELSE OldElectrodeStep
									END AS OldElectrodeStep,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									ElectrodeStep,
									Seq,
									ElectrodeMaterialCode,
									InputQty1,
									InputQty2,
									MaterialLotNumber,
									BinderInputTime,
									BinderOutputTime,
									MixingInputTime,
									MixingOutputTime,
									SpecInOut,
									SpecOutQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldElectrodeStep VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 ElectrodeStep VARCHAR(10),
											 Seq INT,
											 ElectrodeMaterialCode VARCHAR(20),
											 InputQty1 NUMERIC(20,5),
											 InputQty2 NUMERIC(20,5),
											 MaterialLotNumber VARCHAR(20),
											 BinderInputTime DATETIMEOFFSET,
											 BinderOutputTime DATETIMEOFFSET,
											 MixingInputTime DATETIMEOFFSET,
											 MixingOutputTime DATETIMEOFFSET,
											 SpecInOut VARCHAR(5),
											 SpecOutQty NUMERIC(20,5),
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
									CASE 
										WHEN OldElectrodeStep IS NULL THEN ElectrodeStep
										ELSE OldElectrodeStep
									END AS OldElectrodeStep,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									ElectrodeStep,
									Seq,
									ElectrodeMaterialCode,
									InputQty1,
									InputQty2,
									MaterialLotNumber,
									BinderInputTime,
									BinderOutputTime,
									MixingInputTime,
									MixingOutputTime,
									SpecInOut,
									SpecOutQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldElectrodeStep VARCHAR(10),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 ElectrodeStep VARCHAR(10),
											 Seq INT,
											 ElectrodeMaterialCode VARCHAR(20),
											 InputQty1 NUMERIC(20,5),
											 InputQty2 NUMERIC(20,5),
											 MaterialLotNumber VARCHAR(20),
											 BinderInputTime DATETIMEOFFSET,
											 BinderOutputTime DATETIMEOFFSET,
											 MixingInputTime DATETIMEOFFSET,
											 MixingOutputTime DATETIMEOFFSET,
											 SpecInOut VARCHAR(5),
											 SpecOutQty NUMERIC(20,5),
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
								 @OldElectrodeStep,
								 @OldSeq,
								 @ElectrodeLotNumber,
								 @ElectrodeStep,
								 @Seq,
								 @ElectrodeMaterialCode,
								 @InputQty1,
								 @InputQty2,
								 @MaterialLotNumber,
								 @BinderInputTime,
								 @BinderOutputTime,
								 @MixingInputTime,
								 @MixingOutputTime,
								 @SpecInOut,
								 @SpecOutQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID



			
					


				--Declare @company varchar(20)='';
--select * 
--from STB_UserInfo 
--where UserID=@pProcessUserID and CompanyCode='VVT' ;

if(@pProcessUserID='nguyentung' /*or @@ROWCOUNT>0 and @ElectrodeMaterialCode like '%GAKCCA-00%'*/) begin 

raiserror('nguyentung',16,1)  WITH NOWAIT;
break;
				return;

			select * from 
			STB_MaterialLotInfo
			where MaterialCode=replace(@ElectrodeMaterialCode,'VJJ','')
			and MaterialWarehouseCode like 'ROH%WH'
			and Lotid=@MaterialLotNumber

			if(@@ROWCOUNT=0 ) begin 
				raiserror('Ma LotID cua Kho khong dung voi Nguyen Lieu Dien Cuc thiet lap!',16,1)  WITH NOWAIT;
				break;
				return;
			end
end 



                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END



                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber AND ElectrodeStep = @ElectrodeStep AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeMixStepInfo',@ElectrodeLotNumber OUTPUT
                    END
	

                    INSERT INTO STB_ElectrodeMixStepInfo
						(
						    ElectrodeLotNumber,
						    ElectrodeStep,
						    Seq,
						    ElectrodeMaterialCode,
						    InputQty1,
						    InputQty2,
						    MaterialLotNumber,
						    BinderInputTime,
						    BinderOutputTime,
						    MixingInputTime,
						    MixingOutputTime,
						    SpecInOut,
						    SpecOutQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @ElectrodeStep,
						    @Seq,
						    @ElectrodeMaterialCode,
						    @InputQty1,
						    @InputQty2,
						    @MaterialLotNumber,
						    @BinderInputTime,
						    @BinderOutputTime,
						    @MixingInputTime,
						    @MixingOutputTime,
						    @SpecInOut,
						    @SpecOutQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN


                    UPDATE STB_ElectrodeMixStepInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    ElectrodeStep =   ISNULL(@ElectrodeStep,ElectrodeStep),
						    Seq =   ISNULL(@Seq,Seq),
						    ElectrodeMaterialCode =   ISNULL(@ElectrodeMaterialCode,ElectrodeMaterialCode),
						    InputQty1 =   ISNULL(@InputQty1,InputQty1),
						    InputQty2 =   ISNULL(@InputQty2,InputQty2),
						    MaterialLotNumber =   ISNULL(@MaterialLotNumber,MaterialLotNumber),
						    BinderInputTime =   ISNULL(@BinderInputTime,BinderInputTime),
						    BinderOutputTime =   ISNULL(@BinderOutputTime,BinderOutputTime),
						    MixingInputTime =   ISNULL(@MixingInputTime,MixingInputTime),
						    MixingOutputTime =   ISNULL(@MixingOutputTime,MixingOutputTime),
						    SpecInOut =   ISNULL(@SpecInOut,SpecInOut),
						    SpecOutQty =   ISNULL(@SpecOutQty,SpecOutQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    ElectrodeStep = @OldElectrodeStep AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeMixStepInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    ElectrodeStep = @OldElectrodeStep AND
						    Seq = @OldSeq
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
GO

PRINT 'Procedure usp_ElectrodeMixStepInfo_HY_iud created successfully.';
GO
-- =========================================================
-- 9. Stored Procedure: usp_ElectrodeRollPressingInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeRollPressingInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeRollPressingInfo_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극롤프레싱정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingInfo_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber


	declare @company varchar(10)=''
	select @company=CompanyCode from STB_UserInfo
	where UserID=@pProcessUserID

	   

	SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ERPI.MachineCode
			,MM.MachineName
			,isnull(case when @company='VVT' then dateadd(hour,2,(ERPI.WorkDate)) else (ERPI.WorkDate) end, getdate() ) WorkDate   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
			,ERPI.WorkerCode 
			,PWI.WorkerName
			,ERPI.Temperature
			,ERPI.Humidity
			,ERPI.RollingDensityValue
			,ERPI.RollingDensityResult
			,ERPI.HeadGapInitLeft
			,ERPI.HeadGapInitRight
			,ERPI.ProdConTemp
			,ERPI.ProdConSpeed
			,ERPI.ProductionQty
			,ERPI.GoodQty
			,ERPI.BadQty
			,ERPI.VisualInspectionResult
			,ERPI.CreateDateTime
			,ERPI.CreateUserID
			,ERPI.ChangeDateTime
			,ERPI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,'Report' AS CommandType
			,'O' AS IsRollPress
			,dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber) AS QcRollingDensityValue
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2	                 ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	    ON SI.Barcode = ERPI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON ERPI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON ERPI.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
END
GO

PRINT 'Procedure usp_ElectrodeRollPressingInfo_HY_get created successfully.';
GO
-- =========================================================
-- 10. Stored Procedure: usp_ElectrodeRollPressingInfo_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeRollPressingInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeRollPressingInfo_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극롤프레스정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingInfo_HY_iud]
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
GO

PRINT 'Procedure usp_ElectrodeRollPressingInfo_HY_iud created successfully.';
GO
-- =========================================================
-- 11. Stored Procedure: usp_ElectrodeRollPressingVisualInspectionInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeRollPressingVisualInspectionInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeRollPressingVisualInspectionInfo_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리 > 실적등록> [B550] 전극측정결과 > 롤프레싱 버튼 > 전극롤프레싱정보
-- Description:	전극롤프레싱외관검사정보
-- Modified: Mr.Tung on 31-July-2021
-- usp_ElectrodeRollPressingVisualInspectionInfo_get '','','VJNS2020001E01'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingVisualInspectionInfo_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	;WITH DefaultList AS (
		SELECT 'FIRST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'AUTO' AS MeasureTimeCode, 0 AS Seq  --add by Mr.Tung on 31-July-2021
	)
	SELECT   ISNULL(ERPVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ERPVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ERPVII.Seq, DL.Seq) AS Seq
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.LeftValue,3)-3 else ERPVII.LeftValue end  as LeftValue
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.MiddleValue,3)-3 else ERPVII.MiddleValue end  as MiddleValue
			,case when ERPVII.MeasureTimeCode like 'AUTO%' then isnull(ERPVII.RightValue,3)-3 else ERPVII.RightValue end  as RightValue
			,ERPVII.CreateDateTime
			,ERPVII.CreateUserID
			,ERPVII.ChangeDateTime
			,ERPVII.ChangeUserID
			,EC.OneSideLowerTolerance
			,EC.OneSideUpperTolerance
			,EC.BothSideLowerTolerance
			,EC.BothSideUpperTolerance
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL	    ON 1 = 1
	  OUTER apply (select  distinct ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID,
					  max(Seq) as Seq,
					  max(CreateDateTime) as CreateDateTime,
					  (datepart(minute,CreateDateTime))/6 as maxminute,
					  max(ChangeDateTime) as ChangeDateTime,
					  max(ChangeUserID) as ChangeUserID
						from STB_ElectrodeRollPressingVisualInspectionInfo ERPVII	   where SI.Barcode = ERPVII.ElectrodeLotNumber	and (MeasureTimeCode<>'AUTO' or MeasureTimeCode='AUTO' and MeasureTimeCode not like '% %' and CreateUserID='soft_vvt')
									AND  (
											(DL.MeasureTimeCode = ERPVII.MeasureTimeCode	   AND DL.Seq = ERPVII.Seq) 
											or (DL.MeasureTimeCode = ERPVII.MeasureTimeCode and DL.Seq = 0) --add by Mr.Tung on 31-July-2021
										)
										group by ElectrodeLotNumber,MeasureTimeCode,LeftValue,MiddleValue,RightValue,CreateUserID,(datepart(minute,CreateDateTime))/6
					) ERPVII
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	    
	    ON BC.ItemCode = DL.MeasureTimeCode + CONVERT(CHAR(1), DL.seq)
	   AND BC.CodeGroup = 'MeasureTime'
	  LEFT OUTER JOIN STB_ElectrodeCommon EC ON EC.ProdCode = SI.MaterialCode
	 WHERE SI.Barcode = @ElectrodeLotNumber 
	 
	 -- if  MeasureTimeCode=AUTO then only show value > 0 , Mr.Tung modify because PLC of automatic team send 0 value
	 and ( DL.MeasureTimeCode not like 'AUTO%' or  isnull(ERPVII.LeftValue,0)>0 or	 isnull(ERPVII.MiddleValue,0)>0 or	 isnull(ERPVII.RightValue,0)>0 )
	 -- if  MeasureTimeCode=AUTO then only show value > 0

	 ORDER BY CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	               WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
				   ELSE 4 END
		     ,DL.Seq
			 ,ERPVII.Seq  --add by Mr.Tung on 31-July-2021
			 	
END
GO

PRINT 'Procedure usp_ElectrodeRollPressingVisualInspectionInfo_HY_get created successfully.';
GO
-- =========================================================
-- 12. Stored Procedure: usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극롤프레스외관검사정보
-- Modified: Mr.Tung on 31-July-2021
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud]
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
  DECLARE @OldMeasureTimeCode VARCHAR(1)
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @MeasureTimeCode VARCHAR(1)
  DECLARE @Seq INT
  DECLARE @LeftValue NUMERIC(20,5)
  DECLARE @MiddleValue NUMERIC(20,5)
  DECLARE @RightValue NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeRollPressingVisualInspectionInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeRollPressingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldMeasureTimeCode VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										MeasureTimeCode VARCHAR(20),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					LeftValue = ISNULL(SourceTable.LeftValue,TargetTable.LeftValue),
					MiddleValue = ISNULL(SourceTable.MiddleValue,TargetTable.MiddleValue),
					RightValue = ISNULL(SourceTable.RightValue,TargetTable.RightValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MeasureTimeCode,
						Seq,
						LeftValue,
						MiddleValue,
						RightValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.LeftValue,
							SourceTable.MiddleValue,
							SourceTable.RightValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeRollPressingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldMeasureTimeCode VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										MeasureTimeCode VARCHAR(20),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.MeasureTimeCode = SourceTable.OldMeasureTimeCode AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					LeftValue = ISNULL(SourceTable.LeftValue,TargetTable.LeftValue),
					MiddleValue = ISNULL(SourceTable.MiddleValue,TargetTable.MiddleValue),
					RightValue = ISNULL(SourceTable.RightValue,TargetTable.RightValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MeasureTimeCode,
						Seq,
						LeftValue,
						MiddleValue,
						RightValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.LeftValue,
							SourceTable.MiddleValue,
							SourceTable.RightValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeRollPressingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldMeasureTimeCode VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										MeasureTimeCode VARCHAR(20),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
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
									OldMeasureTimeCode,
									OldSeq,
									ElectrodeLotNumber,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldMeasureTimeCode VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 MeasureTimeCode VARCHAR(20),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
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
									CASE 
										WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
										ELSE OldMeasureTimeCode
									END AS OldMeasureTimeCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldMeasureTimeCode VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 MeasureTimeCode VARCHAR(20),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
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
									CASE 
										WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
										ELSE OldMeasureTimeCode
									END AS OldMeasureTimeCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldMeasureTimeCode VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 MeasureTimeCode VARCHAR(20),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
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
								 @OldMeasureTimeCode,
								 @OldSeq,
								 @ElectrodeLotNumber,
								 @MeasureTimeCode,
								 @Seq,
								 @LeftValue,
								 @MiddleValue,
								 @RightValue,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				if(@MeasureTimeCode='AUTO') continue;  --add by Mr.Tung on 31-July-2021

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeRollPressingVisualInspectionInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber AND MeasureTimeCode = @MeasureTimeCode AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeRollPressingVisualInspectionInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeRollPressingVisualInspectionInfo
						(
						    ElectrodeLotNumber,
						    MeasureTimeCode,
						    Seq,
						    LeftValue,
						    MiddleValue,
						    RightValue,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @MeasureTimeCode,
						    @Seq,
						    @LeftValue,
						    @MiddleValue,
						    @RightValue,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeRollPressingVisualInspectionInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MeasureTimeCode =   ISNULL(@MeasureTimeCode,MeasureTimeCode),
						    Seq =   ISNULL(@Seq,Seq),
						    LeftValue =   ISNULL(@LeftValue,LeftValue),
						    MiddleValue =   ISNULL(@MiddleValue,MiddleValue),
						    RightValue =   ISNULL(@RightValue,RightValue),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    MeasureTimeCode = @OldMeasureTimeCode AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeRollPressingVisualInspectionInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    MeasureTimeCode = @OldMeasureTimeCode AND
						    Seq = @OldSeq
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
GO

PRINT 'Procedure usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud created successfully.';
GO
-- =========================================================
-- 13. Stored Procedure: usp_ElectrodeSlittingInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeSlittingInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeSlittingInfo_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극슬리팅정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingInfo_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber
			
	
	declare @company varchar(10)=''
	select @company=CompanyCode from STB_UserInfo
	where UserID=@pProcessUserID
	

	SELECT   ISNULL(ESI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ESI.MachineCode
			,MM.MachineName
			,ISNULL(case when @company='VVT' then dateadd(hour,2,(ESI.WorkDate)) else (ESI.WorkDate) end , getdate() ) WorkDate  --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
			,ESI.WorkerCode 
			,PWI.WorkerName
			,ESI.Temperature
			,ESI.Humidity
			,ESI.PushingYn
			,ESI.VisualInspectionResult
			,ESI.SlittingLength
			,ESI.Remark
			,ESI.CreateDateTime
			,ESI.CreateUserID
			,ESI.ChangeDateTime
			,ESI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,ESI.PicturesLotNo
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeSlittingInfo ESI
	    ON SI.Barcode = ESI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON ESI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON ESI.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
END
GO

PRINT 'Procedure usp_ElectrodeSlittingInfo_HY_get created successfully.';
GO
-- =========================================================
-- 14. Stored Procedure: usp_ElectrodeSlittingInfo_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeSlittingInfo_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeSlittingInfo_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극슬리팅정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingInfo_HY_iud]
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
  DECLARE @PushingYn VARCHAR(1)
  DECLARE @VisualInspectionResult VARCHAR(1000)
  DECLARE @SlittingLength NUMERIC(20,5)
  DECLARE @Remark VARCHAR(1000)
  DECLARE @PicturesLotNo varbinary(max)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeSlittingInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeSlittingInfo AS TargetTable
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
							PushingYn,
							VisualInspectionResult,
							SlittingLength,
							Remark,
							dbo.fnBase64ToBinary(PicturesLotNo) AS PicturesLotNo,
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
										PushingYn VARCHAR(1),
										VisualInspectionResult VARCHAR(1000),
										SlittingLength NUMERIC(20,5),
										Remark VARCHAR(1000),
										PicturesLotNo NVARCHAR(max),
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
					PushingYn = ISNULL(SourceTable.PushingYn,TargetTable.PushingYn),
					VisualInspectionResult = ISNULL(SourceTable.VisualInspectionResult,TargetTable.VisualInspectionResult),
					SlittingLength = ISNULL(SourceTable.SlittingLength,TargetTable.SlittingLength),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					PicturesLotNo = ISNULL(SourceTable.PicturesLotNo,TargetTable.PicturesLotNo),
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
						PushingYn,
						VisualInspectionResult,
						SlittingLength,
						Remark,
						PicturesLotNo,
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
							SourceTable.PushingYn,
							SourceTable.VisualInspectionResult,
							SourceTable.SlittingLength,
							SourceTable.Remark,
							SourceTable.PicturesLotNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeSlittingInfo AS TargetTable
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
							PushingYn,
							VisualInspectionResult,
							SlittingLength,
							Remark,
							dbo.fnBase64ToBinary(PicturesLotNo) AS PicturesLotNo,
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
										PushingYn VARCHAR(1),
										VisualInspectionResult VARCHAR(1000),
										SlittingLength NUMERIC(20,5),
										Remark VARCHAR(1000),
										PicturesLotNo NVARCHAR(max),
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
					PushingYn = ISNULL(SourceTable.PushingYn,TargetTable.PushingYn),
					VisualInspectionResult = ISNULL(SourceTable.VisualInspectionResult,TargetTable.VisualInspectionResult),
					SlittingLength = ISNULL(SourceTable.SlittingLength,TargetTable.SlittingLength),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					PicturesLotNo = ISNULL(SourceTable.PicturesLotNo,TargetTable.PicturesLotNo),
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
						PushingYn,
						VisualInspectionResult,
						SlittingLength,
						Remark,
						PicturesLotNo,
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
							SourceTable.PushingYn,
							SourceTable.VisualInspectionResult,
							SourceTable.SlittingLength,
							SourceTable.Remark,
							SourceTable.PicturesLotNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeSlittingInfo AS TargetTable
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
							PushingYn,
							VisualInspectionResult,
							SlittingLength,
							Remark,
							dbo.fnBase64ToBinary(PicturesLotNo) AS PicturesLotNo,
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
										PushingYn VARCHAR(1),
										VisualInspectionResult VARCHAR(1000),
										SlittingLength NUMERIC(20,5),
										Remark VARCHAR(1000),
										PicturesLotNo NVARCHAR(MAX),
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
									PushingYn,
									VisualInspectionResult,
									SlittingLength,
									Remark,
									dbo.fnBase64ToBinary(PicturesLotNo) AS PicturesLotNo,
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
											 PushingYn VARCHAR(1),
											 VisualInspectionResult VARCHAR(1000),
											 SlittingLength NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 PicturesLotNo NVARCHAR(MAX),
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
									PushingYn,
									VisualInspectionResult,
									SlittingLength,
									Remark,
									dbo.fnBase64ToBinary(PicturesLotNo) AS PicturesLotNo,
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
											 PushingYn VARCHAR(1),
											 VisualInspectionResult VARCHAR(1000),
											 SlittingLength NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 PicturesLotNo NVARCHAR(MAX),
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
									PushingYn,
									VisualInspectionResult,
									SlittingLength,
									Remark,
									dbo.fnBase64ToBinary(PicturesLotNo) AS PicturesLotNo,
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
											 PushingYn VARCHAR(1),
											 VisualInspectionResult VARCHAR(1000),
											 SlittingLength NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 PicturesLotNo NVARCHAR(MAX),
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
								 @PushingYn,
								 @VisualInspectionResult,
								 @SlittingLength,
								 @Remark,
								 @PicturesLotNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeSlittingInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeSlittingInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeSlittingInfo
						(
						    ElectrodeLotNumber,
						    MachineCode,
						    WorkDate,
						    WorkerCode,
						    Temperature,
						    Humidity,
						    PushingYn,
						    VisualInspectionResult,
						    SlittingLength,
						    Remark,
							PicturesLotNo,
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
						    @PushingYn,
						    @VisualInspectionResult,
						    @SlittingLength,
						    @Remark,
							@PicturesLotNo,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeSlittingInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    WorkDate =   ISNULL(@WorkDate,WorkDate),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    Temperature =   ISNULL(@Temperature,Temperature),
						    Humidity =   ISNULL(@Humidity,Humidity),
						    PushingYn =   ISNULL(@PushingYn,PushingYn),
						    VisualInspectionResult =   ISNULL(@VisualInspectionResult,VisualInspectionResult),
						    SlittingLength =   ISNULL(@SlittingLength,SlittingLength),
						    Remark =   ISNULL(@Remark,Remark),
							PicturesLotNo = ISNULL(@PicturesLotNo,PicturesLotNo),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeSlittingInfo
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
GO

PRINT 'Procedure usp_ElectrodeSlittingInfo_HY_iud created successfully.';
GO
-- =========================================================
-- 15. Stored Procedure: usp_ElectrodeSlittingResult_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeSlittingResult_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeSlittingResult_HY_get];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극슬리팅결과정보
-- 2021.11.08  조회항목추가 (밀도값)
-- [usp_ElectrodeSlittingResult_get] '','', 'VVQK2718001E32'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingResult_HY_get]
	  @pProcessUserID VARCHAR(20),
	  @pProcessLanguage VARCHAR(20),
	  @pElectrodeLotNumber VARCHAR(20) = NULL
--	, @pQcRollingDensityValue Numeric = Null
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	       ,@UserCompanyCode VARCHAR(20)

	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	SELECT @UserCompanyCode = CompanyCode 
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID



	--raiserror ( @ElectrodeLotNumber ,16,1) ;
	IF @UserCompanyCode = 'VNT' BEGIN
		SELECT   ESR.ElectrodeLotNumber
				,ESR.Seq
				,ESR.ElectrodeThick
				,ESR.SlittingWidth
				,ESR.ProductionQty
				,ESR.GoodQtyLength
				,ESR.CreateDateTime
				,ESR.CreateUserID
				,ESR.ChangeDateTime
				,ESR.ChangeUserID
				,'Report' AS CommandType
				,ESR.Barcode
				,ESR.LotUniqueNumber
				,RIGHT(ESR.Barcode, 3) AS CutNo
				,MM.MaterialSource
				--, '' AS QcRollingDensityValue
				, Round(dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber), 3) AS QcRollingDensityValue
				,ESR.SlittingMaterialCode
		  FROM STB_ElectrodeSlittingResult ESR
				  LEFT OUTER JOIN STB_SetInfo SI	                ON ESR.ElectrodeLotNumber = SI.Barcode
				  LEFT OUTER JOIN STB_MaterialMaster MM	 ON MM.MaterialCode = SI.MaterialCode
		 WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
		 ORDER BY Seq
	 END ELSE BEGIN
		;with
			getlistElect as (
					SELECT   ESR.ElectrodeLotNumber
					--,ESR.Seq
					,ESR.ElectrodeThick
					,ESR.SlittingWidth
					,MaterialThickness
					,ESR.ProductionQty
					,ESR.GoodQtyLength
					,ESR.CreateDateTime
					,ESR.CreateUserID
					,ESR.ChangeDateTime
					,ESR.ChangeUserID
					,'Report' AS CommandType
					,ESR.Barcode
					,ESR.Seq
					,ESR.LotUniqueNumber
					,RIGHT(ESR.Barcode, 3) AS CutNo
					,MM.MaterialSource
					,MM.MaterialCode
					,MM.MaterialName
					, Round(dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber), 3) AS QcRollingDensityValue
					,ESR.SlittingMaterialCode
			  FROM STB_ElectrodeSlittingResult ESR
					  LEFT OUTER JOIN STB_SetInfo SI	                ON ESR.ElectrodeLotNumber = SI.Barcode
					  LEFT OUTER JOIN STB_MaterialMaster MM	 ON MM.MaterialCode = SI.MaterialCode
			 WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
			 --ORDER BY Seq
			),
			getconfig as(
			select distinct Partno,SlittingCode,SlittingSize ,Width, min(Farad) as Farad
			from stb_slittinglocationconfig_vvt vvt	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth 
			and vvt.WarehouseLocation IN ('VVT_F1') -- hiện tại chỉ có bắc ninh sản xuất điện cực nên so sánh với config điện cực của bắc ninh
			group by Partno,SlittingCode,SlittingSize,Width
			)
			,
			getFrad as (
			select PartNo,SlittingCode,SlittingSize,Farad,Width,cw.Seq,cw.CommandType
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,ElectrodeLotNumber,cw.Barcode,ElectrodeThick,SlittingWidth,
			GoodQtyLength ,cw.CreateDateTime,LotUniqueNumber,cw.CutNo
			
			from getconfig	with(nolock) 
			join getlistElect cw on (SlittingCode like '%'+cw.MaterialSource+'%' and  (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and  Width=cw.SlittingWidth
			)
			,resultst as (
					select
					-- thay đổi nếu cắt cho hàng 2245 thì sẽ chia làm 2 loai partno được chia theo như bên dưới để tránh nhầm lẫn điện cực cho các hàng theo Mr.Bách 2025-02-17
					case when PartNo in ('2245') and SlittingCode ='YP' then '2245S,C'
					     when PartNo in ('2245') and SlittingCode ='BA21E' then '2245L'
						 when MaterialCode = 'CRFYN85L' and Partno = '1030' then '1030_Low' --Mr Bach request 2026-01-06
						 when MaterialCode = 'CRFYN85' and Partno = '1030' then '1030_VET' --Mr Bach request 2026-01-06
						 when MaterialCode = 'CRFYO85B-02' and Partno = '1030' then '1030_L' --Mr Lân request 2026-01-07
						 when MaterialCode = 'CREBO85L' and PartNo = '1030' then  '1030_Low' --Mr Huy request 2026-01-15
						 when MaterialCode = 'CREYO85B-02' and Partno = '1030' and ElectrodeLotNumber = 'VVQL1720001E19' then '1030_L' --Mr Lân request 2026-01-07
						 when MaterialCode = 'CRFYN85L' and Partno = '1625' then '1625_Low' --Mr Huy request 2026-04-24
						 when MaterialCode = 'CRECO85A' and Partno = '1625' then '1625_Low' --Mr Huy request 2026-04-24
						 when MaterialCode = 'CRECO85-03' and Partno = '1625' then '1625_Low' --Mr Huy request 2026-04-24
						when MaterialCode = 'CREBO85' and Partno = '1030' then '1030_VET(+)' --Mr Huy request 2026-04-24

					else PartNo end as PartNo
					,case when MaterialCode = 'CRYPK0-018' then 'BH(4:6)' else SlittingCode end as SlittingCode --updated 2025-12-27
					,SlittingSize,
					case when PartNo in ('1840') and SlittingCode in ('YP') and Farad in ('50','60') -- bỏ trắng theo yêu cầu của Mr.Bách 2024-09-18
						then 
							null
						else
							Farad
						end as Farad
					,Width,Seq,CommandType
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,ElectrodeLotNumber,Barcode,ElectrodeThick,
			SlittingWidth,
			GoodQtyLength ,CreateDateTime,LotUniqueNumber,CutNo from getFrad
			)
					select * from resultst 	

		END
END
GO

PRINT 'Procedure usp_ElectrodeSlittingResult_HY_get created successfully.';
GO
-- =========================================================
-- 16. Stored Procedure: usp_ElectrodeSlittingResult_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeSlittingResult_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeSlittingResult_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극슬리팅결과
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingResult_HY_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pElectrodeLotNumber VARCHAR(20) = NULL
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
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @Seq INT
  DECLARE @ElectrodeThick NUMERIC(20,5)
  DECLARE @SlittingWidth NUMERIC(20,5)
  DECLARE @ProductionQty NUMERIC(20,5)
  DECLARE @GoodQtyLength NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @SlittingBarcodeSeq INT


  declare @companycode varchar(10)=''
  select @companycode=companycode from STB_UserInfo
  where UserID=@pProcessUserID


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeSlittingResult',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeSlittingResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							Seq,
							ElectrodeThick,
							SlittingWidth,
							ProductionQty,
							GoodQtyLength,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										Seq INT,
										ElectrodeThick NUMERIC(20,5),
										SlittingWidth NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQtyLength NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeThick = ISNULL(SourceTable.ElectrodeThick,TargetTable.ElectrodeThick),
					SlittingWidth = ISNULL(SourceTable.SlittingWidth,TargetTable.SlittingWidth),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQtyLength = ISNULL(SourceTable.GoodQtyLength,TargetTable.GoodQtyLength),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						Seq,
						ElectrodeThick,
						SlittingWidth,
						ProductionQty,
						GoodQtyLength,
						CreateDateTime,
						CreateUserID,
						CompanyCode,
						WorkCenterCode
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.Seq,
							SourceTable.ElectrodeThick,
							SourceTable.SlittingWidth,
							SourceTable.ProductionQty,
							SourceTable.GoodQtyLength,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							'VVT',
							'VVT_F1'
					);


			-- Process Update Table
            MERGE STB_ElectrodeSlittingResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							Seq,
							ElectrodeThick,
							SlittingWidth,
							ProductionQty,
							GoodQtyLength,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										Seq INT,
										ElectrodeThick NUMERIC(20,5),
										SlittingWidth NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQtyLength NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					ElectrodeThick = ISNULL(SourceTable.ElectrodeThick,TargetTable.ElectrodeThick),
					SlittingWidth = ISNULL(SourceTable.SlittingWidth,TargetTable.SlittingWidth),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					GoodQtyLength = ISNULL(SourceTable.GoodQtyLength,TargetTable.GoodQtyLength),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						Seq,
						ElectrodeThick,
						SlittingWidth,
						ProductionQty,
						GoodQtyLength,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.Seq,
							SourceTable.ElectrodeThick,
							SourceTable.SlittingWidth,
							SourceTable.ProductionQty,
							SourceTable.GoodQtyLength,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeSlittingResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							Seq,
							ElectrodeThick,
							SlittingWidth,
							ProductionQty,
							GoodQtyLength,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										Seq INT,
										ElectrodeThick NUMERIC(20,5),
										SlittingWidth NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										GoodQtyLength NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.Seq = SourceTable.Seq
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
									OldSeq,
									ElectrodeLotNumber,
									Seq,
									ElectrodeThick,
									SlittingWidth,
									ProductionQty,
									GoodQtyLength,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 Seq INT,
											 ElectrodeThick NUMERIC(20,5),
											 SlittingWidth NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQtyLength NUMERIC(20,5),
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
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									Seq,
									ElectrodeThick,
									SlittingWidth,
									ProductionQty,
									GoodQtyLength,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 Seq INT,
											 ElectrodeThick NUMERIC(20,5),
											 SlittingWidth NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQtyLength NUMERIC(20,5),
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
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									Seq,
									ElectrodeThick,
									SlittingWidth,
									ProductionQty,
									GoodQtyLength,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 Seq INT,
											 ElectrodeThick NUMERIC(20,5),
											 SlittingWidth NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 GoodQtyLength NUMERIC(20,5),
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
								 @OldSeq,
								 @ElectrodeLotNumber,
								 @Seq,
								 @ElectrodeThick,
								 @SlittingWidth,
								 @ProductionQty,
								 @GoodQtyLength,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeSlittingResult WHERE ElectrodeLotNumber = @ElectrodeLotNumber AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        --EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeSlittingResult',@ElectrodeLotNumber OUTPUT

						EXEC usp_GetNewSerialNoForBarcode @pProcessUserID, '', @ElectrodeLotNumber, @SlittingBarcodeSeq OUTPUT
                    END

                    INSERT INTO STB_ElectrodeSlittingResult
						(
						    ElectrodeLotNumber,
						    Seq,
						    ElectrodeThick,
						    SlittingWidth,
						    ProductionQty,
						    GoodQtyLength,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
									CompanyCode,
									WorkCenterCode
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @SlittingBarcodeSeq,
						    @ElectrodeThick,
						    @SlittingWidth,
						    @GoodQtyLength, -- ProductionQty는 화면에서 삭제(의미없음.)
						    @GoodQtyLength,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							'VVT',
							'VVT_F1'
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
						  -- Mr.Triều Block user delete lotnumber for Electrode
  						IF (@pProcessUserID NOT IN ('HaiTrieu','DinhManh') )
						BEGIN
							RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1);
						END    

					--Mr.Manh update 2026-03-20 Lưu lịch sử chỉnh sửa
					INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID) values
						(@ElectrodeLotNumber, @Seq, @IUD_FLAG, GETDATE(), @pProcessUserID)
					--

                    UPDATE STB_ElectrodeSlittingResult
						SET
						    SlittingWidth =   ISNULL(@SlittingWidth,SlittingWidth),
						    ProductionQty =   case when @companycode='VVT' then ISNULL(@ProductionQty,ProductionQty) else ProductionQty end, --updated for Vietnam Factory, remain for Korean
						    GoodQtyLength =   ISNULL(@GoodQtyLength,GoodQtyLength),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    Seq = @OldSeq

					
							
					
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
						  -- Mr.Triều Block user delete lotnumber for Electrode
  							IF (@pProcessUserID NOT IN ('HaiTrieu','DinhManh') )
							BEGIN
								RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1);
							END    

					--Mr.Manh update 2026-03-20 Lưu lịch sử Xóa
					INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID) values
						(@ElectrodeLotNumber, @Seq, @IUD_FLAG, GETDATE(), @pProcessUserID)
					--

                    DELETE FROM STB_ElectrodeSlittingResult
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    Seq = @OldSeq
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
GO

PRINT 'Procedure usp_ElectrodeSlittingResult_HY_iud created successfully.';
GO
-- =========================================================
-- 17. Stored Procedure: usp_ElectrodeWasteInfoNew_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeWasteInfoNew_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeWasteInfoNew_HY_iud];
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-04
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWasteInfoNew_HY_iud]
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
  DECLARE @OldElectrodeWasteNo VARCHAR(20)
  DECLARE @ElectrodeWasteNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @JobDate DATE
  DECLARE @CalendarCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @ElectrodeClassCode VARCHAR(20)
  DECLARE @CurrentCollectorClassCode VARCHAR(20)
  DECLARE @ElectrodeThickness VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @DefectWeight NUMERIC(20,3)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeWasteInfoNew',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeWasteInfoNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
							    ELSE OldElectrodeWasteNo
							END AS OldElectrodeWasteNo,
							ElectrodeWasteNo,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							JobDate,
							CalendarCode,
							RouteCode,
							ElectrodeClassCode,
							CurrentCollectorClassCode,
							ElectrodeThickness,
							MachineCode,
							DefectCode,
							DefectWeight,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeWasteNo VARCHAR(20),
										ElectrodeWasteNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CalendarCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										CurrentCollectorClassCode VARCHAR(20),
										ElectrodeThickness VARCHAR(20),
										MachineCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectWeight NUMERIC(20,3),
										Remark NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWasteNo = SourceTable.ElectrodeWasteNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeWasteNo = ISNULL(SourceTable.ElectrodeWasteNo,TargetTable.ElectrodeWasteNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CalendarCode = ISNULL(SourceTable.CalendarCode,TargetTable.CalendarCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ElectrodeClassCode = ISNULL(SourceTable.ElectrodeClassCode,TargetTable.ElectrodeClassCode),
					CurrentCollectorClassCode = ISNULL(SourceTable.CurrentCollectorClassCode,TargetTable.CurrentCollectorClassCode),
					ElectrodeThickness = ISNULL(SourceTable.ElectrodeThickness,TargetTable.ElectrodeThickness),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectWeight = ISNULL(SourceTable.DefectWeight,TargetTable.DefectWeight),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeWasteNo,
						CompanyCode,
						WorkCenterCode,
						LineCode,
						JobDate,
						CalendarCode,
						RouteCode,
						ElectrodeClassCode,
						CurrentCollectorClassCode,
						ElectrodeThickness,
						MachineCode,
						DefectCode,
						DefectWeight,
						Remark,
						CreateDateTime,
						CreateUserID,
						Barcode
					)
				VALUES
					(
							SourceTable.ElectrodeWasteNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.JobDate,
							SourceTable.CalendarCode,
							SourceTable.RouteCode,
							SourceTable.ElectrodeClassCode,
							SourceTable.CurrentCollectorClassCode,
							SourceTable.ElectrodeThickness,
							SourceTable.MachineCode,
							SourceTable.DefectCode,
							SourceTable.DefectWeight,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Barcode
					);


			-- Process Update Table
            MERGE STB_ElectrodeWasteInfoNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
							    ELSE OldElectrodeWasteNo
							END AS OldElectrodeWasteNo,
							ElectrodeWasteNo,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							JobDate,
							CalendarCode,
							RouteCode,
							ElectrodeClassCode,
							CurrentCollectorClassCode,
							ElectrodeThickness,
							MachineCode,
							DefectCode,
							DefectWeight,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeWasteNo VARCHAR(20),
										ElectrodeWasteNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CalendarCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										CurrentCollectorClassCode VARCHAR(20),
										ElectrodeThickness VARCHAR(20),
										MachineCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectWeight NUMERIC(20,3),
										Remark NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWasteNo = SourceTable.OldElectrodeWasteNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeWasteNo = ISNULL(SourceTable.ElectrodeWasteNo,TargetTable.ElectrodeWasteNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CalendarCode = ISNULL(SourceTable.CalendarCode,TargetTable.CalendarCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ElectrodeClassCode = ISNULL(SourceTable.ElectrodeClassCode,TargetTable.ElectrodeClassCode),
					CurrentCollectorClassCode = ISNULL(SourceTable.CurrentCollectorClassCode,TargetTable.CurrentCollectorClassCode),
					ElectrodeThickness = ISNULL(SourceTable.ElectrodeThickness,TargetTable.ElectrodeThickness),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectWeight = ISNULL(SourceTable.DefectWeight,TargetTable.DefectWeight),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeWasteNo,
						CompanyCode,
						WorkCenterCode,
						LineCode,
						JobDate,
						CalendarCode,
						RouteCode,
						ElectrodeClassCode,
						CurrentCollectorClassCode,
						ElectrodeThickness,
						MachineCode,
						DefectCode,
						DefectWeight,
						Remark,
						CreateDateTime,
						CreateUserID,
						Barcode
					)
				VALUES
					(
							SourceTable.ElectrodeWasteNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.JobDate,
							SourceTable.CalendarCode,
							SourceTable.RouteCode,
							SourceTable.ElectrodeClassCode,
							SourceTable.CurrentCollectorClassCode,
							SourceTable.ElectrodeThickness,
							SourceTable.MachineCode,
							SourceTable.DefectCode,
							SourceTable.DefectWeight,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Barcode
					);


			-- Process Delete Table
            MERGE STB_ElectrodeWasteInfoNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
							    ELSE OldElectrodeWasteNo
							END AS OldElectrodeWasteNo,
							ElectrodeWasteNo,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							JobDate,
							CalendarCode,
							RouteCode,
							ElectrodeClassCode,
							CurrentCollectorClassCode,
							ElectrodeThickness,
							MachineCode,
							DefectCode,
							DefectWeight,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeWasteNo VARCHAR(20),
										ElectrodeWasteNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CalendarCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										CurrentCollectorClassCode VARCHAR(20),
										ElectrodeThickness VARCHAR(20),
										MachineCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectWeight NUMERIC(20,3),
										Remark NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWasteNo = SourceTable.ElectrodeWasteNo
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
									OldElectrodeWasteNo,
									ElectrodeWasteNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									JobDate,
									CalendarCode,
									RouteCode,
									ElectrodeClassCode,
									CurrentCollectorClassCode,
									ElectrodeThickness,
									MachineCode,
									DefectCode,
									DefectWeight,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeWasteNo VARCHAR(20),
											 ElectrodeWasteNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CalendarCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 ElectrodeClassCode VARCHAR(20),
											 CurrentCollectorClassCode VARCHAR(20),
											 ElectrodeThickness VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectWeight NUMERIC(20,3),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
										ELSE OldElectrodeWasteNo
									END AS OldElectrodeWasteNo,
									ElectrodeWasteNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									JobDate,
									CalendarCode,
									RouteCode,
									ElectrodeClassCode,
									CurrentCollectorClassCode,
									ElectrodeThickness,
									MachineCode,
									DefectCode,
									DefectWeight,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeWasteNo VARCHAR(20),
											 ElectrodeWasteNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CalendarCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 ElectrodeClassCode VARCHAR(20),
											 CurrentCollectorClassCode VARCHAR(20),
											 ElectrodeThickness VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectWeight NUMERIC(20,3),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
										ELSE OldElectrodeWasteNo
									END AS OldElectrodeWasteNo,
									ElectrodeWasteNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									JobDate,
									CalendarCode,
									RouteCode,
									ElectrodeClassCode,
									CurrentCollectorClassCode,
									ElectrodeThickness,
									MachineCode,
									DefectCode,
									DefectWeight,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeWasteNo VARCHAR(20),
											 ElectrodeWasteNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CalendarCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 ElectrodeClassCode VARCHAR(20),
											 CurrentCollectorClassCode VARCHAR(20),
											 ElectrodeThickness VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectWeight NUMERIC(20,3),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeWasteNo,
								 @ElectrodeWasteNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineCode,
								 @JobDate,
								 @CalendarCode,
								 @RouteCode,
								 @ElectrodeClassCode,
								 @CurrentCollectorClassCode,
								 @ElectrodeThickness,
								 @MachineCode,
								 @DefectCode,
								 @DefectWeight,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Barcode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeWasteInfoNew WHERE ElectrodeWasteNo = @ElectrodeWasteNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeWasteNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeWasteInfoNew',@ElectrodeWasteNo OUTPUT
                    END

                    INSERT INTO STB_ElectrodeWasteInfoNew
						(
						    ElectrodeWasteNo,
						    CompanyCode,
						    WorkCenterCode,
						    LineCode,
						    JobDate,
						    CalendarCode,
						    RouteCode,
						    ElectrodeClassCode,
						    CurrentCollectorClassCode,
						    ElectrodeThickness,
						    MachineCode,
						    DefectCode,
						    DefectWeight,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    Barcode
						)
						VALUES
						(
						    @ElectrodeWasteNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @LineCode,
						    @JobDate,
						    @CalendarCode,
						    @RouteCode,
						    @ElectrodeClassCode,
						    @CurrentCollectorClassCode,
						    @ElectrodeThickness,
						    @MachineCode,
						    @DefectCode,
						    @DefectWeight,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @Barcode
						)


						-- Mr.Manh update 2026-04-01
						update STB_ElectrodeWasteInfoNew
						set ElectrodeThickness = SUBSTRING(ElectrodeThickness, 1, CHARINDEX('.', ElectrodeThickness) - 1)
						where ElectrodeThickness LIKE '%.00%'



				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeWasteInfoNew
						SET
						    ElectrodeWasteNo =   ISNULL(@ElectrodeWasteNo,ElectrodeWasteNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    CalendarCode =   ISNULL(@CalendarCode,CalendarCode),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    ElectrodeClassCode =   ISNULL(@ElectrodeClassCode,ElectrodeClassCode),
						    CurrentCollectorClassCode =   ISNULL(@CurrentCollectorClassCode,CurrentCollectorClassCode),
						    ElectrodeThickness =   ISNULL(@ElectrodeThickness,ElectrodeThickness),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
						    DefectWeight =   ISNULL(@DefectWeight,DefectWeight),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    Barcode =   ISNULL(@Barcode,Barcode)
						WHERE
						    ElectrodeWasteNo = @OldElectrodeWasteNo

						-- Mr.Manh update 2026-04-01
						update STB_ElectrodeWasteInfoNew
						set ElectrodeThickness = SUBSTRING(ElectrodeThickness, 1, CHARINDEX('.', ElectrodeThickness) - 1)
						where ElectrodeThickness LIKE '%.00%'

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeWasteInfoNew
						WHERE
						    ElectrodeWasteNo = @OldElectrodeWasteNo
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
GO

PRINT 'Procedure usp_ElectrodeWasteInfoNew_HY_iud created successfully.';
GO
-- =========================================================
-- 18. Stored Procedure: usp_ElectrodeWastePriceNewByBarcode_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeWastePriceNewByBarcode_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeWastePriceNewByBarcode_HY_get];
GO

-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020.02.26
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWastePriceNewByBarcode_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = ''
AS

BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode

	SELECT EWIN.ElectrodeWasteNo
	      ,EWIN.CompanyCode
		  ,EWIN.WorkCenterCode
		  ,EWIN.LineCode
	      ,EWIN.JobDate
          ,EWIN.CalendarCode
		  ,CM.CalendarName
          ,EWIN.RouteCode
		  ,RI.RouteName
		  ,EWIN.Barcode
          ,EWIN.MachineCode
		  ,MM.MachineName
		  ,EWIN.ElectrodeClassCode
		  ,BC1.Description AS ElectrodeClassName
          ,EWIN.CurrentCollectorClassCode
		  ,BC2.Description AS CurrentCollectorClassName
          ,EWIN.ElectrodeThickness
          ,BC3.Description AS ElectrodeThicknessName
          ,EWIN.DefectCode
		  ,DI.BasicDefectName
		  ,EWIN.DefectWeight
		  ,EWPN.DefectUnitPrice
		  ,EWIN.DefectWeight * EWPN.DefectUnitPrice AS DefectPrice
		  ,EWIN.Remark
          ,EWIN.CreateDateTime
          ,EWIN.CreateUserID
          ,EWIN.ChangeDateTime
          ,EWIN.ChangeUserID
		  ,'Report' AS CommandType
	  FROM STB_ElectrodeWasteInfoNew EWIN
	  LEFT OUTER JOIN STB_CalendarMaster CM
	    ON EWIN.CalendarCode = CM.CalendarCode
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON EWIN.RouteCode = RI.RouteCode
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = EWIN.MachineCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON EWIN.ElectrodeClassCode = BC1.ItemCode
	   AND BC1.CodeGroup = 'EWCategory1'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON EWIN.CurrentCollectorClassCode = BC2.ItemCode
	   AND BC2.CodeGroup = 'EWCategory2'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON EWIN.ElectrodeThickness = BC3.ItemCode
	   AND BC3.CodeGroup = 'EWCategory3'
	  LEFT OUTER JOIN STB_DefectInfo DI
	    ON DI.DefectCode = EWIN.DefectCode
	  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN
	    ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode
	   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
	   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
	   AND EWPN.CompanyCode = EWIN.CompanyCode
	   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
	   AND EWPN.RouteCode = EWIN.RouteCode
	   AND EWPN.DefectCode = EWIN.DefectCode
	 WHERE EWIN.Barcode = @Barcode
	 ORDER BY EWIN.JobDate
END
GO

PRINT 'Procedure usp_ElectrodeWastePriceNewByBarcode_HY_get created successfully.';
GO
-- =========================================================
-- 19. Stored Procedure: usp_LocationElectric_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_LocationElectric_HY')
    DROP PROCEDURE [dbo].[usp_LocationElectric_HY];
GO

-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-09-21
-- Description:	Lấy ra vị trí của lot điện cực hiện tại exec usp_LocationElectric '','','VVOR2020001E13'
-- =============================================
CREATE PROCEDURE [dbo].[usp_LocationElectric_HY]
	@pProcessUserID varchar(20)=NULL,
	@pProcessLanguage varchar(20)=NULL,
	@pElectrodeLotNumber varchar(30) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--RAISERROR(14138, -1, -1, @pElectrodeLotNumber);
	select ESR.*,MM.MaterialCode,MM.MaterialName
	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 
	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
	  where 
	  1=1
	  and	ESR.ElectrodeLotNumber=@pElectrodeLotNumber

END
GO

PRINT 'Procedure usp_LocationElectric_HY created successfully.';
GO
-- =========================================================
-- 20. Stored Procedure: usp_test_check_expired_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_test_check_expired_HY')
    DROP PROCEDURE [dbo].[usp_test_check_expired_HY];
GO

-- =============================================
-- Author: Mr.Duy
-- Create date: 2023-12-05
-- Browsable : true
-- =============================================
--exec usp_test_check_expired 'VVNP0120001E02'
CREATE PROCEDURE [dbo].[usp_test_check_expired_HY] 
	@pRawMaterialBarcode1 NVARCHAR(200) 
AS
BEGIN
	
	if(@pRawMaterialBarcode1 ='')
	begin
		DECLARE @errNullest_check_expired  nvarchar(200)
		set @errNullest_check_expired=N'Bị Null';
		RAISERROR(@errNullest_check_expired,16,1)
	end
	declare @OpenExpired bit = 0 
	 	;with data1 as (
			select LotID,max(createdatetime) as createdatetime
			from stb_vvt_OpenExpiredMaterial  with(nolock) 
			where (LotID=substring(@pRawMaterialBarcode1,1,14)  )
			group by lotid
		)
		select top 1 @OpenExpired = voem.OpenExpired 
		from stb_vvt_OpenExpiredMaterial voem with(nolock) 
		join data1 on voem.lotid=data1.lotid and voem.createdatetime = data1.createdatetime

		
		if(isnull(@OpenExpired,0)=0 or @OpenExpired=0 or convert(bit,@OpenExpired)=0)
			   begin
					if(@pRawMaterialBarcode1 like 'VV%' or @pRawMaterialBarcode1 like 'VJ%')
						begin
							DECLARE @time22 varchar(20)
							DECLARE @nDay int
							DECLARE @err22  nvarchar(200)
							SET @time22=dbo.fn_VVT_getdatebyVendorLot('SRFYPK0',@pRawMaterialBarcode1)
							SET @nDay = Cast(DATEDIFF(dd,@time22, GETDATE()) as int)
								if(@nDay>=90)
								begin
									set @err22=N'Mã Lot đã hết hạn.Vui lòng muốn mở liên hệ với QC :' +@pRawMaterialBarcode1;
									--print @err22
									RAISERROR(@err22,16,1)
								end
							
						end
				end

END
GO

PRINT 'Procedure usp_test_check_expired_HY created successfully.';
GO
-- =========================================================
-- 21. Stored Procedure: usp_Vietnam_RollPressingSlitting_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_Vietnam_RollPressingSlitting_HY_get')
    DROP PROCEDURE [dbo].[usp_Vietnam_RollPressingSlitting_HY_get];
GO

-- =============================================
-- Author: Mr.Tung
-- Create date: 2021-12-30
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_RollPressingSlitting_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	declare @topLotNo  VARCHAR(20) ; 
	declare @error varchar(1000) =''; 



	select top 1 @topLotNo = sim.barcode FROM STB_SetInfo SIM   with(nolock) 
	join STB_SetInfo SIB  with(nolock)  on  sim.materialcode = sib.materialcode
	LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI  with(nolock)  ON  SIM.Barcode = ERPI.ElectrodeLotNumber
	--LEFT OUTER JOIN STB_ElectrodeWasteInfoNew eci  with(nolock) on SIM.Barcode = eci.Barcode
	where sib.barcode= @ElectrodeLotNumber
	and sim.createdatetime < sib.createdatetime
	and ERPI.GoodQty is null
	and SIM.Barcode like 'VV%'
	--and sim.barcode < 'VVMJ1820001E04'
	and sim.barcode < @ElectrodeLotNumber
	--and (eci.CompanyCode='VVT' or eci.CompanyCode is null)
	order by sim.CreateDateTime,sim.barcode	
	/*
   if(@topLotNo <> @ElectrodeLotNumber and @@ROWCOUNT>0 )
		select  @error = @error + ' ROLLPRESS: LOT DIEN CUC:    "'+@topLotNo+'"    CHUA NHAP CONG DOAN ROLLPRESS, CAN NHAP LOT:      "'+@topLotNo+'"    TRUOC';
*/

		

	select top 1 @topLotNo = sim.barcode FROM STB_SetInfo SIM   with(nolock) 
	join STB_SetInfo SIB  with(nolock)  on  sim.materialcode = sib.materialcode 
	LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI  with(nolock)  ON  SIM.Barcode = ERPI.ElectrodeLotNumber 
	--LEFT OUTER JOIN STB_ElectrodeWasteInfoNew eci  with(nolock) on SIM.Barcode = eci.Barcode
	OUTER APPLY (
		select top 1 * from STB_ElectrodeSlittingResult esr  with(nolock)  
		where esr.ElectrodeLotNumber = ERPI.ElectrodeLotNumber 			
		) esr
	where sib.barcode= @ElectrodeLotNumber 
	and sim.createdatetime < sib.createdatetime 
	and SIM.Barcode like 'VV%'
	and ERPI.GoodQty>0	
	and sim.barcode < @ElectrodeLotNumber
	and  ( esr.GoodQtyLength is null   and  esr.ProductionQty is null )
	--and (eci.CompanyCode='VVT' or eci.CompanyCode is null)
	order by sim.CreateDateTime,sim.barcode 
	   	/*
    if(@topLotNo <> @ElectrodeLotNumber and @@ROWCOUNT>0 ) 
		select  @error = @error + 
									'                                                                                                     ' +
									'                                                                                                     ' +
				'SLITTING: LOT DIEN CUC:    "'+@topLotNo+'"    CHUA NHAP CONG DOAN SLITTING, CAN NHAP LOT:      "'+@topLotNo+'"    TRUOC'; 
		
		*/
		
	if(@error<>'') 
	begin 
			raiserror (@error,16,1) ; 
			return; 
	end 
	

	select  @ElectrodeLotNumber as ElectrodeLotNumber 
	

	----SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
	----		,ERPI.MachineCode
	----		,MM.MachineName
	----		,ERPI.WorkDate
	----		,ERPI.WorkerCode 
	----		,PWI.WorkerName
	----		,ERPI.Temperature
	----		,ERPI.Humidity
	----		,ERPI.RollingDensityValue
	----		,ERPI.RollingDensityResult
	----		,ERPI.HeadGapInitLeft
	----		,ERPI.HeadGapInitRight
	----		,ERPI.ProdConTemp
	----		,ERPI.ProdConSpeed
	----		,ERPI.ProductionQty
	----		,ERPI.GoodQty
	----		,ERPI.BadQty
	----		,ERPI.VisualInspectionResult
	----		,ERPI.CreateDateTime
	----		,ERPI.CreateUserID
	----		,ERPI.ChangeDateTime
	----		,ERPI.ChangeUserID
	----		,SI.MaterialCode
	----		,MM2.MaterialName
	----		,MM2.MaterialThickness
	----		,'Report' AS CommandType
	----		,'O' AS IsRollPress
	----		, dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber) AS QcRollingDensityValue
	----		, Round(dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber), 3) AS QcRollingDensityValueNew
	----  FROM STB_SetInfo SI with(nolock) 
	----  LEFT OUTER JOIN STB_MaterialMaster MM2 with(nolock) 	                 ON SI.MaterialCode = MM2.MaterialCode
	----  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI with(nolock) 	    ON SI.Barcode = ERPI.ElectrodeLotNumber
	----  LEFT OUTER JOIN STB_MachineMaster MM with(nolock) 	    ON ERPI.MachineCode = MM.MachineCode
	----   LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 	    ON ERPI.WorkerCode = PWI.WorkerCode
	---- WHERE SI.Barcode = @ElectrodeLotNumber
	   
END
GO

PRINT 'Procedure usp_Vietnam_RollPressingSlitting_HY_get created successfully.';
GO
COMMIT TRAN;
PRINT 'Transaction COMMIT successfully. Stored procedures created.';
-- ROLLBACK
GO