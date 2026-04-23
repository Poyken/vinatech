
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-17
-- Description:	피킹을 할당합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAssignPicking]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo
	DECLARE @MaterialDocDetailNo VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@MaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@GRDate VARCHAR(10),
			@MaterialStockNo BIGINT,
			@AllowQty NUMERIC(20,5)
	
	DECLARE @MaterialDocType VARCHAR(20),
			@DocStatus VARCHAR(20),
			@IsCancel BIT
	SELECT
			@MaterialDocType = MDI.MaterialDocType,
			@DocStatus = MDI.DocStatus,
			@IsCancel = MDI.IsCancel
	FROM
			STB_MaterialDocInfo MDI
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo

	EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @MaterialDocNo,
									@pErrorWhenStart = 1	-- 작업이 시작되었으면 에러
	IF @@ERROR <> 0 BEGIN
		RETURN
	END

	DELETE FROM STB_MaterialDocPickingPlan
	WHERE
			MaterialDocNo = @MaterialDocNo

	-- 선입선출 내역 조회
	DECLARE @MaterialDocDetail TABLE
	(
		Row INT IDENTITY(1,1),
		MaterialDocDetailNo VARCHAR(20),
		CompanyCode VARCHAR(20),
		WorkCenterCode VARCHAR(20),
		MaterialWarehouseCode VARCHAR(20),
		MaterialCode VARCHAR(50),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		AllowQty NUMERIC(20,5)
	)
	INSERT INTO @MaterialDocDetail
	(		
		MaterialDocDetailNo,
		CompanyCode,
		WorkCenterCode,
		MaterialWarehouseCode,		
		MaterialCode,
		MaterialStockAttribute,
		StockAttrib1,
		StockAttrib2,
		StockAttrib3,
		AllowQty
	)
	SELECT
			MDD.MaterialDocDetailNo,
			MDI.SourceCompanyCode,
			MDI.SourceWorkCenterCode,
			MDI.SourceMaterialWarehouseCode,
			MDD.MaterialCode,
			MDD.MaterialStockAttribute,
			MDD.StockAttrib1,
			MDD.StockAttrib2,
			MDD.StockAttrib3,
			MDD.AllowQty
	FROM
			STB_MaterialDocDetail MDD
			INNER JOIN STB_MaterialDocInfo MDI
				ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			INNER JOIN STB_MaterialMaster MM
				ON	MM.MaterialCode = MDD.MaterialCode
			INNER JOIN STB_MaterialStockAttributeInfo MSA
				ON	MSA.MaterialCode = MM.MaterialCode
	WHERE
			MDD.MaterialDocNo = @MaterialDocNo AND
			MDI.MaterialDocType = 'GI' AND
			MSA.IsFIFO = 1
			
	-- 출고예정정보 중 동일 조건인
	-- 진행중인 할당정보 조회
	DECLARE @AlreadyAssignPicking TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialWarehouseCode VARCHAR(20),
		MaterialCode VARCHAR(50),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		GRDate VARCHAR(10),
		PickingAssignQty NUMERIC(20,5)
	)
	INSERT INTO @AlreadyAssignPicking
	(
		MaterialWarehouseCode,
		MaterialCode,
		MaterialStockAttribute,
		StockAttrib1,
		StockAttrib2,
		StockAttrib3,
		GRDate,
		PickingAssignQty
	)
	SELECT
			MS.MaterialWarehouseCode,
			MS.MaterialCode,
			MS.MaterialStockAttribute,
			MS.StockAttrib1,
			MS.StockAttrib2,
			MS.StockAttrib3,
			MDPP.GRDate,
			SUM(MDPP.PickingAssingQty)
	FROM
			STB_MaterialDocPickingPlan MDPP
			INNER JOIN STB_MaterialDocInfo MDI
				ON	MDI.MaterialDocNo = MDPP.MaterialDocNo
			INNER JOIN STB_MaterialStock MS
				ON	MS.MaterialStockNo = MDPP.MaterialStockNo
			INNER JOIN @MaterialDocDetail MDD
				ON	MDD.MaterialWarehouseCode = MS.MaterialWarehouseCode AND
					MDD.MaterialCode = MS.MaterialCode AND
					MDD.MaterialStockAttribute = MS.MaterialStockAttribute AND
					MDD.StockAttrib1 = MS.StockAttrib1 AND
					MDD.StockAttrib2 = MS.StockAttrib2 AND
					MDD.StockAttrib3 = MS.StockAttrib3
	WHERE
			MDI.MaterialDocNo <> @MaterialDocNo AND
			MDI.DocStatus <> 'FIX' AND
			MDI.IsCancel = 0
	GROUP BY
			MS.MaterialWarehouseCode,
			MS.MaterialCode,
			MS.MaterialStockAttribute,
			MS.StockAttrib1,
			MS.StockAttrib2,
			MS.StockAttrib3,
			MDPP.GRDate

	-- 출고예정정보 중 동일 조건인
	-- 선입선출 재고내역 조회
	DECLARE @Stock TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialStockNo BIGINT,
		MaterialWarehouseCode VARCHAR(20),
		MaterialCode VARCHAR(50),		
		MaterialLocationCode VARCHAR(20),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		GRDate VARCHAR(10),
		StockQty NUMERIC(20,5)
	)
	INSERT INTO @Stock
	SELECT
			MS.MaterialStockNo,
			MLI.MaterialWarehouseCode,
			MLI.MaterialCode,			
			MLI.MaterialLocationCode,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.GRDate,
			MLI.CurrentQty - MLI.PickingQty
	FROM
			@MaterialDocDetail MDD
			INNER JOIN STB_MaterialLotInfo MLI
				ON	MLI.CompanyCode = MDD.CompanyCode AND
					MLI.WorkCenterCode = MDD.WorkCenterCode AND
					MLI.MaterialWarehouseCode = MDD.MaterialWarehouseCode AND
					MLI.MaterialCode = MDD.MaterialCode AND
					MLI.MaterialStockAttribute = MDD.MaterialStockAttribute AND
					MLI.StockAttrib1 = MDD.StockAttrib1 AND
					MLI.StockAttrib2 = MDD.StockAttrib2 AND
					MLI.StockAttrib3 = MDD.StockAttrib3
			INNER JOIN STB_MaterialStock MS
				ON	MS.MaterialWarehouseCode = MLI.MaterialWarehouseCode AND
					MS.MaterialLocationCode = MLI.MaterialLocationCode AND
					MS.MaterialCode = MLI.MaterialCode AND
					MS.MaterialStockAttribute = MLI.MaterialStockAttribute AND
					MS.StockAttrib1 = MLI.StockAttrib1 AND
					MS.StockAttrib2 = MLI.StockAttrib2 AND
					MS.StockAttrib3 = MLI.StockAttrib3
	WHERE
			MLI.CurrentQty - MLI.PickingQty > 0
	
	-- 기할당수량 차감을 위해 사용할 임시 재고테이블
	DECLARE @TargetStock TABLE
	(
		ROW INT,
		StockRow INT,
		StockQty NUMERIC(20,5)
	)

	DECLARE @DetailRow INT,
			@DetailCount INT

	SELECT
			@DetailRow = 1,
			@DetailCount = COUNT(*)
	FROM
			@MaterialDocDetail MDD

	DECLARE @AlreadyAssignQty NUMERIC(20,5) = 0,
			@StockQty NUMERIC(20,5),
			@StockRow INT,
			@TargetRow INT

	WHILE @DetailRow <= @DetailCount BEGIN
		SELECT
				@MaterialDocDetailNo = MDD.MaterialDocDetailNo,
				@MaterialWarehouseCode = MDD.MaterialWarehouseCode,
				@MaterialCode = MDD.MaterialCode,
				@MaterialStockAttribute = MDD.MaterialStockAttribute,
				@StockAttrib1 = MDD.StockAttrib1,
				@StockAttrib2 = MDD.StockAttrib2,
				@StockAttrib3 = MDD.StockAttrib3,
				@AllowQty = MDD.AllowQty
		FROM
				@MaterialDocDetail MDD
		WHERE
				MDD.Row = @DetailRow

		SELECT
				@AlreadyAssignQty = SUM(AAP.PickingAssignQty)
		FROM
				@AlreadyAssignPicking AAP
		WHERE
				AAP.MaterialWarehouseCode = @MaterialWarehouseCode AND
				AAP.MaterialCode = @MaterialCode AND
				AAP.MaterialStockAttribute = @MaterialStockAttribute AND
				AAP.StockAttrib1 = @StockAttrib1 AND
				AAP.StockAttrib2 = @StockAttrib2 AND
				AAP.StockAttrib3 = @StockAttrib3

		DELETE FROM @TargetStock
		-- 할당할 대상재고 준비
		INSERT INTO @TargetStock
		SELECT
				ROW_NUMBER() OVER(ORDER BY S.ROW),
				S.ROW,
				S.StockQty
		FROM
				@Stock S
		WHERE
				S.MaterialWarehouseCode = @MaterialWarehouseCode AND
				S.MaterialCode = @MaterialCode AND
				S.MaterialStockAttribute = @MaterialStockAttribute AND
				S.StockAttrib1 = @StockAttrib1 AND
				S.StockAttrib2 = @StockAttrib2 AND
				S.StockAttrib3 = @StockAttrib3
		ORDER BY
				S.GRDate

		SET @TargetRow = 1
		WHILE @AlreadyAssignQty > 0 BEGIN
			SELECT
					@StockQty = TS.StockQty
			FROM
					@TargetStock TS
			WHERE
					TS.ROW = @TargetRow

			if @StockQty IS NULL BEGIN
				BREAK
			END

			-- 재고가 할당할 수량보다 많으면
			IF @StockQty > @AlreadyAssignQty BEGIN						
				UPDATE	@TargetStock
				SET
						StockQty = StockQty - @AlreadyAssignQty
				WHERE
						ROW = @TargetRow

				SET @AlreadyAssignQty = 0
			END ELSE BEGIN
				UPDATE	@TargetStock
				SET		StockQty = 0
				WHERE
						ROW = @TargetRow

				SET @AlreadyAssignQty = @AlreadyAssignQty - @StockQty
			END
			
			SET @TargetRow = @TargetRow + 1
			PRINT 'Already Assign Check'
		END	-- WHILE @AlreadyAssignQty > 0 BEGIN

		SET @TargetRow = 1
		WHILE @AllowQty > 0 BEGIN
			SET @MaterialStockNo = NULL

			SELECT
					@MaterialStockNo = S.MaterialStockNo,
					@StockQty = TS.StockQty, -- S.StockQty 는 기할당재고를 차감하지 않은 수량이 이므로 사용안함
					@GRDate = S.GRDate
			FROM
					@TargetStock TS
					INNER JOIN @Stock S
						ON	S.ROW = TS.StockRow
			WHERE
					TS.ROW = @TargetRow
			
			-- 대상재고가 없음
			IF @MaterialStockNo IS NULL BEGIN
				PRINT 'NO TARGET'
				BREAK
			END
			-- 더이상 대상재고가 없음
			IF @AllowQty = 0 BEGIN
				BREAK
			END

			-- 할당할 재고가 없음(기할당수량이 차감되었음)
			IF @StockQty = 0 BEGIN
				SET @TargetRow = @TargetRow + 1
				CONTINUE
			END

			IF @AllowQty < @StockQty BEGIN
				SET @StockQty = @AllowQty
				SET @AllowQty = 0
			END ELSE BEGIN
				SET @AllowQty = @AllowQty - @StockQty
			END

			PRINT @StockQty
			-- 동일조건에 할당된 내역이 있으면 수량 업데이트
			UPDATE	STB_MaterialDocPickingPlan
			SET
					PickingAssingQty = PickingAssingQty + @StockQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo AND
					MaterialStockNo = @MaterialStockNo AND
					GRDate = @GRDate
			-- 동일조건에 할당되어 있지 않으면 새행 입력
			IF @@ROWCOUNT = 0 BEGIN
				INSERT INTO STB_MaterialDocPickingPlan
				(
					MaterialDocDetailNo,
					PickingPlanSeq,
					MaterialStockNo,
					GRDate,
					PickingAssingQty,
					PickingQty,
					MaterialDocNo,
					CreateDateTime,
					CreateUserID
				)
				VALUES
				(
					@MaterialDocDetailNo,
					(SELECT COUNT(*) + 1 FROM STB_MaterialDocPickingPlan WHERE MaterialDocDetailNo = @MaterialDocDetailNo),
					@MaterialStockNo,
					@GRDate,
					@StockQty,
					0,
					@MaterialDocNo,
					GETDATE(),
					@ProcessUserID
				)
				PRINT 'INSERT'
			END -- IF @@ROWCOUNT = 0 BEGIN

			SET @TargetRow = @TargetRow + 1 -- 다음 대상재고
		END -- WHILE @AllowQty > 0 BEGIN
		SET @DetailRow = @DetailRow + 1
	END -- WHILE @DetailRow <= @DetailCount BEGIN
		
	UPDATE	STB_MaterialDocInfo
	SET		IsAssignPicking = 1,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE	MaterialDocNo = @MaterialDocNo
END

