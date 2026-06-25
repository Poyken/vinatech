-- =============================================
-- Hotfix ID: 13_FIX_ELECTRODE_DAILY_PLAN_HUNG_YEN_SPS
-- Target Object: usp_DayProdPlan_HY_iud, usp_DoCancelDayProdPlan_HY, usp_DoFixDayProdPlan_HY, usp_SetInfo_HY_iud_VNT
-- Author: vanduc
-- Date: 2026-06-11
-- Description: Tao 4 SP lien quan cho phan he Ke hoach ngay Hung Yen (_HY) tren cac bang dung chung.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 13_FIX_ELECTRODE_DAILY_PLAN_HUNG_YEN_SPS...';
GO

-- =========================================================
-- 1. Stored Procedure: usp_DayProdPlan_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DayProdPlan_HY_iud')
    DROP PROCEDURE [dbo].[usp_DayProdPlan_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_DayProdPlan_HY_iud]
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
  DECLARE @OldDayPlanNo VARCHAR(20)
  DECLARE @DayPlanNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @PONo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(20)
  DECLARE @LineCode VARCHAR(30)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @MoldNumber VARCHAR(20)
  DECLARE @MoldChangePlanTime NUMERIC(6,2)
  DECLARE @PlanWorkTime NUMERIC(6,2)
  DECLARE @PlanDate DATE
  DECLARE @PlanShiftCode VARCHAR(1)
  DECLARE @ProdPrior INT
  DECLARE @PlanQty NUMERIC(20,4)
  DECLARE @IsFixed BIT
  DECLARE @IsCancel BIT
  DECLARE @DPPExtText01 NVARCHAR(200)
  DECLARE @DPPExtText02 NVARCHAR(200)
  DECLARE @DPPExtText03 NVARCHAR(200)
  DECLARE @DPPExtText04 NVARCHAR(200)
  DECLARE @DPPExtText05 NVARCHAR(200)
  DECLARE @PlanCT NUMERIC(10,2)
  DECLARE @BarcodeModel VARCHAR(10)
  DECLARE @MonthlyLotSeq INT
  DECLARE @MonthlyLotSeqText VARCHAR(10)
  DECLARE @ProdSnHeader VARCHAR(50)
  DECLARE @StartSerial BIGINT
  DECLARE @EndSerial BIGINT
  DECLARE @StartProdSn VARCHAR(50)
  DECLARE @EndProdSn VARCHAR(50)
  DECLARE @CurrentTarget NUMERIC(20,4)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  Declare @TargetMaterialCodes TABLE (
		TargetMaterialCode VARCHAR(20)
		,TargetPONo VARCHAR(20)
  );

  Declare @TargetMaterialCode VARCHAR(20)
  Declare @TargetPONo VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DayProdPlan',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DayProdPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDayPlanNo IS NULL THEN DayPlanNo
							    ELSE OldDayPlanNo
							END AS OldDayPlanNo,
							DayPlanNo,
							CompanyCode,
							WorkCenterCode,
							PONo,
							MaterialCode,
							BomVersion,
							LineCode,
							RouteCode,
							MachineCode,
							MoldNumber,
							MoldChangePlanTime,
							PlanWorkTime,
							PlanDate,
							PlanShiftCode,
							ProdPrior,
							PlanQty,
							IsFixed,
							IsCancel,
							DPPExtText01,
							DPPExtText02,
							DPPExtText03,
							DPPExtText04,
							DPPExtText05,
							PlanCT,
							BarcodeModel,
							MonthlyLotSeq,
							MonthlyLotSeqText,
							ProdSnHeader,
							StartSerial,
							EndSerial,
							StartProdSn,
							EndProdSn,
							CurrentTarget,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDayPlanNo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										PONo VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										LineCode VARCHAR(30),
										RouteCode VARCHAR(20),
										MachineCode VARCHAR(20),
										MoldNumber VARCHAR(20),
										MoldChangePlanTime NUMERIC(6,2),
										PlanWorkTime NUMERIC(6,2),
										PlanDate DATETIMEOFFSET,
										PlanShiftCode VARCHAR(1),
										ProdPrior INT,
										PlanQty NUMERIC(20,4),
										IsFixed BIT,
										IsCancel BIT,
										DPPExtText01 NVARCHAR(200),
										DPPExtText02 NVARCHAR(200),
										DPPExtText03 NVARCHAR(200),
										DPPExtText04 NVARCHAR(200),
										DPPExtText05 NVARCHAR(200),
										PlanCT NUMERIC(10,2),
										BarcodeModel VARCHAR(10),
										MonthlyLotSeq INT,
										MonthlyLotSeqText VARCHAR(10),
										ProdSnHeader VARCHAR(50),
										StartSerial BIGINT,
										EndSerial BIGINT,
										StartProdSn VARCHAR(50),
										EndProdSn VARCHAR(50),
										CurrentTarget NUMERIC(20,4),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DayPlanNo = SourceTable.DayPlanNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DayPlanNo = ISNULL(SourceTable.DayPlanNo,TargetTable.DayPlanNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					MoldNumber = ISNULL(SourceTable.MoldNumber,TargetTable.MoldNumber),
					MoldChangePlanTime = ISNULL(SourceTable.MoldChangePlanTime,TargetTable.MoldChangePlanTime),
					PlanWorkTime = ISNULL(SourceTable.PlanWorkTime,TargetTable.PlanWorkTime),
					PlanDate = ISNULL(SourceTable.PlanDate,TargetTable.PlanDate),
					PlanShiftCode = ISNULL(SourceTable.PlanShiftCode,TargetTable.PlanShiftCode),
					ProdPrior = ISNULL(SourceTable.ProdPrior,TargetTable.ProdPrior),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty),
					IsFixed = ISNULL(SourceTable.IsFixed,TargetTable.IsFixed),
					IsCancel = ISNULL(SourceTable.IsCancel,TargetTable.IsCancel),
					DPPExtText01 = ISNULL(SourceTable.DPPExtText01,TargetTable.DPPExtText01),
					DPPExtText02 = ISNULL(SourceTable.DPPExtText02,TargetTable.DPPExtText02),
					DPPExtText03 = ISNULL(SourceTable.DPPExtText03,TargetTable.DPPExtText03),
					DPPExtText04 = ISNULL(SourceTable.DPPExtText04,TargetTable.DPPExtText04),
					DPPExtText05 = ISNULL(SourceTable.DPPExtText05,TargetTable.DPPExtText05),
					PlanCT = ISNULL(SourceTable.PlanCT,TargetTable.PlanCT),
					BarcodeModel = ISNULL(SourceTable.BarcodeModel,TargetTable.BarcodeModel),
					MonthlyLotSeq = ISNULL(SourceTable.MonthlyLotSeq,TargetTable.MonthlyLotSeq),
					MonthlyLotSeqText = ISNULL(SourceTable.MonthlyLotSeqText,TargetTable.MonthlyLotSeqText),
					ProdSnHeader = ISNULL(SourceTable.ProdSnHeader,TargetTable.ProdSnHeader),
					StartSerial = ISNULL(SourceTable.StartSerial,TargetTable.StartSerial),
					EndSerial = ISNULL(SourceTable.EndSerial,TargetTable.EndSerial),
					StartProdSn = ISNULL(SourceTable.StartProdSn,TargetTable.StartProdSn),
					EndProdSn = ISNULL(SourceTable.EndProdSn,TargetTable.EndProdSn),
					CurrentTarget = ISNULL(SourceTable.CurrentTarget,TargetTable.CurrentTarget),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DayPlanNo,
						CompanyCode,
						WorkCenterCode,
						PONo,
						MaterialCode,
						BomVersion,
						LineCode,
						RouteCode,
						MachineCode,
						MoldNumber,
						MoldChangePlanTime,
						PlanWorkTime,
						PlanDate,
						PlanShiftCode,
						ProdPrior,
						PlanQty,
						IsFixed,
						IsCancel,
						DPPExtText01,
						DPPExtText02,
						DPPExtText03,
						DPPExtText04,
						DPPExtText05,
						PlanCT,
						BarcodeModel,
						MonthlyLotSeq,
						MonthlyLotSeqText,
						ProdSnHeader,
						StartSerial,
						EndSerial,
						StartProdSn,
						EndProdSn,
						CurrentTarget,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DayPlanNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.PONo,
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.LineCode,
							SourceTable.RouteCode,
							SourceTable.MachineCode,
							SourceTable.MoldNumber,
							SourceTable.MoldChangePlanTime,
							SourceTable.PlanWorkTime,
							SourceTable.PlanDate,
							SourceTable.PlanShiftCode,
							SourceTable.ProdPrior,
							SourceTable.PlanQty,
							SourceTable.IsFixed,
							SourceTable.IsCancel,
							SourceTable.DPPExtText01,
							SourceTable.DPPExtText02,
							SourceTable.DPPExtText03,
							SourceTable.DPPExtText04,
							SourceTable.DPPExtText05,
							SourceTable.PlanCT,
							SourceTable.BarcodeModel,
							SourceTable.MonthlyLotSeq,
							SourceTable.MonthlyLotSeqText,
							SourceTable.ProdSnHeader,
							SourceTable.StartSerial,
							SourceTable.EndSerial,
							SourceTable.StartProdSn,
							SourceTable.EndProdSn,
							SourceTable.CurrentTarget,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_DayProdPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDayPlanNo IS NULL THEN DayPlanNo
							    ELSE OldDayPlanNo
							END AS OldDayPlanNo,
							DayPlanNo,
							CompanyCode,
							WorkCenterCode,
							PONo,
							MaterialCode,
							BomVersion,
							LineCode,
							RouteCode,
							MachineCode,
							MoldNumber,
							MoldChangePlanTime,
							PlanWorkTime,
							PlanDate,
							PlanShiftCode,
							ProdPrior,
							PlanQty,
							IsFixed,
							IsCancel,
							DPPExtText01,
							DPPExtText02,
							DPPExtText03,
							DPPExtText04,
							DPPExtText05,
							PlanCT,
							BarcodeModel,
							MonthlyLotSeq,
							MonthlyLotSeqText,
							ProdSnHeader,
							StartSerial,
							EndSerial,
							StartProdSn,
							EndProdSn,
							CurrentTarget,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDayPlanNo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										PONo VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										LineCode VARCHAR(30),
										RouteCode VARCHAR(20),
										MachineCode VARCHAR(20),
										MoldNumber VARCHAR(20),
										MoldChangePlanTime NUMERIC(6,2),
										PlanWorkTime NUMERIC(6,2),
										PlanDate DATETIMEOFFSET,
										PlanShiftCode VARCHAR(1),
										ProdPrior INT,
										PlanQty NUMERIC(20,4),
										IsFixed BIT,
										IsCancel BIT,
										DPPExtText01 NVARCHAR(200),
										DPPExtText02 NVARCHAR(200),
										DPPExtText03 NVARCHAR(200),
										DPPExtText04 NVARCHAR(200),
										DPPExtText05 NVARCHAR(200),
										PlanCT NUMERIC(10,2),
										BarcodeModel VARCHAR(10),
										MonthlyLotSeq INT,
										MonthlyLotSeqText VARCHAR(10),
										ProdSnHeader VARCHAR(50),
										StartSerial BIGINT,
										EndSerial BIGINT,
										StartProdSn VARCHAR(50),
										EndProdSn VARCHAR(50),
										CurrentTarget NUMERIC(20,4),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DayPlanNo = SourceTable.OldDayPlanNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DayPlanNo = ISNULL(SourceTable.DayPlanNo,TargetTable.DayPlanNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					MoldNumber = ISNULL(SourceTable.MoldNumber,TargetTable.MoldNumber),
					MoldChangePlanTime = ISNULL(SourceTable.MoldChangePlanTime,TargetTable.MoldChangePlanTime),
					PlanWorkTime = ISNULL(SourceTable.PlanWorkTime,TargetTable.PlanWorkTime),
					PlanDate = ISNULL(SourceTable.PlanDate,TargetTable.PlanDate),
					PlanShiftCode = ISNULL(SourceTable.PlanShiftCode,TargetTable.PlanShiftCode),
					ProdPrior = ISNULL(SourceTable.ProdPrior,TargetTable.ProdPrior),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty),
					IsFixed = ISNULL(SourceTable.IsFixed,TargetTable.IsFixed),
					IsCancel = ISNULL(SourceTable.IsCancel,TargetTable.IsCancel),
					DPPExtText01 = ISNULL(SourceTable.DPPExtText01,TargetTable.DPPExtText01),
					DPPExtText02 = ISNULL(SourceTable.DPPExtText02,TargetTable.DPPExtText02),
					DPPExtText03 = ISNULL(SourceTable.DPPExtText03,TargetTable.DPPExtText03),
					DPPExtText04 = ISNULL(SourceTable.DPPExtText04,TargetTable.DPPExtText04),
					DPPExtText05 = ISNULL(SourceTable.DPPExtText05,TargetTable.DPPExtText05),
					PlanCT = ISNULL(SourceTable.PlanCT,TargetTable.PlanCT),
					BarcodeModel = ISNULL(SourceTable.BarcodeModel,TargetTable.BarcodeModel),
					MonthlyLotSeq = ISNULL(SourceTable.MonthlyLotSeq,TargetTable.MonthlyLotSeq),
					MonthlyLotSeqText = ISNULL(SourceTable.MonthlyLotSeqText,TargetTable.MonthlyLotSeqText),
					ProdSnHeader = ISNULL(SourceTable.ProdSnHeader,TargetTable.ProdSnHeader),
					StartSerial = ISNULL(SourceTable.StartSerial,TargetTable.StartSerial),
					EndSerial = ISNULL(SourceTable.EndSerial,TargetTable.EndSerial),
					StartProdSn = ISNULL(SourceTable.StartProdSn,TargetTable.StartProdSn),
					EndProdSn = ISNULL(SourceTable.EndProdSn,TargetTable.EndProdSn),
					CurrentTarget = ISNULL(SourceTable.CurrentTarget,TargetTable.CurrentTarget),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DayPlanNo,
						CompanyCode,
						WorkCenterCode,
						PONo,
						MaterialCode,
						BomVersion,
						LineCode,
						RouteCode,
						MachineCode,
						MoldNumber,
						MoldChangePlanTime,
						PlanWorkTime,
						PlanDate,
						PlanShiftCode,
						ProdPrior,
						PlanQty,
						IsFixed,
						IsCancel,
						DPPExtText01,
						DPPExtText02,
						DPPExtText03,
						DPPExtText04,
						DPPExtText05,
						PlanCT,
						BarcodeModel,
						MonthlyLotSeq,
						MonthlyLotSeqText,
						ProdSnHeader,
						StartSerial,
						EndSerial,
						StartProdSn,
						EndProdSn,
						CurrentTarget,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DayPlanNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.PONo,
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.LineCode,
							SourceTable.RouteCode,
							SourceTable.MachineCode,
							SourceTable.MoldNumber,
							SourceTable.MoldChangePlanTime,
							SourceTable.PlanWorkTime,
							SourceTable.PlanDate,
							SourceTable.PlanShiftCode,
							SourceTable.ProdPrior,
							SourceTable.PlanQty,
							SourceTable.IsFixed,
							SourceTable.IsCancel,
							SourceTable.DPPExtText01,
							SourceTable.DPPExtText02,
							SourceTable.DPPExtText03,
							SourceTable.DPPExtText04,
							SourceTable.DPPExtText05,
							SourceTable.PlanCT,
							SourceTable.BarcodeModel,
							SourceTable.MonthlyLotSeq,
							SourceTable.MonthlyLotSeqText,
							SourceTable.ProdSnHeader,
							SourceTable.StartSerial,
							SourceTable.EndSerial,
							SourceTable.StartProdSn,
							SourceTable.EndProdSn,
							SourceTable.CurrentTarget,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DayProdPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDayPlanNo IS NULL THEN DayPlanNo
							    ELSE OldDayPlanNo
							END AS OldDayPlanNo,
							DayPlanNo,
							CompanyCode,
							WorkCenterCode,
							PONo,
							MaterialCode,
							BomVersion,
							LineCode,
							RouteCode,
							MachineCode,
							MoldNumber,
							MoldChangePlanTime,
							PlanWorkTime,
							PlanDate,
							PlanShiftCode,
							ProdPrior,
							PlanQty,
							IsFixed,
							IsCancel,
							DPPExtText01,
							DPPExtText02,
							DPPExtText03,
							DPPExtText04,
							DPPExtText05,
							PlanCT,
							BarcodeModel,
							MonthlyLotSeq,
							MonthlyLotSeqText,
							ProdSnHeader,
							StartSerial,
							EndSerial,
							StartProdSn,
							EndProdSn,
							CurrentTarget,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDayPlanNo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										PONo VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										LineCode VARCHAR(30),
										RouteCode VARCHAR(20),
										MachineCode VARCHAR(20),
										MoldNumber VARCHAR(20),
										MoldChangePlanTime NUMERIC(6,2),
										PlanWorkTime NUMERIC(6,2),
										PlanDate DATETIMEOFFSET,
										PlanShiftCode VARCHAR(1),
										ProdPrior INT,
										PlanQty NUMERIC(20,4),
										IsFixed BIT,
										IsCancel BIT,
										DPPExtText01 NVARCHAR(200),
										DPPExtText02 NVARCHAR(200),
										DPPExtText03 NVARCHAR(200),
										DPPExtText04 NVARCHAR(200),
										DPPExtText05 NVARCHAR(200),
										PlanCT NUMERIC(10,2),
										BarcodeModel VARCHAR(10),
										MonthlyLotSeq INT,
										MonthlyLotSeqText VARCHAR(10),
										ProdSnHeader VARCHAR(50),
										StartSerial BIGINT,
										EndSerial BIGINT,
										StartProdSn VARCHAR(50),
										EndProdSn VARCHAR(50),
										CurrentTarget NUMERIC(20,4),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DayPlanNo = SourceTable.DayPlanNo
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
									OldDayPlanNo,
									DayPlanNo,
									CompanyCode,
									WorkCenterCode,
									PONo,
									MaterialCode,
									BomVersion,
									LineCode,
									RouteCode,
									MachineCode,
									MoldNumber,
									MoldChangePlanTime,
									PlanWorkTime,
									PlanDate,
									PlanShiftCode,
									ProdPrior,
									PlanQty,
									IsFixed,
									IsCancel,
									DPPExtText01,
									DPPExtText02,
									DPPExtText03,
									DPPExtText04,
									DPPExtText05,
									PlanCT,
									BarcodeModel,
									MonthlyLotSeq,
									MonthlyLotSeqText,
									ProdSnHeader,
									StartSerial,
									EndSerial,
									StartProdSn,
									EndProdSn,
									CurrentTarget,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDayPlanNo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 PONo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 LineCode VARCHAR(30),
											 RouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 MoldChangePlanTime NUMERIC(6,2),
											 PlanWorkTime NUMERIC(6,2),
											 PlanDate DATETIMEOFFSET,
											 PlanShiftCode VARCHAR(1),
											 ProdPrior INT,
											 PlanQty NUMERIC(20,4),
											 IsFixed BIT,
											 IsCancel BIT,
											 DPPExtText01 NVARCHAR(200),
											 DPPExtText02 NVARCHAR(200),
											 DPPExtText03 NVARCHAR(200),
											 DPPExtText04 NVARCHAR(200),
											 DPPExtText05 NVARCHAR(200),
											 PlanCT NUMERIC(10,2),
											 BarcodeModel VARCHAR(10),
											 MonthlyLotSeq INT,
											 MonthlyLotSeqText VARCHAR(10),
											 ProdSnHeader VARCHAR(50),
											 StartSerial BIGINT,
											 EndSerial BIGINT,
											 StartProdSn VARCHAR(50),
											 EndProdSn VARCHAR(50),
											 CurrentTarget NUMERIC(20,4),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDayPlanNo IS NULL THEN DayPlanNo
										ELSE OldDayPlanNo
									END AS OldDayPlanNo,
									DayPlanNo,
									CompanyCode,
									WorkCenterCode,
									PONo,
									MaterialCode,
									BomVersion,
									LineCode,
									RouteCode,
									MachineCode,
									MoldNumber,
									MoldChangePlanTime,
									PlanWorkTime,
									PlanDate,
									PlanShiftCode,
									ProdPrior,
									PlanQty,
									IsFixed,
									IsCancel,
									DPPExtText01,
									DPPExtText02,
									DPPExtText03,
									DPPExtText04,
									DPPExtText05,
									PlanCT,
									BarcodeModel,
									MonthlyLotSeq,
									MonthlyLotSeqText,
									ProdSnHeader,
									StartSerial,
									EndSerial,
									StartProdSn,
									EndProdSn,
									CurrentTarget,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDayPlanNo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 PONo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 LineCode VARCHAR(30),
											 RouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 MoldChangePlanTime NUMERIC(6,2),
											 PlanWorkTime NUMERIC(6,2),
											 PlanDate DATETIMEOFFSET,
											 PlanShiftCode VARCHAR(1),
											 ProdPrior INT,
											 PlanQty NUMERIC(20,4),
											 IsFixed BIT,
											 IsCancel BIT,
											 DPPExtText01 NVARCHAR(200),
											 DPPExtText02 NVARCHAR(200),
											 DPPExtText03 NVARCHAR(200),
											 DPPExtText04 NVARCHAR(200),
											 DPPExtText05 NVARCHAR(200),
											 PlanCT NUMERIC(10,2),
											 BarcodeModel VARCHAR(10),
											 MonthlyLotSeq INT,
											 MonthlyLotSeqText VARCHAR(10),
											 ProdSnHeader VARCHAR(50),
											 StartSerial BIGINT,
											 EndSerial BIGINT,
											 StartProdSn VARCHAR(50),
											 EndProdSn VARCHAR(50),
											 CurrentTarget NUMERIC(20,4),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDayPlanNo IS NULL THEN DayPlanNo
										ELSE OldDayPlanNo
									END AS OldDayPlanNo,
									DayPlanNo,
									CompanyCode,
									WorkCenterCode,
									PONo,
									MaterialCode,
									BomVersion,
									LineCode,
									RouteCode,
									MachineCode,
									MoldNumber,
									MoldChangePlanTime,
									PlanWorkTime,
									PlanDate,
									PlanShiftCode,
									ProdPrior,
									PlanQty,
									IsFixed,
									IsCancel,
									DPPExtText01,
									DPPExtText02,
									DPPExtText03,
									DPPExtText04,
									DPPExtText05,
									PlanCT,
									BarcodeModel,
									MonthlyLotSeq,
									MonthlyLotSeqText,
									ProdSnHeader,
									StartSerial,
									EndSerial,
									StartProdSn,
									EndProdSn,
									CurrentTarget,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDayPlanNo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 PONo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 LineCode VARCHAR(30),
											 RouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 MoldChangePlanTime NUMERIC(6,2),
											 PlanWorkTime NUMERIC(6,2),
											 PlanDate DATETIMEOFFSET,
											 PlanShiftCode VARCHAR(1),
											 ProdPrior INT,
											 PlanQty NUMERIC(20,4),
											 IsFixed BIT,
											 IsCancel BIT,
											 DPPExtText01 NVARCHAR(200),
											 DPPExtText02 NVARCHAR(200),
											 DPPExtText03 NVARCHAR(200),
											 DPPExtText04 NVARCHAR(200),
											 DPPExtText05 NVARCHAR(200),
											 PlanCT NUMERIC(10,2),
											 BarcodeModel VARCHAR(10),
											 MonthlyLotSeq INT,
											 MonthlyLotSeqText VARCHAR(10),
											 ProdSnHeader VARCHAR(50),
											 StartSerial BIGINT,
											 EndSerial BIGINT,
											 StartProdSn VARCHAR(50),
											 EndProdSn VARCHAR(50),
											 CurrentTarget NUMERIC(20,4),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDayPlanNo,
								 @DayPlanNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @PONo,
								 @MaterialCode,
								 @BomVersion,
								 @LineCode,
								 @RouteCode,
								 @MachineCode,
								 @MoldNumber,
								 @MoldChangePlanTime,
								 @PlanWorkTime,
								 @PlanDate,
								 @PlanShiftCode,
								 @ProdPrior,
								 @PlanQty,
								 @IsFixed,
								 @IsCancel,
								 @DPPExtText01,
								 @DPPExtText02,
								 @DPPExtText03,
								 @DPPExtText04,
								 @DPPExtText05,
								 @PlanCT,
								 @BarcodeModel,
								 @MonthlyLotSeq,
								 @MonthlyLotSeqText,
								 @ProdSnHeader,
								 @StartSerial,
								 @EndSerial,
								 @StartProdSn,
								 @EndProdSn,
								 @CurrentTarget,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END



                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DayProdPlan WHERE DayPlanNo = @DayPlanNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DayPlanNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayProdPlan',@DayPlanNo OUTPUT
                    END

                    INSERT INTO STB_DayProdPlan
						(
						    DayPlanNo,
						    CompanyCode,
						    WorkCenterCode,
						    PONo,
						    MaterialCode,
						    BomVersion,
						    LineCode,
						    RouteCode,
							MachineCode,
							MoldNumber,
							MoldChangePlanTime,
							PlanWorkTime,
						    PlanDate,
						    PlanShiftCode,
						    ProdPrior,
						    PlanQty,
						    IsFixed,
						    IsCancel,
						    DPPExtText01,
						    DPPExtText02,
						    DPPExtText03,
						    DPPExtText04,
						    DPPExtText05,
						    PlanCT,
						    BarcodeModel,
						    MonthlyLotSeq,
						    MonthlyLotSeqText,
						    ProdSnHeader,
						    StartSerial,
						    EndSerial,
						    StartProdSn,
						    EndProdSn,
						    CurrentTarget,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DayPlanNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @PONo,
						    @MaterialCode,
						    @BomVersion,
						    @LineCode,
						    @RouteCode,
							@MachineCode,
							@MoldNumber,
							@MoldChangePlanTime,
							@PlanWorkTime,
						    @PlanDate,
						    @PlanShiftCode,
						    @ProdPrior,
						    @PlanQty,
						    @IsFixed,
						    @IsCancel,
						    @DPPExtText01,
						    @DPPExtText02,
						    @DPPExtText03,
						    @DPPExtText04,
						    @DPPExtText05,
						    @PlanCT,
						    @BarcodeModel,
						    @MonthlyLotSeq,
						    @MonthlyLotSeqText,
						    @ProdSnHeader,
						    @StartSerial,
						    @EndSerial,
						    @StartProdSn,
						    @EndProdSn,
						    @CurrentTarget,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

					IF EXISTS (SELECT 1
								FROM STB_ProductionOrderBatchInfo
								WHERE ParentMaterialCode =  @MaterialCode
							) BEGIN
						INSERT INTO @TargetMaterialCodes
							SELECT TargetMaterialCode, TargetPONo
							  FROM (
									SELECT TargetMaterialCode
									      ,(SELECT MAX(PONo) 
 										      FROM STB_ProductionOrderInfo 
											 WHERE MaterialCode = TargetMaterialCode
											   AND PlanYearMonth = (SELECT PlanYearMonth 
											                          FROM STB_ProductionOrderInfo 
																	 WHERE PONo = @PONo
																   )
											   AND IsFix = CONVERT(BIT, 1)
											) AS TargetPONo
									  FROM STB_ProductionOrderBatchInfo
									 WHERE ParentMaterialCode =  @MaterialCode
							) A

						-- #240612 완제품에 걸려있는 반제품이 있으면 동일하게 계획을 생성한다.
						DECLARE cur2 CURSOR FOR

							SELECT TargetMaterialCode, TargetPONo
							  FROM @TargetMaterialCodes
							 WHERE TargetMaterialCode <> @MaterialCode

						OPEN cur2

						FETCH NEXT FROM cur2 INTO @TargetMaterialCode, @TargetPONo

						IF ISNULL(@TargetPONo, '') = '' BEGIN
							RAISERROR('반제품의 PO번호를 가져오지 못했습니다. PO정보 확인 바랍니다.', 16, 1)
						END

						WHILE @@FETCH_STATUS = 0
						BEGIN
							-- To-Do
							IF @IsAutoKey = 1 BEGIN
								EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayProdPlan',@DayPlanNo OUTPUT
							END

							INSERT INTO STB_DayProdPlan
								(
									DayPlanNo,
									CompanyCode,
									WorkCenterCode,
									PONo,
									MaterialCode,
									BomVersion,
									LineCode,
									RouteCode,
									MachineCode,
									MoldNumber,
									MoldChangePlanTime,
									PlanWorkTime,
									PlanDate,
									PlanShiftCode,
									ProdPrior,
									PlanQty,
									IsFixed,
									IsCancel,
									DPPExtText01,
									DPPExtText02,
									DPPExtText03,
									DPPExtText04,
									DPPExtText05,
									PlanCT,
									BarcodeModel,
									MonthlyLotSeq,
									MonthlyLotSeqText,
									ProdSnHeader,
									StartSerial,
									EndSerial,
									StartProdSn,
									EndProdSn,
									CurrentTarget,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
								)
								VALUES
								(
									@DayPlanNo,
									@CompanyCode,
									@WorkCenterCode,
									@TargetPONo,
									@TargetMaterialCode,
									@BomVersion,
									@LineCode,
									@RouteCode,
									@MachineCode,
									@MoldNumber,
									@MoldChangePlanTime,
									@PlanWorkTime,
									@PlanDate,
									@PlanShiftCode,
									@ProdPrior,
									@PlanQty,
									@IsFixed,
									@IsCancel,
									@DPPExtText01,
									@DPPExtText02,
									@DPPExtText03,
									@DPPExtText04,
									@DPPExtText05,
									@PlanCT,
									@BarcodeModel,
									@MonthlyLotSeq,
									@MonthlyLotSeqText,
									@ProdSnHeader,
									@StartSerial,
									@EndSerial,
									@StartProdSn,
									@EndProdSn,
									@CurrentTarget,
									GETDATE(),
									@pProcessUserID,
									@ChangeDateTime,
									@ChangeUserID
								)
	
							FETCH NEXT FROM cur2 INTO @TargetMaterialCode, @TargetPONo
						END

						CLOSE cur2
						DEALLOCATE cur2
					END



				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					IF @IsFixed = 1 BEGIN
							EXEC usp_RaiseLocalizedError @pProcessLanguage,'확정된 계획은 수정할수 없습니다'
					END

                    UPDATE STB_DayProdPlan
						SET
						    DayPlanNo =   ISNULL(@DayPlanNo,DayPlanNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    PONo =   ISNULL(@PONo,PONo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    BomVersion =   ISNULL(@BomVersion,BomVersion),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
							MachineCode = ISNULL(@MachineCode,MachineCode),
							MoldNumber = ISNULL(@MoldNumber,MoldNumber),
							MoldChangePlanTime = ISNULL(@MoldChangePlanTime,MoldChangePlanTime),
							PlanWorkTime = ISNULL(@PlanWorkTime,PlanWorkTime),
						    PlanDate =   ISNULL(@PlanDate,PlanDate),
						    PlanShiftCode =   ISNULL(@PlanShiftCode,PlanShiftCode),
						    ProdPrior =   ISNULL(@ProdPrior,ProdPrior),
						    PlanQty =   ISNULL(@PlanQty,PlanQty),
						    IsFixed =   ISNULL(@IsFixed,IsFixed),
						    IsCancel =   ISNULL(@IsCancel,IsCancel),
						    DPPExtText01 =   ISNULL(@DPPExtText01,DPPExtText01),
						    DPPExtText02 =   ISNULL(@DPPExtText02,DPPExtText02),
						    DPPExtText03 =   ISNULL(@DPPExtText03,DPPExtText03),
						    DPPExtText04 =   ISNULL(@DPPExtText04,DPPExtText04),
						    DPPExtText05 =   ISNULL(@DPPExtText05,DPPExtText05),
						    PlanCT =   ISNULL(@PlanCT,PlanCT),
						    BarcodeModel =   ISNULL(@BarcodeModel,BarcodeModel),
						    MonthlyLotSeq =   ISNULL(@MonthlyLotSeq,MonthlyLotSeq),
						    MonthlyLotSeqText =   ISNULL(@MonthlyLotSeqText,MonthlyLotSeqText),
						    ProdSnHeader =   ISNULL(@ProdSnHeader,ProdSnHeader),
						    StartSerial =   ISNULL(@StartSerial,StartSerial),
						    EndSerial =   ISNULL(@EndSerial,EndSerial),
						    StartProdSn =   ISNULL(@StartProdSn,StartProdSn),
						    EndProdSn =   ISNULL(@EndProdSn,EndProdSn),
						    CurrentTarget =   ISNULL(@CurrentTarget,CurrentTarget),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    DayPlanNo = @OldDayPlanNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					IF (SELECT COUNT(*) FROM STB_SetInfo WHERE DayPlanNo = @DayPlanNo) > 0 BEGIN
							EXEC usp_RaiseLocalizedError @pProcessLanguage,'Lot이 생성된 계획은 삭제할수 없습니다'
					END
                    DELETE FROM STB_DayProdPlan
						WHERE
						    DayPlanNo = @OldDayPlanNo
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

PRINT 'Procedure usp_DayProdPlan_HY_iud created successfully.';
GO

-- =========================================================
-- 2. Stored Procedure: usp_DoCancelDayProdPlan_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoCancelDayProdPlan_HY')
    DROP PROCEDURE [dbo].[usp_DoCancelDayProdPlan_HY];
GO

CREATE PROCEDURE [dbo].[usp_DoCancelDayProdPlan_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDayPlanNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @IsFixed BIT
	DECLARE @IsCancel BIT
	DECLARE @PONo VARCHAR(20)
	DECLARE @PlanQty NUMERIC(20,5)
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@PONo = DPP.PONo,
			@PlanQty = DPP.PlanQty,
			@IsFixed = DPP.IsFixed,
			@IsCancel = DPP.IsCancel
	FROM
			STB_DayProdPlan DPP
	WHERE
			DPP.DayPlanNo = @DayPlanNo

	IF EXISTS (
				SELECT	1
				FROM
						STB_SetInfo SI
				WHERE
						SI.PONo = @PONo AND
						SI.DayPlanNo = @DayPlanNo
				) BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
											'^Lot이 생성된 일일 계획은 취소할 수 없습니다^',
											@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@DayPlanNo)
			RETURN

	END

	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 취소된 계획입니다'
	END

	IF @IsFixed = 1 BEGIN
			UPDATE	STB_ProductionOrderInfo
			SET
					ProdOrderQty = ProdOrderQty - @PlanQty
			WHERE
					PONo = @PONo
	END

	UPDATE	STB_DayProdPlan
	SET
			IsCancel = 1,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			DayPlanNo = @DayPlanNo

END
GO

PRINT 'Procedure usp_DoCancelDayProdPlan_HY created successfully.';
GO

-- =========================================================
-- 3. Stored Procedure: usp_DoFixDayProdPlan_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoFixDayProdPlan_HY')
    DROP PROCEDURE [dbo].[usp_DoFixDayProdPlan_HY];
GO

CREATE PROCEDURE [dbo].[usp_DoFixDayProdPlan_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDayPlanNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @IsFixed BIT
	DECLARE @IsCancel BIT
	DECLARE @PONo VARCHAR(20)
	DECLARE @PlanQty NUMERIC(20,5)
	DECLARE @LineCod VARCHAR(20)
	DECLARE @Companycod VARCHAR(20)

	SELECT
			@PONo = DPP.PONo,
			@PlanQty = DPP.PlanQty,
			@IsFixed = DPP.IsFixed,
			@IsCancel = DPP.IsCancel,
			@LineCod = LineCode, 
			@Companycod = CompanyCode
	FROM
			STB_DayProdPlan DPP
	WHERE
			DPP.DayPlanNo = @DayPlanNo


	IF (@Companycod ='VVT' and @LineCod = '%')
	BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage, 'Chua chon ma Line, ma Line van la %'
			RETURN
	END


	IF ISNULL(@IsFixed,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 확정된 계획입니다 (Kế hoạch đã được xác định rồi)'
	END


	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 취소된 계획입니다 (Kế hoạch đã bị hủy bỏ)'
	END

	UPDATE	STB_ProductionOrderInfo
	SET
			ProdOrderQty = ISNULL(ProdOrderQty,0) + @PlanQty
	WHERE
			PONo = @PONo

	UPDATE	STB_DayProdPlan
	SET
			IsFixed = 1,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			DayPlanNo = @DayPlanNo

END
GO

PRINT 'Procedure usp_DoFixDayProdPlan_HY created successfully.';
GO

-- =========================================================
-- 4. Stored Procedure: usp_SetInfo_HY_iud_VNT
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_SetInfo_HY_iud_VNT')
    DROP PROCEDURE [dbo].[usp_SetInfo_HY_iud_VNT];
GO

CREATE PROCEDURE [dbo].[usp_SetInfo_HY_iud_VNT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pCompanyCode VARCHAR(20) = NULL,
						@pXml NVARCHAR(MAX) = null
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN @pCompanyCode IS NULL THEN 'VNT' ELSE @pCompanyCode END
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
  DECLARE @OldControlNo VARCHAR(20)
  DECLARE @ControlNo VARCHAR(20)
  DECLARE @PONo VARCHAR(20)
  DECLARE @DayPlanNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @SetSeq INT
  DECLARE @IsLineInput BIT
  DECLARE @IsLoss BIT
  DECLARE @IsDefect BIT
  DECLARE @CurrentRouteCode VARCHAR(20)
  DECLARE @InternalProdNo VARCHAR(50)
  DECLARE @OutSetNo VARCHAR(50)
  DECLARE @OutSetNoSeq INT
  DECLARE @Barcode VARCHAR(50)
  DECLARE @InputLineCode VARCHAR(20)
  DECLARE @InputJobDate DATE
  DECLARE @InputShiftCode VARCHAR(1)
  DECLARE @InputDateTime DATETIME
  DECLARE @DefectQty INT
  DECLARE @IsProdFinish BIT
  DECLARE @ProdFinishJobDate DATE
  DECLARE @ProdFinishShiftCode VARCHAR(1)
  DECLARE @ProdFinishDateTime DATETIME
  DECLARE @SalesOrderNo VARCHAR(20)
  DECLARE @SOISequence BIGINT
  DECLARE @IsOutboundFinalInspection BIT
  DECLARE @IsFinalInspection BIT
  DECLARE @FinalInspectionJobDate DATE
  DECLARE @FinalInspectionShiftCode VARCHAR(1)
  DECLARE @FinalInspectionDateTime DATETIME
  DECLARE @LotNumber VARCHAR(50)
  DECLARE @LotCreateDateTime DATETIME
  DECLARE @LotDecisionResult VARCHAR(10)
  DECLARE @GradeCode VARCHAR(1)
  DECLARE @GradeChangeJobDate DATE
  DECLARE @GradeChangeShiftCode VARCHAR(1)
  DECLARE @GradeChangeDateTime DATETIME
  DECLARE @GradeChangeUserID VARCHAR(20)
  DECLARE @GradeModelCode VARCHAR(50)
  DECLARE @GradeChangeSetNo VARCHAR(50)
  DECLARE @PrintDate DATETIME
  DECLARE @LineOutTactTime NUMERIC(10,3)
  DECLARE @ProdQty NUMERIC(20,5)
  DECLARE @SIExtText01 VARCHAR(50)
  DECLARE @SIExtText02 VARCHAR(50)
  DECLARE @SIExtText03 VARCHAR(50)
  DECLARE @SIExtText04 VARCHAR(50)
  DECLARE @SIExtText05 VARCHAR(50)
  DECLARE @SIExtInt01 BIGINT
  DECLARE @SIExtInt02 BIGINT
  DECLARE @SIExtInt03 BIGINT
  DECLARE @SIExtInt04 BIGINT
  DECLARE @SIExtInt05 BIGINT
  DECLARE @SIExtReal01 NUMERIC(20,5)
  DECLARE @SIExtReal02 NUMERIC(20,5)
  DECLARE @SIExtReal03 NUMERIC(20,5)
  DECLARE @SIExtReal04 NUMERIC(20,5)
  DECLARE @SIExtReal05 NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @MixBatchNo INT
  DECLARE @EDLC VARCHAR(1)

  DECLARE @iDoc INT
  

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SetInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 
	
	BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SetInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldControlNo IS NULL THEN ControlNo
							    ELSE OldControlNo
							END AS OldControlNo,
							ControlNo,
							PONo,
							DayPlanNo,
							MaterialCode,
							SetSeq,
							IsLineInput,
							IsLoss,
							IsDefect,
							CurrentRouteCode,
							InternalProdNo,
							OutSetNo,
							OutSetNoSeq,
							Barcode,
							InputLineCode,
							InputJobDate,
							InputShiftCode,
							InputDateTime,
							DefectQty,
							IsProdFinish,
							ProdFinishJobDate,
							ProdFinishShiftCode,
							ProdFinishDateTime,
							SalesOrderNo,
							SOISequence,
							IsOutboundFinalInspection,
							IsFinalInspection,
							FinalInspectionJobDate,
							FinalInspectionShiftCode,
							FinalInspectionDateTime,
							LotNumber,
							LotCreateDateTime,
							LotDecisionResult,
							GradeCode,
							GradeChangeJobDate,
							GradeChangeShiftCode,
							GradeChangeDateTime,
							GradeChangeUserID,
							GradeModelCode,
							GradeChangeSetNo,
							PrintDate,
							LineOutTactTime,
							ProdQty,
							SIExtText01,
							SIExtText02,
							SIExtText03,
							SIExtText04,
							SIExtText05,
							SIExtInt01,
							SIExtInt02,
							SIExtInt03,
							SIExtInt04,
							SIExtInt05,
							SIExtReal01,
							SIExtReal02,
							SIExtReal03,
							SIExtReal04,
							SIExtReal05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldControlNo VARCHAR(20),
										ControlNo VARCHAR(20),
										PONo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										SetSeq INT,
										IsLineInput BIT,
										IsLoss BIT,
										IsDefect BIT,
										CurrentRouteCode VARCHAR(20),
										InternalProdNo VARCHAR(50),
										OutSetNo VARCHAR(50),
										OutSetNoSeq INT,
										Barcode VARCHAR(50),
										InputLineCode VARCHAR(20),
										InputJobDate DATETIMEOFFSET,
										InputShiftCode VARCHAR(1),
										InputDateTime DATETIMEOFFSET,
										DefectQty INT,
										IsProdFinish BIT,
										ProdFinishJobDate DATETIMEOFFSET,
										ProdFinishShiftCode VARCHAR(1),
										ProdFinishDateTime DATETIMEOFFSET,
										SalesOrderNo VARCHAR(20),
										SOISequence BIGINT,
										IsOutboundFinalInspection BIT,
										IsFinalInspection BIT,
										FinalInspectionJobDate DATETIMEOFFSET,
										FinalInspectionShiftCode VARCHAR(1),
										FinalInspectionDateTime DATETIMEOFFSET,
										LotNumber VARCHAR(50),
										LotCreateDateTime DATETIMEOFFSET,
										LotDecisionResult VARCHAR(10),
										GradeCode VARCHAR(1),
										GradeChangeJobDate DATETIMEOFFSET,
										GradeChangeShiftCode VARCHAR(1),
										GradeChangeDateTime DATETIMEOFFSET,
										GradeChangeUserID VARCHAR(20),
										GradeModelCode VARCHAR(50),
										GradeChangeSetNo VARCHAR(50),
										PrintDate DATETIMEOFFSET,
										LineOutTactTime NUMERIC(10,3),
										ProdQty NUMERIC(20,5),
										SIExtText01 VARCHAR(50),
										SIExtText02 VARCHAR(50),
										SIExtText03 VARCHAR(50),
										SIExtText04 VARCHAR(50),
										SIExtText05 VARCHAR(50),
										SIExtInt01 BIGINT,
										SIExtInt02 BIGINT,
										SIExtInt03 BIGINT,
										SIExtInt04 BIGINT,
										SIExtInt05 BIGINT,
										SIExtReal01 NUMERIC(20,5),
										SIExtReal02 NUMERIC(20,5),
										SIExtReal03 NUMERIC(20,5),
										SIExtReal04 NUMERIC(20,5),
										SIExtReal05 NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ControlNo = SourceTable.ControlNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ControlNo = ISNULL(SourceTable.ControlNo,TargetTable.ControlNo),
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					DayPlanNo = ISNULL(SourceTable.DayPlanNo,TargetTable.DayPlanNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					SetSeq = ISNULL(SourceTable.SetSeq,TargetTable.SetSeq),
					IsLineInput = ISNULL(SourceTable.IsLineInput,TargetTable.IsLineInput),
					IsLoss = ISNULL(SourceTable.IsLoss,TargetTable.IsLoss),
					IsDefect = ISNULL(SourceTable.IsDefect,TargetTable.IsDefect),
					CurrentRouteCode = ISNULL(SourceTable.CurrentRouteCode,TargetTable.CurrentRouteCode),
					InternalProdNo = ISNULL(SourceTable.InternalProdNo,TargetTable.InternalProdNo),
					OutSetNo = ISNULL(SourceTable.OutSetNo,TargetTable.OutSetNo),
					OutSetNoSeq = ISNULL(SourceTable.OutSetNoSeq,TargetTable.OutSetNoSeq),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					InputLineCode = ISNULL(SourceTable.InputLineCode,TargetTable.InputLineCode),
					InputJobDate = ISNULL(SourceTable.InputJobDate,TargetTable.InputJobDate),
					InputShiftCode = ISNULL(SourceTable.InputShiftCode,TargetTable.InputShiftCode),
					InputDateTime = ISNULL(SourceTable.InputDateTime,TargetTable.InputDateTime),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					IsProdFinish = ISNULL(SourceTable.IsProdFinish,TargetTable.IsProdFinish),
					ProdFinishJobDate = ISNULL(SourceTable.ProdFinishJobDate,TargetTable.ProdFinishJobDate),
					ProdFinishShiftCode = ISNULL(SourceTable.ProdFinishShiftCode,TargetTable.ProdFinishShiftCode),
					ProdFinishDateTime = ISNULL(SourceTable.ProdFinishDateTime,TargetTable.ProdFinishDateTime),
					SalesOrderNo = ISNULL(SourceTable.SalesOrderNo,TargetTable.SalesOrderNo),
					SOISequence = ISNULL(SourceTable.SOISequence,TargetTable.SOISequence),
					IsOutboundFinalInspection = ISNULL(SourceTable.IsOutboundFinalInspection,TargetTable.IsOutboundFinalInspection),
					IsFinalInspection = ISNULL(SourceTable.IsFinalInspection,TargetTable.IsFinalInspection),
					FinalInspectionJobDate = ISNULL(SourceTable.FinalInspectionJobDate,TargetTable.FinalInspectionJobDate),
					FinalInspectionShiftCode = ISNULL(SourceTable.FinalInspectionShiftCode,TargetTable.FinalInspectionShiftCode),
					FinalInspectionDateTime = ISNULL(SourceTable.FinalInspectionDateTime,TargetTable.FinalInspectionDateTime),
					LotNumber = ISNULL(SourceTable.LotNumber,TargetTable.LotNumber),
					LotCreateDateTime = ISNULL(SourceTable.LotCreateDateTime,TargetTable.LotCreateDateTime),
					LotDecisionResult = ISNULL(SourceTable.LotDecisionResult,TargetTable.LotDecisionResult),
					GradeCode = ISNULL(SourceTable.GradeCode,TargetTable.GradeCode),
					GradeChangeJobDate = ISNULL(SourceTable.GradeChangeJobDate,TargetTable.GradeChangeJobDate),
					GradeChangeShiftCode = ISNULL(SourceTable.GradeChangeShiftCode,TargetTable.GradeChangeShiftCode),
					GradeChangeDateTime = ISNULL(SourceTable.GradeChangeDateTime,TargetTable.GradeChangeDateTime),
					GradeChangeUserID = ISNULL(SourceTable.GradeChangeUserID,TargetTable.GradeChangeUserID),
					GradeModelCode = ISNULL(SourceTable.GradeModelCode,TargetTable.GradeModelCode),
					GradeChangeSetNo = ISNULL(SourceTable.GradeChangeSetNo,TargetTable.GradeChangeSetNo),
					PrintDate = ISNULL(SourceTable.PrintDate,TargetTable.PrintDate),
					LineOutTactTime = ISNULL(SourceTable.LineOutTactTime,TargetTable.LineOutTactTime),
					ProdQty = ISNULL(SourceTable.ProdQty,TargetTable.ProdQty),
					SIExtText01 = ISNULL(SourceTable.SIExtText01,TargetTable.SIExtText01),
					SIExtText02 = ISNULL(SourceTable.SIExtText02,TargetTable.SIExtText02),
					SIExtText03 = ISNULL(SourceTable.SIExtText03,TargetTable.SIExtText03),
					SIExtText04 = ISNULL(SourceTable.SIExtText04,TargetTable.SIExtText04),
					SIExtText05 = ISNULL(SourceTable.SIExtText05,TargetTable.SIExtText05),
					SIExtInt01 = ISNULL(SourceTable.SIExtInt01,TargetTable.SIExtInt01),
					SIExtInt02 = ISNULL(SourceTable.SIExtInt02,TargetTable.SIExtInt02),
					SIExtInt03 = ISNULL(SourceTable.SIExtInt03,TargetTable.SIExtInt03),
					SIExtInt04 = ISNULL(SourceTable.SIExtInt04,TargetTable.SIExtInt04),
					SIExtInt05 = ISNULL(SourceTable.SIExtInt05,TargetTable.SIExtInt05),
					SIExtReal01 = ISNULL(SourceTable.SIExtReal01,TargetTable.SIExtReal01),
					SIExtReal02 = ISNULL(SourceTable.SIExtReal02,TargetTable.SIExtReal02),
					SIExtReal03 = ISNULL(SourceTable.SIExtReal03,TargetTable.SIExtReal03),
					SIExtReal04 = ISNULL(SourceTable.SIExtReal04,TargetTable.SIExtReal04),
					SIExtReal05 = ISNULL(SourceTable.SIExtReal05,TargetTable.SIExtReal05),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ControlNo,
						PONo,
						DayPlanNo,
						MaterialCode,
						SetSeq,
						IsLineInput,
						IsLoss,
						IsDefect,
						CurrentRouteCode,
						InternalProdNo,
						OutSetNo,
						OutSetNoSeq,
						Barcode,
						InputLineCode,
						InputJobDate,
						InputShiftCode,
						InputDateTime,
						DefectQty,
						IsProdFinish,
						ProdFinishJobDate,
						ProdFinishShiftCode,
						ProdFinishDateTime,
						SalesOrderNo,
						SOISequence,
						IsOutboundFinalInspection,
						IsFinalInspection,
						FinalInspectionJobDate,
						FinalInspectionShiftCode,
						FinalInspectionDateTime,
						LotNumber,
						LotCreateDateTime,
						LotDecisionResult,
						GradeCode,
						GradeChangeJobDate,
						GradeChangeShiftCode,
						GradeChangeDateTime,
						GradeChangeUserID,
						GradeModelCode,
						GradeChangeSetNo,
						PrintDate,
						LineOutTactTime,
						ProdQty,
						SIExtText01,
						SIExtText02,
						SIExtText03,
						SIExtText04,
						SIExtText05,
						SIExtInt01,
						SIExtInt02,
						SIExtInt03,
						SIExtInt04,
						SIExtInt05,
						SIExtReal01,
						SIExtReal02,
						SIExtReal03,
						SIExtReal04,
						SIExtReal05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ControlNo,
							SourceTable.PONo,
							SourceTable.DayPlanNo,
							SourceTable.MaterialCode,
							SourceTable.SetSeq,
							SourceTable.IsLineInput,
							SourceTable.IsLoss,
							SourceTable.IsDefect,
							SourceTable.CurrentRouteCode,
							SourceTable.InternalProdNo,
							SourceTable.OutSetNo,
							SourceTable.OutSetNoSeq,
							SourceTable.Barcode,
							SourceTable.InputLineCode,
							SourceTable.InputJobDate,
							SourceTable.InputShiftCode,
							SourceTable.InputDateTime,
							SourceTable.DefectQty,
							SourceTable.IsProdFinish,
							SourceTable.ProdFinishJobDate,
							SourceTable.ProdFinishShiftCode,
							SourceTable.ProdFinishDateTime,
							SourceTable.SalesOrderNo,
							SourceTable.SOISequence,
							SourceTable.IsOutboundFinalInspection,
							SourceTable.IsFinalInspection,
							SourceTable.FinalInspectionJobDate,
							SourceTable.FinalInspectionShiftCode,
							SourceTable.FinalInspectionDateTime,
							SourceTable.LotNumber,
							SourceTable.LotCreateDateTime,
							SourceTable.LotDecisionResult,
							SourceTable.GradeCode,
							SourceTable.GradeChangeJobDate,
							SourceTable.GradeChangeShiftCode,
							SourceTable.GradeChangeDateTime,
							SourceTable.GradeChangeUserID,
							SourceTable.GradeModelCode,
							SourceTable.GradeChangeSetNo,
							SourceTable.PrintDate,
							SourceTable.LineOutTactTime,
							SourceTable.ProdQty,
							SourceTable.SIExtText01,
							SourceTable.SIExtText02,
							SourceTable.SIExtText03,
							SourceTable.SIExtText04,
							SourceTable.SIExtText05,
							SourceTable.SIExtInt01,
							SourceTable.SIExtInt02,
							SourceTable.SIExtInt03,
							SourceTable.SIExtInt04,
							SourceTable.SIExtInt05,
							SourceTable.SIExtReal01,
							SourceTable.SIExtReal02,
							SourceTable.SIExtReal03,
							SourceTable.SIExtReal04,
							SourceTable.SIExtReal05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_SetInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldControlNo IS NULL THEN ControlNo
							    ELSE OldControlNo
							END AS OldControlNo,
							ControlNo,
							PONo,
							DayPlanNo,
							MaterialCode,
							SetSeq,
							IsLineInput,
							IsLoss,
							IsDefect,
							CurrentRouteCode,
							InternalProdNo,
							OutSetNo,
							OutSetNoSeq,
							Barcode,
							InputLineCode,
							InputJobDate,
							InputShiftCode,
							InputDateTime,
							DefectQty,
							IsProdFinish,
							ProdFinishJobDate,
							ProdFinishShiftCode,
							ProdFinishDateTime,
							SalesOrderNo,
							SOISequence,
							IsOutboundFinalInspection,
							IsFinalInspection,
							FinalInspectionJobDate,
							FinalInspectionShiftCode,
							FinalInspectionDateTime,
							LotNumber,
							LotCreateDateTime,
							LotDecisionResult,
							GradeCode,
							GradeChangeJobDate,
							GradeChangeShiftCode,
							GradeChangeDateTime,
							GradeChangeUserID,
							GradeModelCode,
							GradeChangeSetNo,
							PrintDate,
							LineOutTactTime,
							ProdQty,
							SIExtText01,
							SIExtText02,
							SIExtText03,
							SIExtText04,
							SIExtText05,
							SIExtInt01,
							SIExtInt02,
							SIExtInt03,
							SIExtInt04,
							SIExtInt05,
							SIExtReal01,
							SIExtReal02,
							SIExtReal03,
							SIExtReal04,
							SIExtReal05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldControlNo VARCHAR(20),
										ControlNo VARCHAR(20),
										PONo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										SetSeq INT,
										IsLineInput BIT,
										IsLoss BIT,
										IsDefect BIT,
										CurrentRouteCode VARCHAR(20),
										InternalProdNo VARCHAR(50),
										OutSetNo VARCHAR(50),
										OutSetNoSeq INT,
										Barcode VARCHAR(50),
										InputLineCode VARCHAR(20),
										InputJobDate DATETIMEOFFSET,
										InputShiftCode VARCHAR(1),
										InputDateTime DATETIMEOFFSET,
										DefectQty INT,
										IsProdFinish BIT,
										ProdFinishJobDate DATETIMEOFFSET,
										ProdFinishShiftCode VARCHAR(1),
										ProdFinishDateTime DATETIMEOFFSET,
										SalesOrderNo VARCHAR(20),
										SOISequence BIGINT,
										IsOutboundFinalInspection BIT,
										IsFinalInspection BIT,
										FinalInspectionJobDate DATETIMEOFFSET,
										FinalInspectionShiftCode VARCHAR(1),
										FinalInspectionDateTime DATETIMEOFFSET,
										LotNumber VARCHAR(50),
										LotCreateDateTime DATETIMEOFFSET,
										LotDecisionResult VARCHAR(10),
										GradeCode VARCHAR(1),
										GradeChangeJobDate DATETIMEOFFSET,
										GradeChangeShiftCode VARCHAR(1),
										GradeChangeDateTime DATETIMEOFFSET,
										GradeChangeUserID VARCHAR(20),
										GradeModelCode VARCHAR(50),
										GradeChangeSetNo VARCHAR(50),
										PrintDate DATETIMEOFFSET,
										LineOutTactTime NUMERIC(10,3),
										ProdQty NUMERIC(20,5),
										SIExtText01 VARCHAR(50),
										SIExtText02 VARCHAR(50),
										SIExtText03 VARCHAR(50),
										SIExtText04 VARCHAR(50),
										SIExtText05 VARCHAR(50),
										SIExtInt01 BIGINT,
										SIExtInt02 BIGINT,
										SIExtInt03 BIGINT,
										SIExtInt04 BIGINT,
										SIExtInt05 BIGINT,
										SIExtReal01 NUMERIC(20,5),
										SIExtReal02 NUMERIC(20,5),
										SIExtReal03 NUMERIC(20,5),
										SIExtReal04 NUMERIC(20,5),
										SIExtReal05 NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ControlNo = SourceTable.OldControlNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ControlNo = ISNULL(SourceTable.ControlNo,TargetTable.ControlNo),
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					DayPlanNo = ISNULL(SourceTable.DayPlanNo,TargetTable.DayPlanNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					SetSeq = ISNULL(SourceTable.SetSeq,TargetTable.SetSeq),
					IsLineInput = ISNULL(SourceTable.IsLineInput,TargetTable.IsLineInput),
					IsLoss = ISNULL(SourceTable.IsLoss,TargetTable.IsLoss),
					IsDefect = ISNULL(SourceTable.IsDefect,TargetTable.IsDefect),
					CurrentRouteCode = ISNULL(SourceTable.CurrentRouteCode,TargetTable.CurrentRouteCode),
					InternalProdNo = ISNULL(SourceTable.InternalProdNo,TargetTable.InternalProdNo),
					OutSetNo = ISNULL(SourceTable.OutSetNo,TargetTable.OutSetNo),
					OutSetNoSeq = ISNULL(SourceTable.OutSetNoSeq,TargetTable.OutSetNoSeq),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					InputLineCode = ISNULL(SourceTable.InputLineCode,TargetTable.InputLineCode),
					InputJobDate = ISNULL(SourceTable.InputJobDate,TargetTable.InputJobDate),
					InputShiftCode = ISNULL(SourceTable.InputShiftCode,TargetTable.InputShiftCode),
					InputDateTime = ISNULL(SourceTable.InputDateTime,TargetTable.InputDateTime),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					IsProdFinish = ISNULL(SourceTable.IsProdFinish,TargetTable.IsProdFinish),
					ProdFinishJobDate = ISNULL(SourceTable.ProdFinishJobDate,TargetTable.ProdFinishJobDate),
					ProdFinishShiftCode = ISNULL(SourceTable.ProdFinishShiftCode,TargetTable.ProdFinishShiftCode),
					ProdFinishDateTime = ISNULL(SourceTable.ProdFinishDateTime,TargetTable.ProdFinishDateTime),
					SalesOrderNo = ISNULL(SourceTable.SalesOrderNo,TargetTable.SalesOrderNo),
					SOISequence = ISNULL(SourceTable.SOISequence,TargetTable.SOISequence),
					IsOutboundFinalInspection = ISNULL(SourceTable.IsOutboundFinalInspection,TargetTable.IsOutboundFinalInspection),
					IsFinalInspection = ISNULL(SourceTable.IsFinalInspection,TargetTable.IsFinalInspection),
					FinalInspectionJobDate = ISNULL(SourceTable.FinalInspectionJobDate,TargetTable.FinalInspectionJobDate),
					FinalInspectionShiftCode = ISNULL(SourceTable.FinalInspectionShiftCode,TargetTable.FinalInspectionShiftCode),
					FinalInspectionDateTime = ISNULL(SourceTable.FinalInspectionDateTime,TargetTable.FinalInspectionDateTime),
					LotNumber = ISNULL(SourceTable.LotNumber,TargetTable.LotNumber),
					LotCreateDateTime = ISNULL(SourceTable.LotCreateDateTime,TargetTable.LotCreateDateTime),
					LotDecisionResult = ISNULL(SourceTable.LotDecisionResult,TargetTable.LotDecisionResult),
					GradeCode = ISNULL(SourceTable.GradeCode,TargetTable.GradeCode),
					GradeChangeJobDate = ISNULL(SourceTable.GradeChangeJobDate,TargetTable.GradeChangeJobDate),
					GradeChangeShiftCode = ISNULL(SourceTable.GradeChangeShiftCode,TargetTable.GradeChangeShiftCode),
					GradeChangeDateTime = ISNULL(SourceTable.GradeChangeDateTime,TargetTable.GradeChangeDateTime),
					GradeChangeUserID = ISNULL(SourceTable.GradeChangeUserID,TargetTable.GradeChangeUserID),
					GradeModelCode = ISNULL(SourceTable.GradeModelCode,TargetTable.GradeModelCode),
					GradeChangeSetNo = ISNULL(SourceTable.GradeChangeSetNo,TargetTable.GradeChangeSetNo),
					PrintDate = ISNULL(SourceTable.PrintDate,TargetTable.PrintDate),
					LineOutTactTime = ISNULL(SourceTable.LineOutTactTime,TargetTable.LineOutTactTime),
					ProdQty = ISNULL(SourceTable.ProdQty,TargetTable.ProdQty),
					SIExtText01 = ISNULL(SourceTable.SIExtText01,TargetTable.SIExtText01),
					SIExtText02 = ISNULL(SourceTable.SIExtText02,TargetTable.SIExtText02),
					SIExtText03 = ISNULL(SourceTable.SIExtText03,TargetTable.SIExtText03),
					SIExtText04 = ISNULL(SourceTable.SIExtText04,TargetTable.SIExtText04),
					SIExtText05 = ISNULL(SourceTable.SIExtText05,TargetTable.SIExtText05),
					SIExtInt01 = ISNULL(SourceTable.SIExtInt01,TargetTable.SIExtInt01),
					SIExtInt02 = ISNULL(SourceTable.SIExtInt02,TargetTable.SIExtInt02),
					SIExtInt03 = ISNULL(SourceTable.SIExtInt03,TargetTable.SIExtInt03),
					SIExtInt04 = ISNULL(SourceTable.SIExtInt04,TargetTable.SIExtInt04),
					SIExtInt05 = ISNULL(SourceTable.SIExtInt05,TargetTable.SIExtInt05),
					SIExtReal01 = ISNULL(SourceTable.SIExtReal01,TargetTable.SIExtReal01),
					SIExtReal02 = ISNULL(SourceTable.SIExtReal02,TargetTable.SIExtReal02),
					SIExtReal03 = ISNULL(SourceTable.SIExtReal03,TargetTable.SIExtReal03),
					SIExtReal04 = ISNULL(SourceTable.SIExtReal04,TargetTable.SIExtReal04),
					SIExtReal05 = ISNULL(SourceTable.SIExtReal05,TargetTable.SIExtReal05),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ControlNo,
						PONo,
						DayPlanNo,
						MaterialCode,
						SetSeq,
						IsLineInput,
						IsLoss,
						IsDefect,
						CurrentRouteCode,
						InternalProdNo,
						OutSetNo,
						OutSetNoSeq,
						Barcode,
						InputLineCode,
						InputJobDate,
						InputShiftCode,
						InputDateTime,
						DefectQty,
						IsProdFinish,
						ProdFinishJobDate,
						ProdFinishShiftCode,
						ProdFinishDateTime,
						SalesOrderNo,
						SOISequence,
						IsOutboundFinalInspection,
						IsFinalInspection,
						FinalInspectionJobDate,
						FinalInspectionShiftCode,
						FinalInspectionDateTime,
						LotNumber,
						LotCreateDateTime,
						LotDecisionResult,
						GradeCode,
						GradeChangeJobDate,
						GradeChangeShiftCode,
						GradeChangeDateTime,
						GradeChangeUserID,
						GradeModelCode,
						GradeChangeSetNo,
						PrintDate,
						LineOutTactTime,
						ProdQty,
						SIExtText01,
						SIExtText02,
						SIExtText03,
						SIExtText04,
						SIExtText05,
						SIExtInt01,
						SIExtInt02,
						SIExtInt03,
						SIExtInt04,
						SIExtInt05,
						SIExtReal01,
						SIExtReal02,
						SIExtReal03,
						SIExtReal04,
						SIExtReal05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ControlNo,
							SourceTable.PONo,
							SourceTable.DayPlanNo,
							SourceTable.MaterialCode,
							SourceTable.SetSeq,
							SourceTable.IsLineInput,
							SourceTable.IsLoss,
							SourceTable.IsDefect,
							SourceTable.CurrentRouteCode,
							SourceTable.InternalProdNo,
							SourceTable.OutSetNo,
							SourceTable.OutSetNoSeq,
							SourceTable.Barcode,
							SourceTable.InputLineCode,
							SourceTable.InputJobDate,
							SourceTable.InputShiftCode,
							SourceTable.InputDateTime,
							SourceTable.DefectQty,
							SourceTable.IsProdFinish,
							SourceTable.ProdFinishJobDate,
							SourceTable.ProdFinishShiftCode,
							SourceTable.ProdFinishDateTime,
							SourceTable.SalesOrderNo,
							SourceTable.SOISequence,
							SourceTable.IsOutboundFinalInspection,
							SourceTable.IsFinalInspection,
							SourceTable.FinalInspectionJobDate,
							SourceTable.FinalInspectionShiftCode,
							SourceTable.FinalInspectionDateTime,
							SourceTable.LotNumber,
							SourceTable.LotCreateDateTime,
							SourceTable.LotDecisionResult,
							SourceTable.GradeCode,
							SourceTable.GradeChangeJobDate,
							SourceTable.GradeChangeShiftCode,
							SourceTable.GradeChangeDateTime,
							SourceTable.GradeChangeUserID,
							SourceTable.GradeModelCode,
							SourceTable.GradeChangeSetNo,
							SourceTable.PrintDate,
							SourceTable.LineOutTactTime,
							SourceTable.ProdQty,
							SourceTable.SIExtText01,
							SourceTable.SIExtText02,
							SourceTable.SIExtText03,
							SourceTable.SIExtText04,
							SourceTable.SIExtText05,
							SourceTable.SIExtInt01,
							SourceTable.SIExtInt02,
							SourceTable.SIExtInt03,
							SourceTable.SIExtInt04,
							SourceTable.SIExtInt05,
							SourceTable.SIExtReal01,
							SourceTable.SIExtReal02,
							SourceTable.SIExtReal03,
							SourceTable.SIExtReal04,
							SourceTable.SIExtReal05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_SetInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldControlNo IS NULL THEN ControlNo
							    ELSE OldControlNo
							END AS OldControlNo,
							ControlNo,
							PONo,
							DayPlanNo,
							MaterialCode,
							SetSeq,
							IsLineInput,
							IsLoss,
							IsDefect,
							CurrentRouteCode,
							InternalProdNo,
							OutSetNo,
							OutSetNoSeq,
							Barcode,
							InputLineCode,
							InputJobDate,
							InputShiftCode,
							InputDateTime,
							DefectQty,
							IsProdFinish,
							ProdFinishJobDate,
							ProdFinishShiftCode,
							ProdFinishDateTime,
							SalesOrderNo,
							SOISequence,
							IsOutboundFinalInspection,
							IsFinalInspection,
							FinalInspectionJobDate,
							FinalInspectionShiftCode,
							FinalInspectionDateTime,
							LotNumber,
							LotCreateDateTime,
							LotDecisionResult,
							GradeCode,
							GradeChangeJobDate,
							GradeChangeShiftCode,
							GradeChangeDateTime,
							GradeChangeUserID,
							GradeModelCode,
							GradeChangeSetNo,
							PrintDate,
							LineOutTactTime,
							ProdQty,
							SIExtText01,
							SIExtText02,
							SIExtText03,
							SIExtText04,
							SIExtText05,
							SIExtInt01,
							SIExtInt02,
							SIExtInt03,
							SIExtInt04,
							SIExtInt05,
							SIExtReal01,
							SIExtReal02,
							SIExtReal03,
							SIExtReal04,
							SIExtReal05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldControlNo VARCHAR(20),
										ControlNo VARCHAR(20),
										PONo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										SetSeq INT,
										IsLineInput BIT,
										IsLoss BIT,
										IsDefect BIT,
										CurrentRouteCode VARCHAR(20),
										InternalProdNo VARCHAR(50),
										OutSetNo VARCHAR(50),
										OutSetNoSeq INT,
										Barcode VARCHAR(50),
										InputLineCode VARCHAR(20),
										InputJobDate DATETIMEOFFSET,
										InputShiftCode VARCHAR(1),
										InputDateTime DATETIMEOFFSET,
										DefectQty INT,
										IsProdFinish BIT,
										ProdFinishJobDate DATETIMEOFFSET,
										ProdFinishShiftCode VARCHAR(1),
										ProdFinishDateTime DATETIMEOFFSET,
										SalesOrderNo VARCHAR(20),
										SOISequence BIGINT,
										IsOutboundFinalInspection BIT,
										IsFinalInspection BIT,
										FinalInspectionJobDate DATETIMEOFFSET,
										FinalInspectionShiftCode VARCHAR(1),
										FinalInspectionDateTime DATETIMEOFFSET,
										LotNumber VARCHAR(50),
										LotCreateDateTime DATETIMEOFFSET,
										LotDecisionResult VARCHAR(10),
										GradeCode VARCHAR(1),
										GradeChangeJobDate DATETIMEOFFSET,
										GradeChangeShiftCode VARCHAR(1),
										GradeChangeDateTime DATETIMEOFFSET,
										GradeChangeUserID VARCHAR(20),
										GradeModelCode VARCHAR(50),
										GradeChangeSetNo VARCHAR(50),
										PrintDate DATETIMEOFFSET,
										LineOutTactTime NUMERIC(10,3),
										ProdQty NUMERIC(20,5),
										SIExtText01 VARCHAR(50),
										SIExtText02 VARCHAR(50),
										SIExtText03 VARCHAR(50),
										SIExtText04 VARCHAR(50),
										SIExtText05 VARCHAR(50),
										SIExtInt01 BIGINT,
										SIExtInt02 BIGINT,
										SIExtInt03 BIGINT,
										SIExtInt04 BIGINT,
										SIExtInt05 BIGINT,
										SIExtReal01 NUMERIC(20,5),
										SIExtReal02 NUMERIC(20,5),
										SIExtReal03 NUMERIC(20,5),
										SIExtReal04 NUMERIC(20,5),
										SIExtReal05 NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ControlNo = SourceTable.ControlNo
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
									OldControlNo,
									ControlNo,
									PONo,
									DayPlanNo,
									MaterialCode,
									SetSeq,
									IsLineInput,
									IsLoss,
									IsDefect,
									CurrentRouteCode,
									InternalProdNo,
									OutSetNo,
									OutSetNoSeq,
									Barcode,
									InputLineCode,
									InputJobDate,
									InputShiftCode,
									InputDateTime,
									DefectQty,
									IsProdFinish,
									ProdFinishJobDate,
									ProdFinishShiftCode,
									ProdFinishDateTime,
									SalesOrderNo,
									SOISequence,
									IsOutboundFinalInspection,
									IsFinalInspection,
									FinalInspectionJobDate,
									FinalInspectionShiftCode,
									FinalInspectionDateTime,
									LotNumber,
									LotCreateDateTime,
									LotDecisionResult,
									GradeCode,
									GradeChangeJobDate,
									GradeChangeShiftCode,
									GradeChangeDateTime,
									GradeChangeUserID,
									GradeModelCode,
									GradeChangeSetNo,
									PrintDate,
									LineOutTactTime,
									ProdQty,
									SIExtText01,
									SIExtText02,
									SIExtText03,
									SIExtText04,
									SIExtText05,
									SIExtInt01,
									SIExtInt02,
									SIExtInt03,
									SIExtInt04,
									SIExtInt05,
									SIExtReal01,
									SIExtReal02,
									SIExtReal03,
									SIExtReal04,
									SIExtReal05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MixBatchNo,
									EDLC
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 ControlNo VARCHAR(20),
											 PONo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 SetSeq INT,
											 IsLineInput BIT,
											 IsLoss BIT,
											 IsDefect BIT,
											 CurrentRouteCode VARCHAR(20),
											 InternalProdNo VARCHAR(50),
											 OutSetNo VARCHAR(50),
											 OutSetNoSeq INT,
											 Barcode VARCHAR(50),
											 InputLineCode VARCHAR(20),
											 InputJobDate DATETIMEOFFSET,
											 InputShiftCode VARCHAR(1),
											 InputDateTime DATETIMEOFFSET,
											 DefectQty INT,
											 IsProdFinish BIT,
											 ProdFinishJobDate DATETIMEOFFSET,
											 ProdFinishShiftCode VARCHAR(1),
											 ProdFinishDateTime DATETIMEOFFSET,
											 SalesOrderNo VARCHAR(20),
											 SOISequence BIGINT,
											 IsOutboundFinalInspection BIT,
											 IsFinalInspection BIT,
											 FinalInspectionJobDate DATETIMEOFFSET,
											 FinalInspectionShiftCode VARCHAR(1),
											 FinalInspectionDateTime DATETIMEOFFSET,
											 LotNumber VARCHAR(50),
											 LotCreateDateTime DATETIMEOFFSET,
											 LotDecisionResult VARCHAR(10),
											 GradeCode VARCHAR(1),
											 GradeChangeJobDate DATETIMEOFFSET,
											 GradeChangeShiftCode VARCHAR(1),
											 GradeChangeDateTime DATETIMEOFFSET,
											 GradeChangeUserID VARCHAR(20),
											 GradeModelCode VARCHAR(50),
											 GradeChangeSetNo VARCHAR(50),
											 PrintDate DATETIMEOFFSET,
											 LineOutTactTime NUMERIC(10,3),
											 ProdQty NUMERIC(20,5),
											 SIExtText01 VARCHAR(50),
											 SIExtText02 VARCHAR(50),
											 SIExtText03 VARCHAR(50),
											 SIExtText04 VARCHAR(50),
											 SIExtText05 VARCHAR(50),
											 SIExtInt01 BIGINT,
											 SIExtInt02 BIGINT,
											 SIExtInt03 BIGINT,
											 SIExtInt04 BIGINT,
											 SIExtInt05 BIGINT,
											 SIExtReal01 NUMERIC(20,5),
											 SIExtReal02 NUMERIC(20,5),
											 SIExtReal03 NUMERIC(20,5),
											 SIExtReal04 NUMERIC(20,5),
											 SIExtReal05 NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MixBatchNo INT,
											 EDLC VARCHAR(1)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 	WHEN OldControlNo IS NULL THEN ControlNo	ELSE OldControlNo	 END  AS OldControlNo,
									ControlNo,
									PONo,
									DayPlanNo,
									MaterialCode,
									SetSeq,
									IsLineInput,
									IsLoss,
									IsDefect,
									CurrentRouteCode,
									InternalProdNo,
									OutSetNo,
									OutSetNoSeq,
									Barcode,
									InputLineCode,
									InputJobDate,
									InputShiftCode,
									InputDateTime,
									DefectQty,
									IsProdFinish,
									ProdFinishJobDate,
									ProdFinishShiftCode,
									ProdFinishDateTime,
									SalesOrderNo,
									SOISequence,
									IsOutboundFinalInspection,
									IsFinalInspection,
									FinalInspectionJobDate,
									FinalInspectionShiftCode,
									FinalInspectionDateTime,
									LotNumber,
									LotCreateDateTime,
									LotDecisionResult,
									GradeCode,
									GradeChangeJobDate,
									GradeChangeShiftCode,
									GradeChangeDateTime,
									GradeChangeUserID,
									GradeModelCode,
									GradeChangeSetNo,
									PrintDate,
									LineOutTactTime,
									ProdQty,
									SIExtText01,
									SIExtText02,
									SIExtText03,
									SIExtText04,
									SIExtText05,
									SIExtInt01,
									SIExtInt02,
									SIExtInt03,
									SIExtInt04,
									SIExtInt05,
									SIExtReal01,
									SIExtReal02,
									SIExtReal03,
									SIExtReal04,
									SIExtReal05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MixBatchNo,
									EDLC
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 ControlNo VARCHAR(20),
											 PONo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 SetSeq INT,
											 IsLineInput BIT,
											 IsLoss BIT,
											 IsDefect BIT,
											 CurrentRouteCode VARCHAR(20),
											 InternalProdNo VARCHAR(50),
											 OutSetNo VARCHAR(50),
											 OutSetNoSeq INT,
											 Barcode VARCHAR(50),
											 InputLineCode VARCHAR(20),
											 InputJobDate DATETIMEOFFSET,
											 InputShiftCode VARCHAR(1),
											 InputDateTime DATETIMEOFFSET,
											 DefectQty INT,
											 IsProdFinish BIT,
											 ProdFinishJobDate DATETIMEOFFSET,
											 ProdFinishShiftCode VARCHAR(1),
											 ProdFinishDateTime DATETIMEOFFSET,
											 SalesOrderNo VARCHAR(20),
											 SOISequence BIGINT,
											 IsOutboundFinalInspection BIT,
											 IsFinalInspection BIT,
											 FinalInspectionJobDate DATETIMEOFFSET,
											 FinalInspectionShiftCode VARCHAR(1),
											 FinalInspectionDateTime DATETIMEOFFSET,
											 LotNumber VARCHAR(50),
											 LotCreateDateTime DATETIMEOFFSET,
											 LotDecisionResult VARCHAR(10),
											 GradeCode VARCHAR(1),
											 GradeChangeJobDate DATETIMEOFFSET,
											 GradeChangeShiftCode VARCHAR(1),
											 GradeChangeDateTime DATETIMEOFFSET,
											 GradeChangeUserID VARCHAR(20),
											 GradeModelCode VARCHAR(50),
											 GradeChangeSetNo VARCHAR(50),
											 PrintDate DATETIMEOFFSET,
											 LineOutTactTime NUMERIC(10,3),
											 ProdQty NUMERIC(20,5),
											 SIExtText01 VARCHAR(50),
											 SIExtText02 VARCHAR(50),
											 SIExtText03 VARCHAR(50),
											 SIExtText04 VARCHAR(50),
											 SIExtText05 VARCHAR(50),
											 SIExtInt01 BIGINT,
											 SIExtInt02 BIGINT,
											 SIExtInt03 BIGINT,
											 SIExtInt04 BIGINT,
											 SIExtInt05 BIGINT,
											 SIExtReal01 NUMERIC(20,5),
											 SIExtReal02 NUMERIC(20,5),
											 SIExtReal03 NUMERIC(20,5),
											 SIExtReal04 NUMERIC(20,5),
											 SIExtReal05 NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MixBatchNo INT,
											 EDLC VARCHAR(1)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldControlNo IS NULL THEN ControlNo
										ELSE OldControlNo
									END AS OldControlNo,
									ControlNo,
									PONo,
									DayPlanNo,
									MaterialCode,
									SetSeq,
									IsLineInput,
									IsLoss,
									IsDefect,
									CurrentRouteCode,
									InternalProdNo,
									OutSetNo,
									OutSetNoSeq,
									Barcode,
									InputLineCode,
									InputJobDate,
									InputShiftCode,
									InputDateTime,
									DefectQty,
									IsProdFinish,
									ProdFinishJobDate,
									ProdFinishShiftCode,
									ProdFinishDateTime,
									SalesOrderNo,
									SOISequence,
									IsOutboundFinalInspection,
									IsFinalInspection,
									FinalInspectionJobDate,
									FinalInspectionShiftCode,
									FinalInspectionDateTime,
									LotNumber,
									LotCreateDateTime,
									LotDecisionResult,
									GradeCode,
									GradeChangeJobDate,
									GradeChangeShiftCode,
									GradeChangeDateTime,
									GradeChangeUserID,
									GradeModelCode,
									GradeChangeSetNo,
									PrintDate,
									LineOutTactTime,
									ProdQty,
									SIExtText01,
									SIExtText02,
									SIExtText03,
									SIExtText04,
									SIExtText05,
									SIExtInt01,
									SIExtInt02,
									SIExtInt03,
									SIExtInt04,
									SIExtInt05,
									SIExtReal01,
									SIExtReal02,
									SIExtReal03,
									SIExtReal04,
									SIExtReal05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MixBatchNo,
									EDLC
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 ControlNo VARCHAR(20),
											 PONo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 SetSeq INT,
											 IsLineInput BIT,
											 IsLoss BIT,
											 IsDefect BIT,
											 CurrentRouteCode VARCHAR(20),
											 InternalProdNo VARCHAR(50),
											 OutSetNo VARCHAR(50),
											 OutSetNoSeq INT,
											 Barcode VARCHAR(50),
											 InputLineCode VARCHAR(20),
											 InputJobDate DATETIMEOFFSET,
											 InputShiftCode VARCHAR(1),
											 InputDateTime DATETIMEOFFSET,
											 DefectQty INT,
											 IsProdFinish BIT,
											 ProdFinishJobDate DATETIMEOFFSET,
											 ProdFinishShiftCode VARCHAR(1),
											 ProdFinishDateTime DATETIMEOFFSET,
											 SalesOrderNo VARCHAR(20),
											 SOISequence BIGINT,
											 IsOutboundFinalInspection BIT,
											 IsFinalInspection BIT,
											 FinalInspectionJobDate DATETIMEOFFSET,
											 FinalInspectionShiftCode VARCHAR(1),
											 FinalInspectionDateTime DATETIMEOFFSET,
											 LotNumber VARCHAR(50),
											 LotCreateDateTime DATETIMEOFFSET,
											 LotDecisionResult VARCHAR(10),
											 GradeCode VARCHAR(1),
											 GradeChangeJobDate DATETIMEOFFSET,
											 GradeChangeShiftCode VARCHAR(1),
											 GradeChangeDateTime DATETIMEOFFSET,
											 GradeChangeUserID VARCHAR(20),
											 GradeModelCode VARCHAR(50),
											 GradeChangeSetNo VARCHAR(50),
											 PrintDate DATETIMEOFFSET,
											 LineOutTactTime NUMERIC(10,3),
											 ProdQty NUMERIC(20,5),
											 SIExtText01 VARCHAR(50),
											 SIExtText02 VARCHAR(50),
											 SIExtText03 VARCHAR(50),
											 SIExtText04 VARCHAR(50),
											 SIExtText05 VARCHAR(50),
											 SIExtInt01 BIGINT,
											 SIExtInt02 BIGINT,
											 SIExtInt03 BIGINT,
											 SIExtInt04 BIGINT,
											 SIExtInt05 BIGINT,
											 SIExtReal01 NUMERIC(20,5),
											 SIExtReal02 NUMERIC(20,5),
											 SIExtReal03 NUMERIC(20,5),
											 SIExtReal04 NUMERIC(20,5),
											 SIExtReal05 NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MixBatchNo INT,
											 EDLC VARCHAR(1)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldControlNo,
								 @ControlNo,
								 @PONo,
								 @DayPlanNo,
								 @MaterialCode,
								 @SetSeq,
								 @IsLineInput,
								 @IsLoss,
								 @IsDefect,
								 @CurrentRouteCode,
								 @InternalProdNo,
								 @OutSetNo,
								 @OutSetNoSeq,
								 @Barcode,
								 @InputLineCode,
								 @InputJobDate,
								 @InputShiftCode,
								 @InputDateTime,
								 @DefectQty,
								 @IsProdFinish,
								 @ProdFinishJobDate,
								 @ProdFinishShiftCode,
								 @ProdFinishDateTime,
								 @SalesOrderNo,
								 @SOISequence,
								 @IsOutboundFinalInspection,
								 @IsFinalInspection,
								 @FinalInspectionJobDate,
								 @FinalInspectionShiftCode,
								 @FinalInspectionDateTime,
								 @LotNumber,
								 @LotCreateDateTime,
								 @LotDecisionResult,
								 @GradeCode,
								 @GradeChangeJobDate,
								 @GradeChangeShiftCode,
								 @GradeChangeDateTime,
								 @GradeChangeUserID,
								 @GradeModelCode,
								 @GradeChangeSetNo,
								 @PrintDate,
								 @LineOutTactTime,
								 @ProdQty,
								 @SIExtText01,
								 @SIExtText02,
								 @SIExtText03,
								 @SIExtText04,
								 @SIExtText05,
								 @SIExtInt01,
								 @SIExtInt02,
								 @SIExtInt03,
								 @SIExtInt04,
								 @SIExtInt05,
								 @SIExtReal01,
								 @SIExtReal02,
								 @SIExtReal03,
								 @SIExtReal04,
								 @SIExtReal05,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @MixBatchNo,
								 @EDLC


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				DECLARE @CurrentIsLineInput BIT

				-- 롤프레스 번호 추가
				Declare @EDLCnRollPress VARCHAR(10) = @EDLC + ISNULL(@SIExtText02, '')

				SELECT
						@CurrentIsLineInput = SI.IsLineInput
				FROM
						STB_SetInfo SI
				WHERE
						SI.ControlNo = @ControlNo

                IF @IUD_FLAG = 'INSERT' 
				
				BEGIN
					DECLARE @IsFixed BIT
					DECLARE @IsCancel BIT

					SELECT
							@IsFixed = DPP.IsFixed,
							@IsCancel = DPP.IsCancel
					FROM
							STB_DayProdPlan DPP
					WHERE
							DPP.DayPlanNo = @DayPlanNo

					IF ISNULL(@IsFixed,0) = 0 OR ISNULL(@IsCancel,0) = 1 
					
						BEGIN
								EXEC usp_RaiseLocalizedError @pProcessLanguage, '미확정 또는 취소된 계획은 Lot을 생성할수 없습니다'
						END

                    IF @IsAutoKey = 1 
					
					BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SetInfo',@ControlNo OUTPUT
                    END


					-- 생산 코팅롤 생성 프로시저 !!!
					EXEC usp_DoCreateSetInfoForCoatingRoll_VNT	@pProcessUserID = @ProcessUserID,
																				@pProcessLanguage = @ProcessLanguage,
																				@pPONo = @PONo,
																				@pDayPlanNo = @DayPlanNo,
																				@pProdQty = @ProdQty,
																				@pThickness = @SIExtReal03,
																				@pMixBatchNo = @MixBatchNo,
																				@pEDLC = @EDLCnRollPress,
																				@pCompanyCode = @CompanyCode

				END ELSE IF @IUD_FLAG = 'UPDATE' 
				
				BEGIN
					IF ISNULL(@CurrentIsLineInput,0) = 1 
				
					BEGIN
							EXEC usp_RaiseLocalizedError @pProcessLanguage,'이미 투입된 Lot은 변경할수 없습니다'
					END
					
					-- 2026-03-23 Insert history because Electrode Team delete lot
					INSERT INTO STB_ElectrodeSetInfoHist(OldControlNo, ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, Flag, CreateDateTime, CreateUserID) 
					VALUES (@OldControlNo, @ControlNo, @PONo, @DayPlanNo, @MaterialCode, @Barcode, @IUD_FLAG, GETDATE(), @pProcessUserID)

                    UPDATE STB_SetInfo
						SET
						    ControlNo =   ISNULL(@ControlNo,ControlNo),
						    PONo =   ISNULL(@PONo,PONo),
						    DayPlanNo =   ISNULL(@DayPlanNo,DayPlanNo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    SetSeq =   ISNULL(@SetSeq,SetSeq),
						    IsLineInput =   ISNULL(@IsLineInput,IsLineInput),
						    IsLoss =   ISNULL(@IsLoss,IsLoss),
						    IsDefect =   ISNULL(@IsDefect,IsDefect),
						    CurrentRouteCode =   ISNULL(@CurrentRouteCode,CurrentRouteCode),
						    InternalProdNo =   ISNULL(@InternalProdNo,InternalProdNo),
						    OutSetNo =   ISNULL(@OutSetNo,OutSetNo),
						    OutSetNoSeq =   ISNULL(@OutSetNoSeq,OutSetNoSeq),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    InputLineCode =   ISNULL(@InputLineCode,InputLineCode),
						    InputJobDate =   ISNULL(@InputJobDate,InputJobDate),
						    InputShiftCode =   ISNULL(@InputShiftCode,InputShiftCode),
						    InputDateTime =   ISNULL(@InputDateTime,InputDateTime),
						    DefectQty =   ISNULL(@DefectQty,DefectQty),
						    IsProdFinish =   ISNULL(@IsProdFinish,IsProdFinish),
						    ProdFinishJobDate =   ISNULL(@ProdFinishJobDate,ProdFinishJobDate),
						    ProdFinishShiftCode =   ISNULL(@ProdFinishShiftCode,ProdFinishShiftCode),
						    ProdFinishDateTime =   ISNULL(@ProdFinishDateTime,ProdFinishDateTime),
						    SalesOrderNo =   ISNULL(@SalesOrderNo,SalesOrderNo),
						    SOISequence =   ISNULL(@SOISequence,SOISequence),
						    IsOutboundFinalInspection =   ISNULL(@IsOutboundFinalInspection,IsOutboundFinalInspection),
						    IsFinalInspection =   ISNULL(@IsFinalInspection,IsFinalInspection),
						    FinalInspectionJobDate =   ISNULL(@FinalInspectionJobDate,FinalInspectionJobDate),
						    FinalInspectionShiftCode =   ISNULL(@FinalInspectionShiftCode,FinalInspectionShiftCode),
						    FinalInspectionDateTime =   ISNULL(@FinalInspectionDateTime,FinalInspectionDateTime),
						    LotNumber =   ISNULL(@LotNumber,LotNumber),
						    LotCreateDateTime =   ISNULL(@LotCreateDateTime,LotCreateDateTime),
						    LotDecisionResult =   ISNULL(@LotDecisionResult,LotDecisionResult),
						    GradeCode =   ISNULL(@GradeCode,GradeCode),
						    GradeChangeJobDate =   ISNULL(@GradeChangeJobDate,GradeChangeJobDate),
						    GradeChangeShiftCode =   ISNULL(@GradeChangeShiftCode,GradeChangeShiftCode),
						    GradeChangeDateTime =   ISNULL(@GradeChangeDateTime,GradeChangeDateTime),
						    GradeChangeUserID =   ISNULL(@GradeChangeUserID,GradeChangeUserID),
						    GradeModelCode =   ISNULL(@GradeModelCode,GradeModelCode),
						    GradeChangeSetNo =   ISNULL(@GradeChangeSetNo,GradeChangeSetNo),
						    PrintDate =   ISNULL(@PrintDate,PrintDate),
						    LineOutTactTime =   ISNULL(@LineOutTactTime,LineOutTactTime),
						    ProdQty =   ISNULL(@ProdQty,ProdQty),
						    SIExtText01 =   ISNULL(@SIExtText01,SIExtText01),
						    SIExtText02 =   ISNULL(@SIExtText02,SIExtText02),
						    SIExtText03 =   ISNULL(@SIExtText03,SIExtText03),
						    SIExtText04 =   ISNULL(@SIExtText04,SIExtText04),
						    SIExtText05 =   ISNULL(@SIExtText05,SIExtText05),
						    SIExtInt01 =   ISNULL(@SIExtInt01,SIExtInt01),
						    SIExtInt02 =   ISNULL(@SIExtInt02,SIExtInt02),
						    SIExtInt03 =   ISNULL(@SIExtInt03,SIExtInt03),
						    SIExtInt04 =   ISNULL(@SIExtInt04,SIExtInt04),
						    SIExtInt05 =   ISNULL(@SIExtInt05,SIExtInt05),
						    SIExtReal01 =   ISNULL(@SIExtReal01,SIExtReal01),
						    SIExtReal02 =   ISNULL(@SIExtReal02,SIExtReal02),
						    SIExtReal03 =   ISNULL(@SIExtReal03,SIExtReal03),
						    SIExtReal04 =   ISNULL(@SIExtReal04,SIExtReal04),
						    SIExtReal05 =   ISNULL(@SIExtReal05,SIExtReal05),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ControlNo = @OldControlNo
                
				END ELSE IF @IUD_FLAG = 'DELETE' 
				
				BEGIN
					IF ISNULL(@CurrentIsLineInput,0) = 1 
					
					BEGIN
							EXEC usp_RaiseLocalizedError @pProcessLanguage,'Lock khong the xoa lot da scan vao line'
					END

					IF (@CompanyCode = 'VVT' AND @pProcessUserID NOT IN ('HaiTrieu','DinhManh'))
					BEGIN
						RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1);
						RETURN;
					END

					INSERT INTO STB_ElectrodeSetInfoHist(OldControlNo, ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, Flag, CreateDateTime, CreateUserID) 
					VALUES (@OldControlNo, @ControlNo, @PONo, @DayPlanNo, @MaterialCode, @Barcode, @IUD_FLAG, GETDATE(), @pProcessUserID)

                    DELETE FROM STB_SetInfo
						WHERE
						    ControlNo = @OldControlNo
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

PRINT 'Procedure usp_SetInfo_HY_iud_VNT created successfully.';
GO

COMMIT TRAN;
PRINT 'Transaction COMMIT successfully. Stored procedures created.';
-- ROLLBACK
GO
