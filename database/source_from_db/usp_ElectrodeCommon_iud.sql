
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-22
-- Browsable : true
-- Group : 생산관리
-- Description: 전극 공통정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCommon_iud]
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


			-- Process Delete Table
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
