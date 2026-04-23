


-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-09-26
-- Browsable : true
-- Group : 재고관리 > [F740] 자재 Lot수량조정 > Main조회
-- Description:	분리된 재고정보를 조회합니다.
-- Modified: 
--                2020.06.15 바코드오류 (제조일자, 유효일자 추가)

-- [프로시저 실행문] exec usp_GetMaterialLotInfoPacking '','','','SL20250211000051'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialLotInfoPacking]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pWorkerCode VARCHAR(20) = NULL,
						@pLotId VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--select * from STB_MaterialLotInfo where lotID like '%SL%'
	--DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @LotId VARCHAR(50) = @pLotId
	DECLARE @MergeParentId VARCHAR(50) = @pLotId
	--DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
	select @MergeParentId = MergeParentId FROM
				STB_MaterialLotInfo  MLI WITH(NOLOCK)
		WHERE  LotId = @LotId 
	;
	WITH Lot AS
	(
		SELECT
				MLI.MaterialLotNo
		FROM
				STB_MaterialLotInfo  MLI WITH(NOLOCK)
		WHERE  LotId = @MergeParentId 

					
				--(MLI.CompanyCode = @CompanyCode) AND
				--(MLI.WorkCenterCode = @WorkCenterCode) AND
				--(MLI.MaterialCode = @MaterialCode) AND
				--((@MaterialWarehouseCode = '*') OR (MLI.MaterialWarehouseCode = @MaterialWarehouseCode))
				--(MLI.LotNo = @LotNo)
	)    
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
			FORMAT(MLI.InitialQty, '0.######') as InitialQty,
			FORMAT(MLI.CurrentQty, '0.######') as CurrentQty,
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
			--'MATERIAL_LABEL' AS LabelType,
			--'MATERIAL' AS LabelType,
			--'MaterialLabel' AS LabelFormatName,

			--'PartLabel' AS LabelType,                        --2020.04.08
			--'자재라벨' AS LabelFormatName,			
			--'Report' AS CommandType,
			MM.MaterialUnit
			--MM.MMExtText02,
			--MM.MMExtText03 

			-- 추가사항
			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    --제조일자
			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  --Mr.Duy sửa 2023-12-12 lấy ngày đóng gói	 của lot mới tách
			--, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)  AS PackDate	  --유효일자	
			,MLI.isSlitting,
			'PartLabel' AS LabelType,                        --2020.04.08
			'자재라벨slitting' AS LabelFormatName,			
			'Report' AS CommandType
	 	
	FROM
			Lot L
			INNER JOIN STB_MaterialLotInfo  MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK) ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15

		 -- LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK) 	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)           -- 원본백업
	WHERE
			MLI.CurrentQty > 0

END



