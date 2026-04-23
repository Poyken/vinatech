

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-19
-- Browsable : true
-- Group : 공통
-- Description:	자재수불유형정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialDocInfo_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldMaterialDocNo VARCHAR(20)
  DECLARE @MaterialDocNo VARCHAR(20)
  DECLARE @BasicDate DATE
  DECLARE @MaterialDocType VARCHAR(20)
  DECLARE @MaterialDocTypeCode VARCHAR(20)
  DECLARE @DocStatus VARCHAR(20)
  DECLARE @SourceCustomerCode VARCHAR(20)
  DECLARE @SourceCompanyCode VARCHAR(20)
  DECLARE @SourceWorkCenterCode VARCHAR(20)
  DECLARE @SourceRouteCode VARCHAR(20)
  DECLARE @SourceMaterialWarehouseCode VARCHAR(20)
  DECLARE @TargetCustomerCode VARCHAR(20)
  DECLARE @TargetCompanyCode VARCHAR(20)
  DECLARE @TargetWorkCenterCode VARCHAR(20)
  DECLARE @TargetRouteCode VARCHAR(20)
  DECLARE @TargetMaterialWarehouseCode VARCHAR(20)
  DECLARE @RefMaterialDocNo VARCHAR(20)
  DECLARE @PONo VARCHAR(20)
  DECLARE @FPItemWorkNo VARCHAR(20)
  DECLARE @RequestDateTime DATETIME
  DECLARE @RequestUserID VARCHAR(20)
  DECLARE @RequestPlanDate DATE
  DECLARE @RequestDesc NVARCHAR(200)
  DECLARE @RequestFixDateTime DATETIME
  DECLARE @RequestFixUserID VARCHAR(20)
  DECLARE @IsRequestFix BIT
  DECLARE @RequestApprovalDateTime DATETIME
  DECLARE @RequestApprovalUserID VARCHAR(20)
  DECLARE @IsRequestApproval BIT
  DECLARE @IsAssignPicking BIT
  DECLARE @PickingStartDateTime DATETIME
  DECLARE @PickingEndDateTime DATETIME
  DECLARE @PickingUserID VARCHAR(20)
  DECLARE @IsPickingFix BIT
  DECLARE @IsSourceFinish BIT
  DECLARE @SourceProcessDateTime DATETIME
  DECLARE @SourceProcessUserID VARCHAR(20)
  DECLARE @IsTargetFinish BIT
  DECLARE @TargetProcessDateTime DATETIME
  DECLARE @TargetProcessUserID VARCHAR(20)
  DECLARE @TotalPlanPrice NUMERIC(20,5)
  DECLARE @TotalActualPrice NUMERIC(20,5)
  DECLARE @MRMIExtText01 NVARCHAR(MAX)
  DECLARE @MRMIExtText02 NVARCHAR(MAX)
  DECLARE @MRMIExtText03 NVARCHAR(MAX)
  DECLARE @MRMIExtText04 NVARCHAR(MAX)
  DECLARE @MRMIExtText05 NVARCHAR(MAX)
  DECLARE @MDIErpRefText01 NVARCHAR(MAX)
  DECLARE @MDIErpRefText02 NVARCHAR(MAX)
  DECLARE @MDIErpRefText03 NVARCHAR(MAX)
  DECLARE @MDIErpRefText04 NVARCHAR(MAX)
  DECLARE @MDIErpRefText05 NVARCHAR(MAX)
  DECLARE @MDIErpRefText06 NVARCHAR(MAX)
  DECLARE @MDIErpRefText07 NVARCHAR(MAX)
  DECLARE @MDIErpRefText08 NVARCHAR(MAX)
  DECLARE @MDIErpRefText09 NVARCHAR(MAX)
  DECLARE @MDIErpRefText10 NVARCHAR(MAX)
  DECLARE @IsCancel BIT
  DECLARE @CancelUserID VARCHAR(20)
  DECLARE @CancelReason NVARCHAR(200)
  DECLARE @CancelDateTime DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @BefDocStatus VARCHAR(20)
  DECLARE @BefIsCancel BIT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialDocInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialDocInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialDocNo IS NULL THEN MaterialDocNo
							    ELSE OldMaterialDocNo
							END AS OldMaterialDocNo,
							MaterialDocNo,
							BasicDate,
							MaterialDocType,
							MaterialDocTypeCode,
							DocStatus,
							SourceCustomerCode,
							SourceCompanyCode,
							SourceWorkCenterCode,
							SourceRouteCode,
							SourceMaterialWarehouseCode,
							TargetCustomerCode,
							TargetCompanyCode,
							TargetWorkCenterCode,
							TargetRouteCode,
							TargetMaterialWarehouseCode,
							RefMaterialDocNo,
							PONo,
							FPItemWorkNo,
							RequestDateTime,
							RequestUserID,
							RequestPlanDate,
							RequestDesc,
							RequestFixDateTime,
							RequestFixUserID,
							IsRequestFix,
							RequestApprovalDateTime,
							RequestApprovalUserID,
							IsRequestApproval,
							IsAssignPicking,
							PickingStartDateTime,
							PickingEndDateTime,
							PickingUserID,
							IsPickingFix,
							IsSourceFinish,
							SourceProcessDateTime,
							SourceProcessUserID,
							IsTargetFinish,
							TargetProcessDateTime,
							TargetProcessUserID,
							TotalPlanPrice,
							TotalActualPrice,
							IsCancel,
							CancelUserID,
							CancelReason,
							CancelDateTime,
							MRMIExtText01,
							MRMIExtText02,
							MRMIExtText03,
							MRMIExtText04,
							MRMIExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MDIErpRefText01,
							MDIErpRefText02,
							MDIErpRefText03,
							MDIErpRefText04,
							MDIErpRefText05,
							MDIErpRefText06,
							MDIErpRefText07

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialDocNo VARCHAR(20),
										MaterialDocNo VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										MaterialDocType VARCHAR(20),
										MaterialDocTypeCode VARCHAR(20),
										DocStatus VARCHAR(20),
										SourceCustomerCode VARCHAR(20),
										SourceCompanyCode VARCHAR(20),
										SourceWorkCenterCode VARCHAR(20),
										SourceRouteCode VARCHAR(20),
										SourceMaterialWarehouseCode VARCHAR(20),
										TargetCustomerCode VARCHAR(20),
										TargetCompanyCode VARCHAR(20),
										TargetWorkCenterCode VARCHAR(20),
										TargetRouteCode VARCHAR(20),
										TargetMaterialWarehouseCode VARCHAR(20),
										RefMaterialDocNo VARCHAR(20),
										PONo VARCHAR(20),
										FPItemWorkNo VARCHAR(20),
										RequestDateTime DATETIMEOFFSET,
										RequestUserID VARCHAR(20),
										RequestPlanDate DATETIMEOFFSET,
										RequestDesc NVARCHAR(200),
										RequestFixDateTime DATETIMEOFFSET,
										RequestFixUserID VARCHAR(20),
										IsRequestFix BIT,
										RequestApprovalDateTime DATETIMEOFFSET,
										RequestApprovalUserID VARCHAR(20),
										IsRequestApproval BIT,
										IsAssignPicking BIT,
										PickingStartDateTime DATETIMEOFFSET,
										PickingEndDateTime DATETIMEOFFSET,
										PickingUserID VARCHAR(20),
										IsPickingFix BIT,
										IsSourceFinish BIT,
										SourceProcessDateTime DATETIMEOFFSET,
										SourceProcessUserID VARCHAR(20),
										IsTargetFinish BIT,
										TargetProcessDateTime DATETIMEOFFSET,
										TargetProcessUserID VARCHAR(20),
										TotalPlanPrice NUMERIC(20,5),
										TotalActualPrice NUMERIC(20,5),
										IsCancel BIT,
										CancelUserID VARCHAR(20),
										CancelReason NVARCHAR(200),
										CancelDateTime DATETIME,										
										MRMIExtText01 NVARCHAR(MAX),
										MRMIExtText02 NVARCHAR(MAX),
										MRMIExtText03 NVARCHAR(MAX),
										MRMIExtText04 NVARCHAR(MAX),
										MRMIExtText05 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MDIErpRefText01 NVARCHAR(50),
										MDIErpRefText02 NVARCHAR(50),
										MDIErpRefText03 NVARCHAR(50),
										MDIErpRefText04 NVARCHAR(50),
										MDIErpRefText05 NVARCHAR(50),
										MDIErpRefText06 NVARCHAR(50),
										MDIErpRefText07 NVARCHAR(50)

									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialDocNo = SourceTable.MaterialDocNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialDocNo = SourceTable.MaterialDocNo,
					BasicDate = SourceTable.BasicDate,
					MaterialDocType = SourceTable.MaterialDocType,
					MaterialDocTypeCode = SourceTable.MaterialDocTypeCode,
					DocStatus = SourceTable.DocStatus,
					SourceCustomerCode = SourceTable.SourceCustomerCode,
					SourceCompanyCode = SourceTable.SourceCompanyCode,
					SourceWorkCenterCode = SourceTable.SourceWorkCenterCode,
					SourceRouteCode = SourceTable.SourceRouteCode,
					SourceMaterialWarehouseCode = SourceTable.SourceMaterialWarehouseCode,
					TargetCustomerCode = SourceTable.TargetCustomerCode,
					TargetCompanyCode = SourceTable.TargetCompanyCode,
					TargetWorkCenterCode = SourceTable.TargetWorkCenterCode,
					TargetRouteCode = SourceTable.TargetRouteCode,
					TargetMaterialWarehouseCode = SourceTable.TargetMaterialWarehouseCode,
					RefMaterialDocNo = SourceTable.RefMaterialDocNo,
					PONO = SourceTable.PONo,
					FPItemWorkNo = SourceTable.FPItemWorkNo,
					RequestDateTime = SourceTable.RequestDateTime,
					RequestUserID = SourceTable.RequestUserID,
					RequestPlanDate = SourceTable.RequestPlanDate,
					RequestDesc = SourceTable.RequestDesc,
					RequestFixDateTime = SourceTable.RequestFixDateTime,
					RequestFixUserID = SourceTable.RequestFixUserID,
					IsRequestFix = SourceTable.IsRequestFix,
					RequestApprovalDateTime = SourceTable.RequestApprovalDateTime,
					RequestApprovalUserID = SourceTable.RequestApprovalUserID,
					IsRequestApproval = SourceTable.IsRequestApproval,
					IsAssignPicking = SourceTable.IsAssignPicking,
					PickingStartDateTime = SourceTable.PickingStartDateTime,
					PickingEndDateTime = SourceTable.PickingEndDateTime,
					PickingUserID = SourceTable.PickingUserID,
					IsPickingFix = SourceTable.IsPickingFix,
					IsSourceFinish = SourceTable.IsSourceFinish,
					SourceProcessDateTime = SourceTable.SourceProcessDateTime,
					SourceProcessUserID = SourceTable.SourceProcessUserID,
					IsTargetFinish = SourceTable.IsTargetFinish,
					TargetProcessDateTime = SourceTable.TargetProcessDateTime,
					TargetProcessUserID = SourceTable.TargetProcessUserID,
					TotalPlanPrice = SourceTable.TotalPlanPrice,
					TotalActualPrice = SourceTable.TotalActualPrice,
					IsCancel = SourceTable.TotalActualPrice,
					CancelUserID= SourceTable.CancelUserID,
					CancelReason = SourceTable.CancelReason,
					CancelDateTime = SourceTable.CancelDateTime,
					MRMIExtText01 = SourceTable.MRMIExtText01,
					MRMIExtText02 = SourceTable.MRMIExtText02,
					MRMIExtText03 = SourceTable.MRMIExtText03,
					MRMIExtText04 = SourceTable.MRMIExtText04,
					MRMIExtText05 = SourceTable.MRMIExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					MDIErpRefText01 = SourceTable.MDIErpRefText01,
					MDIErpRefText02 = SourceTable.MDIErpRefText02,
					MDIErpRefText03 = SourceTable.MDIErpRefText03,
					MDIErpRefText04 = SourceTable.MDIErpRefText04,
					MDIErpRefText05 = SourceTable.MDIErpRefText05,
					MDIErpRefText06 = SourceTable.MDIErpRefText06,
					MDIErpRefText07 = SourceTable.MDIErpRefText07

			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialDocNo,
						BasicDate,
						MaterialDocType,
						MaterialDocTypeCode,
						DocStatus,
						SourceCustomerCode,
						SourceCompanyCode,
						SourceWorkCenterCode,
						SourceRouteCode,
						SourceMaterialWarehouseCode,
						TargetCustomerCode,
						TargetCompanyCode,
						TargetWorkCenterCode,
						TargetRouteCode,
						TargetMaterialWarehouseCode,
						RefMaterialDocNo,
						PONo,
						FPItemWorkNo,
						RequestDateTime,
						RequestUserID,
						RequestPlanDate,
						RequestDesc,
						RequestFixDateTime,
						RequestFixUserID,
						IsRequestFix,
						RequestApprovalDateTime,
						RequestApprovalUserID,
						IsRequestApproval,
						IsAssignPicking,
						PickingStartDateTime,
						PickingEndDateTime,
						PickingUserID,
						IsPickingFix,
						IsSourceFinish,
						SourceProcessDateTime,
						SourceProcessUserID,
						IsTargetFinish,
						TargetProcessDateTime,
						TargetProcessUserID,
						TotalPlanPrice,
						TotalActualPrice,
						IsCancel,
						CancelUserID,
						CancelReason,
						CancelDateTime,						
						MRMIExtText01,
						MRMIExtText02,
						MRMIExtText03,
						MRMIExtText04,
						MRMIExtText05,
						CreateDateTime,
						CreateUserID,
						MDIErpRefText01,
						MDIErpRefText02,
						MDIErpRefText03,
						MDIErpRefText04,
						MDIErpRefText05,
						MDIErpRefText06,
						MDIErpRefText07
					)
				VALUES
					(
							SourceTable.MaterialDocNo,
							SourceTable.BasicDate,
							SourceTable.MaterialDocType,
							SourceTable.MaterialDocTypeCode,
							SourceTable.DocStatus,
							SourceTable.SourceCustomerCode,
							SourceTable.SourceCompanyCode,
							SourceTable.SourceWorkCenterCode,
							SourceTable.SourceRouteCode,
							SourceTable.SourceMaterialWarehouseCode,
							SourceTable.TargetCustomerCode,
							SourceTable.TargetCompanyCode,
							SourceTable.TargetWorkCenterCode,
							SourceTable.TargetRouteCode,
							SourceTable.TargetMaterialWarehouseCode,
							SourceTable.RefMaterialDocNo,
							SourceTable.PONo,
							SourceTable.FPItemWorkNo,
							SourceTable.RequestDateTime,
							SourceTable.RequestUserID,
							SourceTable.RequestPlanDate,
							SourceTable.RequestDesc,
							SourceTable.RequestFixDateTime,
							SourceTable.RequestFixUserID,
							SourceTable.IsRequestFix,
							SourceTable.RequestApprovalDateTime,
							SourceTable.RequestApprovalUserID,
							SourceTable.IsRequestApproval,
							SourceTable.IsAssignPicking,
							SourceTable.PickingStartDateTime,
							SourceTable.PickingEndDateTime,
							SourceTable.PickingUserID,
							SourceTable.IsPickingFix,
							SourceTable.IsSourceFinish,
							SourceTable.SourceProcessDateTime,
							SourceTable.SourceProcessUserID,
							SourceTable.IsTargetFinish,
							SourceTable.TargetProcessDateTime,
							SourceTable.TargetProcessUserID,
							SourceTable.TotalPlanPrice,
							SourceTable.TotalActualPrice,
							SourceTable.IsCancel,
							SourceTable.CancelUserID,
							SourceTable.CancelReason,
							SourceTable.CancelDateTime,							
							SourceTable.MRMIExtText01,
							SourceTable.MRMIExtText02,
							SourceTable.MRMIExtText03,
							SourceTable.MRMIExtText04,
							SourceTable.MRMIExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MDIErpRefText01,
							SourceTable.MDIErpRefText02,
							SourceTable.MDIErpRefText03,
							SourceTable.MDIErpRefText04,
							SourceTable.MDIErpRefText05,
							SourceTable.MDIErpRefText06,
							SourceTable.MDIErpRefText07
					);


			-- Process Update Table
            MERGE STB_MaterialDocInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialDocNo IS NULL THEN MaterialDocNo
							    ELSE OldMaterialDocNo
							END AS OldMaterialDocNo,
							MaterialDocNo,
							BasicDate,
							MaterialDocType,
							MaterialDocTypeCode,
							DocStatus,
							SourceCustomerCode,
							SourceCompanyCode,
							SourceWorkCenterCode,
							SourceRouteCode,
							SourceMaterialWarehouseCode,
							TargetCustomerCode,
							TargetCompanyCode,
							TargetWorkCenterCode,
							TargetRouteCode,
							TargetMaterialWarehouseCode,
							RefMaterialDocNo,
							PONo,
							FPItemWorkNo,
							RequestDateTime,
							RequestUserID,
							RequestPlanDate,
							RequestDesc,
							RequestFixDateTime,
							RequestFixUserID,
							IsRequestFix,
							RequestApprovalDateTime,
							RequestApprovalUserID,
							IsRequestApproval,
							IsAssignPicking,
							PickingStartDateTime,
							PickingEndDateTime,
							PickingUserID,
							IsPickingFix,
							IsSourceFinish,
							SourceProcessDateTime,
							SourceProcessUserID,
							IsTargetFinish,
							TargetProcessDateTime,
							TargetProcessUserID,
							TotalPlanPrice,
							TotalActualPrice,
							IsCancel,
							CancelUserID,
							CancelReason,
							CancelDateTime,
							MRMIExtText01,
							MRMIExtText02,
							MRMIExtText03,
							MRMIExtText04,
							MRMIExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MDIErpRefText01,
							MDIErpRefText02,
							MDIErpRefText03,
							MDIErpRefText04,
							MDIErpRefText05,
							MDIErpRefText06,
							MDIErpRefText07
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialDocNo VARCHAR(20),
										MaterialDocNo VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										MaterialDocType VARCHAR(20),
										MaterialDocTypeCode VARCHAR(20),
										DocStatus VARCHAR(20),
										SourceCustomerCode VARCHAR(20),
										SourceCompanyCode VARCHAR(20),
										SourceWorkCenterCode VARCHAR(20),
										SourceRouteCode VARCHAR(20),
										SourceMaterialWarehouseCode VARCHAR(20),
										TargetCustomerCode VARCHAR(20),
										TargetCompanyCode VARCHAR(20),
										TargetWorkCenterCode VARCHAR(20),
										TargetRouteCode VARCHAR(20),
										TargetMaterialWarehouseCode VARCHAR(20),
										RefMaterialDocNo VARCHAR(20),
										PONo VARCHAR(20),
										FPItemWorkNo VARCHAR(20),
										RequestDateTime DATETIMEOFFSET,
										RequestUserID VARCHAR(20),
										RequestPlanDate DATETIMEOFFSET,
										RequestDesc NVARCHAR(200),
										RequestFixDateTime DATETIMEOFFSET,
										RequestFixUserID VARCHAR(20),
										IsRequestFix BIT,
										RequestApprovalDateTime DATETIMEOFFSET,
										RequestApprovalUserID VARCHAR(20),
										IsRequestApproval BIT,
										IsAssignPicking BIT,
										PickingStartDateTime DATETIMEOFFSET,
										PickingEndDateTime DATETIMEOFFSET,
										PickingUserID VARCHAR(20),
										IsPickingFix BIT,
										IsSourceFinish BIT,
										SourceProcessDateTime DATETIMEOFFSET,
										SourceProcessUserID VARCHAR(20),
										IsTargetFinish BIT,
										TargetProcessDateTime DATETIMEOFFSET,
										TargetProcessUserID VARCHAR(20),
										TotalPlanPrice NUMERIC(20,5),
										TotalActualPrice NUMERIC(20,5),
										IsCancel BIT,
										CancelUserID VARCHAR(20),
										CancelReason NVARCHAR(200),
										CancelDateTime DATETIME,				
										MRMIExtText01 NVARCHAR(MAX),
										MRMIExtText02 NVARCHAR(MAX),
										MRMIExtText03 NVARCHAR(MAX),
										MRMIExtText04 NVARCHAR(MAX),
										MRMIExtText05 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MDIErpRefText01 NVARCHAR(50),
										MDIErpRefText02 NVARCHAR(50),
										MDIErpRefText03 NVARCHAR(50),
										MDIErpRefText04 NVARCHAR(50),
										MDIErpRefText05 NVARCHAR(50),
										MDIErpRefText06 NVARCHAR(50),
										MDIErpRefText07 NVARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialDocNo = SourceTable.OldMaterialDocNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialDocNo = SourceTable.MaterialDocNo,
					BasicDate = SourceTable.BasicDate,
					MaterialDocType = SourceTable.MaterialDocType,
					MaterialDocTypeCode = SourceTable.MaterialDocTypeCode,
					DocStatus = SourceTable.DocStatus,
					SourceCustomerCode = SourceTable.SourceCustomerCode,
					SourceCompanyCode = SourceTable.SourceCompanyCode,
					SourceWorkCenterCode = SourceTable.SourceWorkCenterCode,
					SourceRouteCode = SourceTable.SourceRouteCode,
					SourceMaterialWarehouseCode = SourceTable.SourceMaterialWarehouseCode,
					TargetCustomerCode = SourceTable.TargetCustomerCode,
					TargetCompanyCode = SourceTable.TargetCompanyCode,
					TargetWorkCenterCode = SourceTable.TargetWorkCenterCode,
					TargetRouteCode = SourceTable.TargetRouteCode,
					TargetMaterialWarehouseCode = SourceTable.TargetMaterialWarehouseCode,
					RefMaterialDocNo = SourceTable.RefMaterialDocNo,
					PONo = SourceTable.PONo,
					FPItemWorkNo = SourceTable.FPItemWorkNo,
					RequestDateTime = SourceTable.RequestDateTime,
					RequestUserID = SourceTable.RequestUserID,
					RequestPlanDate = SourceTable.RequestPlanDate,
					RequestDesc = SourceTable.RequestDesc,
					RequestFixDateTime = SourceTable.RequestFixDateTime,
					RequestFixUserID = SourceTable.RequestFixUserID,
					IsRequestFix = SourceTable.IsRequestFix,
					RequestApprovalDateTime = SourceTable.RequestApprovalDateTime,
					RequestApprovalUserID = SourceTable.RequestApprovalUserID,
					IsRequestApproval = SourceTable.IsRequestApproval,
					IsAssignPicking = SourceTable.IsAssignPicking,
					PickingStartDateTime = SourceTable.PickingStartDateTime,
					PickingEndDateTime = SourceTable.PickingEndDateTime,
					PickingUserID = SourceTable.PickingUserID,
					IsPickingFix = SourceTable.IsPickingFix,
					IsSourceFinish = SourceTable.IsSourceFinish,
					SourceProcessDateTime = SourceTable.SourceProcessDateTime,
					SourceProcessUserID = SourceTable.SourceProcessUserID,
					IsTargetFinish = SourceTable.IsTargetFinish,
					TargetProcessDateTime = SourceTable.TargetProcessDateTime,
					TargetProcessUserID = SourceTable.TargetProcessUserID,
					TotalPlanPrice = SourceTable.TotalPlanPrice,
					TotalActualPrice = SourceTable.TotalActualPrice,
					IsCancel = SourceTable.IsCancel,
					CancelUserID = SourceTable.CancelUserID,
					CancelReason = SourceTable.CancelReason,
					CancelDateTime = SourceTable.CancelDateTime,
					MRMIExtText01 = SourceTable.MRMIExtText01,
					MRMIExtText02 = SourceTable.MRMIExtText02,
					MRMIExtText03 = SourceTable.MRMIExtText03,
					MRMIExtText04 = SourceTable.MRMIExtText04,
					MRMIExtText05 = SourceTable.MRMIExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					MDIErpRefText01 = SourceTable.MDIErpRefText01,
					MDIErpRefText02 = SourceTable.MDIErpRefText02,
					MDIErpRefText03 = SourceTable.MDIErpRefText03,
					MDIErpRefText04 = SourceTable.MDIErpRefText04,
					MDIErpRefText05 = SourceTable.MDIErpRefText05,
					MDIErpRefText06 = SourceTable.MDIErpRefText06,
					MDIErpRefText07 = SourceTable.MDIErpRefText07
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialDocNo,
						BasicDate,
						MaterialDocType,
						MaterialDocTypeCode,
						DocStatus,
						SourceCustomerCode,
						SourceCompanyCode,
						SourceWorkCenterCode,
						SourceRouteCode,
						SourceMaterialWarehouseCode,
						TargetCustomerCode,
						TargetCompanyCode,
						TargetWorkCenterCode,
						TargetRouteCode,
						TargetMaterialWarehouseCode,
						RefMaterialDocNo,
						PONo,
						FPItemWorkNo,
						RequestDateTime,
						RequestUserID,
						RequestPlanDate,
						RequestDesc,
						RequestFixDateTime,
						RequestFixUserID,
						IsRequestFix,
						RequestApprovalDateTime,
						RequestApprovalUserID,
						IsRequestApproval,
						IsAssignPicking,
						PickingStartDateTime,
						PickingEndDateTime,
						PickingUserID,
						IsPickingFix,
						IsSourceFinish,
						SourceProcessDateTime,
						SourceProcessUserID,
						IsTargetFinish,
						TargetProcessDateTime,
						TargetProcessUserID,
						TotalPlanPrice,
						TotalActualPrice,
						IsCancel,
						CancelUserID,
						CancelReason,
						CancelDateTime,					
						MRMIExtText01,
						MRMIExtText02,
						MRMIExtText03,
						MRMIExtText04,
						MRMIExtText05,
						CreateDateTime,
						CreateUserID,
						MDIErpRefText01,
						MDIErpRefText02,
						MDIErpRefText03,
						MDIErpRefText04,
						MDIErpRefText05,
						MDIErpRefText06,
						MDIErpRefText07

					)
				VALUES
					(
							SourceTable.MaterialDocNo,
							SourceTable.BasicDate,
							SourceTable.MaterialDocType,
							SourceTable.MaterialDocTypeCode,
							SourceTable.DocStatus,
							SourceTable.SourceCustomerCode,
							SourceTable.SourceCompanyCode,
							SourceTable.SourceWorkCenterCode,
							SourceTable.SourceRouteCode,
							SourceTable.SourceMaterialWarehouseCode,
							SourceTable.TargetCustomerCode,
							SourceTable.TargetCompanyCode,
							SourceTable.TargetWorkCenterCode,
							SourceTable.TargetRouteCode,
							SourceTable.TargetMaterialWarehouseCode,
							SourceTable.RefMaterialDocNo,
							SourceTable.PONo,
							SourceTable.FPItemWorkNo,
							SourceTable.RequestDateTime,
							SourceTable.RequestUserID,
							SourceTable.RequestPlanDate,
							SourceTable.RequestDesc,
							SourceTable.RequestFixDateTime,
							SourceTable.RequestFixUserID,
							SourceTable.IsRequestFix,
							SourceTable.RequestApprovalDateTime,
							SourceTable.RequestApprovalUserID,
							SourceTable.IsRequestApproval,
							SourceTable.IsAssignPicking,
							SourceTable.PickingStartDateTime,
							SourceTable.PickingEndDateTime,
							SourceTable.PickingUserID,
							SourceTable.IsPickingFix,
							SourceTable.IsSourceFinish,
							SourceTable.SourceProcessDateTime,
							SourceTable.SourceProcessUserID,
							SourceTable.IsTargetFinish,
							SourceTable.TargetProcessDateTime,
							SourceTable.TargetProcessUserID,
							SourceTable.TotalPlanPrice,
							SourceTable.TotalActualPrice,
							SourceTable.IsCancel,
							SourceTable.CancelUserID,
							SourceTable.CancelReason,
							SourceTable.CancelDateTime,						
							SourceTable.MRMIExtText01,
							SourceTable.MRMIExtText02,
							SourceTable.MRMIExtText03,
							SourceTable.MRMIExtText04,
							SourceTable.MRMIExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MDIErpRefText01,
							SourceTable.MDIErpRefText02,
							SourceTable.MDIErpRefText03,
							SourceTable.MDIErpRefText04,
							SourceTable.MDIErpRefText05,
							SourceTable.MDIErpRefText06,
							SourceTable.MDIErpRefText07
					);


			-- Process Delete Table
            MERGE STB_MaterialDocInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialDocNo IS NULL THEN MaterialDocNo
							    ELSE OldMaterialDocNo
							END AS OldMaterialDocNo,
							MaterialDocNo,
							BasicDate,
							MaterialDocType,
							MaterialDocTypeCode,
							DocStatus,
							SourceCustomerCode,
							SourceCompanyCode,
							SourceWorkCenterCode,
							SourceRouteCode,
							SourceMaterialWarehouseCode,
							TargetCustomerCode,
							TargetCompanyCode,
							TargetWorkCenterCode,
							TargetRouteCode,
							TargetMaterialWarehouseCode,
							RefMaterialDocNo,
							PONo,
							FPItemWorkNo,
							RequestDateTime,
							RequestUserID,
							RequestPlanDate,
							RequestDesc,
							RequestFixDateTime,
							RequestFixUserID,
							IsRequestFix,
							RequestApprovalDateTime,
							RequestApprovalUserID,
							IsRequestApproval,
							IsAssignPicking,
							PickingStartDateTime,
							PickingEndDateTime,
							PickingUserID,
							IsPickingFix,
							IsSourceFinish,
							SourceProcessDateTime,
							SourceProcessUserID,
							IsTargetFinish,
							TargetProcessDateTime,
							TargetProcessUserID,
							TotalPlanPrice,
							TotalActualPrice,
							IsCancel,
							CancelUserID,
							CancelReason,
							CancelDateTime,							
							MRMIExtText01,
							MRMIExtText02,
							MRMIExtText03,
							MRMIExtText04,
							MRMIExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MDIErpRefText01,
							MDIErpRefText02,
							MDIErpRefText03,
							MDIErpRefText04,
							MDIErpRefText05,
							MDIErpRefText06,
							MDIErpRefText07
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialDocNo VARCHAR(20),
										MaterialDocNo VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										MaterialDocType VARCHAR(20),
										MaterialDocTypeCode VARCHAR(20),
										DocStatus VARCHAR(20),
										SourceCustomerCode VARCHAR(20),
										SourceCompanyCode VARCHAR(20),
										SourceWorkCenterCode VARCHAR(20),
										SourceRouteCode VARCHAR(20),
										SourceMaterialWarehouseCode VARCHAR(20),
										TargetCustomerCode VARCHAR(20),
										TargetCompanyCode VARCHAR(20),
										TargetWorkCenterCode VARCHAR(20),
										TargetRouteCode VARCHAR(20),
										TargetMaterialWarehouseCode VARCHAR(20),
										RefMaterialDocNo VARCHAR(20),
										PONo VARCHAR(20),
										FPItemWorkNo VARCHAR(20),
										RequestDateTime DATETIMEOFFSET,
										RequestUserID VARCHAR(20),
										RequestPlanDate DATETIMEOFFSET,
										RequestDesc NVARCHAR(200),
										RequestFixDateTime DATETIMEOFFSET,
										RequestFixUserID VARCHAR(20),
										IsRequestFix BIT,
										RequestApprovalDateTime DATETIMEOFFSET,
										RequestApprovalUserID VARCHAR(20),
										IsRequestApproval BIT,
										IsAssignPicking BIT,
										PickingStartDateTime DATETIMEOFFSET,
										PickingEndDateTime DATETIMEOFFSET,
										PickingUserID VARCHAR(20),
										IsPickingFix BIT,
										IsSourceFinish BIT,
										SourceProcessDateTime DATETIMEOFFSET,
										SourceProcessUserID VARCHAR(20),
										IsTargetFinish BIT,
										TargetProcessDateTime DATETIMEOFFSET,
										TargetProcessUserID VARCHAR(20),
										TotalPlanPrice NUMERIC(20,5),
										TotalActualPrice NUMERIC(20,5),
										IsCancel BIT,
										CancelUserID VARCHAR(20),
										CancelReason NVARCHAR(200),
										CancelDateTime DATETIME,														
										MRMIExtText01 NVARCHAR(MAX),
										MRMIExtText02 NVARCHAR(MAX),
										MRMIExtText03 NVARCHAR(MAX),
										MRMIExtText04 NVARCHAR(MAX),
										MRMIExtText05 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MDIErpRefText01 NVARCHAR(50),
										MDIErpRefText02 NVARCHAR(50),
										MDIErpRefText03 NVARCHAR(50),
										MDIErpRefText04 NVARCHAR(50),
										MDIErpRefText05 NVARCHAR(50),
										MDIErpRefText06 NVARCHAR(50),
										MDIErpRefText07 NVARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialDocNo = SourceTable.MaterialDocNo
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
									OldMaterialDocNo,
									MaterialDocNo,
									BasicDate,
									MaterialDocType,
									MaterialDocTypeCode,
									DocStatus,
									SourceCustomerCode,
									SourceCompanyCode,
									SourceWorkCenterCode,
									SourceRouteCode,
									SourceMaterialWarehouseCode,
									TargetCustomerCode,
									TargetCompanyCode,
									TargetWorkCenterCode,
									TargetRouteCode,
									TargetMaterialWarehouseCode,
									RefMaterialDocNo,
									PONo,
									FPItemWorkNo,
									RequestDateTime,
									RequestUserID,
									RequestPlanDate,
									RequestDesc,
									RequestFixDateTime,
									RequestFixUserID,
									IsRequestFix,
									RequestApprovalDateTime,
									RequestApprovalUserID,
									IsRequestApproval,
									IsAssignPicking,
									PickingStartDateTime,
									PickingEndDateTime,
									PickingUserID,
									IsPickingFix,
									IsSourceFinish,
									SourceProcessDateTime,
									SourceProcessUserID,
									IsTargetFinish,
									TargetProcessDateTime,
									TargetProcessUserID,
									TotalPlanPrice,
									TotalActualPrice,
									IsCancel,
									CancelUserID,
									CancelReason,
									CancelDateTime,
									MRMIExtText01,
									MRMIExtText02,
									MRMIExtText03,
									MRMIExtText04,
									MRMIExtText05,
									MDIErpRefText01,
									MDIErpRefText02,
									MDIErpRefText03,
									MDIErpRefText04,
									MDIErpRefText05,
									MDIErpRefText06,
									MDIErpRefText07,
									MDIErpRefText08,
									MDIErpRefText09,
									MDIErpRefText10,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialDocNo VARCHAR(20),
											 MaterialDocNo VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 MaterialDocType VARCHAR(20),
											 MaterialDocTypeCode VARCHAR(20),
											 DocStatus VARCHAR(20),
											 SourceCustomerCode VARCHAR(20),
											 SourceCompanyCode VARCHAR(20),
											 SourceWorkCenterCode VARCHAR(20),
											 SourceRouteCode VARCHAR(20),
											 SourceMaterialWarehouseCode VARCHAR(20),
											 TargetCustomerCode VARCHAR(20),
											 TargetCompanyCode VARCHAR(20),
											 TargetWorkCenterCode VARCHAR(20),
											 TargetRouteCode VARCHAR(20),
											 TargetMaterialWarehouseCode VARCHAR(20),
											 RefMaterialDocNo VARCHAR(20),
											 PONo VARCHAR(20),
											 FPItemWorkNo VARCHAR(20),
											 RequestDateTime DATETIMEOFFSET,
											 RequestUserID VARCHAR(20),
											 RequestPlanDate DATETIMEOFFSET,
											 RequestDesc NVARCHAR(200),
											 RequestFixDateTime DATETIMEOFFSET,
											 RequestFixUserID VARCHAR(20),
											 IsRequestFix BIT,
											 RequestApprovalDateTime DATETIMEOFFSET,
											 RequestApprovalUserID VARCHAR(20),
											 IsRequestApproval BIT,
											 IsAssignPicking BIT,
											 PickingStartDateTime DATETIMEOFFSET,
											 PickingEndDateTime DATETIMEOFFSET,
											 PickingUserID VARCHAR(20),
											 IsPickingFix BIT,
											 IsSourceFinish BIT,
											 SourceProcessDateTime DATETIMEOFFSET,
											 SourceProcessUserID VARCHAR(20),
											 IsTargetFinish BIT,
											 TargetProcessDateTime DATETIMEOFFSET,
											 TargetProcessUserID VARCHAR(20),
											 TotalPlanPrice NUMERIC(20,5),
											 TotalActualPrice NUMERIC(20,5),
											 IsCancel BIT,
											 CancelUserID VARCHAR(20),
											 CancelReason NVARCHAR(200),
											 CancelDateTime DATETIME,														 
											 MRMIExtText01 NVARCHAR(MAX),
											 MRMIExtText02 NVARCHAR(MAX),
											 MRMIExtText03 NVARCHAR(MAX),
											 MRMIExtText04 NVARCHAR(MAX),
											 MRMIExtText05 NVARCHAR(MAX),
											 MDIErpRefText01 NVARCHAR(MAX),
											 MDIErpRefText02 NVARCHAR(MAX),
											 MDIErpRefText03 NVARCHAR(MAX),
											 MDIErpRefText04 NVARCHAR(MAX),
											 MDIErpRefText05 NVARCHAR(MAX),
											 MDIErpRefText06 NVARCHAR(MAX),
											 MDIErpRefText07 NVARCHAR(MAX),
											 MDIErpRefText08 NVARCHAR(MAX),
											 MDIErpRefText09 NVARCHAR(MAX),
											 MDIErpRefText10 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialDocNo IS NULL THEN MaterialDocNo
										ELSE OldMaterialDocNo
									END AS OldMaterialDocNo,
									MaterialDocNo,
									BasicDate,
									MaterialDocType,
									MaterialDocTypeCode,
									DocStatus,
									SourceCustomerCode,
									SourceCompanyCode,
									SourceWorkCenterCode,
									SourceRouteCode,
									SourceMaterialWarehouseCode,
									TargetCustomerCode,
									TargetCompanyCode,
									TargetWorkCenterCode,
									TargetRouteCode,
									TargetMaterialWarehouseCode,
									RefMaterialDocNo,
									PONo,
									FPItemWorkNo,
									RequestDateTime,
									RequestUserID,
									RequestPlanDate,
									RequestDesc,
									RequestFixDateTime,
									RequestFixUserID,
									IsRequestFix,
									RequestApprovalDateTime,
									RequestApprovalUserID,
									IsRequestApproval,
									IsAssignPicking,
									PickingStartDateTime,
									PickingEndDateTime,
									PickingUserID,
									IsPickingFix,
									IsSourceFinish,
									SourceProcessDateTime,
									SourceProcessUserID,
									IsTargetFinish,
									TargetProcessDateTime,
									TargetProcessUserID,
									TotalPlanPrice,
									TotalActualPrice,
									IsCancel,
									CancelUserID,
									CancelReason,
									CancelDateTime,
									MRMIExtText01,
									MRMIExtText02,
									MRMIExtText03,
									MRMIExtText04,
									MRMIExtText05,
									MDIErpRefText01,
									MDIErpRefText02,
									MDIErpRefText03,
									MDIErpRefText04,
									MDIErpRefText05,
									MDIErpRefText06,
									MDIErpRefText07,
									MDIErpRefText08,
									MDIErpRefText09,
									MDIErpRefText10,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialDocNo VARCHAR(20),
											 MaterialDocNo VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 MaterialDocType VARCHAR(20),
											 MaterialDocTypeCode VARCHAR(20),
											 DocStatus VARCHAR(20),
											 SourceCustomerCode VARCHAR(20),
											 SourceCompanyCode VARCHAR(20),
											 SourceWorkCenterCode VARCHAR(20),
											 SourceRouteCode VARCHAR(20),
											 SourceMaterialWarehouseCode VARCHAR(20),
											 TargetCustomerCode VARCHAR(20),
											 TargetCompanyCode VARCHAR(20),
											 TargetWorkCenterCode VARCHAR(20),
											 TargetRouteCode VARCHAR(20),
											 TargetMaterialWarehouseCode VARCHAR(20),
											 RefMaterialDocNo VARCHAR(20),
											 PONo VARCHAR(20),
											 FPItemWorkNo VARCHAR(20),
											 RequestDateTime DATETIMEOFFSET,
											 RequestUserID VARCHAR(20),
											 RequestPlanDate DATETIMEOFFSET,
											 RequestDesc NVARCHAR(200),
											 RequestFixDateTime DATETIMEOFFSET,
											 RequestFixUserID VARCHAR(20),
											 IsRequestFix BIT,
											 RequestApprovalDateTime DATETIMEOFFSET,
											 RequestApprovalUserID VARCHAR(20),
											 IsRequestApproval BIT,
											 IsAssignPicking BIT,
											 PickingStartDateTime DATETIMEOFFSET,
											 PickingEndDateTime DATETIMEOFFSET,
											 PickingUserID VARCHAR(20),
											 IsPickingFix BIT,
											 IsSourceFinish BIT,
											 SourceProcessDateTime DATETIMEOFFSET,
											 SourceProcessUserID VARCHAR(20),
											 IsTargetFinish BIT,
											 TargetProcessDateTime DATETIMEOFFSET,
											 TargetProcessUserID VARCHAR(20),
											 TotalPlanPrice NUMERIC(20,5),
											 TotalActualPrice NUMERIC(20,5),
											 IsCancel BIT,
											 CancelUserID VARCHAR(20),
											 CancelReason NVARCHAR(200),
											 CancelDateTime DATETIME,														 
											 MRMIExtText01 NVARCHAR(MAX),
											 MRMIExtText02 NVARCHAR(MAX),
											 MRMIExtText03 NVARCHAR(MAX),
											 MRMIExtText04 NVARCHAR(MAX),
											 MRMIExtText05 NVARCHAR(MAX),
											 MDIErpRefText01 NVARCHAR(MAX),
											 MDIErpRefText02 NVARCHAR(MAX),
											 MDIErpRefText03 NVARCHAR(MAX),
											 MDIErpRefText04 NVARCHAR(MAX),
											 MDIErpRefText05 NVARCHAR(MAX),
											 MDIErpRefText06 NVARCHAR(MAX),
											 MDIErpRefText07 NVARCHAR(MAX),
											 MDIErpRefText08 NVARCHAR(MAX),
											 MDIErpRefText09 NVARCHAR(MAX),
											 MDIErpRefText10 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialDocNo IS NULL THEN MaterialDocNo
										ELSE OldMaterialDocNo
									END AS OldMaterialDocNo,
									MaterialDocNo,
									BasicDate,
									MaterialDocType,
									MaterialDocTypeCode,
									DocStatus,
									SourceCustomerCode,
									SourceCompanyCode,
									SourceWorkCenterCode,
									SourceRouteCode,
									SourceMaterialWarehouseCode,
									TargetCustomerCode,
									TargetCompanyCode,
									TargetWorkCenterCode,
									TargetRouteCode,
									TargetMaterialWarehouseCode,
									RefMaterialDocNo,
									PONo,
									FPItemWorkNo,
									RequestDateTime,
									RequestUserID,
									RequestPlanDate,
									RequestDesc,
									RequestFixDateTime,
									RequestFixUserID,
									IsRequestFix,
									RequestApprovalDateTime,
									RequestApprovalUserID,
									IsRequestApproval,
									IsAssignPicking,
									PickingStartDateTime,
									PickingEndDateTime,
									PickingUserID,
									IsPickingFix,
									IsSourceFinish,
									SourceProcessDateTime,
									SourceProcessUserID,
									IsTargetFinish,
									TargetProcessDateTime,
									TargetProcessUserID,
									TotalPlanPrice,
									TotalActualPrice,
									IsCancel,
									CancelUserID,
									CancelReason,
									CancelDateTime,																
									MRMIExtText01,
									MRMIExtText02,
									MRMIExtText03,
									MRMIExtText04,
									MRMIExtText05,
									MDIErpRefText01,
									MDIErpRefText02,
									MDIErpRefText03,
									MDIErpRefText04,
									MDIErpRefText05,
									MDIErpRefText06,
									MDIErpRefText07,
									MDIErpRefText08,
									MDIErpRefText09,
									MDIErpRefText10,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialDocNo VARCHAR(20),
											 MaterialDocNo VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 MaterialDocType VARCHAR(20),
											 MaterialDocTypeCode VARCHAR(20),
											 DocStatus VARCHAR(20),
											 SourceCustomerCode VARCHAR(20),
											 SourceCompanyCode VARCHAR(20),
											 SourceWorkCenterCode VARCHAR(20),
											 SourceRouteCode VARCHAR(20),
											 SourceMaterialWarehouseCode VARCHAR(20),
											 TargetCustomerCode VARCHAR(20),
											 TargetCompanyCode VARCHAR(20),
											 TargetWorkCenterCode VARCHAR(20),
											 TargetRouteCode VARCHAR(20),
											 TargetMaterialWarehouseCode VARCHAR(20),
											 RefMaterialDocNo VARCHAR(20),
											 PONo VARCHAR(20),
											 FPItemWorkNo VARCHAR(20),
											 RequestDateTime DATETIMEOFFSET,
											 RequestUserID VARCHAR(20),
											 RequestPlanDate DATETIMEOFFSET,
											 RequestDesc NVARCHAR(200),
											 RequestFixDateTime DATETIMEOFFSET,
											 RequestFixUserID VARCHAR(20),
											 IsRequestFix BIT,
											 RequestApprovalDateTime DATETIMEOFFSET,
											 RequestApprovalUserID VARCHAR(20),
											 IsRequestApproval BIT,
											 IsAssignPicking BIT,
											 PickingStartDateTime DATETIMEOFFSET,
											 PickingEndDateTime DATETIMEOFFSET,
											 PickingUserID VARCHAR(20),
											 IsPickingFix BIT,
											 IsSourceFinish BIT,
											 SourceProcessDateTime DATETIMEOFFSET,
											 SourceProcessUserID VARCHAR(20),
											 IsTargetFinish BIT,
											 TargetProcessDateTime DATETIMEOFFSET,
											 TargetProcessUserID VARCHAR(20),
											 TotalPlanPrice NUMERIC(20,5),
											 TotalActualPrice NUMERIC(20,5),
											 IsCancel BIT,
											 CancelUserID VARCHAR(20),
											 CancelReason NVARCHAR(200),
											 CancelDateTime DATETIME,														 
											 MRMIExtText01 NVARCHAR(MAX),
											 MRMIExtText02 NVARCHAR(MAX),
											 MRMIExtText03 NVARCHAR(MAX),
											 MRMIExtText04 NVARCHAR(MAX),
											 MRMIExtText05 NVARCHAR(MAX),
											 MDIErpRefText01 NVARCHAR(MAX),
											 MDIErpRefText02 NVARCHAR(MAX),
											 MDIErpRefText03 NVARCHAR(MAX),
											 MDIErpRefText04 NVARCHAR(MAX),
											 MDIErpRefText05 NVARCHAR(MAX),
											 MDIErpRefText06 NVARCHAR(MAX),
											 MDIErpRefText07 NVARCHAR(MAX),
											 MDIErpRefText08 NVARCHAR(MAX),
											 MDIErpRefText09 NVARCHAR(MAX),
											 MDIErpRefText10 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialDocNo,
								 @MaterialDocNo,
								 @BasicDate,
								 @MaterialDocType,
								 @MaterialDocTypeCode,
								 @DocStatus,
								 @SourceCustomerCode,
								 @SourceCompanyCode,
								 @SourceWorkCenterCode,
								 @SourceRouteCode,
								 @SourceMaterialWarehouseCode,
								 @TargetCustomerCode,
								 @TargetCompanyCode,
								 @TargetWorkCenterCode,
								 @TargetRouteCode,
								 @TargetMaterialWarehouseCode,
								 @RefMaterialDocNo,
								 @PONo,
								 @FPItemWorkNo,
								 @RequestDateTime,
								 @RequestUserID,
								 @RequestPlanDate,
								 @RequestDesc,
								 @RequestFixDateTime,
								 @RequestFixUserID,
								 @IsRequestFix,
								 @RequestApprovalDateTime,
								 @RequestApprovalUserID,
								 @IsRequestApproval,
								 @IsAssignPicking,
								 @PickingStartDateTime,
								 @PickingEndDateTime,
								 @PickingUserID,
								 @IsPickingFix,
								 @IsSourceFinish,
								 @SourceProcessDateTime,
								 @SourceProcessUserID,
								 @IsTargetFinish,
								 @TargetProcessDateTime,
								 @TargetProcessUserID,
								 @TotalPlanPrice,
								 @TotalActualPrice,
								 @IsCancel,
								 @CancelUserID,
								 @CancelReason,
								 @CancelDateTime,													 
								 @MRMIExtText01,
								 @MRMIExtText02,
								 @MRMIExtText03,
								 @MRMIExtText04,
								 @MRMIExtText05,
								 @MDIErpRefText01,
								 @MDIErpRefText02,
								 @MDIErpRefText03,
								 @MDIErpRefText04,
								 @MDIErpRefText05,
								 @MDIErpRefText06,
								 @MDIErpRefText07,
								 @MDIErpRefText08,
								 @MDIErpRefText09,
								 @MDIErpRefText10,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialDocInfo WHERE MaterialDocNo = @MaterialDocNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialDocNo)
					END

                    IF (@IsAutoKey = 1) AND (ISNULL(@MaterialDocNo,'')='') BEGIN
						EXEC Smartframework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo', @MaterialDocNo OUTPUT
						
						IF OBJECT_ID(N'tempdb..#SEQUENCE_TABLE', N'U') IS NOT NULL BEGIN
						-- 임시 SEQUENCE TABLE 사용 버젼
							INSERT INTO #SEQUENCE_TABLE
								(KeyValue, UID_KEY)
							VALUES
								(@MaterialDocNo, @OldMaterialDocNo)
						--   							
						END
                    END

                    INSERT INTO STB_MaterialDocInfo
						(
						    MaterialDocNo,
						    BasicDate,
						    MaterialDocType,
						    MaterialDocTypeCode,
						    DocStatus,
						    SourceCustomerCode,
						    SourceCompanyCode,
						    SourceWorkCenterCode,
						    SourceRouteCode,
						    SourceMaterialWarehouseCode,
						    TargetCustomerCode,
						    TargetCompanyCode,
						    TargetWorkCenterCode,
						    TargetRouteCode,
						    TargetMaterialWarehouseCode,
						    RefMaterialDocNo,
							PONo,
						    FPItemWorkNo,
						    RequestDateTime,
						    RequestUserID,
						    RequestPlanDate,
						    RequestDesc,
						    RequestFixDateTime,
						    RequestFixUserID,
						    IsRequestFix,
						    RequestApprovalDateTime,
						    RequestApprovalUserID,
						    IsRequestApproval,
						    IsAssignPicking,
						    PickingStartDateTime,
						    PickingEndDateTime,
						    PickingUserID,
						    IsPickingFix,
						    IsSourceFinish,
						    SourceProcessDateTime,
						    SourceProcessUserID,
						    IsTargetFinish,
						    TargetProcessDateTime,
						    TargetProcessUserID,
						    TotalPlanPrice,
						    TotalActualPrice,
							IsCancel,
							CancelUserID,
							CancelReason,
							CancelDateTime,							
						    MRMIExtText01,
						    MRMIExtText02,
						    MRMIExtText03,
						    MRMIExtText04,
						    MRMIExtText05,
							MDIErpRefText01,
							MDIErpRefText02,
							MDIErpRefText03,
							MDIErpRefText04,
							MDIErpRefText05,
							MDIErpRefText06,
							MDIErpRefText07,
							MDIErpRefText08,
							MDIErpRefText09,
							MDIErpRefText10,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialDocNo,
						    @BasicDate,
						    @MaterialDocType,
						    @MaterialDocTypeCode,
						    @DocStatus,
						    @SourceCustomerCode,
						    @SourceCompanyCode,
						    @SourceWorkCenterCode,
						    @SourceRouteCode,
						    @SourceMaterialWarehouseCode,
						    @TargetCustomerCode,
						    @TargetCompanyCode,
						    @TargetWorkCenterCode,
						    @TargetRouteCode,
						    @TargetMaterialWarehouseCode,
						    @RefMaterialDocNo,
							@PONo,
						    @FPItemWorkNo,
						    GETDATE(), --@RequestDateTime,
						    @RequestUserID,
						    @RequestPlanDate,
						    @RequestDesc,
						    @RequestFixDateTime,
						    @RequestFixUserID,
						    ISNULL(@IsRequestFix, CONVERT(BIT, 0)),
						    @RequestApprovalDateTime,
						    @RequestApprovalUserID,
						    ISNULL(@IsRequestApproval, CONVERT(BIT, 0)),
						    ISNULL(@IsAssignPicking, CONVERT(BIT, 0)),
						    @PickingStartDateTime,
						    @PickingEndDateTime,
						    @PickingUserID,
						    ISNULL(@IsPickingFix, CONVERT(BIT, 0)),
						    ISNULL(@IsSourceFinish, CONVERT(BIT, 0)),
						    @SourceProcessDateTime,
						    @SourceProcessUserID,
						    ISNULL(@IsTargetFinish, CONVERT(BIT, 0)),
						    @TargetProcessDateTime,
						    @TargetProcessUserID,
						    @TotalPlanPrice,
						    @TotalActualPrice,
							@IsCancel,
							@CancelUserID,
							@CancelReason,
							@CancelDateTime,							
						    @MRMIExtText01,
						    @MRMIExtText02,
						    @MRMIExtText03,
						    @MRMIExtText04,
						    @MRMIExtText05,
							@MDIErpRefText01,
							@MDIErpRefText02,
							@MDIErpRefText03,
							@MDIErpRefText04,
							@MDIErpRefText05,
							@MDIErpRefText06,
							@MDIErpRefText07,
							@MDIErpRefText08,
							@MDIErpRefText09,
							@MDIErpRefText10,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					SELECT
							@BefDocStatus = MDI.DocStatus,
							@BefIsCancel = MDI.IsCancel
					FROM
							STB_MaterialDocInfo MDI
					WHERE
							MDI.MaterialDocNo = @MaterialDocNo

					IF @BefDocStatus <> 'CREATE' 
					BEGIN
							RAISERROR('작업이 진행된 문서는 수정할 수 없습니다', 16, 1)
							RETURN
					END
							

                    UPDATE STB_MaterialDocInfo
						SET
						    MaterialDocNo =   CASE
						                WHEN @MaterialDocNo IS NOT NULL THEN @MaterialDocNo
						                ELSE MaterialDocNo
						            END,
						    BasicDate =   CASE
						                WHEN @BasicDate IS NOT NULL THEN @BasicDate
						                ELSE BasicDate
						            END,
						    MaterialDocType =   CASE
						                WHEN @MaterialDocType IS NOT NULL THEN @MaterialDocType
						                ELSE MaterialDocType
						            END,
						    MaterialDocTypeCode =   CASE
						                WHEN @MaterialDocTypeCode IS NOT NULL THEN @MaterialDocTypeCode
						                ELSE MaterialDocTypeCode
						            END,
						    DocStatus =   CASE
						                WHEN @DocStatus IS NOT NULL THEN @DocStatus
						                ELSE DocStatus
						            END,
						    SourceCustomerCode =   CASE
						                WHEN @SourceCustomerCode IS NOT NULL THEN @SourceCustomerCode
						                ELSE SourceCustomerCode
						            END,
						    SourceCompanyCode =   CASE
						                WHEN @SourceCompanyCode IS NOT NULL THEN @SourceCompanyCode
						                ELSE SourceCompanyCode
						            END,
						    SourceWorkCenterCode =   CASE
						                WHEN @SourceWorkCenterCode IS NOT NULL THEN @SourceWorkCenterCode
						                ELSE SourceWorkCenterCode
						            END,
						    SourceRouteCode =   CASE
						                WHEN @SourceRouteCode IS NOT NULL THEN @SourceRouteCode
						                ELSE SourceRouteCode
						            END,
						    SourceMaterialWarehouseCode =   CASE
						                WHEN @SourceMaterialWarehouseCode IS NOT NULL THEN @SourceMaterialWarehouseCode
						                ELSE SourceMaterialWarehouseCode
						            END,
						    TargetCustomerCode =   CASE
						                WHEN @TargetCustomerCode IS NOT NULL THEN @TargetCustomerCode
						                ELSE TargetCustomerCode
						            END,
						    TargetCompanyCode =   CASE
						                WHEN @TargetCompanyCode IS NOT NULL THEN @TargetCompanyCode
						                ELSE TargetCompanyCode
						            END,
						    TargetWorkCenterCode =   CASE
						                WHEN @TargetWorkCenterCode IS NOT NULL THEN @TargetWorkCenterCode
						                ELSE TargetWorkCenterCode
						            END,
						    TargetRouteCode =   CASE
						                WHEN @TargetRouteCode IS NOT NULL THEN @TargetRouteCode
						                ELSE TargetRouteCode
						            END,
						    TargetMaterialWarehouseCode =   CASE
						                WHEN @TargetMaterialWarehouseCode IS NOT NULL THEN @TargetMaterialWarehouseCode
						                ELSE TargetMaterialWarehouseCode
						            END,
						    RefMaterialDocNo =   CASE
						                WHEN @RefMaterialDocNo IS NOT NULL THEN @RefMaterialDocNo
						                ELSE RefMaterialDocNo
						            END,
							PONo =   CASE
						                WHEN @PONo IS NOT NULL THEN @PONo
						                ELSE PONo
						            END,
						    FPItemWorkNo =   CASE
						                WHEN @FPItemWorkNo IS NOT NULL THEN @FPItemWorkNo
						                ELSE FPItemWorkNo
						            END,
						    RequestDateTime =   CASE
						                WHEN @RequestDateTime IS NOT NULL THEN @RequestDateTime
						                ELSE RequestDateTime
						            END,
						    RequestUserID =   CASE
						                WHEN @RequestUserID IS NOT NULL THEN @RequestUserID
						                ELSE RequestUserID
						            END,
						    RequestPlanDate =   CASE
						                WHEN @RequestPlanDate IS NOT NULL THEN @RequestPlanDate
						                ELSE RequestPlanDate
						            END,
						    RequestDesc =   CASE
						                WHEN @RequestDesc IS NOT NULL THEN @RequestDesc
						                ELSE RequestDesc
						            END,
						    RequestFixDateTime =   CASE
						                WHEN @RequestFixDateTime IS NOT NULL THEN @RequestFixDateTime
						                ELSE RequestFixDateTime
						            END,
						    RequestFixUserID =   CASE
						                WHEN @RequestFixUserID IS NOT NULL THEN @RequestFixUserID
						                ELSE RequestFixUserID
						            END,
						    IsRequestFix =   CASE
						                WHEN @IsRequestFix IS NOT NULL THEN @IsRequestFix
						                ELSE IsRequestFix
						            END,
						    RequestApprovalDateTime =   CASE
						                WHEN @RequestApprovalDateTime IS NOT NULL THEN @RequestApprovalDateTime
						                ELSE RequestApprovalDateTime
						            END,
						    RequestApprovalUserID =   CASE
						                WHEN @RequestApprovalUserID IS NOT NULL THEN @RequestApprovalUserID
						                ELSE RequestApprovalUserID
						            END,
						    IsRequestApproval =   CASE
						                WHEN @IsRequestApproval IS NOT NULL THEN @IsRequestApproval
						                ELSE IsRequestApproval
						            END,
						    IsAssignPicking =   CASE
						                WHEN @IsAssignPicking IS NOT NULL THEN @IsAssignPicking
						                ELSE IsAssignPicking
						            END,
						    PickingStartDateTime =   CASE
						                WHEN @PickingStartDateTime IS NOT NULL THEN @PickingStartDateTime
						                ELSE PickingStartDateTime
						            END,
						    PickingEndDateTime =   CASE
						                WHEN @PickingEndDateTime IS NOT NULL THEN @PickingEndDateTime
						                ELSE PickingEndDateTime
						            END,
						    PickingUserID =   CASE
						                WHEN @PickingUserID IS NOT NULL THEN @PickingUserID
						                ELSE PickingUserID
						            END,
						    IsPickingFix =   CASE
						                WHEN @IsPickingFix IS NOT NULL THEN @IsPickingFix
						                ELSE IsPickingFix
						            END,
						    IsSourceFinish =   CASE
						                WHEN @IsSourceFinish IS NOT NULL THEN @IsSourceFinish
						                ELSE IsSourceFinish
						            END,
						    SourceProcessDateTime =   CASE
						                WHEN @SourceProcessDateTime IS NOT NULL THEN @SourceProcessDateTime
						                ELSE SourceProcessDateTime
						            END,
						    SourceProcessUserID =   CASE
						                WHEN @SourceProcessUserID IS NOT NULL THEN @SourceProcessUserID
						                ELSE SourceProcessUserID
						            END,
						    IsTargetFinish =   CASE
						                WHEN @IsTargetFinish IS NOT NULL THEN @IsTargetFinish
						                ELSE IsTargetFinish
						            END,
						    TargetProcessDateTime =   CASE
						                WHEN @TargetProcessDateTime IS NOT NULL THEN @TargetProcessDateTime
						                ELSE TargetProcessDateTime
						            END,
						    TargetProcessUserID =   CASE
						                WHEN @TargetProcessUserID IS NOT NULL THEN @TargetProcessUserID
						                ELSE TargetProcessUserID
						            END,
						    TotalPlanPrice =   CASE
						                WHEN @TotalPlanPrice IS NOT NULL THEN @TotalPlanPrice
						                ELSE TotalPlanPrice
						            END,
						    TotalActualPrice =   CASE
						                WHEN @TotalActualPrice IS NOT NULL THEN @TotalActualPrice
						                ELSE TotalActualPrice
						            END,
						    IsCancel =   CASE
						                WHEN @IsCancel IS NOT NULL THEN @IsCancel
						                ELSE IsCancel
						            END,
						    CancelUserID =   CASE
						                WHEN @CancelUserID IS NOT NULL THEN @CancelUserID
						                ELSE CancelUserID
						            END,
						    CancelReason =   CASE
						                WHEN @CancelReason IS NOT NULL THEN @CancelReason
						                ELSE CancelReason
						            END,
						    CancelDateTime =   CASE
						                WHEN @CancelDateTime IS NOT NULL THEN @CancelDateTime
						                ELSE CancelDateTime
						            END,
						    MRMIExtText01 =   CASE
						                WHEN @MRMIExtText01 IS NOT NULL THEN @MRMIExtText01
						                ELSE MRMIExtText01
						            END,
						    MRMIExtText02 =   CASE
						                WHEN @MRMIExtText02 IS NOT NULL THEN @MRMIExtText02
						                ELSE MRMIExtText02
						            END,
						    MRMIExtText03 =   CASE
						                WHEN @MRMIExtText03 IS NOT NULL THEN @MRMIExtText03
						                ELSE MRMIExtText03
						            END,
						    MRMIExtText04 =   CASE
						                WHEN @MRMIExtText04 IS NOT NULL THEN @MRMIExtText04
						                ELSE MRMIExtText04
						            END,
						    MRMIExtText05 =   CASE
						                WHEN @MRMIExtText05 IS NOT NULL THEN @MRMIExtText05
						                ELSE MRMIExtText05
						            END,
						    MDIErpRefText01 =   CASE
						                WHEN @MDIErpRefText01 IS NOT NULL THEN @MDIErpRefText01
						                ELSE MDIErpRefText01
						            END,
						    MDIErpRefText02 =   CASE
						                WHEN @MDIErpRefText02 IS NOT NULL THEN @MDIErpRefText02
						                ELSE MDIErpRefText02
						            END,
						    MDIErpRefText03 =   CASE
						                WHEN @MDIErpRefText03 IS NOT NULL THEN @MDIErpRefText03
						                ELSE MDIErpRefText03
						            END,
						    MDIErpRefText04 =   CASE
						                WHEN @MDIErpRefText04 IS NOT NULL THEN @MDIErpRefText04
						                ELSE MDIErpRefText04
						            END,
						    MDIErpRefText05 =   CASE
						                WHEN @MDIErpRefText05 IS NOT NULL THEN @MDIErpRefText05
						                ELSE MDIErpRefText05
						            END,
						    MDIErpRefText06 =   CASE
						                WHEN @MDIErpRefText06 IS NOT NULL THEN @MDIErpRefText06
						                ELSE MDIErpRefText06
						            END,
						    MDIErpRefText07 =   CASE
						                WHEN @MDIErpRefText07 IS NOT NULL THEN @MDIErpRefText07
						                ELSE MDIErpRefText07
						            END,
						    MDIErpRefText08 =   CASE
						                WHEN @MDIErpRefText08 IS NOT NULL THEN @MDIErpRefText08
						                ELSE MDIErpRefText08
						            END,
						    MDIErpRefText09 =   CASE
						                WHEN @MDIErpRefText09 IS NOT NULL THEN @MDIErpRefText09
						                ELSE MDIErpRefText09
						            END,
						    MDIErpRefText10 =   CASE
						                WHEN @MDIErpRefText10 IS NOT NULL THEN @MDIErpRefText10
						                ELSE MDIErpRefText10
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialDocNo = @OldMaterialDocNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					SELECT
							@BefDocStatus = MDI.DocStatus,
							@BefIsCancel = MDI.IsCancel
					FROM
							STB_MaterialDocInfo MDI
					WHERE
							MDI.MaterialDocNo = @MaterialDocNo

					IF (@BefDocStatus <> 'CREATE') OR (ISNULL(@BefIsCancel,0) = 1)
					BEGIN
							RAISERROR('작업이 진행된 문서나 취소된 문서는 삭제할 수 없습니다', 16, 1)
							RETURN
					END

					IF @MaterialDocType = 'GR'
					BEGIN
							UPDATE STB_MaterialOrderItem 
							SET
									MaterialOrderRemainQty = MaterialOrderRemainQty + MDD.RequestQty
							FROM
									(
										SELECT
												*
										FROM
												STB_MaterialDocDetail MDD
										WHERE
												MDD.MaterialDocNo = @MaterialDocNo
									) MDD
							WHERE
									STB_MaterialOrderItem.MaterialOrderItemNo = MDD.OrderDetailNo

					END

					IF @MaterialDocType = 'GI'
					BEGIN
							UPDATE STB_SalesOrderItem
							SET
									GIPlanQty = GIPlanQty - RequestQty
							FROM
									(
										SELECT
												*
										FROM
												STB_MaterialDocDetail MDD
										WHERE
												MDD.MaterialDocNo = @MaterialDocNo
									) MDD
							WHERE
									STB_SalesOrderItem.SOISequence = MDD.OrderDetailNo

					END

					DELETE FROM STB_MaterialDocDetail
					WHERE
							MaterialDocNo = @MaterialDocNo

                    DELETE FROM STB_MaterialDocInfo
						WHERE
						    MaterialDocNo = @MaterialDocNo

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

