
-- ED-VJPMTR000000012
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-17
-- Description:	재고요약 입력 트리거
-- =============================================
CREATE TRIGGER [dbo].[tgMaterialLotInfoForInsert]
   ON  [dbo].[STB_MaterialLotInfo]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	Declare @LotID VARCHAR(50)
	       ,@PackingID VARCHAR(50)

	SELECT @LotID = LotID 
	      ,@PackingID = PackingID
	  FROM inserted
	
   ;WITH InsertedStock AS
	(
		SELECT
				ROW_NUMBER() OVER (ORDER BY I.CompanyCode, I.WorkCenterCode, I.MaterialWarehouseCode, I.MaterialLocationCode, I.MaterialCode, I.MaterialStockAttribute, I.StockAttrib2, I.StockAttrib3) AS SeqNo,
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
			S.CompanyCode,
			S.WorkCenterCode,
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
	
	-- 창고이동(GI_MOVE => GR_MOVE)에 의해 입고될 경우 
	-- STB_MaterialLotSnapshot 정보로 STB_MaterialLotInfo 를 생성한다.
	-- 해당 제품이 출고될 경우 다시 STB_MaterialSnapshot 에 추가될 때 중복입력을 막기 위해
	-- STB_MaterialLotSnapshot 에서 삭제한다.
	DELETE FROM STB_MaterialLotSnapshot
	WHERE
			MaterialLotNo IN	(
									SELECT
											I.MaterialLotNo
									FROM
											inserted I
								)

	-- 원자재 박스가 소분될 경우 소분 전 오리지널 바코드 백업
	IF @PackingID LIKE 'ML%' AND @LotID <> @PackingID BEGIN
		INSERT INTO STB_OriginalLotIDInfo (LotID, PackingID)
			SELECT LotID, PackingID FROM inserted
	END
END
