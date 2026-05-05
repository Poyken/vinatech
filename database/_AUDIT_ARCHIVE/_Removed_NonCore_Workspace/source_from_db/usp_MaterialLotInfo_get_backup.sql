
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-21
-- Browsable : true
-- Group : 자재수불관리
-- Description:	재고 자재리스트를 조회합니다.
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_MaterialLotInfo_get_backup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL,
	@pMaterialLocationCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pMaterialStockAttribute VARCHAR(20) = NULL,
	@pStockAttrib1 VARCHAR(20) = NULL,
	@pStockAttrib2 VARCHAR(20) = NULL,
	@pStockAttrib3 VARCHAR(20) = NULL,
	@pBasicMaterialType VARCHAR(20) = NULL,
	@pExcludeBasicMaterialTypes VARCHAR(100) = NULL,
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pCanPickingOnly BIT = NULL,	-- 피킹이 가능한 재고만 조회
	@pLotID varchar(50) = Null, -->M.SH
	@pTargetMaterialLocationCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '%' ELSE @pMaterialWarehouseCode END
	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '%' ELSE @pMaterialLocationCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @MaterialStockAttribute VARCHAR(20) = CASE WHEN ISNULL(@pMaterialStockAttribute,'') = '' THEN '%' ELSE @pMaterialStockAttribute END
	DECLARE @StockAttrib1 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib1,'') = '' THEN '%' ELSE @pStockAttrib1 END
	DECLARE @StockAttrib2 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib2,'') = '' THEN '%' ELSE @pStockAttrib2 END
	DECLARE @StockAttrib3 VARCHAR(20) = CASE WHEN ISNULL(@pStockAttrib3,'') = '' THEN '%' ELSE @pStockAttrib3 END
	DECLARE @BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '%' ELSE @pBasicMaterialType END
	DECLARE @ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes
	DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @CanPickingOnly BIT = ISNULL(@pCanPickingOnly, 0)
	DECLARE @LotID varchar(50) =CASE WHEN ISNULL(@pLotID,'') = '' THEN '%' ELSE @pLotID END -->M.SH
    
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
			MM.MaterialUnit,
			MLI.MaterialStockAttribute,
			--MLI.StockAttrib1,
			--MLI.StockAttrib2,
			--MLI.StockAttrib3,
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
			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼
			MLI.BefMaterialLotNo,
			--MLI.CreateDateTime,
			--MLI.CreateUserID,
			--MLI.ChangeDateTime,
			--MLI.ChangeUserID,
			--'MATERIAL_LABEL' AS LabelType,
			--Label.FormatName AS LabelFormatName,
			'MATERIAL' AS LabelType,
			--Label.FormatName AS LabelFormatName
			'MaterialLabel' AS LabelFormatName,
			'Report' AS CommandType,
			MLI.LotAttr01,
			MLI.LotAttr02,
			MLI.LotAttr03,
			MLI.LotAttr04,
			MLI.LotAttr05,
			MLI.LotAttr06,
			MLI.LotAttr07,
			MLI.LotAttr08,
			MLI.LotAttr09,
			CONVERT(DATE, MLI.LotAttr10) AS LotAttr10,
			MM.MMExtText02,
			MM.MMExtText03
			--@pTargetMaterialLocationCode AS TargetMaterialLocationCode
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
			(MLI.CompanyCode = @CompanyCode) AND
			(MLI.WorkCenterCode = @WorkCenterCode) AND
			(MLI.MaterialWarehouseCode LIKE @MaterialWarehouseCode) AND
			MLI.MaterialLocationCode LIKE @MaterialLocationCode AND
			MLI.MaterialCode LIKE @MaterialCode AND
			MLI.MaterialStockAttribute LIKE @MaterialStockAttribute AND
			MLI.StockAttrib1 LIKE @StockAttrib1 AND
			MLI.StockAttrib2 LIKE @StockAttrib2 AND
			MLI.StockAttrib3 LIKE @StockAttrib3 AND
			MT.MaterialTypeCode LIKE @MaterialTypeCode AND
			MT.BasicMaterialType LIKE @BasicMaterialType AND
			MT.BasicMaterialType NOT IN (
											SELECT
													Item
											FROM
													dbo.fnSplitToTable(',',@ExcludeBasicMaterialTypes)
										) AND
			MM.ProductGroupCode LIKE @ProductGroupCode AND
			MLI.CurrentQty - MLI.PickingQty > 0 AND
			MLI.LotID LIKE @LotID -->M.SH 
			AND MLI.stockAttrib3  <> 'X'                                                   --- 삭제할 부분임

END



 ---  SELECT stockAttrib3, * FROM STB_MaterialLotInfo

 --BEGIN TRAN
 -- COMMIT
 --update STB_MaterialLotInfo
 --set stockAttrib3 = 'X'



 --SELECT * FROM STB_MaterialLotInfo