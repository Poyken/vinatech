-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 품질관리
-- Create date: 2018-08-18
-- Description:	수리자재 출고처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessLossGIMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pPONo VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pMaterialCode VARCHAR(50),
	@pLotID VARCHAR(50) = NULL,
	@pLotNo VARCHAR(50) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pStockAttrib1 VARCHAR(20) = NULL,
	@pStockAttrib2 VARCHAR(20) = NULL,
	@pStockAttrib3 VARCHAR(20) = NULL,
	@pFPItemWorkNo VARCHAR(20) = NULL,
	@pMaterialDocNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	DECLARE @PONo VARCHAR(20) = @pPONO
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @LotID VARCHAR(50) = ISNULL(@pLotID,'')
	DECLARE @LotNo VARCHAR(50) = ISNULL(@pLotNo,'')
	DECLARE @ProdQty NUMERIC(20,5) = @pProdQty
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,'')
	DECLARE @StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,'')
	DECLARE @MaterialDocNo VARCHAR(20) = ISNULL(@pMaterialDocNo,'')
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MaterialStockAttribute VARCHAR(20) = 'NORMAL'
	DECLARE @MaterialDocType VARCHAR(20) = 'GI_PRODUCTION_LOSS'
	DECLARE @GIWarehouseCode VARCHAR(20)
	DECLARE @FPItemWorkNo VARCHAR(20) = @pFPitemWorkNo
	
	SELECT
			@GIWarehouseCode = LRM.MaterialWarehouseCode
	FROM
			STB_LineRouteMapping LRM
	WHERE
			LRM.LineCode = @LineCode AND
			LRM.RouteCode = @RouteCode

	IF @MaterialDocNo = '' BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo',@MaterialDocNo OUTPUT
				
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
				PONo,
				FPItemWorkNo,
				RefMaterialDocNo,
				RequestDateTime,
				RequestUserID,
				RequestPlanDate,
				RequestDesc,
				RequestFixDateTime,
				RequestFixUserID,
				IsAssignPicking,
				IsCancel,
				IsPickingFix,
				IsRequestApproval,
				IsRequestFix,
				IsSourceFinish,
				IsTargetFinish,
				IsUploadERP,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocNo,			--MaterialDocNo,
				GETDATE(),				--BasicDate,
				'GI',					--MaterialDocType,
				@MaterialDocType,		--MaterialDocTypeCode,
				'CREATE',				--DocStatus,
				'',						--SourceCustomerCode,
				@CompanyCode,			--SourceCompanyCode,
				@WorkCenterCode,		--SourceWorkCenterCode,
				@RouteCode,				--SourceRouteCode,
				@GIWarehouseCode,		--SourceMaterialWarehouseCode,
				'',						--TargetCustomerCode,
				@CompanyCode,			--TargetCompanyCode,
				@WorkCenterCode,		--TargetWorkCenterCode,
				@RouteCode,				--TargetRouteCode,
				'',						--TargetMaterialWarehouseCode,
				@PONo,					--PONo,
				@FPItemWorkNo,			--FPItemWorkNo,
				'',						--RefMaterialDocNo,
				GETDATE(),				--RequestDateTime,
				'system',				--RequestUserID,
				GETDATE(),				--RequestPlanDate,
				'',						--RequestDesc,
				GETDATE(),				--RequestFixDateTime,
				'system',				--RequestFixUserID,
				0,						--IsAssignPicking,
				0,						--IsCancel,
				0,						--IsPickingFix,
				1,						--IsRequestApproval,
				1,						--IsRequestFix,
				0,						--IsSourceFinish,
				0,						--IsTargetFinish,
				0,						--IsUploadERP,
				GETDATE(),				--CreateDateTime,
				@ProcessUserID			--CreateUserID
			)
	END

	SELECT
			@MaterialDocDetailNo = MDD.MaterialDocDetailNo
	FROM
			STB_MaterialDocDetail MDD
	WHERE
			MDD.MaterialDocNo = @MaterialDocNo AND
			MDD.MaterialCode = @MaterialCode

	IF ISNULL(@MaterialDocDetailNo,'') = '' BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail',@MaterialDocDetailNo OUTPUT

			INSERT INTO STB_MaterialDocDetail
			(
				MaterialDocDetailNo,
				MaterialDocNo,
				MaterialCode,
				MaterialStockAttribute,
				StockAttrib1,
				StockAttrib2,
				StockAttrib3,
				RequestQty,
				AllowQty,
				PickingAssignQty,
				PickingQty,
				InspectionType,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				@MaterialDocNo,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@ProdQty,		--RequestQty,
				@ProdQty,		--AllowQty,
				@ProdQty,		--PickingAssignQty,
				@ProdQty,		--PickingQty,
				'NONE',
				GETDATE(),
				@ProcessUserID
			)
	END ELSE BEGIN
			UPDATE	STB_MaterialDocDetail
			SET
					RequestQty = RequestQty + @ProdQty,
					AllowQty = AllowQty + @ProdQty,
					PickingAssignQty = PickingAssignQty + @ProdQty,
					PickingQty = PickingQty + @ProdQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo
	END

	SET @pMaterialDocNo = @MaterialDocNo
END
