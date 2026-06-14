-- =============================================
-- Hotfix ID: 14_FIX_ELECTRODE_PRCS_CARD_HUNG_YEN_SPS
-- Target Object: usp_ElectrodeCommon_HY_get, usp_ElectrodeCommon_HY_iud, usp_ElectrodeOven_HY_get, usp_ElectrodeOven_HY_iud, usp_ElectrodeStep_HY_get, usp_ElectrodeStep_HY_iud
-- Author: Antigravity (Advanced Agentic Coding)
-- Date: 2026-06-11
-- Description: Clone 6 stored procedures for Electrode Process Card screen B470 for Hung Yen (_HY).
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 14_FIX_ELECTRODE_PRCS_CARD_HUNG_YEN_SPS...';
GO

-- =========================================================
-- 1. Stored Procedure: usp_ElectrodeCommon_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeCommon_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeCommon_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_ElectrodeCommon_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProdCode VARCHAR(20) = CASE WHEN ISNULL(@pProdCode,'') = '' THEN '*' ELSE @pProdCode END

	SELECT
			 EC.ProdCode
			,MM.MaterialName AS ProdName
			,EC.LivingSubstance
			,EC.MixRatio
			,EC.TankVolume
			,EC.ElectrodeType
			,EC.MeasureViscosity
			,EC.Remark
			,EC.OneSide
			,EC.OneSideLowerTolerance
			,EC.OneSideUpperTolerance
			,EC.BothSide
			,EC.BothSideLowerTolerance
			,EC.BothSideUpperTolerance
			,EC.RollingDensityMin
			,EC.RollingDensityMax
			,EC.ViscosityMin
			,EC.ViscosityMax
			,EC.UnwndngStdMin
			,EC.UnwndngStdMax
			,EC.UnwndngMeasureValue
			,EC.RwndngStdMin
			,EC.RwndngStdMax
			,EC.RwndngMeasureValue
			,EC.ProdConLinePressure
			,EC.ProdConTemp
			,EC.ProdConTempLowerTolerance
			,EC.ProdConTempUpperTolerance
			,EC.ProdConSpeed
			,EC.ProdConSpeedLowerTolerance
			,EC.ProdConSpeedUpperTolerance
			,EC.ProdConThickStdMin
			,EC.ProdConThickStdMax
			,EC.CoolingWaterStdMin
			,EC.CoolingWaterStdMax
			,EC.LeftHeadGap
			,EC.RightHeadGap
			,EC.AlFoilWidth
			,EC.CoatingWidth
			,EC.OneSideSpeed
			,EC.BothSideSpeed
			,EC.CreateDateTime
			,EC.CreateUserID
			,EC.ChangeDateTime
			,EC.ChangeUserID
			,EC.Batches 
	FROM
			STB_ElectrodeCommon EC
		   ,STB_MaterialMaster MM
	WHERE EC.ProdCode = MM.MaterialCode
	  AND ((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
END
GO

PRINT 'Procedure usp_ElectrodeCommon_HY_get created successfully.';
GO

-- =========================================================
-- 2. Stored Procedure: usp_ElectrodeCommon_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeCommon_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeCommon_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_ElectrodeCommon_HY_iud]
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
  DECLARE @OldProdCode VARCHAR(20)
  DECLARE @ProdCode VARCHAR(20)
  DECLARE @LivingSubstance VARCHAR(50)
  DECLARE @MixRatio NUMERIC(20,5)
  DECLARE @TankVolume NUMERIC(20,5)
  DECLARE @ElectrodeType VARCHAR(20)
  DECLARE @MeasureViscosity NUMERIC(20,5)
  DECLARE @Remark VARCHAR(1000)
  DECLARE @OneSide NUMERIC(20,5)
  DECLARE @BothSide NUMERIC(20,5)
  DECLARE @RollingDensityMin NUMERIC(20,5)
  DECLARE @RollingDensityMax NUMERIC(20,5)
  DECLARE @ViscosityMin NUMERIC(20,5)
  DECLARE @ViscosityMax NUMERIC(20,5)
  DECLARE @UnwndngStdMin NUMERIC(20,5)
  DECLARE @UnwndngStdMax NUMERIC(20,5)
  DECLARE @UnwndngMeasureValue NUMERIC(20,5)
  DECLARE @RwndngStdMin NUMERIC(20,5)
  DECLARE @RwndngStdMax NUMERIC(20,5)
  DECLARE @RwndngMeasureValue NUMERIC(20,5)
  DECLARE @ProdConLinePressure NUMERIC(20,5)
  DECLARE @ProdConTemp NUMERIC(20,5)
  DECLARE @ProdConSpeed NUMERIC(20,5)
  DECLARE @ProdConThickStdMin NUMERIC(20,5)
  DECLARE @ProdConThickStdMax NUMERIC(20,5)
  DECLARE @CoolingWaterStdMin NUMERIC(20,5)
  DECLARE @CoolingWaterStdMax NUMERIC(20,5)
  DECLARE @LeftHeadGap VARCHAR(20)
  DECLARE @RightHeadGap VARCHAR(20)
  DECLARE @AlFoilWidth NUMERIC(20,5)
  DECLARE @CoatingWidth NUMERIC(20,5)
  DECLARE @OneSideSpeed NUMERIC(20,5)
  DECLARE @BothSideSpeed NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @OneSideUpperTolerance NUMERIC(20,5)
  DECLARE @OneSideLowerTolerance NUMERIC(20,5)
  DECLARE @BothSideUpperTolerance NUMERIC(20,5)
  DECLARE @BothSideLowerTolerance NUMERIC(20,5)
  DECLARE @ProdConTempUpperTolerance NUMERIC(20,5)
  DECLARE @ProdConTempLowerTolerance NUMERIC(20,5)
  DECLARE @ProdConSpeedUpperTolerance NUMERIC(20,5)
  DECLARE @ProdConSpeedLowerTolerance NUMERIC(20,5)

  DECLARE @Batches INT

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeCommon',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeCommon AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							ProdCode,
							LivingSubstance,
							MixRatio,
							TankVolume,
							ElectrodeType,
							MeasureViscosity,
							Remark,
							OneSide,
							BothSide,
							RollingDensityMin,
							RollingDensityMax,
							ViscosityMin,
							ViscosityMax,
							UnwndngStdMin,
							UnwndngStdMax,
							UnwndngMeasureValue,
							RwndngStdMin,
							RwndngStdMax,
							RwndngMeasureValue,
							ProdConLinePressure,
							ProdConTemp,
							ProdConSpeed,
							ProdConThickStdMin,
							ProdConThickStdMax,
							CoolingWaterStdMin,
							CoolingWaterStdMax,
							LeftHeadGap,
							RightHeadGap,
							AlFoilWidth,
							CoatingWidth,
							OneSideSpeed,
							BothSideSpeed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							OneSideUpperTolerance,
							OneSideLowerTolerance,
							BothSideUpperTolerance,
							BothSideLowerTolerance,
							ProdConTempUpperTolerance,
							ProdConTempLowerTolerance,
							ProdConSpeedUpperTolerance,
							ProdConSpeedLowerTolerance,
							Batches
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										ProdCode VARCHAR(20),
										LivingSubstance VARCHAR(50),
										MixRatio NUMERIC(20,5),
										TankVolume NUMERIC(20,5),
										ElectrodeType VARCHAR(20),
										MeasureViscosity NUMERIC(20,5),
										Remark VARCHAR(1000),
										OneSide NUMERIC(20,5),
										BothSide NUMERIC(20,5),
										RollingDensityMin NUMERIC(20,5),
										RollingDensityMax NUMERIC(20,5),
										ViscosityMin NUMERIC(20,5),
										ViscosityMax NUMERIC(20,5),
										UnwndngStdMin NUMERIC(20,5),
										UnwndngStdMax NUMERIC(20,5),
										UnwndngMeasureValue NUMERIC(20,5),
										RwndngStdMin NUMERIC(20,5),
										RwndngStdMax NUMERIC(20,5),
										RwndngMeasureValue NUMERIC(20,5),
										ProdConLinePressure NUMERIC(20,5),
										ProdConTemp NUMERIC(20,5),
										ProdConSpeed NUMERIC(20,5),
										ProdConThickStdMin NUMERIC(20,5),
										ProdConThickStdMax NUMERIC(20,5),
										CoolingWaterStdMin NUMERIC(20,5),
										CoolingWaterStdMax NUMERIC(20,5),
										LeftHeadGap VARCHAR(20),
										RightHeadGap VARCHAR(20),
										AlFoilWidth NUMERIC(20,5),
										CoatingWidth NUMERIC(20,5),
										OneSideSpeed NUMERIC(20,5),
										BothSideSpeed NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										OneSideUpperTolerance NUMERIC(20,5),
										OneSideLowerTolerance NUMERIC(20,5),
										BothSideUpperTolerance NUMERIC(20,5),
										BothSideLowerTolerance NUMERIC(20,5),
										ProdConTempUpperTolerance NUMERIC(20,5),
										ProdConTempLowerTolerance NUMERIC(20,5),
										ProdConSpeedUpperTolerance NUMERIC(20,5),
										ProdConSpeedLowerTolerance NUMERIC(20,5),
										Batches INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					LivingSubstance = ISNULL(SourceTable.LivingSubstance,TargetTable.LivingSubstance),
					MixRatio = ISNULL(SourceTable.MixRatio,TargetTable.MixRatio),
					TankVolume = ISNULL(SourceTable.TankVolume,TargetTable.TankVolume),
					ElectrodeType = ISNULL(SourceTable.ElectrodeType,TargetTable.ElectrodeType),
					MeasureViscosity = ISNULL(SourceTable.MeasureViscosity,TargetTable.MeasureViscosity),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					OneSide = ISNULL(SourceTable.OneSide,TargetTable.OneSide),
					BothSide = ISNULL(SourceTable.BothSide,TargetTable.BothSide),
					RollingDensityMin = ISNULL(SourceTable.RollingDensityMin,TargetTable.RollingDensityMin),
					RollingDensityMax = ISNULL(SourceTable.RollingDensityMax,TargetTable.RollingDensityMax),
					ViscosityMin = ISNULL(SourceTable.ViscosityMin,TargetTable.ViscosityMin),
					ViscosityMax = ISNULL(SourceTable.ViscosityMax,TargetTable.ViscosityMax),
					UnwndngStdMin = ISNULL(SourceTable.UnwndngStdMin,TargetTable.UnwndngStdMin),
					UnwndngStdMax = ISNULL(SourceTable.UnwndngStdMax,TargetTable.UnwndngStdMax),
					UnwndngMeasureValue = ISNULL(SourceTable.UnwndngMeasureValue,TargetTable.UnwndngMeasureValue),
					RwndngStdMin = ISNULL(SourceTable.RwndngStdMin,TargetTable.RwndngStdMin),
					RwndngStdMax = ISNULL(SourceTable.RwndngStdMax,TargetTable.RwndngStdMax),
					RwndngMeasureValue = ISNULL(SourceTable.RwndngMeasureValue,TargetTable.RwndngMeasureValue),
					ProdConLinePressure = ISNULL(SourceTable.ProdConLinePressure,TargetTable.ProdConLinePressure),
					ProdConTemp = ISNULL(SourceTable.ProdConTemp,TargetTable.ProdConTemp),
					ProdConSpeed = ISNULL(SourceTable.ProdConSpeed,TargetTable.ProdConSpeed),
					ProdConThickStdMin = ISNULL(SourceTable.ProdConThickStdMin,TargetTable.ProdConThickStdMin),
					ProdConThickStdMax = ISNULL(SourceTable.ProdConThickStdMax,TargetTable.ProdConThickStdMax),
					CoolingWaterStdMin = ISNULL(SourceTable.CoolingWaterStdMin,TargetTable.CoolingWaterStdMin),
					CoolingWaterStdMax = ISNULL(SourceTable.CoolingWaterStdMax,TargetTable.CoolingWaterStdMax),
					LeftHeadGap = ISNULL(SourceTable.LeftHeadGap,TargetTable.LeftHeadGap),
					RightHeadGap = ISNULL(SourceTable.RightHeadGap,TargetTable.RightHeadGap),
					AlFoilWidth = ISNULL(SourceTable.AlFoilWidth,TargetTable.AlFoilWidth),
					CoatingWidth = ISNULL(SourceTable.CoatingWidth,TargetTable.CoatingWidth),
					OneSideSpeed = ISNULL(SourceTable.OneSideSpeed,TargetTable.OneSideSpeed),
					BothSideSpeed = ISNULL(SourceTable.BothSideSpeed,TargetTable.BothSideSpeed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					OneSideUpperTolerance = ISNULL(SourceTable.OneSideUpperTolerance,TargetTable.OneSideUpperTolerance),
					OneSideLowerTolerance = ISNULL(SourceTable.OneSideLowerTolerance,TargetTable.OneSideLowerTolerance),
					BothSideUpperTolerance = ISNULL(SourceTable.BothSideUpperTolerance,TargetTable.BothSideUpperTolerance),
					BothSideLowerTolerance = ISNULL(SourceTable.BothSideLowerTolerance,TargetTable.BothSideLowerTolerance),
					ProdConTempUpperTolerance = ISNULL(SourceTable.ProdConTempUpperTolerance,TargetTable.ProdConTempUpperTolerance),
					ProdConTempLowerTolerance = ISNULL(SourceTable.ProdConTempLowerTolerance,TargetTable.ProdConTempLowerTolerance),
					ProdConSpeedUpperTolerance = ISNULL(SourceTable.ProdConSpeedUpperTolerance,TargetTable.ProdConSpeedUpperTolerance),
					ProdConSpeedLowerTolerance = ISNULL(SourceTable.ProdConSpeedLowerTolerance,TargetTable.ProdConSpeedLowerTolerance),
					Batches = ISNULL(SourceTable.Batches,TargetTable.Batches)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						LivingSubstance,
						MixRatio,
						TankVolume,
						ElectrodeType,
						MeasureViscosity,
						Remark,
						OneSide,
						BothSide,
						RollingDensityMin,
						RollingDensityMax,
						ViscosityMin,
						ViscosityMax,
						UnwndngStdMin,
						UnwndngStdMax,
						UnwndngMeasureValue,
						RwndngStdMin,
						RwndngStdMax,
						RwndngMeasureValue,
						ProdConLinePressure,
						ProdConTemp,
						ProdConSpeed,
						ProdConThickStdMin,
						ProdConThickStdMax,
						CoolingWaterStdMin,
						CoolingWaterStdMax,
						LeftHeadGap,
						RightHeadGap,
						AlFoilWidth,
						CoatingWidth,
						OneSideSpeed,
						BothSideSpeed,
						CreateDateTime,
						CreateUserID,
						OneSideUpperTolerance,
						OneSideLowerTolerance,
						BothSideUpperTolerance,
						BothSideLowerTolerance,
						ProdConTempUpperTolerance,
						ProdConTempLowerTolerance,
						ProdConSpeedUpperTolerance,
						ProdConSpeedLowerTolerance,
						Batches
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.LivingSubstance,
							SourceTable.MixRatio,
							SourceTable.TankVolume,
							SourceTable.ElectrodeType,
							SourceTable.MeasureViscosity,
							SourceTable.Remark,
							SourceTable.OneSide,
							SourceTable.BothSide,
							SourceTable.RollingDensityMin,
							SourceTable.RollingDensityMax,
							SourceTable.ViscosityMin,
							SourceTable.ViscosityMax,
							SourceTable.UnwndngStdMin,
							SourceTable.UnwndngStdMax,
							SourceTable.UnwndngMeasureValue,
							SourceTable.RwndngStdMin,
							SourceTable.RwndngStdMax,
							SourceTable.RwndngMeasureValue,
							SourceTable.ProdConLinePressure,
							SourceTable.ProdConTemp,
							SourceTable.ProdConSpeed,
							SourceTable.ProdConThickStdMin,
							SourceTable.ProdConThickStdMax,
							SourceTable.CoolingWaterStdMin,
							SourceTable.CoolingWaterStdMax,
							SourceTable.LeftHeadGap,
							SourceTable.RightHeadGap,
							SourceTable.AlFoilWidth,
							SourceTable.CoatingWidth,
							SourceTable.OneSideSpeed,
							SourceTable.BothSideSpeed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.OneSideUpperTolerance,
							SourceTable.OneSideLowerTolerance,
							SourceTable.BothSideUpperTolerance,
							SourceTable.BothSideLowerTolerance,
							SourceTable.ProdConTempUpperTolerance,
							SourceTable.ProdConTempLowerTolerance,
							SourceTable.ProdConSpeedUpperTolerance,
							SourceTable.ProdConSpeedLowerTolerance,
							SourceTable.Batches							
					);


			-- Process Update Table
            MERGE STB_ElectrodeCommon AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							ProdCode,
							LivingSubstance,
							MixRatio,
							TankVolume,
							ElectrodeType,
							MeasureViscosity,
							Remark,
							OneSide,
							BothSide,
							RollingDensityMin,
							RollingDensityMax,
							ViscosityMin,
							ViscosityMax,
							UnwndngStdMin,
							UnwndngStdMax,
							UnwndngMeasureValue,
							RwndngStdMin,
							RwndngStdMax,
							RwndngMeasureValue,
							ProdConLinePressure,
							ProdConTemp,
							ProdConSpeed,
							ProdConThickStdMin,
							ProdConThickStdMax,
							CoolingWaterStdMin,
							CoolingWaterStdMax,
							LeftHeadGap,
							RightHeadGap,
							AlFoilWidth,
							CoatingWidth,
							OneSideSpeed,
							BothSideSpeed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							OneSideUpperTolerance,
							OneSideLowerTolerance,
							BothSideUpperTolerance,
							BothSideLowerTolerance,
							ProdConTempUpperTolerance,
							ProdConTempLowerTolerance,
							ProdConSpeedUpperTolerance,
							ProdConSpeedLowerTolerance,
							Batches
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										ProdCode VARCHAR(20),
										LivingSubstance VARCHAR(50),
										MixRatio NUMERIC(20,5),
										TankVolume NUMERIC(20,5),
										ElectrodeType VARCHAR(20),
										MeasureViscosity NUMERIC(20,5),
										Remark VARCHAR(1000),
										OneSide NUMERIC(20,5),
										BothSide NUMERIC(20,5),
										RollingDensityMin NUMERIC(20,5),
										RollingDensityMax NUMERIC(20,5),
										ViscosityMin NUMERIC(20,5),
										ViscosityMax NUMERIC(20,5),
										UnwndngStdMin NUMERIC(20,5),
										UnwndngStdMax NUMERIC(20,5),
										UnwndngMeasureValue NUMERIC(20,5),
										RwndngStdMin NUMERIC(20,5),
										RwndngStdMax NUMERIC(20,5),
										RwndngMeasureValue NUMERIC(20,5),
										ProdConLinePressure NUMERIC(20,5),
										ProdConTemp NUMERIC(20,5),
										ProdConSpeed NUMERIC(20,5),
										ProdConThickStdMin NUMERIC(20,5),
										ProdConThickStdMax NUMERIC(20,5),
										CoolingWaterStdMin NUMERIC(20,5),
										CoolingWaterStdMax NUMERIC(20,5),
										LeftHeadGap VARCHAR(20),
										RightHeadGap VARCHAR(20),
										AlFoilWidth NUMERIC(20,5),
										CoatingWidth NUMERIC(20,5),
										OneSideSpeed NUMERIC(20,5),
										BothSideSpeed NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										OneSideUpperTolerance NUMERIC(20,5),
										OneSideLowerTolerance NUMERIC(20,5),
										BothSideUpperTolerance NUMERIC(20,5),
										BothSideLowerTolerance NUMERIC(20,5),
										ProdConTempUpperTolerance NUMERIC(20,5),
										ProdConTempLowerTolerance NUMERIC(20,5),
										ProdConSpeedUpperTolerance NUMERIC(20,5),
										ProdConSpeedLowerTolerance NUMERIC(20,5),
										Batches INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.OldProdCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					LivingSubstance = ISNULL(SourceTable.LivingSubstance,TargetTable.LivingSubstance),
					MixRatio = ISNULL(SourceTable.MixRatio,TargetTable.MixRatio),
					TankVolume = ISNULL(SourceTable.TankVolume,TargetTable.TankVolume),
					ElectrodeType = ISNULL(SourceTable.ElectrodeType,TargetTable.ElectrodeType),
					MeasureViscosity = ISNULL(SourceTable.MeasureViscosity,TargetTable.MeasureViscosity),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					OneSide = ISNULL(SourceTable.OneSide,TargetTable.OneSide),
					BothSide = ISNULL(SourceTable.BothSide,TargetTable.BothSide),
					RollingDensityMin = ISNULL(SourceTable.RollingDensityMin,TargetTable.RollingDensityMin),
					RollingDensityMax = ISNULL(SourceTable.RollingDensityMax,TargetTable.RollingDensityMax),
					ViscosityMin = ISNULL(SourceTable.ViscosityMin,TargetTable.ViscosityMin),
					ViscosityMax = ISNULL(SourceTable.ViscosityMax,TargetTable.ViscosityMax),
					UnwndngStdMin = ISNULL(SourceTable.UnwndngStdMin,TargetTable.UnwndngStdMin),
					UnwndngStdMax = ISNULL(SourceTable.UnwndngStdMax,TargetTable.UnwndngStdMax),
					UnwndngMeasureValue = ISNULL(SourceTable.UnwndngMeasureValue,TargetTable.UnwndngMeasureValue),
					RwndngStdMin = ISNULL(SourceTable.RwndngStdMin,TargetTable.RwndngStdMin),
					RwndngStdMax = ISNULL(SourceTable.RwndngStdMax,TargetTable.RwndngStdMax),
					RwndngMeasureValue = ISNULL(SourceTable.RwndngMeasureValue,TargetTable.RwndngMeasureValue),
					ProdConLinePressure = ISNULL(SourceTable.ProdConLinePressure,TargetTable.ProdConLinePressure),
					ProdConTemp = ISNULL(SourceTable.ProdConTemp,TargetTable.ProdConTemp),
					ProdConSpeed = ISNULL(SourceTable.ProdConSpeed,TargetTable.ProdConSpeed),
					ProdConThickStdMin = ISNULL(SourceTable.ProdConThickStdMin,TargetTable.ProdConThickStdMin),
					ProdConThickStdMax = ISNULL(SourceTable.ProdConThickStdMax,TargetTable.ProdConThickStdMax),
					CoolingWaterStdMin = ISNULL(SourceTable.CoolingWaterStdMin,TargetTable.CoolingWaterStdMin),
					CoolingWaterStdMax = ISNULL(SourceTable.CoolingWaterStdMax,TargetTable.CoolingWaterStdMax),
					LeftHeadGap = ISNULL(SourceTable.LeftHeadGap,TargetTable.LeftHeadGap),
					RightHeadGap = ISNULL(SourceTable.RightHeadGap,TargetTable.RightHeadGap),
					AlFoilWidth = ISNULL(SourceTable.AlFoilWidth,TargetTable.AlFoilWidth),
					CoatingWidth = ISNULL(SourceTable.CoatingWidth,TargetTable.CoatingWidth),
					OneSideSpeed = ISNULL(SourceTable.OneSideSpeed,TargetTable.OneSideSpeed),
					BothSideSpeed = ISNULL(SourceTable.BothSideSpeed,TargetTable.BothSideSpeed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					OneSideUpperTolerance = ISNULL(SourceTable.OneSideUpperTolerance,TargetTable.OneSideUpperTolerance),
					OneSideLowerTolerance = ISNULL(SourceTable.OneSideLowerTolerance,TargetTable.OneSideLowerTolerance),
					BothSideUpperTolerance = ISNULL(SourceTable.BothSideUpperTolerance,TargetTable.BothSideUpperTolerance),
					BothSideLowerTolerance = ISNULL(SourceTable.BothSideLowerTolerance,TargetTable.BothSideLowerTolerance),
					ProdConTempUpperTolerance = ISNULL(SourceTable.ProdConTempUpperTolerance,TargetTable.ProdConTempUpperTolerance),
					ProdConTempLowerTolerance = ISNULL(SourceTable.ProdConTempLowerTolerance,TargetTable.ProdConTempLowerTolerance),
					ProdConSpeedUpperTolerance = ISNULL(SourceTable.ProdConSpeedUpperTolerance,TargetTable.ProdConSpeedUpperTolerance),
					ProdConSpeedLowerTolerance = ISNULL(SourceTable.ProdConSpeedLowerTolerance,TargetTable.ProdConSpeedLowerTolerance),
					Batches = ISNULL(SourceTable.Batches,TargetTable.Batches)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						LivingSubstance,
						MixRatio,
						TankVolume,
						ElectrodeType,
						MeasureViscosity,
						Remark,
						OneSide,
						BothSide,
						RollingDensityMin,
						RollingDensityMax,
						ViscosityMin,
						ViscosityMax,
						UnwndngStdMin,
						UnwndngStdMax,
						UnwndngMeasureValue,
						RwndngStdMin,
						RwndngStdMax,
						RwndngMeasureValue,
						ProdConLinePressure,
						ProdConTemp,
						ProdConSpeed,
						ProdConThickStdMin,
						ProdConThickStdMax,
						CoolingWaterStdMin,
						CoolingWaterStdMax,
						LeftHeadGap,
						RightHeadGap,
						AlFoilWidth,
						CoatingWidth,
						OneSideSpeed,
						BothSideSpeed,
						CreateDateTime,
						CreateUserID,
						OneSideUpperTolerance,
						OneSideLowerTolerance,
						BothSideUpperTolerance,
						BothSideLowerTolerance,
						ProdConTempUpperTolerance,
						ProdConTempLowerTolerance,
						ProdConSpeedUpperTolerance,
						ProdConSpeedLowerTolerance,
						Batches
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.LivingSubstance,
							SourceTable.MixRatio,
							SourceTable.TankVolume,
							SourceTable.ElectrodeType,
							SourceTable.MeasureViscosity,
							SourceTable.Remark,
							SourceTable.OneSide,
							SourceTable.BothSide,
							SourceTable.RollingDensityMin,
							SourceTable.RollingDensityMax,
							SourceTable.ViscosityMin,
							SourceTable.ViscosityMax,
							SourceTable.UnwndngStdMin,
							SourceTable.UnwndngStdMax,
							SourceTable.UnwndngMeasureValue,
							SourceTable.RwndngStdMin,
							SourceTable.RwndngStdMax,
							SourceTable.RwndngMeasureValue,
							SourceTable.ProdConLinePressure,
							SourceTable.ProdConTemp,
							SourceTable.ProdConSpeed,
							SourceTable.ProdConThickStdMin,
							SourceTable.ProdConThickStdMax,
							SourceTable.CoolingWaterStdMin,
							SourceTable.CoolingWaterStdMax,
							SourceTable.LeftHeadGap,
							SourceTable.RightHeadGap,
							SourceTable.AlFoilWidth,
							SourceTable.CoatingWidth,
							SourceTable.OneSideSpeed,
							SourceTable.BothSideSpeed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.OneSideUpperTolerance,
							SourceTable.OneSideLowerTolerance,
							SourceTable.BothSideUpperTolerance,
							SourceTable.BothSideLowerTolerance,
							SourceTable.ProdConTempUpperTolerance,
							SourceTable.ProdConTempLowerTolerance,
							SourceTable.ProdConSpeedUpperTolerance,
							SourceTable.ProdConSpeedLowerTolerance,
							SourceTable.Batches
					);


			-- Process Process Table
            MERGE STB_ElectrodeCommon AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							ProdCode,
							LivingSubstance,
							MixRatio,
							TankVolume,
							ElectrodeType,
							MeasureViscosity,
							Remark,
							OneSide,
							BothSide,
							RollingDensityMin,
							RollingDensityMax,
							ViscosityMin,
							ViscosityMax,
							UnwndngStdMin,
							UnwndngStdMax,
							UnwndngMeasureValue,
							RwndngStdMin,
							RwndngStdMax,
							RwndngMeasureValue,
							ProdConLinePressure,
							ProdConTemp,
							ProdConSpeed,
							ProdConThickStdMin,
							ProdConThickStdMax,
							CoolingWaterStdMin,
							CoolingWaterStdMax,
							LeftHeadGap,
							RightHeadGap,
							AlFoilWidth,
							CoatingWidth,
							OneSideSpeed,
							BothSideSpeed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							OneSideUpperTolerance,
							OneSideLowerTolerance,
							BothSideUpperTolerance,
							BothSideLowerTolerance,
							ProdConTempUpperTolerance,
							ProdConTempLowerTolerance,
							ProdConSpeedUpperTolerance,
							ProdConSpeedLowerTolerance,
							Batches
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										ProdCode VARCHAR(20),
										LivingSubstance VARCHAR(50),
										MixRatio NUMERIC(20,5),
										TankVolume NUMERIC(20,5),
										ElectrodeType VARCHAR(20),
										MeasureViscosity NUMERIC(20,5),
										Remark VARCHAR(1000),
										OneSide NUMERIC(20,5),
										BothSide NUMERIC(20,5),
										RollingDensityMin NUMERIC(20,5),
										RollingDensityMax NUMERIC(20,5),
										ViscosityMin NUMERIC(20,5),
										ViscosityMax NUMERIC(20,5),
										UnwndngStdMin NUMERIC(20,5),
										UnwndngStdMax NUMERIC(20,5),
										UnwndngMeasureValue NUMERIC(20,5),
										RwndngStdMin NUMERIC(20,5),
										RwndngStdMax NUMERIC(20,5),
										RwndngMeasureValue NUMERIC(20,5),
										ProdConLinePressure NUMERIC(20,5),
										ProdConTemp NUMERIC(20,5),
										ProdConSpeed NUMERIC(20,5),
										ProdConThickStdMin NUMERIC(20,5),
										ProdConThickStdMax NUMERIC(20,5),
										CoolingWaterStdMin NUMERIC(20,5),
										CoolingWaterStdMax NUMERIC(20,5),
										LeftHeadGap VARCHAR(20),
										RightHeadGap VARCHAR(20),
										AlFoilWidth NUMERIC(20,5),
										CoatingWidth NUMERIC(20,5),
										OneSideSpeed NUMERIC(20,5),
										BothSideSpeed NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										OneSideUpperTolerance NUMERIC(20,5),
										OneSideLowerTolerance NUMERIC(20,5),
										BothSideUpperTolerance NUMERIC(20,5),
										BothSideLowerTolerance NUMERIC(20,5),
										ProdConTempUpperTolerance NUMERIC(20,5),
										ProdConTempLowerTolerance NUMERIC(20,5),
										ProdConSpeedUpperTolerance NUMERIC(20,5),
										ProdConSpeedLowerTolerance NUMERIC(20,5),
										Batches INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode
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
									OldProdCode,
									ProdCode,
									LivingSubstance,
									MixRatio,
									TankVolume,
									ElectrodeType,
									MeasureViscosity,
									Remark,
									OneSide,
									BothSide,
									RollingDensityMin,
									RollingDensityMax,
									ViscosityMin,
									ViscosityMax,
									UnwndngStdMin,
									UnwndngStdMax,
									UnwndngMeasureValue,
									RwndngStdMin,
									RwndngStdMax,
									RwndngMeasureValue,
									ProdConLinePressure,
									ProdConTemp,
									ProdConSpeed,
									ProdConThickStdMin,
									ProdConThickStdMax,
									CoolingWaterStdMin,
									CoolingWaterStdMax,
									LeftHeadGap,
									RightHeadGap,
									AlFoilWidth,
									CoatingWidth,
									OneSideSpeed,
									BothSideSpeed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									OneSideUpperTolerance,
									OneSideLowerTolerance,
									BothSideUpperTolerance,
									BothSideLowerTolerance,
									ProdConTempUpperTolerance,
									ProdConTempLowerTolerance,
									ProdConSpeedUpperTolerance,
									ProdConSpeedLowerTolerance,
									Batches
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 LivingSubstance VARCHAR(50),
											 MixRatio NUMERIC(20,5),
											 TankVolume NUMERIC(20,5),
											 ElectrodeType VARCHAR(20),
											 MeasureViscosity NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 OneSide NUMERIC(20,5),
											 BothSide NUMERIC(20,5),
											 RollingDensityMin NUMERIC(20,5),
											 RollingDensityMax NUMERIC(20,5),
											 ViscosityMin NUMERIC(20,5),
											 ViscosityMax NUMERIC(20,5),
											 UnwndngStdMin NUMERIC(20,5),
											 UnwndngStdMax NUMERIC(20,5),
											 UnwndngMeasureValue NUMERIC(20,5),
											 RwndngStdMin NUMERIC(20,5),
											 RwndngStdMax NUMERIC(20,5),
											 RwndngMeasureValue NUMERIC(20,5),
											 ProdConLinePressure NUMERIC(20,5),
											 ProdConTemp NUMERIC(20,5),
											 ProdConSpeed NUMERIC(20,5),
											 ProdConThickStdMin NUMERIC(20,5),
											 ProdConThickStdMax NUMERIC(20,5),
											 CoolingWaterStdMin NUMERIC(20,5),
											 CoolingWaterStdMax NUMERIC(20,5),
											 LeftHeadGap VARCHAR(20),
											 RightHeadGap VARCHAR(20),
											 AlFoilWidth NUMERIC(20,5),
											 CoatingWidth NUMERIC(20,5),
											 OneSideSpeed NUMERIC(20,5),
											 BothSideSpeed NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 OneSideUpperTolerance NUMERIC(20,5),
											 OneSideLowerTolerance NUMERIC(20,5),
											 BothSideUpperTolerance NUMERIC(20,5),
											 BothSideLowerTolerance NUMERIC(20,5),
											 ProdConTempUpperTolerance NUMERIC(20,5),
											 ProdConTempLowerTolerance NUMERIC(20,5),
											 ProdConSpeedUpperTolerance NUMERIC(20,5),
											 ProdConSpeedLowerTolerance NUMERIC(20,5),
											 Batches INT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									ProdCode,
									LivingSubstance,
									MixRatio,
									TankVolume,
									ElectrodeType,
									MeasureViscosity,
									Remark,
									OneSide,
									BothSide,
									RollingDensityMin,
									RollingDensityMax,
									ViscosityMin,
									ViscosityMax,
									UnwndngStdMin,
									UnwndngStdMax,
									UnwndngMeasureValue,
									RwndngStdMin,
									RwndngStdMax,
									RwndngMeasureValue,
									ProdConLinePressure,
									ProdConTemp,
									ProdConSpeed,
									ProdConThickStdMin,
									ProdConThickStdMax,
									CoolingWaterStdMin,
									CoolingWaterStdMax,
									LeftHeadGap,
									RightHeadGap,
									AlFoilWidth,
									CoatingWidth,
									OneSideSpeed,
									BothSideSpeed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									OneSideUpperTolerance,
									OneSideLowerTolerance,
									BothSideUpperTolerance,
									BothSideLowerTolerance,
									ProdConTempUpperTolerance,
									ProdConTempLowerTolerance,
									ProdConSpeedUpperTolerance,
									ProdConSpeedLowerTolerance,
									Batches
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 LivingSubstance VARCHAR(50),
											 MixRatio NUMERIC(20,5),
											 TankVolume NUMERIC(20,5),
											 ElectrodeType VARCHAR(20),
											 MeasureViscosity NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 OneSide NUMERIC(20,5),
											 BothSide NUMERIC(20,5),
											 RollingDensityMin NUMERIC(20,5),
											 RollingDensityMax NUMERIC(20,5),
											 ViscosityMin NUMERIC(20,5),
											 ViscosityMax NUMERIC(20,5),
											 UnwndngStdMin NUMERIC(20,5),
											 UnwndngStdMax NUMERIC(20,5),
											 UnwndngMeasureValue NUMERIC(20,5),
											 RwndngStdMin NUMERIC(20,5),
											 RwndngStdMax NUMERIC(20,5),
											 RwndngMeasureValue NUMERIC(20,5),
											 ProdConLinePressure NUMERIC(20,5),
											 ProdConTemp NUMERIC(20,5),
											 ProdConSpeed NUMERIC(20,5),
											 ProdConThickStdMin NUMERIC(20,5),
											 ProdConThickStdMax NUMERIC(20,5),
											 CoolingWaterStdMin NUMERIC(20,5),
											 CoolingWaterStdMax NUMERIC(20,5),
											 LeftHeadGap VARCHAR(20),
											 RightHeadGap VARCHAR(20),
											 AlFoilWidth NUMERIC(20,5),
											 CoatingWidth NUMERIC(20,5),
											 OneSideSpeed NUMERIC(20,5),
											 BothSideSpeed NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 OneSideUpperTolerance NUMERIC(20,5),
											 OneSideLowerTolerance NUMERIC(20,5),
											 BothSideUpperTolerance NUMERIC(20,5),
											 BothSideLowerTolerance NUMERIC(20,5),
											 ProdConTempUpperTolerance NUMERIC(20,5),
											 ProdConTempLowerTolerance NUMERIC(20,5),
											 ProdConSpeedUpperTolerance NUMERIC(20,5),
											 ProdConSpeedLowerTolerance NUMERIC(20,5),
											 Batches INT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									ProdCode,
									LivingSubstance,
									MixRatio,
									TankVolume,
									ElectrodeType,
									MeasureViscosity,
									Remark,
									OneSide,
									BothSide,
									RollingDensityMin,
									RollingDensityMax,
									ViscosityMin,
									ViscosityMax,
									UnwndngStdMin,
									UnwndngStdMax,
									UnwndngMeasureValue,
									RwndngStdMin,
									RwndngStdMax,
									RwndngMeasureValue,
									ProdConLinePressure,
									ProdConTemp,
									ProdConSpeed,
									ProdConThickStdMin,
									ProdConThickStdMax,
									CoolingWaterStdMin,
									CoolingWaterStdMax,
									LeftHeadGap,
									RightHeadGap,
									AlFoilWidth,
									CoatingWidth,
									OneSideSpeed,
									BothSideSpeed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									OneSideUpperTolerance,
									OneSideLowerTolerance,
									BothSideUpperTolerance,
									BothSideLowerTolerance,
									ProdConTempUpperTolerance,
									ProdConTempLowerTolerance,
									ProdConSpeedUpperTolerance,
									ProdConSpeedLowerTolerance,
									Batches
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 LivingSubstance VARCHAR(50),
											 MixRatio NUMERIC(20,5),
											 TankVolume NUMERIC(20,5),
											 ElectrodeType VARCHAR(20),
											 MeasureViscosity NUMERIC(20,5),
											 Remark VARCHAR(1000),
											 OneSide NUMERIC(20,5),
											 BothSide NUMERIC(20,5),
											 RollingDensityMin NUMERIC(20,5),
											 RollingDensityMax NUMERIC(20,5),
											 ViscosityMin NUMERIC(20,5),
											 ViscosityMax NUMERIC(20,5),
											 UnwndngStdMin NUMERIC(20,5),
											 UnwndngStdMax NUMERIC(20,5),
											 UnwndngMeasureValue NUMERIC(20,5),
											 RwndngStdMin NUMERIC(20,5),
											 RwndngStdMax NUMERIC(20,5),
											 RwndngMeasureValue NUMERIC(20,5),
											 ProdConLinePressure NUMERIC(20,5),
											 ProdConTemp NUMERIC(20,5),
											 ProdConSpeed NUMERIC(20,5),
											 ProdConThickStdMin NUMERIC(20,5),
											 ProdConThickStdMax NUMERIC(20,5),
											 CoolingWaterStdMin NUMERIC(20,5),
											 CoolingWaterStdMax NUMERIC(20,5),
											 LeftHeadGap VARCHAR(20),
											 RightHeadGap VARCHAR(20),
											 AlFoilWidth NUMERIC(20,5),
											 CoatingWidth NUMERIC(20,5),
											 OneSideSpeed NUMERIC(20,5),
											 BothSideSpeed NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 OneSideUpperTolerance NUMERIC(20,5),
											 OneSideLowerTolerance NUMERIC(20,5),
											 BothSideUpperTolerance NUMERIC(20,5),
											 BothSideLowerTolerance NUMERIC(20,5),
											 ProdConTempUpperTolerance NUMERIC(20,5),
											 ProdConTempLowerTolerance NUMERIC(20,5),
											 ProdConSpeedUpperTolerance NUMERIC(20,5),
											 ProdConSpeedLowerTolerance NUMERIC(20,5),
											 Batches INT
											) 

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProdCode,
								 @ProdCode,
								 @LivingSubstance,
								 @MixRatio,
								 @TankVolume,
								 @ElectrodeType,
								 @MeasureViscosity,
								 @Remark,
								 @OneSide,
								 @BothSide,
								 @RollingDensityMin,
								 @RollingDensityMax,
								 @ViscosityMin,
								 @ViscosityMax,
								 @UnwndngStdMin,
								 @UnwndngStdMax,
								 @UnwndngMeasureValue,
								 @RwndngStdMin,
								 @RwndngStdMax,
								 @RwndngMeasureValue,
								 @ProdConLinePressure,
								 @ProdConTemp,
								 @ProdConSpeed,
								 @ProdConThickStdMin,
								 @ProdConThickStdMax,
								 @CoolingWaterStdMin,
								 @CoolingWaterStdMax,
								 @LeftHeadGap,
								 @RightHeadGap,
								 @AlFoilWidth,
								 @CoatingWidth,
								 @OneSideSpeed,
								 @BothSideSpeed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @OneSideUpperTolerance,
								 @OneSideLowerTolerance,
								 @BothSideUpperTolerance,
								 @BothSideLowerTolerance,
								 @ProdConTempUpperTolerance,
								 @ProdConTempLowerTolerance,
								 @ProdConSpeedUpperTolerance,
								 @ProdConSpeedLowerTolerance,
								 @Batches

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeCommon WHERE ProdCode = @ProdCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProdCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeCommon',@ProdCode OUTPUT
                    END

                    INSERT INTO STB_ElectrodeCommon
						(
						    ProdCode,
						    LivingSubstance,
						    MixRatio,
						    TankVolume,
						    ElectrodeType,
						    MeasureViscosity,
						    Remark,
						    OneSide,
						    BothSide,
						    RollingDensityMin,
						    RollingDensityMax,
						    ViscosityMin,
						    ViscosityMax,
						    UnwndngStdMin,
						    UnwndngStdMax,
						    UnwndngMeasureValue,
						    RwndngStdMin,
						    RwndngStdMax,
						    RwndngMeasureValue,
						    ProdConLinePressure,
						    ProdConTemp,
						    ProdConSpeed,
						    ProdConThickStdMin,
						    ProdConThickStdMax,
						    CoolingWaterStdMin,
						    CoolingWaterStdMax,
						    LeftHeadGap,
						    RightHeadGap,
						    AlFoilWidth,
						    CoatingWidth,
						    OneSideSpeed,
						    BothSideSpeed,
						    CreateDateTime,
						    CreateUserID,
						    OneSideUpperTolerance,
						    OneSideLowerTolerance,
						    BothSideUpperTolerance,
						    BothSideLowerTolerance,
						    ProdConTempUpperTolerance,
						    ProdConTempLowerTolerance,
						    ProdConSpeedUpperTolerance,
						    ProdConSpeedLowerTolerance,
						    Batches
						)
						VALUES
						(
						    @ProdCode,
						    @LivingSubstance,
						    @MixRatio,
						    @TankVolume,
						    @ElectrodeType,
						    @MeasureViscosity,
						    @Remark,
						    @OneSide,
						    @BothSide,
						    @RollingDensityMin,
						    @RollingDensityMax,
						    @ViscosityMin,
						    @ViscosityMax,
						    @UnwndngStdMin,
						    @UnwndngStdMax,
						    @UnwndngMeasureValue,
						    @RwndngStdMin,
						    @RwndngStdMax,
						    @RwndngMeasureValue,
						    @ProdConLinePressure,
						    @ProdConTemp,
						    @ProdConSpeed,
						    @ProdConThickStdMin,
						    @ProdConThickStdMax,
						    @CoolingWaterStdMin,
						    @CoolingWaterStdMax,
						    @LeftHeadGap,
						    @RightHeadGap,
						    @AlFoilWidth,
						    @CoatingWidth,
						    @OneSideSpeed,
						    @BothSideSpeed,
						    GETDATE(),
						    @pProcessUserID,
						    @OneSideUpperTolerance,
						    @OneSideLowerTolerance,
						    @BothSideUpperTolerance,
						    @BothSideLowerTolerance,
						    @ProdConTempUpperTolerance,
						    @ProdConTempLowerTolerance,
						    @ProdConSpeedUpperTolerance,
						    @ProdConSpeedLowerTolerance,
						    @Batches
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeCommon
						SET
						    ProdCode =   ISNULL(@ProdCode,ProdCode),
						    LivingSubstance =   ISNULL(@LivingSubstance,LivingSubstance),
						    MixRatio =   ISNULL(@MixRatio,MixRatio),
						    TankVolume =   ISNULL(@TankVolume,TankVolume),
						    ElectrodeType =   ISNULL(@ElectrodeType,ElectrodeType),
						    MeasureViscosity =   ISNULL(@MeasureViscosity,MeasureViscosity),
						    Remark =   ISNULL(@Remark,Remark),
						    OneSide =   ISNULL(@OneSide,OneSide),
						    BothSide =   ISNULL(@BothSide,BothSide),
						    RollingDensityMin =   ISNULL(@RollingDensityMin,RollingDensityMin),
						    RollingDensityMax =   ISNULL(@RollingDensityMax,RollingDensityMax),
						    ViscosityMin =   ISNULL(@ViscosityMin,ViscosityMin),
						    ViscosityMax =   ISNULL(@ViscosityMax,ViscosityMax),
						    UnwndngStdMin =   ISNULL(@UnwndngStdMin,UnwndngStdMin),
						    UnwndngStdMax =   ISNULL(@UnwndngStdMax,UnwndngStdMax),
						    UnwndngMeasureValue =   ISNULL(@UnwndngMeasureValue,UnwndngMeasureValue),
						    RwndngStdMin =   ISNULL(@RwndngStdMin,RwndngStdMin),
						    RwndngStdMax =   ISNULL(@RwndngStdMax,RwndngStdMax),
						    RwndngMeasureValue =   ISNULL(@RwndngMeasureValue,RwndngMeasureValue),
						    ProdConLinePressure =   ISNULL(@ProdConLinePressure,ProdConLinePressure),
						    ProdConTemp =   ISNULL(@ProdConTemp,ProdConTemp),
						    ProdConSpeed =   ISNULL(@ProdConSpeed,ProdConSpeed),
						    ProdConThickStdMin =   ISNULL(@ProdConThickStdMin,ProdConThickStdMin),
						    ProdConThickStdMax =   ISNULL(@ProdConThickStdMax,ProdConThickStdMax),
						    CoolingWaterStdMin =   ISNULL(@CoolingWaterStdMin,CoolingWaterStdMin),
						    CoolingWaterStdMax =   ISNULL(@CoolingWaterStdMax,CoolingWaterStdMax),
						    LeftHeadGap =   ISNULL(@LeftHeadGap,LeftHeadGap),
						    RightHeadGap =   ISNULL(@RightHeadGap,RightHeadGap),
						    AlFoilWidth =   ISNULL(@AlFoilWidth,AlFoilWidth),
						    CoatingWidth =   ISNULL(@CoatingWidth,CoatingWidth),
						    OneSideSpeed =   ISNULL(@OneSideSpeed,OneSideSpeed),
						    BothSideSpeed =   ISNULL(@BothSideSpeed,BothSideSpeed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    OneSideUpperTolerance =   ISNULL(@OneSideUpperTolerance,OneSideUpperTolerance),
						    OneSideLowerTolerance =   ISNULL(@OneSideLowerTolerance,OneSideLowerTolerance),
						    BothSideUpperTolerance =   ISNULL(@BothSideUpperTolerance,BothSideUpperTolerance),
						    BothSideLowerTolerance =   ISNULL(@BothSideLowerTolerance,BothSideLowerTolerance),
						    ProdConTempUpperTolerance =   ISNULL(@ProdConTempUpperTolerance,ProdConTempUpperTolerance),
						    ProdConTempLowerTolerance =   ISNULL(@ProdConTempLowerTolerance,ProdConTempLowerTolerance),
						    ProdConSpeedUpperTolerance =   ISNULL(@ProdConSpeedUpperTolerance,ProdConSpeedUpperTolerance),
						    ProdConSpeedLowerTolerance =   ISNULL(@ProdConSpeedLowerTolerance,ProdConSpeedLowerTolerance),
						    Batches =   ISNULL(@Batches,Batches)
						WHERE
						    ProdCode = @OldProdCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeCommon
						WHERE
						    ProdCode = @OldProdCode
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

PRINT 'Procedure usp_ElectrodeCommon_HY_iud created successfully.';
GO

-- =========================================================
-- 3. Stored Procedure: usp_ElectrodeOven_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeOven_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeOven_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_ElectrodeOven_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProdCode VARCHAR(20) = CASE WHEN ISNULL(@pProdCode,'') = '' THEN '*' ELSE @pProdCode END

	SELECT
			EO.ProdCode
		   ,EO.Seq
		   ,EO.DryingFurnaceName
		   ,EO.DryingFurnaceTemp
		   ,EO.DryingFurnaceAirUpperPart
		   ,EO.DryingFurnaceAirLowerPart
		   ,EO.TempLowerTolerance
		   ,EO.TempUpperTolerance
		   ,EO.AirLowerTolerance
		   ,EO.AirUpperTolerance
		   ,EO.CreateDateTime
		   ,EO.CreateUserID
		   ,EO.ChangeDateTime
		   ,EO.ChangeUserID
	FROM
			STB_ElectrodeOven EO
   WHERE ((@ProdCode = '*') OR (EO.ProdCode = @ProdCode)) 
END
GO

PRINT 'Procedure usp_ElectrodeOven_HY_get created successfully.';
GO

-- =========================================================
-- 4. Stored Procedure: usp_ElectrodeOven_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeOven_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeOven_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_ElectrodeOven_HY_iud]
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
  DECLARE @OldProdCode VARCHAR(20)
  DECLARE @OldSeq INT
  DECLARE @ProdCode VARCHAR(20)
  DECLARE @Seq INT
  DECLARE @DryingFurnaceName VARCHAR(20)
  DECLARE @DryingFurnaceTemp NUMERIC(20,5)
  DECLARE @DryingFurnaceAirUpperPart NUMERIC(20,5)
  DECLARE @DryingFurnaceAirLowerPart NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @TempUpperTolerance NUMERIC(20,5)
  DECLARE @TempLowerTolerance NUMERIC(20,5)
  DECLARE @AirUpperTolerance NUMERIC(20,5)
  DECLARE @AirLowerTolerance NUMERIC(20,5)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeOven',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeOven AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ProdCode,
							Seq,
							DryingFurnaceName,
							DryingFurnaceTemp,
							DryingFurnaceAirUpperPart,
							DryingFurnaceAirLowerPart,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TempUpperTolerance,
							TempLowerTolerance,
							AirUpperTolerance,
							AirLowerTolerance
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										OldSeq INT,
										ProdCode VARCHAR(20),
										Seq INT,
										DryingFurnaceName VARCHAR(20),
										DryingFurnaceTemp NUMERIC(20,5),
										DryingFurnaceAirUpperPart NUMERIC(20,5),
										DryingFurnaceAirLowerPart NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TempUpperTolerance NUMERIC(20,5),
										TempLowerTolerance NUMERIC(20,5),
										AirUpperTolerance NUMERIC(20,5),
										AirLowerTolerance NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					DryingFurnaceName = ISNULL(SourceTable.DryingFurnaceName,TargetTable.DryingFurnaceName),
					DryingFurnaceTemp = ISNULL(SourceTable.DryingFurnaceTemp,TargetTable.DryingFurnaceTemp),
					DryingFurnaceAirUpperPart = ISNULL(SourceTable.DryingFurnaceAirUpperPart,TargetTable.DryingFurnaceAirUpperPart),
					DryingFurnaceAirLowerPart = ISNULL(SourceTable.DryingFurnaceAirLowerPart,TargetTable.DryingFurnaceAirLowerPart),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					TempUpperTolerance = ISNULL(SourceTable.TempUpperTolerance,TargetTable.TempUpperTolerance),
					TempLowerTolerance = ISNULL(SourceTable.TempLowerTolerance,TargetTable.TempLowerTolerance),
					AirUpperTolerance = ISNULL(SourceTable.AirUpperTolerance,TargetTable.AirUpperTolerance),
					AirLowerTolerance = ISNULL(SourceTable.AirLowerTolerance,TargetTable.AirLowerTolerance)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						Seq,
						DryingFurnaceName,
						DryingFurnaceTemp,
						DryingFurnaceAirUpperPart,
						DryingFurnaceAirLowerPart,
						CreateDateTime,
						CreateUserID,
						TempUpperTolerance,
						TempLowerTolerance,
						AirUpperTolerance,
						AirLowerTolerance
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.Seq,
							SourceTable.DryingFurnaceName,
							SourceTable.DryingFurnaceTemp,
							SourceTable.DryingFurnaceAirUpperPart,
							SourceTable.DryingFurnaceAirLowerPart,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.TempUpperTolerance,
							SourceTable.TempLowerTolerance,
							SourceTable.AirUpperTolerance,
							SourceTable.AirLowerTolerance
					);


			-- Process Update Table
            MERGE STB_ElectrodeOven AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ProdCode,
							Seq,
							DryingFurnaceName,
							DryingFurnaceTemp,
							DryingFurnaceAirUpperPart,
							DryingFurnaceAirLowerPart,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TempUpperTolerance,
							TempLowerTolerance,
							AirUpperTolerance,
							AirLowerTolerance
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										OldSeq INT,
										ProdCode VARCHAR(20),
										Seq INT,
										DryingFurnaceName VARCHAR(20),
										DryingFurnaceTemp NUMERIC(20,5),
										DryingFurnaceAirUpperPart NUMERIC(20,5),
										DryingFurnaceAirLowerPart NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TempUpperTolerance NUMERIC(20,5),
										TempLowerTolerance NUMERIC(20,5),
										AirUpperTolerance NUMERIC(20,5),
										AirLowerTolerance NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.OldProdCode AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					DryingFurnaceName = ISNULL(SourceTable.DryingFurnaceName,TargetTable.DryingFurnaceName),
					DryingFurnaceTemp = ISNULL(SourceTable.DryingFurnaceTemp,TargetTable.DryingFurnaceTemp),
					DryingFurnaceAirUpperPart = ISNULL(SourceTable.DryingFurnaceAirUpperPart,TargetTable.DryingFurnaceAirUpperPart),
					DryingFurnaceAirLowerPart = ISNULL(SourceTable.DryingFurnaceAirLowerPart,TargetTable.DryingFurnaceAirLowerPart),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					TempUpperTolerance = ISNULL(SourceTable.TempUpperTolerance,TargetTable.TempUpperTolerance),
					TempLowerTolerance = ISNULL(SourceTable.TempLowerTolerance,TargetTable.TempLowerTolerance),
					AirUpperTolerance = ISNULL(SourceTable.AirUpperTolerance,TargetTable.AirUpperTolerance),
					AirLowerTolerance = ISNULL(SourceTable.AirLowerTolerance,TargetTable.AirLowerTolerance)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						Seq,
						DryingFurnaceName,
						DryingFurnaceTemp,
						DryingFurnaceAirUpperPart,
						DryingFurnaceAirLowerPart,
						CreateDateTime,
						CreateUserID,
						TempUpperTolerance,
						TempLowerTolerance,
						AirUpperTolerance,
						AirLowerTolerance
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.Seq,
							SourceTable.DryingFurnaceName,
							SourceTable.DryingFurnaceTemp,
							SourceTable.DryingFurnaceAirUpperPart,
							SourceTable.DryingFurnaceAirLowerPart,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.TempUpperTolerance,
							SourceTable.TempLowerTolerance,
							SourceTable.AirUpperTolerance,
							SourceTable.AirLowerTolerance
					);


			-- Process Delete Table
            MERGE STB_ElectrodeOven AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ProdCode,
							Seq,
							DryingFurnaceName,
							DryingFurnaceTemp,
							DryingFurnaceAirUpperPart,
							DryingFurnaceAirLowerPart,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TempUpperTolerance,
							TempLowerTolerance,
							AirUpperTolerance,
							AirLowerTolerance
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										OldSeq INT,
										ProdCode VARCHAR(20),
										Seq INT,
										DryingFurnaceName VARCHAR(20),
										DryingFurnaceTemp NUMERIC(20,5),
										DryingFurnaceAirUpperPart NUMERIC(20,5),
										DryingFurnaceAirLowerPart NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TempUpperTolerance NUMERIC(20,5),
										TempLowerTolerance NUMERIC(20,5),
										AirUpperTolerance NUMERIC(20,5),
										AirLowerTolerance NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
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
									OldProdCode,
									OldSeq,
									ProdCode,
									Seq,
									DryingFurnaceName,
									DryingFurnaceTemp,
									DryingFurnaceAirUpperPart,
									DryingFurnaceAirLowerPart,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TempUpperTolerance,
									TempLowerTolerance,
									AirUpperTolerance,
									AirLowerTolerance
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 OldSeq INT,
											 ProdCode VARCHAR(20),
											 Seq INT,
											 DryingFurnaceName VARCHAR(20),
											 DryingFurnaceTemp NUMERIC(20,5),
											 DryingFurnaceAirUpperPart NUMERIC(20,5),
											 DryingFurnaceAirLowerPart NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TempUpperTolerance NUMERIC(20,5),
											 TempLowerTolerance NUMERIC(20,5),
											 AirUpperTolerance NUMERIC(20,5),
											 AirLowerTolerance NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ProdCode,
									Seq,
									DryingFurnaceName,
									DryingFurnaceTemp,
									DryingFurnaceAirUpperPart,
									DryingFurnaceAirLowerPart,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TempUpperTolerance,
									TempLowerTolerance,
									AirUpperTolerance,
									AirLowerTolerance
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 OldSeq INT,
											 ProdCode VARCHAR(20),
											 Seq INT,
											 DryingFurnaceName VARCHAR(20),
											 DryingFurnaceTemp NUMERIC(20,5),
											 DryingFurnaceAirUpperPart NUMERIC(20,5),
											 DryingFurnaceAirLowerPart NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TempUpperTolerance NUMERIC(20,5),
											 TempLowerTolerance NUMERIC(20,5),
											 AirUpperTolerance NUMERIC(20,5),
											 AirLowerTolerance NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ProdCode,
									Seq,
									DryingFurnaceName,
									DryingFurnaceTemp,
									DryingFurnaceAirUpperPart,
									DryingFurnaceAirLowerPart,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TempUpperTolerance,
									TempLowerTolerance,
									AirUpperTolerance,
									AirLowerTolerance
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 OldSeq INT,
											 ProdCode VARCHAR(20),
											 Seq INT,
											 DryingFurnaceName VARCHAR(20),
											 DryingFurnaceTemp NUMERIC(20,5),
											 DryingFurnaceAirUpperPart NUMERIC(20,5),
											 DryingFurnaceAirLowerPart NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TempUpperTolerance NUMERIC(20,5),
											 TempLowerTolerance NUMERIC(20,5),
											 AirUpperTolerance NUMERIC(20,5),
											 AirLowerTolerance NUMERIC(20,5)
											) 

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProdCode,
								 @OldSeq,
								 @ProdCode,
								 @Seq,
								 @DryingFurnaceName,
								 @DryingFurnaceTemp,
								 @DryingFurnaceAirUpperPart,
								 @DryingFurnaceAirLowerPart,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @TempUpperTolerance,
								 @TempLowerTolerance,
								 @AirUpperTolerance,
								 @AirLowerTolerance

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeOven WHERE ProdCode = @ProdCode AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProdCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeOven',@ProdCode OUTPUT
                    END

                    INSERT INTO STB_ElectrodeOven
						(
						    ProdCode,
						    Seq,
						    DryingFurnaceName,
						    DryingFurnaceTemp,
						    DryingFurnaceAirUpperPart,
						    DryingFurnaceAirLowerPart,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    TempUpperTolerance,
						    TempLowerTolerance,
						    AirUpperTolerance,
						    AirLowerTolerance
						)
						VALUES
						(
						    @ProdCode,
						    @Seq,
						    @DryingFurnaceName,
						    @DryingFurnaceTemp,
						    @DryingFurnaceAirUpperPart,
						    @DryingFurnaceAirLowerPart,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @TempUpperTolerance,
						    @TempLowerTolerance,
						    @AirUpperTolerance,
						    @AirLowerTolerance
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeOven
						SET
						    ProdCode =   ISNULL(@ProdCode,ProdCode),
						    Seq =   ISNULL(@Seq,Seq),
						    DryingFurnaceName =   ISNULL(@DryingFurnaceName,DryingFurnaceName),
						    DryingFurnaceTemp =   ISNULL(@DryingFurnaceTemp,DryingFurnaceTemp),
						    DryingFurnaceAirUpperPart =   ISNULL(@DryingFurnaceAirUpperPart,DryingFurnaceAirUpperPart),
						    DryingFurnaceAirLowerPart =   ISNULL(@DryingFurnaceAirLowerPart,DryingFurnaceAirLowerPart),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    TempUpperTolerance =   ISNULL(@TempUpperTolerance,TempUpperTolerance),
						    TempLowerTolerance =   ISNULL(@TempLowerTolerance,TempLowerTolerance),
						    AirUpperTolerance =   ISNULL(@AirUpperTolerance,AirUpperTolerance),
						    AirLowerTolerance =   ISNULL(@AirLowerTolerance,AirLowerTolerance)
						WHERE
						    ProdCode = @OldProdCode AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeOven
						WHERE
						    ProdCode = @OldProdCode AND
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

PRINT 'Procedure usp_ElectrodeOven_HY_iud created successfully.';
GO

-- =========================================================
-- 5. Stored Procedure: usp_ElectrodeStep_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeStep_HY_get')
    DROP PROCEDURE [dbo].[usp_ElectrodeStep_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_ElectrodeStep_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProdCode VARCHAR(20) = CASE WHEN ISNULL(@pProdCode,'') = '' THEN '' ELSE @pProdCode END

	SELECT
			ES.ProdCode AS OldProdCode
		   ,ES.ProdCode
		   ,MM2.MaterialName AS ProdName
		   ,ES.seq
		   ,ES.seq AS OldSeq
		   ,ES.ElectrodeStepCode
		   ,ES.ElectrodeStepCode AS OldElectrodeStepCode
		   ,BC.Description AS ElectrodeStepName
		   ,ES.MaterialCode
		   ,ES.MaterialCode AS OldMaterialCode
		   ,MM.MaterialName
		   ,MM.MaterialSpec
		   ,ES.StdMinVal
		   ,ES.StdMaxVal
		   ,ES.WorkTime
		   ,ES.HighSpeedSpin
		   ,ES.LowSpeedSpin
		   ,ES.Remark
		   ,ES.CreateDateTime
		   ,ES.CreateUserID
		   ,ES.ChangeDateTime
		   ,ES.ChangeUserID
	FROM
			STB_ElectrodeStep ES
		   ,SmartFramework.dbo.STB_BaseCode BC
		   ,STB_MaterialMaster MM
		   ,STB_MaterialMaster MM2
	WHERE 1=1
	  AND BC.CodeGroup = 'ElectrodeStep'
	  AND ES.ElectrodeStepCode = BC.ItemCode
	  AND ES.MaterialCode = MM.MaterialCode
	  AND ES.ProdCode = MM2.MaterialCode
	  AND  ((@ProdCode = '*') OR (ES.ProdCode = @ProdCode)) 
	ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D' THEN 1
	              WHEN ES.ElectrodeStepCode = 'G' THEN 2
				  WHEN ES.ElectrodeStepCode = 'K' THEN 3
				  WHEN ES.ElectrodeStepCode = 'P' THEN 4
				  WHEN ES.ElectrodeStepCode = 'S' THEN 5
				  WHEN ES.ElectrodeStepCode = 'S1' THEN 6
				  WHEN ES.ElectrodeStepCode = 'S2' THEN 7
				  WHEN ES.ElectrodeStepCode = 'S3' THEN 8
				  WHEN ES.ElectrodeStepCode = 'S4' THEN 9
				  WHEN ES.ElectrodeStepCode = 'S5' THEN 10
				  WHEN ES.ElectrodeStepCode = 'DA' THEN 11
				  ELSE 100 END 
				  , ES.seq
END
GO

PRINT 'Procedure usp_ElectrodeStep_HY_get created successfully.';
GO

-- =========================================================
-- 6. Stored Procedure: usp_ElectrodeStep_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ElectrodeStep_HY_iud')
    DROP PROCEDURE [dbo].[usp_ElectrodeStep_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_ElectrodeStep_HY_iud]
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
  DECLARE @OldProdCode VARCHAR(20)
  DECLARE @Oldseq INT
  DECLARE @OldElectrodeStepCode VARCHAR(10)
  DECLARE @OldMaterialCode VARCHAR(20)
  DECLARE @ProdCode VARCHAR(20)
  DECLARE @seq INT
  DECLARE @ElectrodeStepCode VARCHAR(10)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @StdMinVal NUMERIC(20,5)
  DECLARE @StdMaxVal NUMERIC(20,5)
  DECLARE @WorkTime NUMERIC(20,5)
  DECLARE @HighSpeedSpin NUMERIC(20,5)
  DECLARE @LowSpeedSpin NUMERIC(20,5)
  DECLARE @Remark VARCHAR(500)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeStep',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeStep AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN Oldseq IS NULL THEN seq
							    ELSE Oldseq
							END AS Oldseq,
							CASE
							    WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
							    ELSE OldElectrodeStepCode
							END AS OldElectrodeStepCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							ProdCode,
							seq,
							ElectrodeStepCode,
							MaterialCode,
							StdMinVal,
							StdMaxVal,
							WorkTime,
							HighSpeedSpin,
							LowSpeedSpin,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										Oldseq INT,
										OldElectrodeStepCode VARCHAR(10),
										OldMaterialCode VARCHAR(20),
										ProdCode VARCHAR(20),
										seq INT,
										ElectrodeStepCode VARCHAR(10),
										MaterialCode VARCHAR(20),
										StdMinVal NUMERIC(20,5),
										StdMaxVal NUMERIC(20,5),
										WorkTime NUMERIC(20,5),
										HighSpeedSpin NUMERIC(20,5),
										LowSpeedSpin NUMERIC(20,5),
										Remark VARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
					TargetTable.seq = SourceTable.seq AND
					TargetTable.ElectrodeStepCode = SourceTable.ElectrodeStepCode AND
					TargetTable.MaterialCode = SourceTable.MaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					seq = ISNULL(SourceTable.seq,TargetTable.seq),
					ElectrodeStepCode = ISNULL(SourceTable.ElectrodeStepCode,TargetTable.ElectrodeStepCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					StdMinVal = ISNULL(SourceTable.StdMinVal,TargetTable.StdMinVal),
					StdMaxVal = ISNULL(SourceTable.StdMaxVal,TargetTable.StdMaxVal),
					WorkTime = ISNULL(SourceTable.WorkTime,TargetTable.WorkTime),
					HighSpeedSpin = ISNULL(SourceTable.HighSpeedSpin,TargetTable.HighSpeedSpin),
					LowSpeedSpin = ISNULL(SourceTable.LowSpeedSpin,TargetTable.LowSpeedSpin),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						seq,
						ElectrodeStepCode,
						MaterialCode,
						StdMinVal,
						StdMaxVal,
						WorkTime,
						HighSpeedSpin,
						LowSpeedSpin,
						Remark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.seq,
							SourceTable.ElectrodeStepCode,
							SourceTable.MaterialCode,
							SourceTable.StdMinVal,
							SourceTable.StdMaxVal,
							SourceTable.WorkTime,
							SourceTable.HighSpeedSpin,
							SourceTable.LowSpeedSpin,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeStep AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN Oldseq IS NULL THEN seq
							    ELSE Oldseq
							END AS Oldseq,
							CASE
							    WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
							    ELSE OldElectrodeStepCode
							END AS OldElectrodeStepCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							ProdCode,
							seq,
							ElectrodeStepCode,
							MaterialCode,
							StdMinVal,
							StdMaxVal,
							WorkTime,
							HighSpeedSpin,
							LowSpeedSpin,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										Oldseq INT,
										OldElectrodeStepCode VARCHAR(10),
										OldMaterialCode VARCHAR(20),
										ProdCode VARCHAR(20),
										seq INT,
										ElectrodeStepCode VARCHAR(10),
										MaterialCode VARCHAR(20),
										StdMinVal NUMERIC(20,5),
										StdMaxVal NUMERIC(20,5),
										WorkTime NUMERIC(20,5),
										HighSpeedSpin NUMERIC(20,5),
										LowSpeedSpin NUMERIC(20,5),
										Remark VARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.OldProdCode AND
					TargetTable.seq = SourceTable.Oldseq AND
					TargetTable.ElectrodeStepCode = SourceTable.OldElectrodeStepCode AND
					TargetTable.MaterialCode = SourceTable.OldMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					seq = ISNULL(SourceTable.seq,TargetTable.seq),
					ElectrodeStepCode = ISNULL(SourceTable.ElectrodeStepCode,TargetTable.ElectrodeStepCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					StdMinVal = ISNULL(SourceTable.StdMinVal,TargetTable.StdMinVal),
					StdMaxVal = ISNULL(SourceTable.StdMaxVal,TargetTable.StdMaxVal),
					WorkTime = ISNULL(SourceTable.WorkTime,TargetTable.WorkTime),
					HighSpeedSpin = ISNULL(SourceTable.HighSpeedSpin,TargetTable.HighSpeedSpin),
					LowSpeedSpin = ISNULL(SourceTable.LowSpeedSpin,TargetTable.LowSpeedSpin),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						seq,
						ElectrodeStepCode,
						MaterialCode,
						StdMinVal,
						StdMaxVal,
						WorkTime,
						HighSpeedSpin,
						LowSpeedSpin,
						Remark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.seq,
							SourceTable.ElectrodeStepCode,
							SourceTable.MaterialCode,
							SourceTable.StdMinVal,
							SourceTable.StdMaxVal,
							SourceTable.WorkTime,
							SourceTable.HighSpeedSpin,
							SourceTable.LowSpeedSpin,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeStep AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN Oldseq IS NULL THEN seq
							    ELSE Oldseq
							END AS Oldseq,
							CASE
							    WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
							    ELSE OldElectrodeStepCode
							END AS OldElectrodeStepCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							ProdCode,
							seq,
							ElectrodeStepCode,
							MaterialCode,
							StdMinVal,
							StdMaxVal,
							WorkTime,
							HighSpeedSpin,
							LowSpeedSpin,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										Oldseq INT,
										OldElectrodeStepCode VARCHAR(10),
										OldMaterialCode VARCHAR(20),
										ProdCode VARCHAR(20),
										seq INT,
										ElectrodeStepCode VARCHAR(10),
										MaterialCode VARCHAR(20),
										StdMinVal NUMERIC(20,5),
										StdMaxVal NUMERIC(20,5),
										WorkTime NUMERIC(20,5),
										HighSpeedSpin NUMERIC(20,5),
										LowSpeedSpin NUMERIC(20,5),
										Remark VARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
					TargetTable.seq = SourceTable.seq AND
					TargetTable.ElectrodeStepCode = SourceTable.ElectrodeStepCode AND
					TargetTable.MaterialCode = SourceTable.MaterialCode
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
									OldProdCode,
									Oldseq,
									OldElectrodeStepCode,
									OldMaterialCode,
									ProdCode,
									seq,
									ElectrodeStepCode,
									MaterialCode,
									StdMinVal,
									StdMaxVal,
									WorkTime,
									HighSpeedSpin,
									LowSpeedSpin,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 Oldseq INT,
											 OldElectrodeStepCode VARCHAR(10),
											 OldMaterialCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 seq INT,
											 ElectrodeStepCode VARCHAR(10),
											 MaterialCode VARCHAR(20),
											 StdMinVal NUMERIC(20,5),
											 StdMaxVal NUMERIC(20,5),
											 WorkTime NUMERIC(20,5),
											 HighSpeedSpin NUMERIC(20,5),
											 LowSpeedSpin NUMERIC(20,5),
											 Remark VARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN Oldseq IS NULL THEN seq
										ELSE Oldseq
									END AS Oldseq,
									CASE 
										WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
										ELSE OldElectrodeStepCode
									END AS OldElectrodeStepCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									ProdCode,
									seq,
									ElectrodeStepCode,
									MaterialCode,
									StdMinVal,
									StdMaxVal,
									WorkTime,
									HighSpeedSpin,
									LowSpeedSpin,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 Oldseq INT,
											 OldElectrodeStepCode VARCHAR(10),
											 OldMaterialCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 seq INT,
											 ElectrodeStepCode VARCHAR(10),
											 MaterialCode VARCHAR(20),
											 StdMinVal NUMERIC(20,5),
											 StdMaxVal NUMERIC(20,5),
											 WorkTime NUMERIC(20,5),
											 HighSpeedSpin NUMERIC(20,5),
											 LowSpeedSpin NUMERIC(20,5),
											 Remark VARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN Oldseq IS NULL THEN seq
										ELSE Oldseq
									END AS Oldseq,
									CASE 
										WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
										ELSE OldElectrodeStepCode
									END AS OldElectrodeStepCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									ProdCode,
									seq,
									ElectrodeStepCode,
									MaterialCode,
									StdMinVal,
									StdMaxVal,
									WorkTime,
									HighSpeedSpin,
									LowSpeedSpin,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 Oldseq INT,
											 OldElectrodeStepCode VARCHAR(10),
											 OldMaterialCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 seq INT,
											 ElectrodeStepCode VARCHAR(10),
											 MaterialCode VARCHAR(20),
											 StdMinVal NUMERIC(20,5),
											 StdMaxVal NUMERIC(20,5),
											 WorkTime NUMERIC(20,5),
											 HighSpeedSpin NUMERIC(20,5),
											 LowSpeedSpin NUMERIC(20,5),
											 Remark VARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProdCode,
								 @Oldseq,
								 @OldElectrodeStepCode,
								 @OldMaterialCode,
								 @ProdCode,
								 @seq,
								 @ElectrodeStepCode,
								 @MaterialCode,
								 @StdMinVal,
								 @StdMaxVal,
								 @WorkTime,
								 @HighSpeedSpin,
								 @LowSpeedSpin,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeStep WHERE ProdCode = @ProdCode AND seq = @seq AND ElectrodeStepCode = @ElectrodeStepCode AND MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProdCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeStep',@ProdCode OUTPUT
                    END

                    INSERT INTO STB_ElectrodeStep
						(
						    ProdCode,
						    seq,
						    ElectrodeStepCode,
						    MaterialCode,
						    StdMinVal,
						    StdMaxVal,
						    WorkTime,
						    HighSpeedSpin,
						    LowSpeedSpin,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ProdCode,
						    @seq,
						    @ElectrodeStepCode,
						    @MaterialCode,
						    @StdMinVal,
						    @StdMaxVal,
						    @WorkTime,
						    @HighSpeedSpin,
						    @LowSpeedSpin,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeStep
						SET
						    ProdCode =   ISNULL(@ProdCode,ProdCode),
						    seq =   ISNULL(@seq,seq),
						    ElectrodeStepCode =   ISNULL(@ElectrodeStepCode,ElectrodeStepCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    StdMinVal =   ISNULL(@StdMinVal,StdMinVal),
						    StdMaxVal =   ISNULL(@StdMaxVal,StdMaxVal),
						    WorkTime =   ISNULL(@WorkTime,WorkTime),
						    HighSpeedSpin =   ISNULL(@HighSpeedSpin,HighSpeedSpin),
						    LowSpeedSpin =   ISNULL(@LowSpeedSpin,LowSpeedSpin),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ProdCode = @OldProdCode AND
						    seq = @Oldseq AND
						    ElectrodeStepCode = @OldElectrodeStepCode AND
						    MaterialCode = @OldMaterialCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeStep
						WHERE
						    ProdCode = @OldProdCode AND
						    seq = @Oldseq AND
						    ElectrodeStepCode = @OldElectrodeStepCode AND
						    MaterialCode = @OldMaterialCode
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

PRINT 'Procedure usp_ElectrodeStep_HY_iud created successfully.';
GO

COMMIT TRAN;
PRINT 'Transaction COMMIT successfully. Stored procedures created.';
-- ROLLBACK
GO
