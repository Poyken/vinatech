

-- =============================================
-- Author:	    Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-11-08
-- Browsable : true
-- Group : MaterialStock
-- Description:	MaterialLotInfo 조회(STB_MaterialLocation에서 IsUseLotID가 아닌 Location만 조회)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialLotInfoForReturn]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL,
	@pMaterialLocationZone NVARCHAR(50) = NULL, 
	@pMaterialLocationCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pPONumber VARCHAR(50) = NULL,
	@pMODELNAME NVARCHAR(100) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(50) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END 
	DECLARE @WorkCenterCode VARCHAR(50) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @MaterialWarehouseCode VARCHAR(20) = @pMaterialWarehouseCode
	DECLARE @MaterialLocationZone NVARCHAR(50) = @pMaterialLocationZone
	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '*' ELSE @pMaterialLocationCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @PONumber VARCHAR(50) = CASE WHEN ISNULL(@pPONumber,'') = '' THEN '' ELSE @pPONumber END
	DECLARE @MODEL_NAME NVARCHAR(100) = CASE WHEN ISNULL(@pMODELNAME,'') = '' THEN '' ELSE @pMODELNAME END
	


	SELECT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			MLI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MLI.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MLI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MW.MaterialWarehouseNameL,
			MLI.MaterialLocationCode,
			ML.MaterialLocationName,
			ML.MaterialLocationNameL,
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			MM.MaterialUnit,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			MM.MaterialSource,
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
			MLI.PickingQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotNo,
			MLI.IsSplitLot,
			MLI.BefMaterialLotNo,
			MLI.LotAttr01,				-- MODEL
			MLI.LotAttr02,				-- Production Order
			MLI.LotAttr03,				-- Vendor Name 
			MLI.LotAttr04,
			MLI.LotAttr05,
			MLI.LotAttr06,
			MLI.LotAttr07,
			MLI.LotAttr08,
			MLI.LotAttr09,
			MLI.LotAttr10,
			MLI.CreateDateTime,
			MLI.CreateUserID,
			MLI.ChangeDateTime,
			MLI.ChangeUserID,
			ML.MLExtText01 AS MaterialLocationZone,					--Zone
			0 AS UnitQty,											--단위수량
			0 AS BoxQty,											--박스수량,
			MLI.CurrentQty - MLI.PickingQty AS AvailableQty,		--가용수량
			@PONumber AS MarshallingPONumber,
			@MODEL_NAME AS MarshallingMODEL,
			MLI.CurrentQty AS StockQty,
			CASE	
					WHEN ISNULL(MLI.LotAttr02,'') <> '' THEN MLI.LotAttr02
					ELSE MLI.LotNo
			END AS LotNo,
			MLI.LotAttr03 AS CustomerName,
			MM.MMExtText01,
			MM.MMExtText02,
			MM.MMExtText03,
			MM.MMExtText04
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON ML.MaterialWarehouseCode = MLI.MaterialWarehouseCode
				AND ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MLI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = MLI.CompanyCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON PG.ProductGroupCode = MM.ProductGroupCode
	WHERE
			((MLI.CompanyCode = @CompanyCode))  AND
			((MLI.WorkCenterCode = @WorkCenterCode))  AND
			((MLI.MaterialWarehouseCode = @MaterialWarehouseCode)) AND
			((ML.MLExtText01 = @MaterialLocationZone)) AND
			((@MaterialLocationCode = '*') OR (MLI.MaterialLocationCode = @MaterialLocationCode)) AND
			((@MaterialCode = '*') OR (MLI.MaterialCode = @MaterialCode)) AND
			((ML.IsUseLotID = 0)) AND
			((MLI.CurrentQty > 0))

END



