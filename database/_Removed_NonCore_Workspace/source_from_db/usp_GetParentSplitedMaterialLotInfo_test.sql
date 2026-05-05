-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetParentSplitedMaterialLotInfo_test]
	-- Add the parameters for the stored procedure here
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20)=NULL,
						@pWorkCenterCode VARCHAR(20)=NULL,
						@pMaterialCode VARCHAR(50)=NULL,
						@pMaterialWarehouseCode VARCHAR(20) = NULL,
						@pLotID VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) =CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END 
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END 
	DECLARE @LotID VARCHAR(50) = CASE WHEN ISNULL(@pLotID,'') = '' THEN '*' ELSE @pLotID END 
	--DECLARE @LotNo VARCHAR(50) = @pLotNo
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END

	Declare @SumCurrentQty NUMERIC(20,5)	,@remaQty NUMERIC(20,5)
	declare @sumTotalTem int
	Declare @ActualExportQuantity NUMERIC(20,5)


	select @SumCurrentQty =SUM(CurrentQty),@sumTotalTem=COUNT(*) from STB_MaterialLotInfo where PackingIdParent=@pLotID and lotid <> PackingID -- lấy ra tổng số lượng đã chia
	select @remaQty = ActualExportQuantity - isnull(@SumCurrentQty,0) ,@ActualExportQuantity= ActualExportQuantity from STB_MaterialWarehouseInOutHist where lotID=@pLotID  and SourceMaterialWarehouseCode='ROH_HN_WH' and TargetMaterialWarehouseCode='SLITTING_HN_WH'  -- lấy ra tổng số lượng còn lại đã chia
	--print @sumTotalTem
	declare @sumCurentVarcha varchar(20)=isnull(@SumCurrentQty,0) --chuyển số lượng sang dạng varchar
	declare @remaQtyVarcha varchar(20)=isnull(@remaQty,0) 
	

	IF (SUBSTRING(@LotID, 1, 2) = 'SL')
		BEGIN
			WITH Lot AS
		
				(SELECT
						MLI.MaterialLotNo,Lotid
				FROM
						STB_MaterialLotInfo MLI WITH(NOLOCK)
				WHERE
						(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND
						(@WorkCenterCode = '*' OR  MLI.WorkCenterCode = @WorkCenterCode) AND

						MLI.MaterialWarehouseCode = 'SLITTING_HN_WH' AND


						MLI.LotID = (SELECT MLI2.PackingIdParent FROM STB_MaterialLotInfo MLI2 WHERE LotId = @LotID)
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
			MLI.InitialQty,
			MLI.CurrentQty,
			MLI.CurrentQty AS StockQty,
			@sumCurentVarcha as PickingQty,
			@sumTotalTem as sumTotalTem,
			@remaQtyVarcha as remaQty,
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

			'PartLabel' AS LabelType,                        --2020.04.08
			'자재라벨' AS LabelFormatName,			
			'Report' AS CommandType,
			MM.MaterialUnit,
			MM.MMExtText02,
			MM.MMExtText03 

			-- 추가사항
			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    --제조일자
			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  --Mr.Duy sửa 2023-12-12 lấy ngày đóng gói	 của lot mới tách
			--, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)  AS PackDate	  --유효일자	
			,MLI.isSlitting	
			,@ActualExportQuantity as ActualExportQuantity	 
	FROM
			Lot L
			LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
						
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK)				
			ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15
		

		END
	ELSE 
		BEGIN
			WITH Lot AS
			(
				SELECT
						MLI.MaterialLotNo,Lotid
				FROM
						STB_MaterialLotInfo MLI WITH(NOLOCK)
				WHERE
						(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND
						(@WorkCenterCode = '*' OR  MLI.WorkCenterCode = @WorkCenterCode) AND

						MLI.MaterialWarehouseCode = 'SLITTING_HN_WH' AND
						MLI.IsParrent = '1' AND

						(@LotID = '*' OR MLI.Lotid = @LotID OR MLI.PackingID = @LotID)
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
			MLI.InitialQty,
			MLI.CurrentQty,
			MLI.CurrentQty AS StockQty,
			@sumCurentVarcha as PickingQty,
			@sumTotalTem as sumTotalTem,
			@remaQtyVarcha as remaQty,
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

			'PartLabel' AS LabelType,                        --2020.04.08
			'자재라벨' AS LabelFormatName,			
			'Report' AS CommandType,
			MM.MaterialUnit,
			MM.MMExtText02,
			MM.MMExtText03 

			-- 추가사항
			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    --제조일자
			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  --Mr.Duy sửa 2023-12-12 lấy ngày đóng gói	 của lot mới tách
			--, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)  AS PackDate	  --유효일자	
			,MLI.isSlitting	
			,@ActualExportQuantity as ActualExportQuantity	 
	FROM
			Lot L
			LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
						
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK)				
			ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15
		

		END
	
	

END
