-- =============================================
-- Author:		Mr.Duy
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec usp_GetMaterialLotInfo_Packing_VVT_F3 'trieu','vi','','PKQL2500261'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialLotInfo_Packing_VVT_F3]
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pWorkerCode VARCHAR(20) = NULL,
		@pPackingID VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--select * from STB_MaterialLotInfo
	--DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @LotId VARCHAR(50) = @pPackingID
	DECLARE @MergeQty INT  = 0
	--STB_PackingNilonToBoxSmall_HN
	--DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END

	;
	WITH Lot AS
	(
		SELECT
				MLI.MaterialLotNo
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
		WHERE  Lotno = @LotId or PackingID = @LotId or MergePackingId=@LotId


				--(MLI.CompanyCode = @CompanyCode) AND
				--(MLI.WorkCenterCode = @WorkCenterCode) AND
				--(MLI.MaterialCode = @MaterialCode) AND
				--((@MaterialWarehouseCode = '*') OR (MLI.MaterialWarehouseCode = @MaterialWarehouseCode))
				--(MLI.LotNo = @LotNo)
	)    
	SELECT DISTINCT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			T4.MarkingName,
			ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
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
			FORMAT(MLI.InitialQty, '0.######') as InitialQty,
			FORMAT(MLI.CurrentQty, '0.######') as CurrentQty,
			--MLI.InitialQty,
			--MLI.CurrentQty,
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
			MLI.CreateDateTime,
			MLI.CreateUserID,
			MLI.ChangeDateTime,
			MLI.ChangeUserID,
			MLI.PackingIdParent,
			MLI.MergeParentId
			--'MATERIAL_LABEL' AS LabelType,
			--'MATERIAL' AS LabelType,
			--'MaterialLabel' AS LabelFormatName,

			--'PartLabel' AS LabelType,                        --2020.04.08
			--'자재라벨' AS LabelFormatName,			
			--'Report' AS CommandType,
			--MM.MaterialUnit,
			--MM.MMExtText02,
			--MM.MMExtText03 

			-- 추가사항
			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    --제조일자
			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  --Mr.Duy sửa 2023-12-12 lấy ngày đóng gói	 của lot mới tách
			--, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)  AS PackDate	  --유효일자	
			,MLI.isSlitting, 
			@MergeQty as MergeQty 		
	FROM
			Lot L
			INNER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK) ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15
			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	        LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
			LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode T4 ON T4.MarkingCode=MLI.MarkingCode
	union all 
	SELECT DISTINCT
			MLI.MaterialLotNo AS OldMaterialLotNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			T4.MarkingName,
			ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
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
			FORMAT(MLI.InitialQty, '0.######') as InitialQty,
			FORMAT(MLI.CurrentQty, '0.######') as CurrentQty,
			--MLI.InitialQty,
			--MLI.CurrentQty,
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
			MLI.CreateDateTime,
			MLI.CreateUserID,
			MLI.ChangeDateTime,
			MLI.ChangeUserID,
			MLI.PackingIdParent,
			MLI.MergeParentId
			--'MATERIAL_LABEL' AS LabelType,
			--'MATERIAL' AS LabelType,
			--'MaterialLabel' AS LabelFormatName,

			--'PartLabel' AS LabelType,                        --2020.04.08
			--'자재라벨' AS LabelFormatName,			
			--'Report' AS CommandType,
			--MM.MaterialUnit,
			--MM.MMExtText02,
			--MM.MMExtText03 

			-- 추가사항
			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    --제조일자
			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  --Mr.Duy sửa 2023-12-12 lấy ngày đóng gói	 của lot mới tách
			--, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)  AS PackDate	  --유효일자	
			,MLI.isSlitting, 
			@MergeQty as MergeQty 		
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_PackingNilonToBoxSmall_HN PN WITH(NOLOCK) ON MLI.MergeNilonToSmallBox = PN.PackingNilonToBoxSmallID
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK) ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15
			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	        LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
		   LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode T4 ON T4.MarkingCode=MLI.MarkingCode
			where PN.PackingNilonToBoxSmallID=@pPackingID
	
	UNION ALL

SELECT
    DISTINCT
    MLI.MaterialLotNo AS OldMaterialLotNo,
    MLI.MaterialLotNo,
    MLI.LotID,
	'' as MarkingName,
    MLI.CompanyCode,
    MLI.WorkCenterCode,
    MLI.MaterialWarehouseCode,
    MW.MaterialWarehouseName,
    MLI.MaterialLocationCode,
    ML.MaterialLocationName,
    ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
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
    DP.PackingID AS PackingID,
    MLI.GRDate,
    MLI.MaterialDeliveryNo,
    MLI.MaterialDeliveryDetailNo,
    FORMAT(DP.Qty, '0.######') AS InitialQty,        -- sửa tại đây
    FORMAT(DP.Qty, '0.######') AS CurrentQty,        -- sửa tại đây
    DP.Qty AS StockQty,                              -- sửa tại đây
    MLI.PickingQty,
    DP.Qty - MLI.PickingQty AS AvailableQty,         -- sửa tại đây
    MLI.VendorLotNo,
    MLI.LifeBasicDate,
    MLI.ProductionDate,
    MLI.EndOfLifeDate,
    MLI.LotNo,
    MLI.IsSplitLot,
    CONVERT(NUMERIC(20,5), NULL) AS SplitQty,
    MLI.BefMaterialLotNo,
    MLI.CreateDateTime,
    MLI.CreateUserID,
    MLI.ChangeDateTime,
    MLI.ChangeUserID,
    MLI.PackingIdParent,
    MLI.MergeParentId,
    ISNULL(MDLI.Lotattr10, MLI.LotAttr10) AS LotAttr10,
    CONVERT(VARCHAR(10), DATEADD(DAY, -1, DATEADD(MM, MM.MMExtInt01, MLI.Lotattr10)), 121) AS PackDate,
    MLI.isSlitting,
    @MergeQty AS MergeQty
    FROM STB_DividePackaging DP WITH(NOLOCK)
    LEFT JOIN STB_MaterialLotInfo MLI ON MLI.LotNo = DP.LotNo and MLI.PackingID = DP.PackingParentID
    LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MLI.MaterialCode = MM.MaterialCode
    LEFT JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode
    LEFT JOIN STB_ProductGroup PG WITH(NOLOCK) ON PG.ProductGroupCode = MM.ProductGroupCode
   LEFT JOIN STB_MaterialWarehouse MW WITH(NOLOCK) ON MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
   LEFT JOIN STB_MaterialLocation ML WITH(NOLOCK) ON ML.MaterialLocationCode = MLI.MaterialLocationCode
   LEFT JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
    ON MLI.MaterialCode = MDLI.MaterialCode
    AND MLI.LotNo = MDLI.LotNo
    AND MLI.LotID = MDLI.LotID
	LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
WHERE DP.PackingID = @pPackingID  
  


END

