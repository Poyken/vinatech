-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-09-05
-- Browsable : true
-- Group : Lot Split
-- Description:	Make a small lot from merge lot
-- =============================================
CREATE PROC usp_DoMakeSplitLotInfo
						@pProcessLanguage VARCHAR(20),
						@pProcessUserID VARCHAR(20),
						@pMergeLotID VARCHAR(50)
AS
BEGIN
	Declare @MergeLotID VARCHAR(50) = @pMergeLotID
	       ,@TotalSplitQty NUMERIC(20,5) 
		   ,@TotalMergeQty NUMERIC(20,5)
		   ,@MaterialWarehouseCode VARCHAR(50)
		   ,@StocktakingDocNo VARCHAR(20)
		   ,@CompanyCode VARCHAR(20)
		   ,@WorkCenterCode VARCHAR(20)
		   ,@MaterialCode VARCHAR(20)
		   ,@NextSeq INT 
	       
	Declare @OriginalLotList TABLE (
		LotID VARCHAR(50)
	);

	Declare @SplitLotList TABLE (
		LotID VARCHAR(50)
	);

	IF EXISTS (SELECT 1 
			    FROM STB_SupportRawMaterialSplitHist 
				WHERE MergeLotID = @MergeLotID
				AND IsFixed = CONVERT(BIT, 1)) BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, '소분Lot이 확정되었습니다. 소분할 수 없습니다.'
					RETURN
			 END

	-- 오리지날 LotID 리스트
	INSERT INTO @OriginalLotList
		SELECT OriginalLotID
		  FROM STB_SupportRawMaterialMergeHist
		 WHERE MergeLotID = @MergeLotID

	-- 분할 LotID 리스트
	INSERT INTO @SplitLotList
		SELECT SplitLotID
		  FROM STB_SupportRawMaterialSplitHist
		 WHERE MergeLotID = @MergeLotID

	-- 병합 LotID Qty
	SELECT TOP 1 @TotalMergeQty = TotalCurrentQty
	  FROM STB_SupportRawMaterialSplitHist
	 WHERE MergeLotID = @MergeLotID

	-- 분할 LotID Qty의 총합
	SELECT @TotalSplitQty = SUM(SplitQty)
	  FROM STB_SupportRawMaterialSplitHist
	 WHERE MergeLotID = @MergeLotID

	-- 품목코드 정보
	SELECT @MaterialCode = MaterialCode
	  FROM STB_MaterialLotInfo
	 WHERE LotID IN (SELECT LotID FROM @OriginalLotList)

	-- 재고실사 창고 정보
	SELECT MaterialWarehouseCode
	  FROM STB_MaterialLotInfo
	 WHERE LotID IN (SELECT LotID FROM @OriginalLotList)
	 GROUP BY MaterialWarehouseCode

	 IF @@ROWCOUNT > 1 BEGIN
		-- 창고가 분산되어 있으므로 처리 불가
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '원자재의 창고가 분산되어 있습니다. 소분처리할 수 없습니다.'
		RETURN
	 END

	 SELECT @MaterialWarehouseCode = MaterialWarehouseCode
	   FROM STB_MaterialLotInfo
	 WHERE LotID IN (SELECT LotID FROM @OriginalLotList)
	 GROUP BY MaterialWarehouseCode

	 IF @MaterialWarehouseCode NOT IN (SELECT MaterialWarehouseCode 
	                                     FROM STB_MaterialWarehouse 
										WHERE IsRouteWarehouse = CONVERT(BIT, 1)) 
	 BEGIN
		-- 원자재고 공정창고에 없으므로 처리 불가
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '원자재가 공정창고에 없습니다. 원자재 불출 후 소분 가능합니다.'
		RETURN
	 END

	 SELECT @CompanyCode = CompanyCode
	       ,@WorkCenterCode = WorkCenterCode
	   FROM STB_UserInfo
	  WHERE UserID = @pProcessUserID

	 -- 자재재고 실사를 위한 StocktackingDocNo 채번
	 EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_StocktakingDoc',@StocktakingDocNo OUTPUT

	 -- 자재재고 실사 입력
	 INSERT INTO STB_StocktakingDoc (StocktakingDocNo, CompanyCode, WorkCenterCode, MaterialWarehouseCode, MaterialCode, BasicDate)
		SELECT @StocktakingDocNo, @CompanyCode, @WorkCenterCode, @MaterialWarehouseCode, @MaterialCode, GETDATE()

	-- 자재재고 실사 기준정보 생성
	EXEC usp_DoMakeStocktakingPlanResult @pProcessLanguage, @pProcessUserID, @StocktakingDocNo

	SELECT @NextSeq = MAX(SDNSeqNo) + 1 FROM STB_StocktakingPlanResult WHERE StocktakingDocNo = @StocktakingDocNo

	-- 오리지널 LotID 실사수량을 0으로 업데이트
	UPDATE STB_StocktakingPlanResult
	   SET IsStocktaking = CONVERT(BIT, 1)
		  ,StocktakingQty = 0
	 WHERE LotID IN (SELECT LotID FROM @OriginalLotList)

	-- 병합 LotID 정보를 추가하고, 병합 LotID의 실사 수량을 @TotalMergeQty - @TotalSplitQty로 업데이트
	INSERT INTO STB_StocktakingPlanResult
	(
		StocktakingDocNo,
		SDNSeqNo,
		MaterialLocationCode,
		MaterialLotNo,
		LotID,
		MaterialCode,
		MaterialStockAttribute,
		StockAttrib1,
		StockAttrib2,
		StockAttrib3,
		PackingID,
		BasicQty,
		LotAttr01,
		LotAttr02,
		LotAttr03,
		LotAttr04,
		LotAttr05,
		LotAttr06,
		LotAttr07,
		LotAttr08,
		LotAttr09,
		LotAttr10,
		StocktakingMaterialLocationCode,
		IsStocktaking,
		StocktakingQty,
		IsApplied,
		CreateDateTime,
		CreateUserID
	)
	SELECT @StocktakingDocNo
	      ,@NextSeq
		  ,(SELECT DefaultLocationCode FROM STB_MaterialWarehouse WHERE MaterialWarehouseCode = @MaterialWarehouseCode)
		  ,''
		  ,@MergeLotID
		  ,@MaterialCode
		  ,'NORMAL'
		  ,''
		  ,''
		  ,''
		  ,@MergeLotID
		  ,0
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,(SELECT DefaultLocationCode FROM STB_MaterialWarehouse WHERE MaterialWarehouseCode = @MaterialWarehouseCode)
		  ,CONVERT(BIT, 1)
		  ,@TotalMergeQty - @TotalSplitQty
		  ,0
		  ,GETDATE()
		  ,@pProcessUserID

	-- 분할 LotID를 입력
	INSERT INTO STB_StocktakingPlanResult
	(
		StocktakingDocNo,
		SDNSeqNo,
		MaterialLocationCode,
		MaterialLotNo,
		LotID,
		MaterialCode,
		MaterialStockAttribute,
		StockAttrib1,
		StockAttrib2,
		StockAttrib3,
		PackingID,
		BasicQty,
		LotAttr01,
		LotAttr02,
		LotAttr03,
		LotAttr04,
		LotAttr05,
		LotAttr06,
		LotAttr07,
		LotAttr08,
		LotAttr09,
		LotAttr10,
		StocktakingMaterialLocationCode,
		IsStocktaking,
		StocktakingQty,
		IsApplied,
		CreateDateTime,
		CreateUserID
	)
	SELECT @StocktakingDocNo
	      ,ROW_NUMBER() OVER(ORDER BY SplitLotID) + @NextSeq
		  ,(SELECT DefaultLocationCode FROM STB_MaterialWarehouse WHERE MaterialWarehouseCode = @MaterialWarehouseCode)
		  ,''
		  ,SplitLotID
		  ,@MaterialCode
		  ,'NORMAL'
		  ,''
		  ,''
		  ,''
		  ,SplitLotID
		  ,0
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
		  ,(SELECT DefaultLocationCode FROM STB_MaterialWarehouse WHERE MaterialWarehouseCode = @MaterialWarehouseCode)
		  ,CONVERT(BIT, 1)
		  ,SplitQty
		  ,0
		  ,GETDATE()
		  ,@pProcessUserID
	FROM STB_SupportRawMaterialSplitHist
   WHERE SplitLotID IN (SELECT LotID FROM @SplitLotList)

   -- 재고실사 실행
   exec usp_DoApplyStocktakingToStock @pProcessLanguage, @pProcessUserID, @StocktakingDocNo

   -- 분할LotID 확정처리
   UPDATE STB_SupportRawMaterialSplitHist
      SET IsFixed = CONVERT(BIT, 1)
	WHERE SplitLotID IN (SELECT LotID FROM @SplitLotList)
END