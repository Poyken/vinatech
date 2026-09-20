
-- ED-VJPMTR000000012
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-21
-- Description:	재고요약 삭제 트리거
-- =============================================
CREATE TRIGGER [dbo].[tgMaterialLotInfoForDelete]
   ON  [dbo].[STB_MaterialLotInfo]
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;

	

	WITH DeletedStock AS
	(
		SELECT
				D.CompanyCode,
				D.WorkCenterCode,
				D.MaterialWarehouseCode,
				D.MaterialLocationCode,
				D.MaterialCode,
				D.MaterialStockAttribute,
				--D.StockAttrib1,
				D.StockAttrib2,
				D.StockAttrib3,
				SUM(D.CurrentQty) AS StockQty
		FROM
				deleted D
		GROUP BY
				D.CompanyCode,
				D.WorkCenterCode,
				D.MaterialWarehouseCode,
				D.MaterialLocationCode,
				D.MaterialCode,
				D.MaterialStockAttribute,
				--D.StockAttrib1,
				D.StockAttrib2,
				D.StockAttrib3
	)
	MERGE STB_MaterialStock AS T
	USING DeletedStock AS S
		ON	(
				S.CompanyCode = T.CompanyCode AND
				S.WorkCenterCode = T.WorkCenterCode AND
				S.MaterialWarehouseCode = T.MaterialWarehouseCode AND
				S.MaterialLocationCode = T.MaterialLocationCode AND
				S.MaterialCode = T.MaterialCode AND
				S.MaterialStockAttribute = T.MaterialStockAttribute AND
				--S.StockAttrib1 = T.StockAttrib1 AND
				S.StockAttrib2 = T.StockAttrib2 AND
				S.StockAttrib3 = T.StockAttrib3
			)
	WHEN MATCHED THEN
		UPDATE SET
			StockQty = T.StockQty - S.StockQty;
	
	-- 입고취소 시에는 트리거가 동작하지 않도록 해서 스냅샷저장을 처리하지 않는다.
	IF CONTEXT_INFO() = 0x999999 BEGIN
		RETURN
	END;
	-- 출고가 확정될 경우 (정확히는 STB_MaterialLotInfo 의 재고(CurrentQty)가 0 이 될때) 
	-- 질의 성능향상을 위해 STB_MaterialLotInfo 를 삭제한다.
	-- 재고정보가 삭제되면 스냅샷(STB_MaterialLotSnapshot)에 저장한다.
	INSERT INTO STB_MaterialLotSnapshot
	(
		MaterialLotNo, 
		LotID, 
		CompanyCode, 
		WorkCenterCode, 
		MaterialWarehouseCode, 
		MaterialLocationCode, 
		MaterialCode, 
		MaterialStockAttribute, 
		--StockAttrib1, 
		StockAttrib2, 
		StockAttrib3, 
		PackingID, 
		GRDate, 
		InitialQty, 
		CurrentQty, 
		PickingQty, 
		VendorLotNo, 
		LifeBasicDate, 
		ProductionDate, 
		EndOfLifeDate, 
		LotNo, 
		IsSplitLot, 
		BefMaterialLotNo, 
		CreateDateTime, 
		CreateUserID, 
		ChangeDateTime, 
		ChangeUserID
	)
	SELECT
			MaterialLotNo, 
			LotID, 
			CompanyCode, 
			WorkCenterCode, 
			MaterialWarehouseCode, 
			MaterialLocationCode, 
			MaterialCode, 
			MaterialStockAttribute, 
			--StockAttrib1, 
			StockAttrib2, 
			StockAttrib3, 
			PackingID, 
			GRDate, 
			InitialQty, 
			CurrentQty, 
			PickingQty, 
			VendorLotNo, 
			LifeBasicDate, 
			ProductionDate, 
			EndOfLifeDate, 
			LotNo, 
			IsSplitLot, 
			BefMaterialLotNo, 
			CreateDateTime, 
			CreateUserID, 
			ChangeDateTime, 
			ChangeUserID
	FROM
			deleted
END
