-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-06
-- Description : 창고내 재고 자재인지 체크
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoValidateMaterialInWarehouse_20190807_BeforeCustomerLot]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20) = NULL,
	@pMaterialDocDetailNo VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL,	
	@pBarcode VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
				@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
				@MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo,
				@MaterialWarehouseCode VARCHAR(20) = @pMaterialWarehouseCode,			
				@Barcode VARCHAR(50) = @pBarcode,
				@CurrWarehouseCode VARCHAR(20),
				@MaterialLotNo VARCHAR(20),
				@MaterialCode VARCHAR(50),
				@MaterialStockAttribute VARCHAR(20),
				@StockAttrib1 VARCHAR(20),
				@StockAttrib2 VARCHAR(20),
				@StockAttrib3 VARCHAR(20),
				@CurBarcode VARCHAR(20)

	DECLARE @ResultList TABLE 
	(
	   MaterialDocNo VARCHAR(30),
	   MaterialDocDetailNo VARCHAR(30),
	   MaterialLotNo VARCHAR(20),
	   LotID VARCHAR(20),
	   MaterialCode VARCHAR(20),
	   MaterialName VARCHAR(100),
	   MaterialTypeCode VARCHAR(20),
	   MaterialTypeName VARCHAR(100),
	   ProductGroupCode VARCHAR(20),
	   ProductGroupName VARCHAR(100),
	   MaterialStockAttribute VARCHAR(200),
	   StockAttrib1 VARCHAR(200),
	   StockAttrib2 VARCHAR(200),
	   StockAttrib3 VARCHAR(200),
	   CurrentQty BIGINT,
	   RequestQty BIGINT
	)


	Declare cur CURSOR FOR

	SELECT LotID FROM STB_MaterialLotInfo WHERE (LotID = @Barcode OR PackingID = @Barcode)

	OPEN cur
	FETCH NEXT FROM cur INTO @CurBarcode

	WHILE @@FETCH_STATUS = 0 BEGIN

	SELECT  @CurrWarehouseCode = MLI.MaterialWarehouseCode,
			@MaterialLotNo = MLI.MaterialLotNo,
			@MaterialCode = MLI.MaterialCode,
			@MaterialStockAttribute = MLI.MaterialStockAttribute,
			@StockAttrib1 = MLI.StockAttrib1,
			@StockAttrib2 = MLI.StockAttrib2,
			@StockAttrib3 = MLI.StockAttrib3
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			(MLI.LotID = @CurBarcode)
	ORDER BY MLI.LotID

	IF @MaterialLotNo IS NULL 
	
	BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage, '재고정보를 찾을 수 없습니다.'
	RETURN
	END

	IF @CurrWarehouseCode <> @MaterialWarehouseCode 
	
	BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage, '다른 창고의 자재입니다.'
		RETURN
	END

	IF EXISTS	(
					SELECT
							1
					FROM
							STB_MaterialDocLotInfo MDLI
					WHERE
							MDLI.MaterialDocNo = @MaterialDocNo AND
							MDLI.MaterialLotNo = @MaterialLotNo
				) BEGIN
		EXEC usp_RaiseLocalizedError	@ProcessLanguage, '이미 추가된 자재입니다.'
		RETURN
	END

	IF @MaterialDocDetailNo IS NOT NULL 
	
	BEGIN
		IF NOT EXISTS	(
								SELECT
										1
								FROM
										STB_MaterialDocDetail MDD
								WHERE 1=1
									AND MDD.MaterialDocDetailNo = @MaterialDocDetailNo 
									AND MDD.MaterialCode = @MaterialCode 
									AND MDD.MaterialStockAttribute = @MaterialStockAttribute 
									AND MDD.StockAttrib1 = @StockAttrib1 
									AND MDD.StockAttrib2 = @StockAttrib2 
									AND MDD.StockAttrib3 = @StockAttrib3
						    ) 
							  BEGIN
										EXEC usp_RaiseLocalizedError	@ProcessLanguage, '상세내역에 해당하지 않는 자재입니다.'
			RETURN
		END
	END



	INSERT INTO @ResultList 
	SELECT
			@MaterialDocNo AS MaterialDocNo,
			@MaterialDocDetailNo AS MaterialDocDetailNo,
			MLI.MaterialLotNo,
			MLI.LotID,
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.CurrentQty,
			MLI.CurrentQty AS RequestQty
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)		ON	PG.ProductGroupCode = MM.ProductGroupCode
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo

	FETCH NEXT FROM cur INTO @CurBarcode
	END

	SELECT * 
	  FROM @ResultList
END