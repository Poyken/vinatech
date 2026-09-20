
-- ED-VJPMTR000000012
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-21
-- Description:	재고요약 업데이트 트리거
-- =============================================
CREATE TRIGGER [dbo].[tgMaterialLotInfoForUpdate]
   ON  [dbo].[STB_MaterialLotInfo]
   AFTER UPDATE
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
	
			
	WITH InsertedStock AS
	(
		SELECT
				ROW_NUMBER() OVER (ORDER BY  I.CompanyCode, I.WorkCenterCode, I.MaterialWarehouseCode, I.MaterialLocationCode, I.MaterialCode, I.MaterialStockAttribute, I.StockAttrib2, I.StockAttrib3) AS SeqNo,
				I.CompanyCode,
				I.WorkCenterCode,
				I.MaterialWarehouseCode,
				I.MaterialLocationCode,
				I.MaterialCode,
				I.MaterialStockAttribute,
				--I.StockAttrib1,
				I.StockAttrib2,
				I.StockAttrib3,
				SUM(I.CurrentQty) AS StockQty
		FROM
				inserted I
		GROUP BY
				I.CompanyCode,
				I.WorkCenterCode,
				I.MaterialWarehouseCode,
				I.MaterialLocationCode,
				I.MaterialCode,
				I.MaterialStockAttribute,
				--I.StockAttrib1,
				I.StockAttrib2,
				I.StockAttrib3
	)
	MERGE STB_MaterialStock AS T
	USING InsertedStock AS S
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
			StockQty = T.StockQty + S.StockQty
	WHEN NOT MATCHED THEN
		INSERT 
		(
			MaterialStockNo,
			CompanyCode,
			WorkCenterCode,
			MaterialWarehouseCode,
			MaterialLocationCode,
			MaterialCode,
			MaterialStockAttribute,
			--StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			StockQty,
			PickingAssignQty
		)
		VALUES
		(
			(SELECT ISNULL(MAX(MaterialStockNo),0) + S.SeqNo FROM STB_MaterialStock),
			CompanyCode,
			WorkCenterCode,
			S.MaterialWarehouseCode,
			S.MaterialLocationCode,
			S.MaterialCode,
			S.MaterialStockAttribute,
			--S.StockAttrib1,
			S.StockAttrib2,
			S.StockAttrib3,
			S.StockQty,
			0
		);
END


