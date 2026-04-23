-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-06
-- Description : 선택대화상자 > 출고LOT생성 
-- Modified : 스캔된 바코드 리스트로 출고 LOT 정보 생성
-- =============================================
--  exec [usp_DoCreateMaterialDocLotPicking] '','','',''

CREATE PROCEDURE [dbo].[usp_DoCreateMaterialDocLotPicking]
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
			@RequestQty NUMERIC(20,5),
			@AllowQty NUMERIC(20,5),
			@LotQty NUMERIC(20,5)

	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	DECLARE @Materials TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20),
		MaterialDocDetailNo VARCHAR(20),
		MaterialLotNo VARCHAR(20),
		RequestQty NUMERIC(20,5)
	)
	INSERT INTO @Materials
	SELECT
			MaterialDocNo,
			MaterialDocDetailNo,
			MaterialLotNo,
			RequestQty
	FROM
			OPENXML(@iDoc , @UpdateTableName , 2)
			WITH  (
					MaterialDocNo VARCHAR(20),
					MaterialDocDetailNo VARCHAR(20),
					MaterialLotNo VARCHAR(20),
					RequestQty NUMERIC(20,5)
				) X

			
	EXEC sp_xml_removedocument @iDoc

	DECLARE @LROW INT,
			@LCOUNT INT

	SET @LROW = 1
	SET @LCOUNT = (SELECT COUNT(1) FROM @Materials)

	WHILE @LROW <= @LCOUNT BEGIN
		SELECT
				@MaterialDocNo = L.MaterialDocNo, 
				@MaterialLotNo = L.MaterialLotNo,
				@MaterialDocDetailNo = L.MaterialDocDetailNo,
				@RequestQty = L.RequestQty
		FROM
				@Materials L
		WHERE
				L.ROW = @LROW

		IF EXISTS ( SELECT 1 FROM STB_MaterialDocLotInfo MDLI WHERE MDLI.MaterialDocNo = @MaterialDocNo AND MDLI.MaterialLotNo = @MaterialLotNo)
		
		BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage, '이미 추가된 바코드입니다.'
			RETURN
		END

		SELECT
				@LotQty = SUM(MDLI.StockQty)
		FROM
				STB_MaterialDocLotInfo MDLI 
		WHERE
				MDLI.MaterialDocDetailNo = @MaterialDocDetailNo

		SELECT
				@AllowQty = MDD.AllowQty
		FROM
				STB_MaterialDocDetail MDD
		WHERE
				MDD.MaterialDocDetailNo = @MaterialDocDetailNo

		IF @AllowQty < @LotQty + @RequestQty 

		BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage, '상세내역의 수량을 초과할 수 없습니다.'
			RETURN
		END

		EXEC usp_PDADoPicking	@pProcessLanguage = @ProcessLanguage,
										@pProcessUserID = @ProcessUserID,
										@pMaterialDocNo = @MaterialDocNo,
										@pMaterialDocDetailNo = @MaterialDocDetailNo,
										@pMaterialLotNo = @MaterialLotNo,
										@pStockQty = @RequestQty,
										@pIsRemovePacking = 1

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
		--		L.MaterialDocDetailNo,
		--		(
		--			SELECT
		--					COUNT(1) + 1
		--			FROM
		--					STB_MaterialDocLotInfo MDLI
		--			WHERE
		--					MDLI.MaterialDocDetailNo = L.MaterialDocDetailNo
		--		),
		--		L.MaterialLotNo,
		--		MLI.LotID,
		--		MLI.MaterialCode,
		--		MLI.MaterialStockAttribute,
		--		MLI.StockAttrib1,
		--		MLI.StockAttrib2,
		--		MLI.StockAttrib3,
		--		@RequestQty,
		--		1,	-- IsChecked
		--		MLI.MaterialLocationCode,
		--		L.MaterialDocNo,
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
		--		@Materials L
		--		INNER JOIN STB_MaterialLotInfo MLI
		--			ON	MLI.MaterialLotNo = L.MaterialLotNo
		--WHERE
		--		L.ROW = @LROW

		SET @LROW = @LROW + 1
	END
END



-- select * FROM				STB_MaterialDocLotInfo ORDER BY CREATEDATETIME DESC
-- select * FROM STB_MaterialDocDetail
-- select * from STB_MaterialLotNo