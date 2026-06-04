-- GW : ED-VJPMTR000000011
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-01
-- Description:	수불정보LOT 업데이트 트리거
--				출고 LOT 정보 변경 시 재고LOT 정보 UPDATE
-- =============================================
CREATE TRIGGER [dbo].[tgMaterialDocLotInfoIUD]
   ON  [dbo].[STB_MaterialDocLotInfo]
   AFTER INSERT,UPDATE,DELETE
AS 
BEGIN
	SET NOCOUNT ON;

	-- 
	Declare @BefLotAttr10 NVARCHAR(100)
	Declare @AftLotAttr10 NVARCHAR(100)
	Declare @LogText NVARCHAR(500)

	
	-- 출고,이동 문서의 경우 STB_MaterialDocLotInfo 에 INSERT/UPDATE/DELETE 할 때 
	-- STB_MaterialLotInfo 의 PickingQty 를 업데이트 하는데 
	-- 문서취소(usp_DoCancelMaterialDoc)시 STB_MaterialDocLotInfo 를 삭제할때는 CONTEXT_INFO 를 0x999997 로 설정해서
	-- 트리거가 동작하지 않도록 한다.
	IF CONTEXT_INFO() = 0x999997 BEGIN
		RETURN
	END

	DECLARE @LotInfo TABLE
	(
		MaterialDocNo VARCHAR(20),
		MaterialDocDetailNo VARCHAR(20),
		IsAssignPicking BIT,
	--	MaterialStockNo BIGINT,
		MaterialLotNo VARCHAR(20),
		LotID VARCHAR(50),		
		GRDate VARCHAR(10),		
		MaterialWarehouseCode VARCHAR(20),
		MaterialLocationCode VARCHAR(20),
		MaterialCode VARCHAR(50),			-- 2016-07-03 JGH 20 -> 50으로 수정
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		PickingQty NUMERIC(20,5),
		IsChecked BIT,
		IsFIFO BIT
	)
	INSERT INTO @LotInfo
	SELECT
			MDD.MaterialDocNo,
			MDD.MaterialDocDetailNo,
			MDI.IsAssignPicking,
		--	MS.MaterialStockNo,
			D.MaterialLotNo,
			D.LotID,
			MLI.GRDate,
			ML.MaterialWarehouseCode,
			D.MaterialLocationCode,
			D.MaterialCode,
			D.MaterialStockAttribute,
			D.StockAttrib1,
			D.StockAttrib2,
			D.StockAttrib3,
			D.StockQty,
			D.IsChecked,
			MSA.IsFIFO						
	FROM
			deleted D
			INNER JOIN STB_MaterialLocation ML
				ON	ML.MaterialLocationCode = D.MaterialLocationCode
			INNER JOIN STB_MaterialDocDetail MDD
				ON	MDD.MaterialDocDetailNo = D.MaterialDocDetailNo
			INNER JOIN STB_MaterialDocInfo MDI
				ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			iNNER JOIN STB_MaterialLotInfo MLI
				ON	MLI.MaterialLotNo = D.MaterialLotNo
		--  필요시 JOIN 조건으로 변경. 하단에 바코드 부분
		--	INNER JOIN STB_MaterialStock MS
		--		ON	MS.MaterialWarehouseCode = ML.MaterialWarehouseCode AND
		--			MS.MaterialLocationCode = D.MaterialLocationCode AND
		--			MS.MaterialCode = D.MaterialCode AND
		--			MS.MaterialStockAttribute = D.MaterialStockAttribute AND
		--			MS.StockAttrib1 = D.StockAttrib1 AND
		--			MS.StockAttrib2 = D.StockAttrib2 AND
		--			MS.StockAttrib3 = D.StockAttrib3
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSA
				ON	MSA.MaterialCode = D.MaterialCode
	WHERE
			D.IsChecked = 1 AND
			MDI.MaterialDocType IN ('GI','MOVE')
	
	-- DELETE 또는 UPDATE 될 경우 STB_MaterialLotInfo 피킹수량 차감	
	-- STB_MaterialLotInfo 의 tgMaterialLotInfo 에 의해서 재고정보(STB_MaterialStock)까지 자동 반영된다.
	MERGE STB_MaterialLotInfo AS T
	USING @LotInfo AS S
		ON	(
				S.MaterialLotNo = T.MaterialLotNo
			)
	WHEN MATCHED THEN
		UPDATE SET
			PickingQty = T.PickingQty - S.PickingQty;

	-- 출고상세 정보에 피킹수량 차감
	MERGE STB_MaterialDocDetail T
	USING	(
				SELECT	MaterialDocDetailNo,
						SUM(PickingQty) AS PickingQty
				FROM	@LotInfo 
				GROUP BY
						MaterialDocDetailNo
			) AS S
		ON	(
				S.MaterialDocDetailNo = T.MaterialDocDetailNo
			)
	WHEN MATCHED THEN 
		UPDATE SET
			PickingQty = T.PickingQty - S.PickingQty;
	
	-- 바코드를 사용하고 선입선출을 사용하는 자재의 경우
	-- 피킹지시정보가 있을 경우 피킹수량 차감		
	MERGE STB_MaterialDocPickingPlan T
	USING (	SELECT
					L.MaterialDocDetailNo,
					MS.MaterialStockNo,
					L.GRDate,
					SUM(L.PickingQty) AS PickingQty
			FROM
					@LotInfo L
			INNER JOIN STB_MaterialStock MS
				ON	MS.MaterialWarehouseCode = L.MaterialWarehouseCode AND
					MS.MaterialLocationCode = L.MaterialLocationCode AND
					MS.MaterialCode = L.MaterialCode AND
					MS.MaterialStockAttribute = L.MaterialStockAttribute AND
					MS.StockAttrib1 = L.StockAttrib1 AND
					MS.StockAttrib2 = L.StockAttrib2 AND
					MS.StockAttrib3 = L.StockAttrib3
			WHERE
					L.IsFIFO = 1
			GROUP BY
					L.MaterialDocDetailNo,
					MS.MaterialStockNo,
					L.GRDate
		 ) AS S
		ON	(
				S.MaterialDocDetailNo = T.MaterialDocDetailNo AND
				S.MaterialStockNo = T.MaterialStockNo AND
				S.GRDate = T.GRDate
			)
	WHEN MATCHED THEN
		UPDATE SET
					PickingQty = T.PickingQty - S.PickingQty;
	
	

	DELETE FROM @LotInfo

	INSERT INTO @LotInfo
	SELECT
			MDD.MaterialDocNo,
			MDD.MaterialDocDetailNo,
			MDI.IsAssignPicking,
		--	MS.MaterialStockNo,
			D.MaterialLotNo,
			D.LotID,
			MLI.GRDate,
			ML.MaterialWarehouseCode,
			D.MaterialLocationCode,
			D.MaterialCode,
			D.MaterialStockAttribute,
			D.StockAttrib1,
			D.StockAttrib2,
			D.StockAttrib3,
			D.StockQty,
			D.IsChecked,
			MSA.IsFIFO			
	FROM
			inserted D
			INNER JOIN STB_MaterialLocation ML
				ON	ML.MaterialLocationCode = D.MaterialLocationCode
			INNER JOIN STB_MaterialDocDetail MDD
				ON	MDD.MaterialDocDetailNo = D.MaterialDocDetailNo
			INNER JOIN STB_MaterialDocInfo MDI
				ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			INNER JOIN STB_MaterialLotInfo MLI
				ON	MLI.MaterialLotNo = D.MaterialLotNo
		--	INNER JOIN STB_MaterialStock MS
		--		ON	MS.MaterialWarehouseCode = ML.MaterialWarehouseCode AND
		--			MS.MaterialLocationCode = D.MaterialLocationCode AND
		--			MS.MaterialCode = D.MaterialCode AND
		--			MS.MaterialStockAttribute = D.MaterialStockAttribute AND
		--			MS.StockAttrib1 = D.StockAttrib1 AND
		--			MS.StockAttrib2 = D.StockAttrib2 AND
		--			MS.StockAttrib3 = D.StockAttrib3
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSA
				ON	MSA.MaterialCode = D.MaterialCode
	WHERE
			MDI.MaterialDocType IN ('GI','MOVE') AND
			D.IsChecked = 1

	-- 재고의 피킹수량 증가
	MERGE STB_MaterialLotInfo AS T
	USING @LotInfo AS S
		ON	(
				S.MaterialLotNo = T.MaterialLotNo
			)
	WHEN MATCHED THEN
		UPDATE SET
			PickingQty = T.PickingQty + S.PickingQty;
	
	-- 출고상세 정보에 피킹수량 증가
	MERGE STB_MaterialDocDetail T
	USING	(
				SELECT	MaterialDocDetailNo,
						SUM(PickingQty) AS PickingQty
				FROM	@LotInfo 
				GROUP BY
						MaterialDocDetailNo
			) AS S
		ON	(
				S.MaterialDocDetailNo = T.MaterialDocDetailNo
			)
	WHEN MATCHED THEN 
		UPDATE SET
			PickingQty = T.PickingQty + S.PickingQty;

	-- 바코드를 사용하고 선입선출을 사용하는 자재의 경우
	-- 피킹지시정보가 있을 경우 피킹수량 증가	
	MERGE STB_MaterialDocPickingPlan T
	USING (	SELECT
					L.MaterialDocDetailNo,
					MS.MaterialStockNo,
					L.GRDate,
					SUM(L.PickingQty) AS PickingQty
			FROM
					@LotInfo L
			INNER JOIN STB_MaterialStock MS
				ON	MS.MaterialWarehouseCode = L.MaterialWarehouseCode AND
					MS.MaterialLocationCode = L.MaterialLocationCode AND
					MS.MaterialCode = L.MaterialCode AND
					MS.MaterialStockAttribute = L.MaterialStockAttribute AND
					MS.StockAttrib1 = L.StockAttrib1 AND
					MS.StockAttrib2 = L.StockAttrib2 AND
					MS.StockAttrib3 = L.StockAttrib3
			WHERE
					L.IsFIFO = 1
			GROUP BY
					L.MaterialDocDetailNo,
					MS.MaterialStockNo,
					L.GRDate
		 ) AS S
		ON	(
				S.MaterialDocDetailNo = T.MaterialDocDetailNo AND
				S.MaterialStockNo = T.MaterialStockNo AND
				S.GRDate = T.GRDate
			)
	WHEN MATCHED THEN
		UPDATE SET
					PickingQty = T.PickingQty + S.PickingQty;

	-- 제조일자 변경 시 MaterialDocLotInfo와 MaterialLotInfo 동기화 2024.11.07 구보겸프로 요청
	SELECT @BefLotAttr10 = LotAttr10 FROM deleted

	SELECT @AftLotAttr10 = LotAttr10 FROM inserted

	IF @BefLotAttr10 <> @AftLotAttr10 BEGIN
		UPDATE STB_MaterialLotInfo
		   SET LotAttr10 = @AftLotAttr10
		 WHERE LotID = (SELECT MAX(LotID) FROM inserted)
	END
END

