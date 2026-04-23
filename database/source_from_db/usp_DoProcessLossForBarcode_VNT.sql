-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 품질관리
-- Create date: 2018-09-12
-- Description:	제품 폐기처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessLossForBarcode_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectSummaryNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage	
	DECLARE @DefectSummaryNo VARCHAR(20) = @pDefectSummaryNo

	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @LineCode VARCHAR(20)
	DECLARE @RouteCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @Barcode VARCHAR(50)
	DECLARE @DefectQty NUMERIC(20,5)
	DECLARE @IsLoss BIT
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @RepairType VARCHAR(20)

	SELECT
			@ControlNo = DRI.ControlNo,
			@DefectQty = DRI.DefectQty - DRI.LossQty - DRI.RepairQty,
			@Barcode = SI.Barcode,
			@CompanyCode = DRI.CompanyCode,
			@WorkCenterCode = DRI.WorkCenterCode,
			@LineCode = DRI.FindLineCode,
			@RouteCode = DRI.FindRouteCode,
			@IsLoss = SI.IsLoss,
			@RepairType = DRI.RepairType
	FROM
			STB_DefectRepairInfo DRI
			INNER JOIN STB_SetInfo SI				ON SI.ControlNo = DRI.ControlNo
	WHERE
			DRI.DefectSummaryNo = @DefectSummaryNo
			
	IF ISNULL(@IsLoss,0) = 1 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^이미 폐기처리된 제품입니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END

	IF ISNULL(@RepairType,'NONE') <> 'FINISH' BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^수리상세 내역이 입력되지 않았습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END

	UPDATE	STB_SetInfo
	SET
			IsLoss = 1,
			ChangeDateTime = @ProcessDateTime,
			ChangeUserID = @ProcessUserID
	WHERE
			ControlNo = @ControlNo

	UPDATE	STB_DefectRepairInfo
	SET
			RepairType = 'LOSS'
	WHERE
			DefectSummaryNo = @DefectSummaryNo
END
