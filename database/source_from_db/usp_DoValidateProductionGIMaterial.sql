-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-02
-- Description : 생산출고 자재유효성 체크
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoValidateProductionGIMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL,
	@pBarcode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo,
			@Barcode VARCHAR(50) = @pBarcode,
			@MaterialCode VARCHAR(50),
			@MaterialLotNo VARCHAR(20),
			@SourceMaterialWarehouseCode VARCHAR(20),
			@TargetMaterialWarehouseCode VARCHAR(20),
			@IsUseFlush BIT,
			@RouteCode VARCHAR(20),
			@GIQty NUMERIC(20,5),
			@CurrentQty NUMERIC(20,5)
	
	-- Developer 에서 화면을 만드는 경우엔 무시
	IF @Barcode IS NOT NULL BEGIN		
		SELECT
				@MaterialLotNo = MLI.MaterialLotNo,
				@MaterialCode = MLI.MaterialCode,
				@SourceMaterialWarehouseCode = MLI.MaterialWarehouseCode,
				@CurrentQty = MLI.CurrentQty
		FROM
				STB_MaterialLotInfo MLI
		WHERE
				MLI.LotID = @Barcode

		--RAISERROR(@Barcode,16,1)
		--RETURN

		IF @MaterialCode IS NULL BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage,
											'재고가 존재하지 않습니다.'
			RETURN
		END

		SELECT
				@GIQty = SUM(MDD.ProcessFixQty)
		FROM
				STB_MaterialDocInfo MDI
				INNER JOIN STB_MaterialDocDetail MDD
					ON	MDD.MaterialDocNo = MDI.MaterialDocNo
		WHERE
				-- 2018-09-28 JGH 수정 생산출고생성시 GI,MOVE 타입의 GI_WH_ROUTE,MV_WH_ROUTE 두가지 타입으로 생성됨
				--MDI.MaterialDocType = 'GI' AND
				MDI.MaterialDocType IN ('GI','MOVE') AND
				--MDI.MaterialDocTypeCode = 'GI_PRODUCTION' AND
				MDI.MaterialDocTypeCode IN ('GI_WH_ROUTE','MV_WH_ROUTE') AND
				MDI.PONo = @PONo AND
				MDI.IsCancel = 0 AND
				MDD.MaterialCode = @MaterialCode

		SELECT
				@RouteCode = POB.RouteCode
		FROM
				STB_ProductionOrderBom POB
		WHERE
				POB.PONo = @PONo AND
				POB.ChildMaterialCode = @MaterialCode AND
				POB.IsUseProduction = 1

		IF (SELECT COUNT(1) FROM STB_LineRouteMapping LRM WHERE LRM.RouteCode = @RouteCode) = 1 BEGIN
			SELECT
					@TargetMaterialWarehouseCode = LRM.MaterialWarehouseCode
			FROM
					STB_LineRouteMapping LRM
			WHERE
					LRM.RouteCode = @RouteCode
		END
	END

	SELECT
			@PONo AS PONo,
			@SourceMaterialWarehouseCode AS SourceMaterialWarehouseCode,
			SMW.MaterialWarehouseName AS SourceMaterialWarehouseName,			
			@MaterialLotNo AS MaterialLotNo,
			POB.ChildMaterialCode AS MaterialCode,			
			MM.MaterialName,			
			POB.TotalUsedQty,
			ISNULL(@GIQty,0) AS GIQty,
			@CurrentQty AS CurrentQty,
			@CurrentQty AS RequestQty,
			MM.IsUseFlush,
			@TargetMaterialWarehouseCode AS TargetMaterialWarehouseCode,
			TMW.MaterialWarehouseName AS TargetMaterialWarehouseName
	FROM
			STB_ProductionOrderBom POB
			LEFT OUTER JOIN STB_MaterialMaster MM
				ON	MM.MaterialCode = POB.MaterialCode
			LEFT OUTER JOIN STB_MaterialWarehouse SMW
				ON	SMW.MaterialWarehouseCode = @SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialWarehouse TMW
				ON	TMW.MaterialWarehouseCode = @TargetMaterialWarehouseCode
	WHERE
			POB.PONo = @PONo AND
			POB.ChildMaterialCode = @MaterialCode AND
			POB.IsUseProduction = 1

	IF @@ROWCOUNT = 0 BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage,
										'대상 자재가 아닙니다.'
		RETURN
	END
END
