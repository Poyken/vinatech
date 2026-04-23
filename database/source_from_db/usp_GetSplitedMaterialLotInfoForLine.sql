


-- =============================================
-- Author:	    Park Jonb Seob(jspark@awoo.co.kr)
-- Create date: 2016-09-26
-- Browsable : true
-- Group : 재고관리
-- Description:	재고 분리를 위한 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSplitedMaterialLotInfoForLine]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
--	@pMaterialCode VARCHAR(50),
--	@pMaterialWarehouseCode VARCHAR(20) = NULL,
--	@pMaterialLocationCode VARCHAR(20) = NULL,
	@pLotID VARCHAR(50) = NULL
	--@pLotNo VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	--DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	--DECLARE @LotNo VARCHAR(50) = @pLotNo
	--DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '' ELSE @pMaterialWarehouseCode END
	--DECLARE @MaterialLocationCode VARCHAR(20) =  CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '' ELSE @pMaterialLocationCode END
	DECLARE @LotID VARCHAR(50) = ISNULL(@pLotID, '')
	

	DECLARE @MaterialLotNo VARCHAR(20) = NULL,
			@CanSplit BIT = 0

	SELECT
			@MaterialLotNo = MLI.MaterialLotNo
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
	WHERE
			(MLI.CompanyCode = @CompanyCode) AND
			(MLI.WorkCenterCode = @WorkCenterCode) AND
			--(MLI.MaterialCode = @MaterialCode) AND
			--(MLI.MaterialWarehouseCode = @MaterialWarehouseCode) AND
			--(MLI.MaterialLocationCode = @MaterialLocationCode) AND
			(MLI.LotID = @LotID)

	IF @MaterialLotNo IS NOT NULL
	BEGIN
			SET @CanSplit = 1
	END ELSE BEGIN
		SELECT
				@MaterialLotNo = MLS.MaterialLotNo
		FROM
				STB_MaterialLotSnapshot MLS WITH(NOLOCK)
		WHERE
				(MLS.CompanyCode = @CompanyCode) AND
				(MLS.WorkCenterCode = @WorkCenterCode) AND
				--(MLI.MaterialCode = @MaterialCode) AND
				--(MLI.MaterialWarehouseCode = @MaterialWarehouseCode) AND
				--(MLI.MaterialLocationCode = @MaterialLocationCode) AND
				(MLS.LotID = @LotID)
	END

	IF @CanSplit = 1
	BEGIN
			SELECT
					MLI.MaterialLotNo AS OldMaterialLotNo,
					MLI.MaterialLotNo,
					MLI.LotID,
					MLI.CompanyCode,
					MLI.WorkCenterCode,
					MLI.MaterialWarehouseCode,
					MW.MaterialWarehouseName,
					MLI.MaterialLocationCode,
					ML.MaterialLocationName,
					MLI.MaterialCode,
					MM.MaterialName,
					MM.MaterialTypeCode,
					MT.MaterialTypeName,
					MM.ProductGroupCode,
					PG.ProductGroupName,
					MM.MaterialSpec,
					MLI.MaterialStockAttribute,
					MLI.StockAttrib1,
					MLI.StockAttrib2,
					MLI.StockAttrib3,
					MLI.PackingID,
					MLI.GRDate,
					MLI.MaterialDeliveryNo,
					MLI.MaterialDeliveryDetailNo,
					MLI.InitialQty,
					MLI.CurrentQty,
					MLI.CurrentQty AS StockQty,
					MLI.PickingQty,
					MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
					MLI.VendorLotNo,
					MLI.LifeBasicDate,
					MLI.ProductionDate,
					MLI.EndOfLifeDate,
					MLI.LotNo,
					MLI.IsSplitLot,
					CASE
						WHEN ISNULL(MM.MMExtInt01, MLI.CurrentQty) > MLI.CurrentQty THEN ISNULL(MM.MMExtInt01, MLI.CurrentQty)
						ELSE MLI.CurrentQty
					END AS SplitQty,
					--ISNULL(MM.MMExtInt01, MLI.PickingQty) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼
					CASE
						WHEN (MLI.CurrentQty % ISNULL(MM.MMExtInt01, CONVERT(INT, MLI.CurrentQty))) = 0 THEN MLI.CurrentQty / ISNULL(MM.MMExtInt01, CONVERT(INT, MLI.CurrentQty))
						ELSE (MLI.CurrentQty / ISNULL(MM.MMExtInt01, CONVERT(INT, MLI.CurrentQty))) + 1
					END AS PlanPackingQty,
					MLI.BefMaterialLotNo,
					MLI.CreateDateTime,
					MLI.CreateUserID,
					MLI.ChangeDateTime,
					MLI.ChangeUserID,
					MM.MaterialUnit,
					MM.MMExtText02,
					MM.MMExtText03,
					@CanSplit AS CanSplit,
					MLI.LotAttr02
			FROM
					STB_MaterialLotInfo MLI WITH(NOLOCK)
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
						ON	MLI.MaterialCode = MM.MaterialCode
					LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
						ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
						ON	PG.ProductGroupCode = MM.ProductGroupCode
					LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
						ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
					LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
						ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
					--LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK)
					--	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)
			WHERE
					MLI.MaterialLotNo = @MaterialLotNo --AND
					--MLI.CurrentQty > 0
	END ELSE BEGIN
			SELECT
					MLS.MaterialLotNo AS OldMaterialLotNo,
					MLS.MaterialLotNo,
					MLS.LotID,
					MLS.CompanyCode,
					MLS.WorkCenterCode,
					MLS.MaterialWarehouseCode,
					MW.MaterialWarehouseName,
					MLS.MaterialLocationCode,
					ML.MaterialLocationName,
					MLS.MaterialCode,
					MM.MaterialName,
					MM.MaterialTypeCode,
					MT.MaterialTypeName,
					MM.ProductGroupCode,
					PG.ProductGroupName,
					MM.MaterialSpec,
					MLS.MaterialStockAttribute,
					MLS.StockAttrib1,
					MLS.StockAttrib2,
					MLS.StockAttrib3,
					MLS.PackingID,
					MLS.GRDate,
					'' AS MaterialDeliveryNo,
					'' AS MaterialDeliveryDetailNo,
					MLS.InitialQty,
					0 AS CurrentQty,
					0 AS StockQty,
					MLS.PickingQty,
					MLS.CurrentQty - MLS.PickingQty AS AvailableQty,
					MLS.VendorLotNo,
					MLS.LifeBasicDate,
					MLS.ProductionDate,
					MLS.EndOfLifeDate,
					MLS.LotNo,
					MLS.IsSplitLot,
					0 AS SplitQty,
					--ISNULL(MM.MMExtInt01, MLS.PickingQty) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼
					0 AS PlanPackingQty,
					MLS.BefMaterialLotNo,
					MLS.CreateDateTime,
					MLS.CreateUserID,
					MLS.ChangeDateTime,
					MLS.ChangeUserID,
					MM.MaterialUnit,
					MM.MMExtText02,
					MM.MMExtText03,
					@CanSplit AS CanSplit,
					MLS.LotAttr02
			FROM
					STB_MaterialLotSnapshot MLS WITH(NOLOCK)
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
						ON	MLS.MaterialCode = MM.MaterialCode
					LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
						ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
						ON	PG.ProductGroupCode = MM.ProductGroupCode
					LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
						ON	MW.MaterialWarehouseCode = MLS.MaterialWarehouseCode
					LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
						ON	ML.MaterialLocationCode = MLS.MaterialLocationCode
					--LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK)
					--	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLS.MaterialCode)
			WHERE
					MLS.MaterialLotNo = @MaterialLotNo --AND
					--MLI.CurrentQty > 0
	END


	SELECT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			MLI.CompanyCode,
			MLI.WorkCenterCode,
			MLI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MLI.MaterialLocationCode,
			ML.MaterialLocationName,
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.PackingID,
			MLI.GRDate,
			MLI.MaterialDeliveryNo,
			MLI.MaterialDeliveryDetailNo,
			MLI.InitialQty,
			MLI.CurrentQty,
			MLI.CurrentQty AS StockQty,
			MLI.PickingQty,
			MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotAttr02 AS LotNo,
			MLI.IsSplitLot,
			MLI.BefMaterialLotNo,
			MLI.CreateDateTime,
			MLI.CreateUserID,
			MLI.ChangeDateTime,
			MLI.ChangeUserID,
			--'MATERIAL_LABEL' AS LabelType,
			'MATERIAL' AS LabelType,
			'MaterialLabel' AS LabelFormatName,
			'Report' AS CommandType,
			MM.MaterialUnit,
			MM.MMExtText02,
			MM.MMExtText03
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
			--LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK)
			--	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)
	WHERE
			MLI.BefMaterialLotNo = @MaterialLotNo --AND
			--MLI.CurrentQty > 0

END



