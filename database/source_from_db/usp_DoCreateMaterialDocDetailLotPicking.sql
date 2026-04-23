-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-06
-- Description : 스캔된 바코드 리스트로 출고상세와 출고 LOT 정보 생성
-- Modified : 선택대화상자 > 출고상세Lot생성
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMaterialDocDetailLotPicking]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pProcessViewName VARCHAR(50),
					@pXml NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName,
			@iDoc INT,
			@MaterialDocNo VARCHAR(20),
			@MaterialDocDetailNo VARCHAR(20),
			@MaterialLotNo VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@MaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@RequestQty NUMERIC(20,5)

	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	DECLARE @Materials TABLE
	(
		MaterialDocNo VARCHAR(20),
		MaterialLotNo VARCHAR(20),
		RequestQty NUMERIC(20,5)
	)
	INSERT INTO @Materials
	SELECT
			MaterialDocNo,
			MaterialLotNo,
			RequestQty
	FROM
			OPENXML(@iDoc , @UpdateTableName , 2)
			WITH  (
					MaterialDocNo VARCHAR(20),
					MaterialLotNo VARCHAR(20),
					RequestQty NUMERIC(20,5)
				) X
			
	EXEC sp_xml_removedocument @iDoc

	DECLARE @Detail TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20),
		MaterialCode VARCHAR(50),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		RequestQty NUMERIC(20,5)
	)
	INSERT INTO @Detail
	SELECT
			M.MaterialDocNo,
			MLI.MaterialCode,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			SUM(M.RequestQty)
	FROM
			@Materials M
			INNER JOIN STB_MaterialLotInfo MLI
				ON	MLI.MaterialLotNo = M.MaterialLotNo
	GROUP BY
			M.MaterialDocNo,
			MLI.MaterialCode,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3
	ORDER BY
			MLI.MaterialCode

	DECLARE @Lot TABLE
	(
		ROW INT,
		MaterialLotNo VARCHAR(20),
		RequestQty NUMERIC(20,5)
	)
	

	DECLARE @DROW INT = 1,
			@DCOUNT INT = (SELECT COUNT(1) FROM @Detail),
			@LROW INT,
			@LCOUNT INT

	WHILE @DROW <= @DCOUNT BEGIN
		SELECT
				@MaterialDocNo = D.MaterialDocNo,
				@MaterialCode = D.MaterialCode,
				@MaterialStockAttribute = D.MaterialStockAttribute,
				@StockAttrib1 = D.StockAttrib1,
				@StockAttrib2 = D.StockAttrib2,
				@StockAttrib3 = D.StockAttrib3,
				@RequestQty = D.RequestQty
		FROM
				@Detail D
		WHERE
				D.ROW = @DROW

		IF EXISTS	(
						SELECT
								1
						FROM
								STB_MaterialDocDetail MDD
						WHERE
								MDD.MaterialDocNo = @MaterialDocNo AND
								MDD.MaterialCode = @MaterialCode AND
								MDD.MaterialStockAttribute = @MaterialStockAttribute AND
								MDD.StockAttrib1 = @StockAttrib1 AND
								MDD.StockAttrib2 = @StockAttrib2 AND
								MDD.StockAttrib3 = @StockAttrib3

					) BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage, '이미 추가된 자재입니다.'
			RETURN
		END

		EXEC usp_DoMakeMaterialDocDetailNo	@ProcessLanguage,
											@ProcessUserID,
											@MaterialDocDetailNo OUTPUT

		INSERT INTO STB_MaterialDocDetail
		(
			MaterialDocDetailNo,
			MaterialDocNo,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			RequestQty,
			AllowQty,
			PickingAssignQty,
			PickingQty,
			ProcessFixQty,
			UnitPriceQty,
			UnitPrice,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@MaterialDocDetailNo,
			@MaterialDocNo,
			@MaterialCode,
			@MaterialStockAttribute,
			@StockAttrib1,
			@StockAttrib2,
			@StockAttrib3,
			@RequestQty,	-- RequestQty
			@RequestQty,	-- AllowQty
			0,		-- PickingAssignQty
			0,		-- PickingQty
			0,		-- ProcessFixQty
			0,		-- UnitPriceQty
			0,		-- UnitPrice
			GETDATE(),
			@ProcessUserID
		)

		DELETE FROM @Lot
		INSERT INTO @Lot
		SELECT
				ROW_NUMBER() OVER(ORDER BY MLI.MaterialCode, MLI.MaterialLotnO),
				MLI.MaterialLotNo,
				M.RequestQty
		FROM
				@Materials M
				INNER JOIN STB_MaterialLotInfo MLI
					ON	MLI.MaterialLotNo = M.MaterialLotNo
		WHERE
				MLI.MaterialCode = @MaterialCode AND
				MLI.MaterialStockAttribute = @MaterialStockAttribute AND
				MLI.StockAttrib1 = @StockAttrib1 AND
				MLI.StockAttrib2 = @StockAttrib2 AND
				MLI.StockAttrib3 = @StockAttrib3
		ORDER BY
				MLI.MaterialCode,
				MLI.MaterialLotNo

		SET @LROW = 1
		SET @LCOUNT = (SELECT COUNT(1) FROM @Lot)

		WHILE @LROW <= @LCOUNT BEGIN
			SELECT
					@MaterialLotNo = L.MaterialLotNo,
					@RequestQty = L.RequestQty
			FROM
					@Lot L
					INNER JOIN STB_MaterialLotInfo MLI
						ON	MLI.MaterialLotNo = L.MaterialLotNo
			WHERE
					L.ROW = @LROW

			EXEC usp_PDADoPicking	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @MaterialDocNo,
									@pMaterialDocDetailNo = @MaterialDocDetailNo,
									@pMaterialLotNo = @MaterialLotNo,
									@pStockQty = @RequestQty
			--INSERT INTO STB_MaterialDocLotInfo
			--(
			--	MaterialDocDetailNo,
			--	MDLISeqNo,
			--	MaterialLotNo,
			--	LotID,
			--	MaterialCode,
			--	MaterialStockAttribute,
			--	StockAttrib1,
			--	StockAttrib2,
			--	StockAttrib3,
			--	StockQty,
			--	IsChecked,
			--	MaterialLocationCode,
			--	MaterialDocNo,
			--	PackingID,
			--	LotNo,
			--	LotAttr01,
			--	LotAttr02,
			--	LotAttr03,
			--	LotAttr04,
			--	LotAttr05,
			--	LotAttr06,
			--	LotAttr07,
			--	LotAttr08,
			--	LotAttr09,
			--	LotAttr10,
			--	CreateDateTime,
			--	CreateUserID
			--)
			--SELECT
			--		@MaterialDocDetailNo,
			--		(
			--			SELECT
			--					COUNT(1) + 1
			--			FROM
			--					STB_MaterialDocLotInfo MDLI
			--			WHERE
			--					MDLI.MaterialDocDetailNo = @MaterialDocDetailNo
			--		),
			--		@MaterialLotNo,
			--		MLI.LotID,
			--		MLI.MaterialCode,
			--		MLI.MaterialStockAttribute,
			--		MLI.StockAttrib1,
			--		MLI.StockAttrib2,
			--		MLI.StockAttrib3,
			--		@RequestQty,
			--		1,	-- IsChecked
			--		MLI.MaterialLocationCode,
			--		@MaterialDocNo,
			--		MLI.PackingID,
			--		MLI.LotNo,
			--		MLI.LotAttr01,
			--		MLI.LotAttr02,
			--		MLI.LotAttr03,
			--		MLI.LotAttr04,
			--		MLI.LotAttr05,
			--		MLI.LotAttr06,
			--		MLI.LotAttr07,
			--		MLI.LotAttr08,
			--		MLI.LotAttr09,
			--		MLI.LotAttr10,
			--		GETDATE(),
			--		@ProcessUserID
			--FROM
			--		@Lot L
			--		INNER JOIN STB_MaterialLotInfo MLI
			--			ON	MLI.MaterialLotNo = L.MaterialLotNo
			--WHERE
			--		L.ROW = @LROW

			SET @LROW = @LROW + 1
		END

		SET @DROW = @DROW + 1
	END	

END
