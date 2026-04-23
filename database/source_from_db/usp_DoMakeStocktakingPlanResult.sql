
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-17
-- Description:	재고실사 기준데이터를 생성합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeStocktakingPlanResult]
						@pProcessLanguage VARCHAR(20),
						@pProcessUserID VARCHAR(20),
						@pStocktackingDocNo VARCHAR(20),
						@pExcludeBasicMaterialTypes VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@StocktackingDocNo VARCHAR(20) = @pStocktackingDocNo,
			@ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes,
			@CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@MaterialCode VARCHAR(20),
			@MLExtText01 NVARCHAR(MAX)

	SELECT
			@CompanyCode = SD.CompanyCode,
			@WorkCenterCode = SD.WorkCenterCode,
			@MaterialWarehouseCode = SD.MaterialWarehouseCode,
			@MLExtText01 = CASE WHEN ISNULL(SD.MLExtText01,'') = '' THEN '%' ELSE SD.MLExtText01 END,
			@MaterialCode = CASE WHEN ISNULL(SD.MaterialCode,'') = '' THEN '%' ELSE SD.MaterialCode END
	FROM
			STB_StocktakingDoc SD
	WHERE
			SD.StocktakingDocNo = @StocktackingDocNo

	IF @CompanyCode IS NULL BEGIN
		DECLARE @NotFoundStocktakingError NVARCHAR(MAX)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^실사 기준정보를 찾을 수 없습니다.^',
										@pValue = @NotFoundStocktakingError OUTPUT
		RAISERROR(@NotFoundStocktakingError,16,1)
		RETURN
	END

	IF EXISTS	(
					SELECT
							1
					FROM
							STB_StocktakingPlanResult SPR
					WHERE
							SPR.StocktakingDocNo = @StocktackingDocNo AND
							SPR.IsStocktaking = 1
				) BEGIN
		DECLARE @AlreadyStartError NVARCHAR(MAX)
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^실사가 이미 시작되었습니다.^',
										@pValue = @AlreadyStartError OUTPUT
		RAISERROR(@AlreadyStartError,16,1)
		RETURN
	END;

	DELETE FROM STB_StocktakingPlanResult
	WHERE
			StocktakingDocNo = @StocktackingDocNo

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
		IsStocktaking,
		StocktakingQty,
		StocktakingMaterialLocationCode,
		IsApplied,
		CreateDateTime,
		CreateUserID
	)
	SELECT
			@StocktackingDocNo,
			ROW_NUMBER() OVER(ORDER BY ML.MaterialLotNo) AS SeqNo,
			ML.MaterialLocationCode,
			ISNULL(ML.MaterialLotNo,''),
			ML.LotID,
			ML.MaterialCode,
			ML.MaterialStockAttribute,
			ML.StockAttrib1,
			ML.StockAttrib2,
			ML.StockAttrib3,
			ML.PackingID,
			ISNULL(ML.CurrentQty,0),
			ML.LotAttr01,
			ML.LotAttr02,
			ML.LotAttr03,
			ML.LotAttr04,
			ML.LotAttr05,
			ML.LotAttr06,
			ML.LotAttr07,
			ML.LotAttr08,
			ML.LotAttr09,
			ML.LotAttr10,
			0,		-- IsStocktaking
			0,		-- StocktakingQty
			ML.MaterialLocationCode, -- StocktakingMaterialLocationCode
			0,		-- IsApplied
			GETDATE(),
			@ProcessUserID
	FROM
			STB_MaterialLotInfo ML WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = ML.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MT.MaterialTypeCode = MM.MaterialTypeCode
	WHERE
			ML.CompanyCode = @CompanyCode AND
			ML.WorkCenterCode = @WorkCenterCode AND
			ML.MaterialWarehouseCode = @MaterialWarehouseCode AND
			ML.MaterialLocationCode IN (
										SELECT MaterialLocationCode 
										FROM 
												STB_MaterialLocation MLL WITH(NOLOCK)
										WHERE 
												MLL.MaterialWarehouseCode = @MaterialWarehouseCode
											--	AND MLL.MLExtText01 LIKE @MLExtText01  존 미사용으로 주석 처리(20250929)
										) AND
			MT.BasicMaterialType NOT IN (
											SELECT
													Item
											FROM
													dbo.fnSplitToTable(',',@ExcludeBasicMaterialTypes)
										) AND
			ML.MaterialCode LIKE @MaterialCode AND
			ML.CurrentQty > 0
END