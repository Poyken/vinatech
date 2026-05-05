
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayProdPlan_iud]
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

  -- #240612
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
