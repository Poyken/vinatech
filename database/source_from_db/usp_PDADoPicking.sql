
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: true
-- Create date: 2016-06-20
-- Description:	자재를 피킹 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDADoPicking]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20) = NULL OUTPUT,
	@pInvoiceNo VARCHAR(20) = NULL,	-- 2017-02-01 김한영. 택배송장 매핑 추가
	@pMaterialDocDetailNo VARCHAR(20) = NULL,
	@pMaterialLotNo VARCHAR(20),
	@pStockQty NUMERIC(20,5),	-- PC 에서는 STB_MaterialDocLotInfo 정보로 호출하므로 StockQty 로 파라미터 처리
	@pIsRemovePacking BIT = 0,		-- 셋트출고의 경우 이값을 1(true) 로 설정
	@pIsFinished BIT = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@InvoiceNo VARCHAR(20) = @pInvoiceNo,
			@MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo,
			@MaterialLotNo VARCHAR(50) = @pMaterialLotNo,
			@PickingQty NUMERIC(20,5) = @pStockQty,
			@CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20)

	IF @PickingQty = 0 BEGIN
		RETURN
	END
	
	EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @MaterialDocNo
									
	IF @@ERROR <> 0 BEGIN
		RETURN
	END
	
	SELECT
			@CompanyCode = UI.CompanyCode,
			@WorkCenterCode = UI.WorkCenterCode
	FROM
			STB_UserInfo UI
	WHERE
			UI.UserID = @ProcessUserID

	DECLARE @LotID VARCHAR(50),
			@SourceCompanyCode VARCHAR(20),
			@SourceWorkCenterCode VARCHAR(20),
			@SourceMaterialWarehouseCode VARCHAR(20),
			@SourceLocationCode VARCHAR(20),
			@MaterialCode VARCHAR(20),
			@CurrentQty NUMERIC(20,5),
			@MaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@PackingID VARCHAR(50),
			@IsUseBarcode BIT,
			@IsFIFO BIT,
			@IsUseBarcoe BIT,
			@GRDate DATE

	IF EXISTS ( 
				SELECT 
						* 
				FROM 
						STB_MaterialDocLotInfo MDLI 
				WHERE 
						MDLI.MaterialDocDetailNo = @MaterialDocDetailNo AND
						MDLI.MaterialLotNo = @MaterialLotNo
			 ) BEGIN
		DECLARE @AlreadyPickingERror NVARCHAR(MAX)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^이미 피킹처리 되었습니다.^',
											@pValue = @AlreadyPickingERror OUTPUT
		RAISERROR(@AlreadyPickingERror,16,1)
		RETURN
	END

	SELECT
			@LotID = MLI.LotID,
			@SourceCompanyCode = MLI.CompanyCode,
			@SourceWorkCenterCode = MLI.WorkCenterCode,
			@SourceMaterialWarehouseCode = MLI.MaterialWarehouseCode,
			@SourceLocationCode = MLI.MaterialLocationCode,
			@MaterialCode = MLI.MaterialCode,
			@CurrentQty = MLI.CurrentQty - MLI.PickingQty,
			@MaterialStockAttribute = MLI.MaterialStockAttribute,
			@StockAttrib1 = MLI.StockAttrib1,
			@StockAttrib2 = MLI.StockAttrib2,
			@StockAttrib3 = MLI.StockAttrib3,
			@GRDate = MLI.GRDate,
			@IsUseBarcode = ISNULL(MSAI.IsUseBarcode,0),
			@IsFIFO = ISNULL(MSAI.IsFIFO,0),
			@PackingID = MLI.PackingID
	FROM
			STB_MaterialLotInfo MLI
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI 
				ON	MSAI.MaterialCode = MLI.MaterialCode
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo

	IF @MaterialCode IS NULL BEGIN
		DECLARE @NotFoundStockError NVARCHAR(500)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^재고를 찾을 수 없습니다.^',
											@pValue = @NotFoundStockError OUTPUT
		RAISERROR(@NotFoundStockError,16,1)
		RETURN
	END

	IF @IsUseBarcode = 1 AND @CurrentQty <> @PickingQty BEGIN
		DECLARE @CantPartialBarcodeError NVARCHAR(500)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^바코드 사용자재는 수량을 변경할 수 없습니다.^',
											@pValue = @CantPartialBarcodeError OUTPUT
		RAISERROR(@CantPartialBarcodeError,16,1)
		RETURN
	END

	IF @CurrentQty < @PickingQty BEGIN
		DECLARE @OverflowError NVARCHAR(500)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^가용수량을 초과하였습니다.^',
											@pValue = @OverflowError OUTPUT
		RAISERROR(@OverflowError,16,1)
		RETURN
	END

	IF @MaterialDocDetailNo IS NULL BEGIN
		SELECT
				@MaterialDocDetailNo =  MDD.MaterialDocDetailNo
		FROM
				STB_MaterialDocDetail MDD
		WHERE
				MDD.MaterialDocNo = @MaterialDocNo AND
				MDD.MaterialCode = @MaterialCode AND
				(MDD.AllowQty - MDD.PickingQty) > 0
	END

	IF @MaterialDocDetailNo IS NULL BEGIN
		DECLARE @NotFoundDetailError NVARCHAR(MAX)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^피킹처리할 상세정보를 찾을 수 없습니다.^',
											@pValue = @NotFoundDetailError OUTPUT
		RAISERROR(@NotFoundDetailError,16,1)
		RETURN
	END

	-- 선입선출 체크
	IF @IsFIFO = 1 BEGIN
		EXEC usp_DoValidateFIFO @pProcessLanguage = @ProcessLanguage,
								@pProcessUserID = @ProcessUserID,
								@pCompanyCode = @SourceCompanyCode,
								@pWorkCenterCode = @SourceWorkCenterCode,
								@pMaterialWarehouseCode = @SourceMaterialWarehouseCode,
								@pMaterialLotNo = @MaterialLotNo

		IF @@ERROR <> 0 BEGIN
			RETURN
		END
	END
	
	DECLARE @PickingRemainQty NUMERIC(20,5)
	SELECT
			@MaterialDocDetailNo = MDD.MaterialDocDetailNo,
			@PickingRemainQty = MDD.AllowQty - MDD.PickingQty
	FROM
			STB_MaterialDocDetail MDD
	WHERE
			MaterialDocDetailNo = @MaterialDocDetailNo

	IF @MaterialDocDetailNo IS NULL BEGIN
		DECLARE @NotTargetProductError NVARCHAR(500)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^출고 대상 제품이 아닙니다.^',
											@pValue = @NotTargetProductError OUTPUT
		RAISERROR(@NotTargetProductError,16,1)
		RETURN
	END

	IF @PickingRemainQty < @PickingQty BEGIN
		DECLARE @OverflowPlanError  NVARCHAR(500)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^출고지시 수량을 초과하였습니다.^',
											@pValue = @OverflowPlanError OUTPUT
		RAISERROR('%s : %s',16,1,@OverflowPlanError,@MaterialCode)
		RETURN
	END

	-- 바코드를 사용하는 제품은 패킹정보가 있을 수 있다.
	-- PackingID 는 동일 패킹의 첫 번째 박스의 바코드(LotID)를 사용하기 때문에
	-- 첫 번째 박스가 세트출고가 될 때는 기존 제품들의 패킹아이디를 다른 제품의 바코드중 하나를 선정해서 업데이트 해준다.
	IF @IsUseBarcoe = 1 AND @pIsRemovePacking = 1 BEGIN
		-- 피킹하는 바코드로 패킹을 사용하는 다른 제품들이 있으면
		-- 그 중에 한 바코드로 패킹번호를 업데이트	
		DECLARE @AnotherPackingID VARCHAR(50)
		SELECT 
				TOP 1
				@AnotherPackingID = MLI.LotID
		FROM 
				STB_MaterialLotInfo MLI
		WHERE
				MLI.PackingID = @LotID AND
				MLI.LotID <> @LotID
		IF @AnotherPackingID IS NOT NULL BEGIN
			UPDATE
					STB_MaterialLotInfo
			SET
					PackingID = @AnotherPackingID
			WHERE
					PackingID = @LotID AND
					LotID <> @LotID
		END

		-- 피킹된 제품의 패킹아이디는 바코드로 업데이트
		UPDATE
				STB_MaterialLotInfo
		SET
				PackingID = LotID
		WHERE
				MaterialLotNo = @MaterialLotNo

		SET @PackingID = @LotID
	END

	
	-- STB_MaterialDocLot 의 트리거에서 자동처리
	-- 수불상세 내역 피킹수량 증가
	--UPDATE
	--		STB_MaterialDocDetail
	--SET
	--		PickingQty = PickingQty + @CurrentQty,
	--		ChangeDateTime = GETDATE(),
	--		ChangeUserID = @ProcessUserID
	--WHERE
	--		MaterialDocDetailNo = @MaterialDocDetailNo

	--  수불헤더 처리
	UPDATE
			STB_MaterialDocInfo
	SET
			DocStatus = 'WORKING',
			PickingStartDateTime =	CASE
										WHEN PickingStartDateTime IS NULL THEN GETDATE()
										ELSE PickingStartDateTime
									END,
			PickingUserID = @ProcessUserID,
			PickingEndDateTime = GETDATE(),
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			MaterialDocNo = @MaterialDocNo AND
			DocStatus = 'CREATE'

	-- 수불 LOT 정보 입력
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
		PackingID,
		--InvoiceNo,
		MaterialLocationCode,
		MaterialDocNo,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@MaterialDocDetailNo,
		(
			SELECT
					ISNULL(MAX(MDLI.MDLISeqNo),0) + 1
			FROM
					STB_MaterialDocLotInfo MDLI
			WHERE
					MDLI.MaterialDocDetailNo = @MaterialDocDetailNo
		),
		@MaterialLotNo,
		@LotID,
		@MaterialCode,
		@MaterialStockAttribute,
		@StockAttrib1,
		@StockAttrib2,
		@StockAttrib3,
		@PickingQty,
		1,
		@PackingID,
		--@InvoiceNo,
		@SourceLocationCode,
		@MaterialDocNo,
		GETDATE(),
		@ProcessUserID
	)
	-- 모든 제품이 스캔되었는 지 체크
	EXEC usp_DoFinishMaterialDoc @pProcessLanguage = @ProcessLanguage,
								 @pProcessUserID = @ProcessUserID,
								 @pMaterialDocNo = @MaterialDocNo,
								 @pIsTry = 1,
								 @pIsFinished = @pIsFinished OUTPUT

END

