-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-02
-- Description : 생산출고 자재리스트 조회
-- Modified : 2019-06-10 창고자동기입요청 (주영진요청)
-- =============================================
-- EXEC usp_GetMaterialList_ForProductionGI '','','190603000003'
   

CREATE PROCEDURE [dbo].[usp_GetMaterialList_ForProductionGI]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			    @PONo VARCHAR(20) = @pPONo
	
	;
	WITH BOM AS
	(
		SELECT
				POB.PONo,
				POB.ChildMaterialCode AS MaterialCode,
				POB.UsedQty,
				POB.TotalUsedQty,
				POB.BomUnit,
				POB.RouteCode,
				ISNULL((
							SELECT
									COUNT(*)
							FROM
									STB_MaterialWarehouse MW WITH(NOLOCK)
							WHERE
									-- 2018-09-10 JGH 수정
									--MW.RequestProductGroupCode LIKE '%' + POB.ChildMaterialCode + '%' AND
									MW.RequestProductGroupCode LIKE '%' + MM.ProductGroupCode + '%' AND
									MW.IsUsed = 1
						),0) AS SourceWarehouseCount,
				ISNULL((
							SELECT
									COUNT(*)
							FROM
									STB_LineRouteMapping LRM WITH(NOLOCK)
							WHERE
									LRM.RouteCode = POB.RouteCode
						),0) AS TargetWarehouseCount,
				MM.ProductGroupCode,

				(
					SELECT
							SUM(MDD.ProcessFixQty)
					FROM
							STB_MaterialDocInfo MDI
							INNER JOIN STB_MaterialDocDetail MDD								ON	MDD.MaterialDocNo = MDI.MaterialDocNo
					WHERE 1=1
							
						 -- AND MDI.MaterialDocType = 'GI'                                                -- 2018-09-10 JGH 수정
							AND MDI.MaterialDocType IN ('GI','MOVE') 							
						 -- AND MDI.MaterialDocTypeCode IN ('GI_Production','MV_WH_ROUTE') AND   -- 2018-09-10 JGH 수정
							AND MDI.MaterialDocTypeCode IN ('GI_WH_ROUTE','MV_WH_ROUTE') 
							AND MDI.PONo = @PONo 
							AND MDI.IsCancel = 0 
							AND MDD.MaterialCode = POB.ChildMaterialCode
				) AS GIQty,


				-- 2018-09-10 JGH 수정
				(
					SELECT
							SUM(MDD.RequestQty)
					FROM
							STB_MaterialDocInfo MDI
							INNER JOIN STB_MaterialDocDetail MDD								ON	MDD.MaterialDocNo = MDI.MaterialDocNo
					WHERE 1=1
							AND MDI.MaterialDocType IN ('GI','MOVE') 
							AND MDI.MaterialDocTypeCode IN ('GI_WH_ROUTE','MV_WH_ROUTE') 
							AND MDI.PONo = @PONo 
							AND MDI.IsCancel = 0 
							AND MDD.MaterialCode = POB.ChildMaterialCode
				) AS RequestQty
				-- 2018-09-10 JGH 수정
		FROM
				STB_ProductionOrderBom POB WITH(NOLOCK)
				INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)					ON	MM.MaterialCode = POB.ChildMaterialCode
		WHERE
				POB.PONo = @PONo AND
				POB.IsUseProduction = 1
	) ,

	Materials AS
					(
						SELECT
								BOM.PONo,
								BOM.MaterialCode,
								BOM.UsedQty,
								BOM.TotalUsedQty,
								BOM.BomUnit,
								BOM.GIQty,
								BOM.RequestQty,
								CASE BOM.SourceWarehouseCount  WHEN 1 THEN (
															SELECT
																	MW.MaterialWarehouseCode
															FROM
																	STB_MaterialWarehouse MW WITH(NOLOCK)
															WHERE
																	MW.RequestProductGroupCode LIKE '%' + BOM.ProductGroupCode + '%'
														)
									ELSE NULL		END AS SourceMaterialWarehouseCode,

								CASE BOM.TargetWarehouseCount 
									WHEN 1 THEN (
													SELECT
															LRM.MaterialWarehouseCode
													FROM
															STB_LineRouteMapping LRM WITH(NOLOCK)
													WHERE
															LRM.RouteCode = BOM.RouteCode
													  )
									ELSE NULL
								END AS TargetMaterialWarehouseCode
						FROM
								BOM
					)

	SELECT
			M.PONo,
			M.SourceMaterialWarehouseCode,
			SMW.MaterialWarehouseName AS SourceMaterialWarehouseName,
			M.MaterialCode,			
			MM.MaterialName,
			M.UsedQty,			
			M.TotalUsedQty,
			ISNULL(M.GIQty,0) AS GIQty,
			--M.TotalUsedQty - M.GIQty AS RequestQty,	-- 2018-09-10 JGH 수정
			M.TotalUsedQty - ISNULL(M.RequestQty,0) AS RequestQty,	-- 2018-09-10 JGH 수정
			MM.IsUseFlush,
			--M.TargetMaterialWarehouseCode,
			'ROUTE_WH' AS TargetMaterialWarehouseCode,
			--TMW.MaterialWarehouseName AS TargetMaterialWarehouseName
			'공정창고' AS TargetMaterialWarehouseName
	FROM
			Materials M WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM       WITH (NOLOCK)	ON	MM.MaterialCode = M.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG          WITH(NOLOCK)	ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse SMW WITH(NOLOCK)	ON	SMW.MaterialWarehouseCode = M.SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialWarehouse TMW WITH(NOLOCK)	ON	TMW.MaterialWarehouseCode = M.TargetMaterialWarehouseCode

END