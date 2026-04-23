


-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-09-26
-- Browsable : true
-- Group : 재고관리 > [F740] 자재 Lot수량조정 > Main조회
-- Description:	분리된 재고정보를 조회합니다.
-- Modified: 
--                2020.06.15 바코드오류 (제조일자, 유효일자 추가)

-- [프로시저 실행문] exec usp_GetSplittingMaterialLotInfo 'ML20250102000015' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSplittingMaterialLotInfo]

						@pPackingID VARCHAR(50)=null
						
AS
BEGIN
	SET NOCOUNT ON;
	--raiserror(@pPackingID,16,1)
	--DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	--DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	--DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	----DECLARE @LotNo VARCHAR(50) = @pLotNo
	--DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END


	DECLARE @PackingID VARCHAR(50) = @pPackingID
	DECLARE @ActualExportQuantity NUMERIC(20,5)
		select @ActualExportQuantity = ActualExportQuantity  from STB_MaterialWarehouseInOutHist where lotID=@pPackingID  and SourceMaterialWarehouseCode='ROH_HN_WH' and TargetMaterialWarehouseCode='SLITTING_HN_WH'  -- lấy ra tổng số lượng còn lại đã chia

	;
	WITH Lot AS
	(
		SELECT
				*
		FROM
				STB_MaterialLotInfo  MLI WITH(NOLOCK)
		WHERE
						MLI.PackingIdParent=@PackingID
				
	)    
	SELECT
			
					L.MaterialLotNo AS OldMaterialLotNo,
					L.MaterialLotNo,
					L.LotID,
					L.CompanyCode,
					L.WorkCenterCode,
					L.MaterialWarehouseCode,
					L.MaterialLocationCode,
					L.MaterialCode,
					MM.MaterialName,
					L.MaterialStockAttribute,
					L.StockAttrib1,
					L.StockAttrib2,
					L.StockAttrib3,
					L.PackingID,
					L.GRDate,
					L.MaterialDeliveryNo,
					L.MaterialDeliveryDetailNo,
					L.InitialQty,
					L.CurrentQty as CurrentQty,
					@ActualExportQuantity as ParentCurrentQty , 
					L.PickingQty,
					L.VendorLotNo,
					L.LifeBasicDate,
					L.ProductionDate,
					L.EndOfLifeDate,
					L.LotNo,
					L.IsSplitLot,
					L.BefMaterialLotNo,
					L.LotAttr01,
					L.LotAttr02,
					L.LotAttr03,
					L.LotAttr04,
					L.LotAttr05,
					L.LotAttr06,
					L.LotAttr07,
					L.LotAttr08,
					L.LotAttr09,
					L.LotAttr10,
					L.CreateDateTime,
					L.CreateUserID,
					L.ChangeDateTime,
					L.ChangeUserID,
					L.DateConfirmEx,
					L.HoldError,
					L.Holddate,
					L.HoldPeriod,
					L.PackingIdParent,
					L.IsSlitting,
					L.CheckTime,
					L.CheckUserID,
					L.IsCheck,
					L.LengthSlitting,
					isnull(MM.MaterialUnit,WS.MaterialUnit) as MaterialUnit,
					'PartLabel' AS LabelType,                        --2020.04.08
					'자재라벨slitting' AS LabelFormatName,			
					'Report' AS CommandType
					, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  --Mr.Duy sửa 2023-12-12 lấy ngày đóng gói	 của lot mới tách
				
			
	FROM
			Lot L
			INNER JOIN  STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.LotID = @PackingID
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	L.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = L.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = L.MaterialLocationCode
				LEFT OUTER JOIN STB_WidthSlitting WS WITH(NOLOCK)		ON	L.MaterialCode = WS.MaterialCode				

		 -- LEFT OUTER JOIN STB_ModelLabelInfo Label WITH (NOLOCK) 	ON (Label.LabelType = 'MATERIAL_LABEL' AND Label.ModelCode = MLI.MaterialCode)           -- 원본백업
	--WHERE
			--MLI.CurrentQty > 0 

END



