-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 생산관리
-- Create date: 2018-08-16
-- Description:	생산에 사용한 자재(바코드사용)를 출고처리합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdGIMaterialForBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pLotID VARCHAR(50),
	@pProdQty NUMERIC(20,5) = NULL,
	@pMaterialDocNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @PONo VARCHAR(20) = @pPONO
	DECLARE @LotID VARCHAR(50) = @pLotID
	DECLARE @MaterialDocNo VARCHAR(20) = ISNULL(@pMaterialDocNo,'')
	DECLARE @ProdQty NUMERIC(20,5) = @pProdQty

	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @GIWarehouseCode VARCHAR(20)
	DECLARE @StockQty NUMERIC(20,5)	
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MaterialLotNo VARCHAR(20)
	DECLARE @MaterialStockAttribute VARCHAR(20)
	DECLARE @MaterialDocType VARCHAR(20) = 'GI_PRODUCTION'
	DECLARE @lotSplitCount INT
	DECLARE @IsSplitLot BIT
	DECLARE @ErrorMessage NVARCHAR(500)
	
	-- LOT가 분할불출된 lot인 경우 가장 먼저 불출된 materialLotNo 조회
	SELECT @lotSplitCount = COUNT(1)
	FROM STB_MaterialLotInfo WITH(NOLOCK)
	WHERE LotID = @LotID AND IsSplitLot = 1 AND CurrentQty > 0

	IF @lotSplitCount > 0
		BEGIN
			SET @IsSplitLot = 1
		END

	SELECT
		@MaterialLotNo = MIN(MLI.MaterialLotNo),
		@MaterialCode = MIN(MLI.MaterialCode),
		@GIWarehouseCode = MIN(MLI.MaterialWarehouseCode),
		@StockQty = SUM(MLI.CurrentQty),
		@CompanyCode = MIN(MLI.CompanyCode),
		@WorkCenterCode = MIN(MLI.WorkCenterCode),
		@MaterialStockAttribute = MIN(MLI.MaterialStockAttribute)
	FROM
		STB_MaterialLotInfo MLI WITH(NOLOCK)
	WHERE
		MLI.LotID = @LotID
		AND
		MLI.IsSplitLot = ISNULL(@IsSplitLot, 0)
	GROUP BY
		MLI.LotId
	
	IF ISNULL(@MaterialLotNo,'') = '' BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^재고에 없는 바코드입니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@LotID)
			RETURN
	END

	IF @StockQty < @ProdQty BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^재고가 부족합니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@LotID)
			RETURN
	END

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
				'',						--SourceRouteCode,
				@GIWarehouseCode,		--SourceMaterialWarehouseCode,
				'',						--TargetCustomerCode,
				@CompanyCode,			--TargetCompanyCode,
				@WorkCenterCode,		--TargetWorkCenterCode,
				'',						--TargetRouteCode,
				'',						--TargetMaterialWarehouseCode,
				@PONo,					--PONo,
				'',						--FPItemWorkNo,
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
			SELECT
					@MaterialDocDetailNo,
					@MaterialDocNo,
					MLI.MaterialCode,
					MLI.MaterialStockAttribute,
					MLI.StockAttrib1,
					MLI.StockAttrib2,
					MLI.StockAttrib3,
					@ProdQty,				--RequestQty,
					@ProdQty,				--AllowQty,
					@ProdQty,				--PickingAssignQty,
					@ProdQty,				--PickingQty,
					'NONE',
					GETDATE(),
					@ProcessUserID
			FROM
					STB_MaterialLotInfo MLI
			WHERE
					MLI.MaterialLotNo = @MaterialLotNo

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

	--분할불출로 등록한 경우 수량 처리
	DECLARE @TargetMaterialLotNo VARCHAR(20)
	DECLARE @CurrentQty NUMERIC(20,5)
	DECLARE @RemainStockQty  NUMERIC(20,5) = @ProdQty
	DECLARE @InputStockQty NUMERIC(20,5)
	
	DECLARE LotInput_CURSOR CURSOR FOR
	SELECT
		MLI.MaterialLotNo,
		MLI.CurrentQty
	FROM
		STB_MaterialLotInfo MLI WITH(NOLOCK)
	WHERE
		MLI.LotID = @LotID
		AND
		MLI.IsSplitLot = ISNULL(@IsSplitLot, 0)

	OPEN LotInput_CURSOR
	FETCH NEXT FROM LotInput_CURSOR INTO @TargetMaterialLotNo, @CurrentQty;

	WHILE @@FETCH_STATUS = 0 AND @RemainStockQty > 0
	BEGIN
		IF @CurrentQty >= @RemainStockQty
			BEGIN
				SET @InputStockQty = @RemainStockQty
			END
		ELSE
			BEGIN
				SET @InputStockQty = @CurrentQty
			END

		INSERT INTO STB_MaterialDocLotInfo
		(
			MaterialDocDetailNo,
			MDLISeqNo,
			MaterialLotNo,
			LotID,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			StockQty,
			IsChecked,
			MaterialLocationCode,
			MaterialDocNo,
			PackingID,
			LotNo,
			VendorLotNo,
			CreateDateTime,
			CreateUserID
		)
		SELECT
			@MaterialDocDetailNo,
			ISNULL((SELECT COUNT(*) FROM STB_MaterialDocLotInfo WHERE MaterialDocDetailNo = @MaterialDocDetailNo),0) + 1,
			MLI.MaterialLotNo,
			MLI.LotID,
			MLI.MaterialCode,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			@InputStockQty,
			1,
			MLI.MaterialLocationCode,
			@MaterialDocNo,
			MLI.PackingID,
			MLI.LotNo,
			MLI.VendorLotNo,
			GETDATE(),
			@ProcessUserID
		FROM
			STB_MaterialLotInfo MLI
		WHERE
			MLI.MaterialLotNo = @TargetMaterialLotNo

		SET @RemainStockQty = @RemainStockQty - @InputStockQty;

		FETCH NEXT FROM LotInput_CURSOR INTO @TargetMaterialLotNo, @CurrentQty;
	END

	CLOSE LotInput_CURSOR;
	DEALLOCATE LotInput_CURSOR;

	SET @pMaterialDocNo = @MaterialDocNo
	
END
