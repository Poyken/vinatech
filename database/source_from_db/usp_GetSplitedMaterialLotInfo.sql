


-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-09-26
-- Browsable : true
-- Group : 재고관리 > [F740] 자재 Lot수량조정 > Main조회
-- Description:	분리된 재고정보를 조회합니다.
-- Modified: 
--                2020.06.15 바코드오류 (제조일자, 유효일자 추가)

--  exec usp_GetSplitedMaterialLotInfo '','','VVT','VVT_F3','','SLITTING_HN_WH','SL20250311000107'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSplitedMaterialLotInfo]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20)=NULL,
						@pWorkCenterCode VARCHAR(20)=NULL,
						@pMaterialCode VARCHAR(50)=NULL,
						@pMaterialWarehouseCode VARCHAR(20) = NULL,
						@pLotID VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) =CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END 
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END 
	DECLARE @PackingID varchar(50) 





	DECLARE @LotID VARCHAR(50) --= CASE WHEN ISNULL(@pLotID,'') = '' THEN '*' ELSE @pLotID END 
	DECLARE @IsPerentCheck VARCHAR(50)
	DECLARE @IsPerentChildrent VARCHAR(50)

	select @IsPerentChildrent= IsParrent from stb_materiallotinfo where lotid=@pLotID

	select @LotID=lotid from stb_materiallotinfo where lotid = (select packingid from STB_MaterialLotInfo where LotID=@pLotID)

	select @IsPerentCheck= IsParrent from stb_materiallotinfo where lotid=@LotID


	--kiểm tra xem lot cha có cắt không nếu không cắt mà là mã SP thì sẽ lấy luôn mã SP đó
	if(@IsPerentCheck is null)
		begin
			
			set @LotID=@pLotID
		end
	-- nếu cả cha lẫn con đều cắt thì sẽ lấy của thằng con
	if(@IsPerentCheck =1 and @IsPerentChildrent =1)
		begin
			
			set @LotID=@pLotID
		end
	--DECLARE @LotNo VARCHAR(50) = @pLotNo
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END

	Declare @SumCurrentQty NUMERIC(20, 10)	,@remaQty NUMERIC(20, 10)
	declare @sumTotalTem int
	Declare @ActualExportQuantity NUMERIC(20, 10)


	select @SumCurrentQty =SUM(InitialQty),@sumTotalTem=COUNT(*) from STB_MaterialLotInfo where PackingIdParent=@LotID and lotid <> PackingID -- lấy ra tổng số lượng đã chia
	select @remaQty = ActualExportQuantity - isnull(@SumCurrentQty,0) ,@ActualExportQuantity= ActualExportQuantity from STB_MaterialWarehouseInOutHist where lotID=@LotID  and SourceMaterialWarehouseCode='ROH_HN_WH' and TargetMaterialWarehouseCode='SLITTING_HN_WH'  -- lấy ra tổng số lượng còn lại đã chia
	--print @sumTotalTem
	declare @sumCurentVarcha varchar(20)=isnull(@SumCurrentQty,0) --chuyển số lượng sang dạng varchar
	declare @remaQtyVarcha varchar(20)=isnull(@remaQty,0) 
	--print @remaQty
	;
	WITH Lot AS
	(
		SELECT
				MLI.MaterialLotNo,Lotid
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
		WHERE
				(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND
				(@WorkCenterCode = '*' OR  MLI.WorkCenterCode = @WorkCenterCode) AND
				(@MaterialCode = '*' OR  MLI.MaterialCode = @MaterialCode) AND
				((@MaterialWarehouseCode = '*') OR (MLI.MaterialWarehouseCode = @MaterialWarehouseCode))
				--And MLI.LotID not like '%SL%' -- không lấy các lot đã cắt rồi bắt đầu là SL
				--and (MLI.IsSlitting = 0 or MLI.IsSlitting is null) -- chỉ lấy các lot chưa được cắt
				and (@LotID = '*' OR MLI.Lotid = @LotID)
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
			MLI.InitialQty - MLI.PickingQty AS AvailableQty,
			MLI.VendorLotNo,
			MLI.LifeBasicDate,
			MLI.ProductionDate,
			MLI.EndOfLifeDate,
			MLI.LotNo,
			MLI.IsSplitLot,
			CONVERT(NUMERIC(20, 10), NULL) AS SplitQty,	-- 재고분리를 위한 DUMMY 컬럼
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
			,isnull(@ActualExportQuantity,0) as ActualExportQuantity	 
	FROM
			Lot L
			LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo
			--LEFT OUTER JOIN STB_MaterialWarehouseInOutHist MWIOH WITH(NOLOCK)				ON	MWIOH.Lotid = MLI.Lotid
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
						
			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK)				
			ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    
			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15
		
		 -- LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK) 	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)           -- 원본백업
	--WHERE
		--	MLI.CurrentQty > 0


	--		DinhManh update 2025-01-22
	--WHERE 
	--		MW.MaterialWarehouseCode LIKE '%ROH%'

	--  
END



