
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2022-04-06
-- Browsable : true
-- Group : 생산관리>생산실적 >  불량현황수정용
-- Description:	iud수정용
-- Modified:
-- =============================================
CREATE PROCEDURE  [dbo].[usp_Bad_RouteHistModify_iud]
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
  DECLARE @OldDefectSummaryNo VARCHAR(20)
  DECLARE @DefectSummaryNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @ControlNo VARCHAR(20)
  DECLARE @PONo VARCHAR(20)
  DECLARE @DayPlanNo VARCHAR(20)
  DECLARE @FindJobdate DATE
  DECLARE @FindShiftCode VARCHAR(1)
  DECLARE @FindTimeCode VARCHAR(2)
  DECLARE @FindLineCode VARCHAR(20)
  DECLARE @FindRouteCode VARCHAR(20)
  DECLARE @FindSubRouteCode VARCHAR(20)
  DECLARE @FindFacilityRouteCode VARCHAR(20)
  DECLARE @CauseJobDate DATE
  DECLARE @CauseShiftCode VARCHAR(1)
  DECLARE @CauseTimeCode VARCHAR(2)
  DECLARE @CauseLineCode VARCHAR(20)
  DECLARE @CauseFacilityRouteCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(10)
  DECLARE @FindDateTime DATETIME
  DECLARE @DefectCauseType VARCHAR(1)
  DECLARE @DutyCostCenterCode VARCHAR(20)
  DECLARE @DutyVendorCode VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @DefectCauseCode VARCHAR(20)
  DECLARE @DefectCauseDetailCode VARCHAR(20)
  DECLARE @DefectExtDesc NVARCHAR(200)
  DECLARE @RepairType VARCHAR(10)
  DECLARE @RepairUserID VARCHAR(20)
  DECLARE @RepairDateTime DATETIME
  DECLARE @RepairDesc NVARCHAR(MAX)
  DECLARE @DefectQty NUMERIC(20,5)
  DECLARE @RepairQty NUMERIC(20,5)
  DECLARE @LossQty NUMERIC(20,5)
  DECLARE @FileID BIGINT
  DECLARE @DRIExtText01 NVARCHAR(200)
  DECLARE @DRIExtText02 NVARCHAR(200)
  DECLARE @DRIExtText03 NVARCHAR(200)
  DECLARE @IsDelete VARCHAR(1)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_DefectRepairInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 
	
	BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DefectRepairInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectSummaryNo IS NULL THEN DefectSummaryNo
							    ELSE OldDefectSummaryNo
							END AS OldDefectSummaryNo,
							DefectSummaryNo,
							CompanyCode,
							WorkCenterCode,
							ControlNo,
							PONo,
							DayPlanNo,
							FindJobdate,
							FindShiftCode,
							FindTimeCode,
							FindLineCode,
							FindRouteCode,
							FindSubRouteCode,
							FindFacilityRouteCode,
							CauseJobDate,
							CauseShiftCode,
							CauseTimeCode,
							CauseLineCode,
							CauseFacilityRouteCode,
							MaterialCode,
							BomVersion,
							FindDateTime,
							DefectCauseType,
							DutyCostCenterCode,
							DutyVendorCode,
							DefectCode,
							DefectCauseCode,
							DefectCauseDetailCode,
							DefectExtDesc,
							RepairType,
							RepairUserID,
							RepairDateTime,
							RepairDesc,
							DefectQty,
							RepairQty,
							LossQty,
							FileID,
							DRIExtText01,
							DRIExtText02,
							DRIExtText03,
							IsDelete,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectSummaryNo VARCHAR(20),
										DefectSummaryNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										ControlNo VARCHAR(20),
										PONo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										FindJobdate DATETIMEOFFSET,
										FindShiftCode VARCHAR(1),
										FindTimeCode VARCHAR(2),
										FindLineCode VARCHAR(20),
										FindRouteCode VARCHAR(20),
										FindSubRouteCode VARCHAR(20),
										FindFacilityRouteCode VARCHAR(20),
										CauseJobDate DATETIMEOFFSET,
										CauseShiftCode VARCHAR(1),
										CauseTimeCode VARCHAR(2),
										CauseLineCode VARCHAR(20),
										CauseFacilityRouteCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(10),
										FindDateTime DATETIMEOFFSET,
										DefectCauseType VARCHAR(1),
										DutyCostCenterCode VARCHAR(20),
										DutyVendorCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectCauseCode VARCHAR(20),
										DefectCauseDetailCode VARCHAR(20),
										DefectExtDesc NVARCHAR(200),
										RepairType VARCHAR(10),
										RepairUserID VARCHAR(20),
										RepairDateTime DATETIMEOFFSET,
										RepairDesc NVARCHAR(MAX),
										DefectQty NUMERIC(20,5),
										RepairQty NUMERIC(20,5),
										LossQty NUMERIC(20,5),
										FileID BIGINT,
										DRIExtText01 NVARCHAR(200),
										DRIExtText02 NVARCHAR(200),
										DRIExtText03 NVARCHAR(200),
										IsDelete VARCHAR(1),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectSummaryNo = SourceTable.DefectSummaryNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectSummaryNo = ISNULL(SourceTable.DefectSummaryNo,TargetTable.DefectSummaryNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					ControlNo = ISNULL(SourceTable.ControlNo,TargetTable.ControlNo),
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					DayPlanNo = ISNULL(SourceTable.DayPlanNo,TargetTable.DayPlanNo),
					FindJobdate = ISNULL(SourceTable.FindJobdate,TargetTable.FindJobdate),
					FindShiftCode = ISNULL(SourceTable.FindShiftCode,TargetTable.FindShiftCode),
					FindTimeCode = ISNULL(SourceTable.FindTimeCode,TargetTable.FindTimeCode),
					FindLineCode = ISNULL(SourceTable.FindLineCode,TargetTable.FindLineCode),
					FindRouteCode = ISNULL(SourceTable.FindRouteCode,TargetTable.FindRouteCode),
					FindSubRouteCode = ISNULL(SourceTable.FindSubRouteCode,TargetTable.FindSubRouteCode),
					FindFacilityRouteCode = ISNULL(SourceTable.FindFacilityRouteCode,TargetTable.FindFacilityRouteCode),
					CauseJobDate = ISNULL(SourceTable.CauseJobDate,TargetTable.CauseJobDate),
					CauseShiftCode = ISNULL(SourceTable.CauseShiftCode,TargetTable.CauseShiftCode),
					CauseTimeCode = ISNULL(SourceTable.CauseTimeCode,TargetTable.CauseTimeCode),
					CauseLineCode = ISNULL(SourceTable.CauseLineCode,TargetTable.CauseLineCode),
					CauseFacilityRouteCode = ISNULL(SourceTable.CauseFacilityRouteCode,TargetTable.CauseFacilityRouteCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					FindDateTime = ISNULL(SourceTable.FindDateTime,TargetTable.FindDateTime),
					DefectCauseType = ISNULL(SourceTable.DefectCauseType,TargetTable.DefectCauseType),
					DutyCostCenterCode = ISNULL(SourceTable.DutyCostCenterCode,TargetTable.DutyCostCenterCode),
					DutyVendorCode = ISNULL(SourceTable.DutyVendorCode,TargetTable.DutyVendorCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectCauseCode = ISNULL(SourceTable.DefectCauseCode,TargetTable.DefectCauseCode),
					DefectCauseDetailCode = ISNULL(SourceTable.DefectCauseDetailCode,TargetTable.DefectCauseDetailCode),
					DefectExtDesc = ISNULL(SourceTable.DefectExtDesc,TargetTable.DefectExtDesc),
					RepairType = ISNULL(SourceTable.RepairType,TargetTable.RepairType),
					RepairUserID = ISNULL(SourceTable.RepairUserID,TargetTable.RepairUserID),
					RepairDateTime = ISNULL(SourceTable.RepairDateTime,TargetTable.RepairDateTime),
					RepairDesc = ISNULL(SourceTable.RepairDesc,TargetTable.RepairDesc),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					RepairQty = ISNULL(SourceTable.RepairQty,TargetTable.RepairQty),
					LossQty = ISNULL(SourceTable.LossQty,TargetTable.LossQty),
					FileID = ISNULL(SourceTable.FileID,TargetTable.FileID),
					DRIExtText01 = ISNULL(SourceTable.DRIExtText01,TargetTable.DRIExtText01),
					DRIExtText02 = ISNULL(SourceTable.DRIExtText02,TargetTable.DRIExtText02),
					DRIExtText03 = ISNULL(SourceTable.DRIExtText03,TargetTable.DRIExtText03),
					IsDelete = ISNULL(SourceTable.IsDelete,TargetTable.IsDelete),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectSummaryNo,
						CompanyCode,
						WorkCenterCode,
						ControlNo,
						PONo,
						DayPlanNo,
						FindJobdate,
						FindShiftCode,
						FindTimeCode,
						FindLineCode,
						FindRouteCode,
						FindSubRouteCode,
						FindFacilityRouteCode,
						CauseJobDate,
						CauseShiftCode,
						CauseTimeCode,
						CauseLineCode,
						CauseFacilityRouteCode,
						MaterialCode,
						BomVersion,
						FindDateTime,
						DefectCauseType,
						DutyCostCenterCode,
						DutyVendorCode,
						DefectCode,
						DefectCauseCode,
						DefectCauseDetailCode,
						DefectExtDesc,
						RepairType,
						RepairUserID,
						RepairDateTime,
						RepairDesc,
						DefectQty,
						RepairQty,
						LossQty,
						FileID,
						DRIExtText01,
						DRIExtText02,
						DRIExtText03,
						IsDelete,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectSummaryNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.ControlNo,
							SourceTable.PONo,
							SourceTable.DayPlanNo,
							SourceTable.FindJobdate,
							SourceTable.FindShiftCode,
							SourceTable.FindTimeCode,
							SourceTable.FindLineCode,
							SourceTable.FindRouteCode,
							SourceTable.FindSubRouteCode,
							SourceTable.FindFacilityRouteCode,
							SourceTable.CauseJobDate,
							SourceTable.CauseShiftCode,
							SourceTable.CauseTimeCode,
							SourceTable.CauseLineCode,
							SourceTable.CauseFacilityRouteCode,
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.FindDateTime,
							SourceTable.DefectCauseType,
							SourceTable.DutyCostCenterCode,
							SourceTable.DutyVendorCode,
							SourceTable.DefectCode,
							SourceTable.DefectCauseCode,
							SourceTable.DefectCauseDetailCode,
							SourceTable.DefectExtDesc,
							SourceTable.RepairType,
							SourceTable.RepairUserID,
							SourceTable.RepairDateTime,
							SourceTable.RepairDesc,
							SourceTable.DefectQty,
							SourceTable.RepairQty,
							SourceTable.LossQty,
							SourceTable.FileID,
							SourceTable.DRIExtText01,
							SourceTable.DRIExtText02,
							SourceTable.DRIExtText03,
							SourceTable.IsDelete,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_DefectRepairInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectSummaryNo IS NULL THEN DefectSummaryNo
							    ELSE OldDefectSummaryNo
							END AS OldDefectSummaryNo,
							DefectSummaryNo,
							CompanyCode,
							WorkCenterCode,
							ControlNo,
							PONo,
							DayPlanNo,
							FindJobdate,
							FindShiftCode,
							FindTimeCode,
							FindLineCode,
							FindRouteCode,
							FindSubRouteCode,
							FindFacilityRouteCode,
							CauseJobDate,
							CauseShiftCode,
							CauseTimeCode,
							CauseLineCode,
							CauseFacilityRouteCode,
							MaterialCode,
							BomVersion,
							FindDateTime,
							DefectCauseType,
							DutyCostCenterCode,
							DutyVendorCode,
							DefectCode,
							DefectCauseCode,
							DefectCauseDetailCode,
							DefectExtDesc,
							RepairType,
							RepairUserID,
							RepairDateTime,
							RepairDesc,
							DefectQty,
							RepairQty,
							LossQty,
							FileID,
							DRIExtText01,
							DRIExtText02,
							DRIExtText03,
							IsDelete,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectSummaryNo VARCHAR(20),
										DefectSummaryNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										ControlNo VARCHAR(20),
										PONo VARCHAR(20),
										DayPlanNo VARCHAR(20),
										FindJobdate DATETIMEOFFSET,
										FindShiftCode VARCHAR(1),
										FindTimeCode VARCHAR(2),
										FindLineCode VARCHAR(20),
										FindRouteCode VARCHAR(20),
										FindSubRouteCode VARCHAR(20),
										FindFacilityRouteCode VARCHAR(20),
										CauseJobDate DATETIMEOFFSET,
										CauseShiftCode VARCHAR(1),
										CauseTimeCode VARCHAR(2),
										CauseLineCode VARCHAR(20),
										CauseFacilityRouteCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(10),
										FindDateTime DATETIMEOFFSET,
										DefectCauseType VARCHAR(1),
										DutyCostCenterCode VARCHAR(20),
										DutyVendorCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectCauseCode VARCHAR(20),
										DefectCauseDetailCode VARCHAR(20),
										DefectExtDesc NVARCHAR(200),
										RepairType VARCHAR(10),
										RepairUserID VARCHAR(20),
										RepairDateTime DATETIMEOFFSET,
										RepairDesc NVARCHAR(MAX),
										DefectQty NUMERIC(20,5),
										RepairQty NUMERIC(20,5),
										LossQty NUMERIC(20,5),
										FileID BIGINT,
										DRIExtText01 NVARCHAR(200),
										DRIExtText02 NVARCHAR(200),
										DRIExtText03 NVARCHAR(200),
										IsDelete VARCHAR(1),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectSummaryNo = SourceTable.OldDefectSummaryNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectSummaryNo = ISNULL(SourceTable.DefectSummaryNo,TargetTable.DefectSummaryNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					ControlNo = ISNULL(SourceTable.ControlNo,TargetTable.ControlNo),
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					DayPlanNo = ISNULL(SourceTable.DayPlanNo,TargetTable.DayPlanNo),
					FindJobdate = ISNULL(SourceTable.FindJobdate,TargetTable.FindJobdate),
					FindShiftCode = ISNULL(SourceTable.FindShiftCode,TargetTable.FindShiftCode),
					FindTimeCode = ISNULL(SourceTable.FindTimeCode,TargetTable.FindTimeCode),
					FindLineCode = ISNULL(SourceTable.FindLineCode,TargetTable.FindLineCode),
					FindRouteCode = ISNULL(SourceTable.FindRouteCode,TargetTable.FindRouteCode),
					FindSubRouteCode = ISNULL(SourceTable.FindSubRouteCode,TargetTable.FindSubRouteCode),
					FindFacilityRouteCode = ISNULL(SourceTable.FindFacilityRouteCode,TargetTable.FindFacilityRouteCode),
					CauseJobDate = ISNULL(SourceTable.CauseJobDate,TargetTable.CauseJobDate),
					CauseShiftCode = ISNULL(SourceTable.CauseShiftCode,TargetTable.CauseShiftCode),
					CauseTimeCode = ISNULL(SourceTable.CauseTimeCode,TargetTable.CauseTimeCode),
					CauseLineCode = ISNULL(SourceTable.CauseLineCode,TargetTable.CauseLineCode),
					CauseFacilityRouteCode = ISNULL(SourceTable.CauseFacilityRouteCode,TargetTable.CauseFacilityRouteCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					FindDateTime = ISNULL(SourceTable.FindDateTime,TargetTable.FindDateTime),
					DefectCauseType = ISNULL(SourceTable.DefectCauseType,TargetTable.DefectCauseType),
					DutyCostCenterCode = ISNULL(SourceTable.DutyCostCenterCode,TargetTable.DutyCostCenterCode),
					DutyVendorCode = ISNULL(SourceTable.DutyVendorCode,TargetTable.DutyVendorCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectCauseCode = ISNULL(SourceTable.DefectCauseCode,TargetTable.DefectCauseCode),
					DefectCauseDetailCode = ISNULL(SourceTable.DefectCauseDetailCode,TargetTable.DefectCauseDetailCode),
					DefectExtDesc = ISNULL(SourceTable.DefectExtDesc,TargetTable.DefectExtDesc),
					RepairType = ISNULL(SourceTable.RepairType,TargetTable.RepairType),
					RepairUserID = ISNULL(SourceTable.RepairUserID,TargetTable.RepairUserID),
					RepairDateTime = ISNULL(SourceTable.RepairDateTime,TargetTable.RepairDateTime),
					RepairDesc = ISNULL(SourceTable.RepairDesc,TargetTable.RepairDesc),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					RepairQty = ISNULL(SourceTable.RepairQty,TargetTable.RepairQty),
					LossQty = ISNULL(SourceTable.LossQty,TargetTable.LossQty),
					FileID = ISNULL(SourceTable.FileID,TargetTable.FileID),
					DRIExtText01 = ISNULL(SourceTable.DRIExtText01,TargetTable.DRIExtText01),
					DRIExtText02 = ISNULL(SourceTable.DRIExtText02,TargetTable.DRIExtText02),
					DRIExtText03 = ISNULL(SourceTable.DRIExtText03,TargetTable.DRIExtText03),
					IsDelete = ISNULL(SourceTable.IsDelete,TargetTable.IsDelete),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectSummaryNo,
						CompanyCode,
						WorkCenterCode,
						ControlNo,
						PONo,
						DayPlanNo,
						FindJobdate,
						FindShiftCode,
						FindTimeCode,
						FindLineCode,
						FindRouteCode,
						FindSubRouteCode,
						FindFacilityRouteCode,
						CauseJobDate,
						CauseShiftCode,
						CauseTimeCode,
						CauseLineCode,
						CauseFacilityRouteCode,
						MaterialCode,
						BomVersion,
						FindDateTime,
						DefectCauseType,
						DutyCostCenterCode,
						DutyVendorCode,
						DefectCode,
						DefectCauseCode,
						DefectCauseDetailCode,
						DefectExtDesc,
						RepairType,
						RepairUserID,
						RepairDateTime,
						RepairDesc,
						DefectQty,
						RepairQty,
						LossQty,
						FileID,
						DRIExtText01,
						DRIExtText02,
						DRIExtText03,
						IsDelete,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DefectSummaryNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.ControlNo,
							SourceTable.PONo,
							SourceTable.DayPlanNo,
							SourceTable.FindJobdate,
							SourceTable.FindShiftCode,
							SourceTable.FindTimeCode,
							SourceTable.FindLineCode,
							SourceTable.FindRouteCode,
							SourceTable.FindSubRouteCode,
							SourceTable.FindFacilityRouteCode,
							SourceTable.CauseJobDate,
							SourceTable.CauseShiftCode,
							SourceTable.CauseTimeCode,
							SourceTable.CauseLineCode,
							SourceTable.CauseFacilityRouteCode,
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.FindDateTime,
							SourceTable.DefectCauseType,
							SourceTable.DutyCostCenterCode,
							SourceTable.DutyVendorCode,
							SourceTable.DefectCode,
							SourceTable.DefectCauseCode,
							SourceTable.DefectCauseDetailCode,
							SourceTable.DefectExtDesc,
							SourceTable.RepairType,
							SourceTable.RepairUserID,
							SourceTable.RepairDateTime,
							SourceTable.RepairDesc,
							SourceTable.DefectQty,
							SourceTable.RepairQty,
							SourceTable.LossQty,
							SourceTable.FileID,
							SourceTable.DRIExtText01,
							SourceTable.DRIExtText02,
							SourceTable.DRIExtText03,
							SourceTable.IsDelete,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DefectRepairInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectSummaryNo IS NULL THEN DefectSummaryNo
							    ELSE OldDefectSummaryNo
							END AS OldDefectSummaryNo,
							DefectSummaryNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectSummaryNo VARCHAR(20),
										DefectSummaryNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectSummaryNo = SourceTable.DefectSummaryNo
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
									OldDefectSummaryNo,
									DefectSummaryNo,
									CompanyCode,
									WorkCenterCode,
									ControlNo,
									PONo,
									DayPlanNo,
									FindJobdate,
									FindShiftCode,
									FindTimeCode,
									FindLineCode,
									FindRouteCode,
									FindSubRouteCode,
									FindFacilityRouteCode,
									CauseJobDate,
									CauseShiftCode,
									CauseTimeCode,
									CauseLineCode,
									CauseFacilityRouteCode,
									MaterialCode,
									BomVersion,
									FindDateTime,
									DefectCauseType,
									DutyCostCenterCode,
									DutyVendorCode,
									DefectCode,
									DefectCauseCode,
									DefectCauseDetailCode,
									DefectExtDesc,
									RepairType,
									RepairUserID,
									RepairDateTime,
									RepairDesc,
									DefectQty,
									RepairQty,
									LossQty,
									FileID,
									DRIExtText01,
									DRIExtText02,
									DRIExtText03,
									IsDelete,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectSummaryNo VARCHAR(20),
											 DefectSummaryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 ControlNo VARCHAR(20),
											 PONo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 FindJobdate DATETIMEOFFSET,
											 FindShiftCode VARCHAR(1),
											 FindTimeCode VARCHAR(2),
											 FindLineCode VARCHAR(20),
											 FindRouteCode VARCHAR(20),
											 FindSubRouteCode VARCHAR(20),
											 FindFacilityRouteCode VARCHAR(20),
											 CauseJobDate DATETIMEOFFSET,
											 CauseShiftCode VARCHAR(1),
											 CauseTimeCode VARCHAR(2),
											 CauseLineCode VARCHAR(20),
											 CauseFacilityRouteCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(10),
											 FindDateTime DATETIMEOFFSET,
											 DefectCauseType VARCHAR(1),
											 DutyCostCenterCode VARCHAR(20),
											 DutyVendorCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectCauseCode VARCHAR(20),
											 DefectCauseDetailCode VARCHAR(20),
											 DefectExtDesc NVARCHAR(200),
											 RepairType VARCHAR(10),
											 RepairUserID VARCHAR(20),
											 RepairDateTime DATETIMEOFFSET,
											 RepairDesc NVARCHAR(MAX),
											 DefectQty NUMERIC(20,5),
											 RepairQty NUMERIC(20,5),
											 LossQty NUMERIC(20,5),
											 FileID BIGINT,
											 DRIExtText01 NVARCHAR(200),
											 DRIExtText02 NVARCHAR(200),
											 DRIExtText03 NVARCHAR(200),
											 IsDelete VARCHAR(1),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectSummaryNo IS NULL THEN DefectSummaryNo
										ELSE OldDefectSummaryNo
									END AS OldDefectSummaryNo,
									DefectSummaryNo,
									CompanyCode,
									WorkCenterCode,
									ControlNo,
									PONo,
									DayPlanNo,
									FindJobdate,
									FindShiftCode,
									FindTimeCode,
									FindLineCode,
									FindRouteCode,
									FindSubRouteCode,
									FindFacilityRouteCode,
									CauseJobDate,
									CauseShiftCode,
									CauseTimeCode,
									CauseLineCode,
									CauseFacilityRouteCode,
									MaterialCode,
									BomVersion,
									FindDateTime,
									DefectCauseType,
									DutyCostCenterCode,
									DutyVendorCode,
									DefectCode,
									DefectCauseCode,
									DefectCauseDetailCode,
									DefectExtDesc,
									RepairType,
									RepairUserID,
									RepairDateTime,
									RepairDesc,
									DefectQty,
									RepairQty,
									LossQty,
									FileID,
									DRIExtText01,
									DRIExtText02,
									DRIExtText03,
									IsDelete,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectSummaryNo VARCHAR(20),
											 DefectSummaryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 ControlNo VARCHAR(20),
											 PONo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 FindJobdate DATETIMEOFFSET,
											 FindShiftCode VARCHAR(1),
											 FindTimeCode VARCHAR(2),
											 FindLineCode VARCHAR(20),
											 FindRouteCode VARCHAR(20),
											 FindSubRouteCode VARCHAR(20),
											 FindFacilityRouteCode VARCHAR(20),
											 CauseJobDate DATETIMEOFFSET,
											 CauseShiftCode VARCHAR(1),
											 CauseTimeCode VARCHAR(2),
											 CauseLineCode VARCHAR(20),
											 CauseFacilityRouteCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(10),
											 FindDateTime DATETIMEOFFSET,
											 DefectCauseType VARCHAR(1),
											 DutyCostCenterCode VARCHAR(20),
											 DutyVendorCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectCauseCode VARCHAR(20),
											 DefectCauseDetailCode VARCHAR(20),
											 DefectExtDesc NVARCHAR(200),
											 RepairType VARCHAR(10),
											 RepairUserID VARCHAR(20),
											 RepairDateTime DATETIMEOFFSET,
											 RepairDesc NVARCHAR(MAX),
											 DefectQty NUMERIC(20,5),
											 RepairQty NUMERIC(20,5),
											 LossQty NUMERIC(20,5),
											 FileID BIGINT,
											 DRIExtText01 NVARCHAR(200),
											 DRIExtText02 NVARCHAR(200),
											 DRIExtText03 NVARCHAR(200),
											 IsDelete VARCHAR(1),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectSummaryNo IS NULL THEN DefectSummaryNo
										ELSE OldDefectSummaryNo
									END AS OldDefectSummaryNo,
									DefectSummaryNo,
									CompanyCode,
									WorkCenterCode,
									ControlNo,
									PONo,
									DayPlanNo,
									FindJobdate,
									FindShiftCode,
									FindTimeCode,
									FindLineCode,
									FindRouteCode,
									FindSubRouteCode,
									FindFacilityRouteCode,
									CauseJobDate,
									CauseShiftCode,
									CauseTimeCode,
									CauseLineCode,
									CauseFacilityRouteCode,
									MaterialCode,
									BomVersion,
									FindDateTime,
									DefectCauseType,
									DutyCostCenterCode,
									DutyVendorCode,
									DefectCode,
									DefectCauseCode,
									DefectCauseDetailCode,
									DefectExtDesc,
									RepairType,
									RepairUserID,
									RepairDateTime,
									RepairDesc,
									DefectQty,
									RepairQty,
									LossQty,
									FileID,
									DRIExtText01,
									DRIExtText02,
									DRIExtText03,
									IsDelete,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectSummaryNo VARCHAR(20),
											 DefectSummaryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 ControlNo VARCHAR(20),
											 PONo VARCHAR(20),
											 DayPlanNo VARCHAR(20),
											 FindJobdate DATETIMEOFFSET,
											 FindShiftCode VARCHAR(1),
											 FindTimeCode VARCHAR(2),
											 FindLineCode VARCHAR(20),
											 FindRouteCode VARCHAR(20),
											 FindSubRouteCode VARCHAR(20),
											 FindFacilityRouteCode VARCHAR(20),
											 CauseJobDate DATETIMEOFFSET,
											 CauseShiftCode VARCHAR(1),
											 CauseTimeCode VARCHAR(2),
											 CauseLineCode VARCHAR(20),
											 CauseFacilityRouteCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(10),
											 FindDateTime DATETIMEOFFSET,
											 DefectCauseType VARCHAR(1),
											 DutyCostCenterCode VARCHAR(20),
											 DutyVendorCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectCauseCode VARCHAR(20),
											 DefectCauseDetailCode VARCHAR(20),
											 DefectExtDesc NVARCHAR(200),
											 RepairType VARCHAR(10),
											 RepairUserID VARCHAR(20),
											 RepairDateTime DATETIMEOFFSET,
											 RepairDesc NVARCHAR(MAX),
											 DefectQty NUMERIC(20,5),
											 RepairQty NUMERIC(20,5),
											 LossQty NUMERIC(20,5),
											 FileID BIGINT,
											 DRIExtText01 NVARCHAR(200),
											 DRIExtText02 NVARCHAR(200),
											 DRIExtText03 NVARCHAR(200),
											 IsDelete VARCHAR(1),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectSummaryNo,
								 @DefectSummaryNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @ControlNo,
								 @PONo,
								 @DayPlanNo,
								 @FindJobdate,
								 @FindShiftCode,
								 @FindTimeCode,
								 @FindLineCode,
								 @FindRouteCode,
								 @FindSubRouteCode,
								 @FindFacilityRouteCode,
								 @CauseJobDate,
								 @CauseShiftCode,
								 @CauseTimeCode,
								 @CauseLineCode,
								 @CauseFacilityRouteCode,
								 @MaterialCode,
								 @BomVersion,
								 @FindDateTime,
								 @DefectCauseType,
								 @DutyCostCenterCode,
								 @DutyVendorCode,
								 @DefectCode,
								 @DefectCauseCode,
								 @DefectCauseDetailCode,
								 @DefectExtDesc,
								 @RepairType,
								 @RepairUserID,
								 @RepairDateTime,
								 @RepairDesc,
								 @DefectQty,
								 @RepairQty,
								 @LossQty,
								 @FileID,
								 @DRIExtText01,
								 @DRIExtText02,
								 @DRIExtText03,
								 @IsDelete,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DefectRepairInfo WHERE DefectSummaryNo = @DefectSummaryNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectSummaryNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_DefectRepairInfo',@DefectSummaryNo OUTPUT
                    END

                    INSERT INTO STB_DefectRepairInfo
						(
						    DefectSummaryNo,
						    CompanyCode,
						    WorkCenterCode,
						    ControlNo,
						    PONo,
						    DayPlanNo,
						    FindJobdate,
						    FindShiftCode,
						    FindTimeCode,
						    FindLineCode,
						    FindRouteCode,
						    FindSubRouteCode,
						    FindFacilityRouteCode,
						    CauseJobDate,
						    CauseShiftCode,
						    CauseTimeCode,
						    CauseLineCode,
						    CauseFacilityRouteCode,
						    MaterialCode,
						    BomVersion,
						    FindDateTime,
						    DefectCauseType,
						    DutyCostCenterCode,
						    DutyVendorCode,
						    DefectCode,
						    DefectCauseCode,
						    DefectCauseDetailCode,
						    DefectExtDesc,
						    RepairType,
						    RepairUserID,
						    RepairDateTime,
						    RepairDesc,
						    DefectQty,
						    RepairQty,
						    LossQty,
						    FileID,
						    DRIExtText01,
						    DRIExtText02,
						    DRIExtText03,
						    IsDelete,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DefectSummaryNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @ControlNo,
						    @PONo,
						    @DayPlanNo,
						    @FindJobdate,
						    @FindShiftCode,
						    @FindTimeCode,
						    @FindLineCode,
						    @FindRouteCode,
						    @FindSubRouteCode,
						    @FindFacilityRouteCode,
						    @CauseJobDate,
						    @CauseShiftCode,
						    @CauseTimeCode,
						    @CauseLineCode,
						    @CauseFacilityRouteCode,
						    @MaterialCode,
						    @BomVersion,
						    @FindDateTime,
						    @DefectCauseType,
						    @DutyCostCenterCode,
						    @DutyVendorCode,
						    @DefectCode,
						    @DefectCauseCode,
						    @DefectCauseDetailCode,
						    @DefectExtDesc,
						    @RepairType,
						    @RepairUserID,
						    @RepairDateTime,
						    @RepairDesc,
						    @DefectQty,
						    @RepairQty,
						    @LossQty,
						    @FileID,
						    @DRIExtText01,
						    @DRIExtText02,
						    @DRIExtText03,
						    @IsDelete,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' 
				
				BEGIN
                    UPDATE STB_DefectRepairInfo
						SET
						    DefectSummaryNo =   ISNULL(@DefectSummaryNo,DefectSummaryNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    ControlNo =   ISNULL(@ControlNo,ControlNo),
						    PONo =   ISNULL(@PONo,PONo),
						    DayPlanNo =   ISNULL(@DayPlanNo,DayPlanNo),
						    FindJobdate =   ISNULL(@FindJobdate,FindJobdate),
						    FindShiftCode =   ISNULL(@FindShiftCode,FindShiftCode),
						    FindTimeCode =   ISNULL(@FindTimeCode,FindTimeCode),
						    FindLineCode =   ISNULL(@FindLineCode,FindLineCode),
						    FindRouteCode =   ISNULL(@FindRouteCode,FindRouteCode),
						    FindSubRouteCode =   ISNULL(@FindSubRouteCode,FindSubRouteCode),
						    FindFacilityRouteCode =   ISNULL(@FindFacilityRouteCode,FindFacilityRouteCode),
						    CauseJobDate =   ISNULL(@CauseJobDate,CauseJobDate),
						    CauseShiftCode =   ISNULL(@CauseShiftCode,CauseShiftCode),
						    CauseTimeCode =   ISNULL(@CauseTimeCode,CauseTimeCode),
						    CauseLineCode =   ISNULL(@CauseLineCode,CauseLineCode),
						    CauseFacilityRouteCode =   ISNULL(@CauseFacilityRouteCode,CauseFacilityRouteCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    BomVersion =   ISNULL(@BomVersion,BomVersion),
						    FindDateTime =   ISNULL(@FindDateTime,FindDateTime),
						    DefectCauseType =   ISNULL(@DefectCauseType,DefectCauseType),
						    DutyCostCenterCode =   ISNULL(@DutyCostCenterCode,DutyCostCenterCode),
						    DutyVendorCode =   ISNULL(@DutyVendorCode,DutyVendorCode),
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
						    DefectCauseCode =   ISNULL(@DefectCauseCode,DefectCauseCode),
						    DefectCauseDetailCode =   ISNULL(@DefectCauseDetailCode,DefectCauseDetailCode),
						    DefectExtDesc =   ISNULL(@DefectExtDesc,DefectExtDesc),
						    RepairType =   ISNULL(@RepairType,RepairType),
						    RepairUserID =   ISNULL(@RepairUserID,RepairUserID),
						    RepairDateTime =   ISNULL(@RepairDateTime,RepairDateTime),
						    RepairDesc =   ISNULL(@RepairDesc,RepairDesc),
						    DefectQty =   ISNULL(@DefectQty,DefectQty),
						    RepairQty =   ISNULL(@RepairQty,RepairQty),
						    LossQty =   ISNULL(@LossQty,LossQty),
						    FileID =   ISNULL(@FileID,FileID),
						    DRIExtText01 =   ISNULL(@DRIExtText01,DRIExtText01),
						    DRIExtText02 =   ISNULL(@DRIExtText02,DRIExtText02),
						    DRIExtText03 =   ISNULL(@DRIExtText03,DRIExtText03),
						    IsDelete =   ISNULL(@IsDelete,IsDelete),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    DefectSummaryNo = @OldDefectSummaryNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DefectRepairInfo
						WHERE
						    DefectSummaryNo = @OldDefectSummaryNo
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