
-- =============================================
-- Author:	   kilee
-- Create date: 2020-06-04
-- Browsable : true
-- Group : 자재수불관리
-- Description:	재고 자재리스트를 조회합니다.
-- Modified:

-- usp_MaterialInventoryLotInfoSum_PowerBI  'VNT', 'VNT_F1', 'ROH_WH', 'ROH_WH_01', '', '', 'ROH', '', '', 'ROH_WH'
-- usp_MaterialInventoryLotInfoSum_PowerBI  'VVT', 'VVT_F1', 'ROH_VN_WH', 'ROH_VN_WH_01', '', '', 'ROH', '', '', 'ROH_VN_WH'

-- usp_MaterialInventoryLotInfoSum_PowerBI 
-- ================================================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialInventoryLotInfoSum_PowerBI]
						
AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT
			
			MLI.CompanyCode,
			--MLI.WorkCenterCode,
			
			--MLI.MaterialStockAttribute,	
			--MLI.PackingID,
			--MLI.GRDate,
		
			SUM(MLI.CurrentQty) AS CurrentQty,
			SUM(MLI.CurrentQty) AS StockQty,
			--SUM(MLI.PickingQty) AS PickingQty
			--MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
			--MLI.VendorLotNo,
			--MLI.LifeBasicDate,
			--MLI.ProductionDate,
			--MLI.EndOfLifeDate,
			--MLI.LotNo,
			--MLI.IsSplitLot,
		
			--MMExtInt01 AS Effectivemonths,
			SUM(MM.BasicCostPrice) AS BasicCostPrice
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MLI.MaterialCode = MM.MaterialCode
	WHERE 1=1                                         
		AND MLI.stockAttrib3  <> 'X'                                                   
		GROUP BY MLI.CompanyCode,
			MLI.WorkCenterCode

			--MLI.GRDate
END

