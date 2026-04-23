-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 현장용
-- Create date: 2018-08-02
-- Description:	공정별 실적 처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessFindDefect]
	@pProcessUserID VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pPONo VARCHAR(20),
	@pProcessDateTime DATETIME,
	@pDayPlanNo VARCHAR(20) = NULL,
	@pControlNo VARCHAR(20) = NULL,
	@pSubRouteCode VARCHAR(20) = NULL,
	@pFacilityRouteCode VARCHAR(20) = NULL,
	@pDefectCode VARCHAR(20),
	@pDefectQty NUMERIC(20,5) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @ControlNo VARCHAR(20) = @pControlNo
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @SubRouteCode VARCHAR(20) = ISNULL(@pSubRouteCode,'')
	DECLARE @FacilityRouteCode VARCHAR(20) = ISNULL(@pFacilityRouteCode,'')
	DECLARE @ProcessDateTime DATETIME = @pProcessDateTime

	DECLARE @DefectCode VARCHAR(20) = @pDefectCode
	DECLARE @DefectQty NUMERIC(20,5) = ISNULL(@pDefectQty,1)

	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @BomVersion VARCHAR(10)
	DECLARE @DefectSummaryNo VARCHAR(20)

	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@MaterialCode = POI.MaterialCode,
			@BomVersion = POI.BomVersion
	FROM
			STB_ProductionOrderInfo POI
	WHERE
			POI.PONo = @PONo

	DECLARE @ShiftDateTime VARCHAR(20) = dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
	DECLARE @JobDate DATE = SUBSTRING(@ShiftDateTime,1,8)
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@ShiftDateTime,9,1)
	DECLARE @TimeCode VARCHAR(2) = SUBSTRING(@ShiftDateTime,10,2)

	SELECT
			@DefectSummaryNo = DRI.DefectSummaryNo
	FROM
			STB_DefectRepairInfo DRI
	WHERE
			DRI.PONo = @PONo AND
			DRI.DayPlanNo = @DayPlanNo AND
			DRI.ControlNo = @ControlNo AND
			DRI.FindLineCode = @LineCode AND
			DRI.FindRouteCode = @RouteCode AND
			DRI.FindSubRouteCode = @SubRouteCode AND
			DRI.FindFacilityRouteCode = @FacilityRouteCode AND
			DRI.DefectCode = @DefectCode AND
			DRI.FindDateTime = @ProcessDateTime

	IF ISNULL(@DefectSummaryNo,'') = '' BEGIN
			INSERT INTO STB_DefectRepairInfo
			(
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
				MaterialCode,
				BomVersion,
				FindDateTime,
				DefectCode,
				DefectQty,
				RepairQty,
				LossQty,
				IsDelete,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@CompanyCode,
				@WorkCenterCode,
				@ControlNo,
				@PONo,
				@DayPlanNo,
				@JobDate,
				@ShiftCode,
				@TimeCode,
				@LineCode,
				@RouteCode,
				@SubRouteCode,
				@FacilityRouteCode,
				@MaterialCode,
				@BomVersion,
				@ProcessDateTime,
				@DefectCode,
				@DefectQty,
				0,
				0,
				0,
				GETDATE(),
				@ProcessUserID
			)

			EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @CompanyCode,
												@pWorkCenterCode = @WorkCenterCode,
												@pLineCode = @LineCode,
												@pRouteCode = @RouteCode,
												@pPONo = @PONo,
												@pJobDate = @JobDate,
												@pShiftCode = @ShiftCode,
												@pTimeCode = @TimeCode,
												@pSubRouteCode = @SubRouteCode,
												@pDefectQty = @DefectQty
	END
END
