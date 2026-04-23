
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-08
-- Description:	피킹처리를 위해서 현재고 리스트를 조회합니다.
--				재고를 선입선출 기준으로 정렬하고 예정수량만큼 Picking 수량을 설정해서 리턴
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialLotList_ForPicking]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20) = NULL,
	@pIsAutoPicking BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,			
			@MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo,
			@IsAutoPicking BIT = ISNULL(@pIsAutoPicking,1),
			@MaterialDocNo VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@MaterialCode VARCHAR(20),
			@PlanQty NUMERIC(20,2);

	SELECT
			@MaterialDocNo = MDD.MaterialDocNo,
			@MaterialCode = MDD.MaterialCode,
			@MaterialWarehouseCode = CASE WHEN ISNULL(MDD.MDDErpRefText09,'') ='' THEN MDI.SourceMaterialWarehouseCode ELSE MDD.MDDErpRefText09 END,
			@PlanQty =	CASE
							WHEN ISNULL(MDD.PickingAssignQty,0) > 0 THEN MDD.PickingAssignQty
							ELSE MDD.AllowQty
						END
	FROM
			STB_MaterialDocDetail MDD WITH(NOLOCK)
			INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)
				ON	MDI.MaterialDocNo = MDD.MaterialDocNo
	WHERE
			MDD.MaterialDocDetailNo = @MaterialDocDetailNo


	IF EXISTS ( SELECT 
						* 
				FROM 
						STB_MaterialDocLotInfo MDLI WITH(NOLOCK) 
				WHERE	
						MDLI.MaterialDocDetailNo = @MaterialDocDetailNo AND 
						MDLI.MaterialCode = @MaterialCode) BEGIN
		SELECT			
				MDLI.MaterialDocNo,
				MDLI.MaterialDocDetailNo,
				-- 2018-09-11 JGH 수정
				--MLI.MaterialLotNo,
				--MLI.LotID,
				--MLI.GRDate,
				--MLI.MaterialCode,
				MDLI.MaterialLotNo,
				MDLI.LotID,
				MLI.GRDate,
				MDLI.MaterialCode,
				-----------------------
				MM.MaterialName,
				MM.MaterialSpec,
				MM.MaterialTypeCode,
				MT.MaterialTypeName,
				MM.ProductGroupCode,
				PG.ProductGroupName,
				ISNULL(MLI.CurrentQty,0) - ISNULL(MLI.PickingQty,0) AS AvailQty,	-- 2018-09-11 JGH 수정
				MDLI.StockQty,
				-- 2018-09-11 JGH 수정
				--MLI.MaterialStockAttribute,
				--MLI.StockAttrib1,
				--MLI.StockAttrib2,
				--MLI.StockAttrib3,
				--MLI.MaterialLocationCode,
				MDLI.MaterialStockAttribute,
				MDLI.StockAttrib1,
				MDLI.StockAttrib2,
				MDLI.StockAttrib3,
				MDLI.MaterialLocationCode,
				-------------------------------------
				ML.MaterialLocationName,
				--MLI.PackingID,		-- 2018-09-11 JGH 수정
				MDLI.PackingID,			-- 2018-09-11 JGH 수정
				MDLI.IsChecked,
				-- 2018-09-11 JGH 수정
				--MLI.CreateDateTime,
				--MLI.CreateUserID,
				--MLI.ChangeDateTime,
				--MLI.ChangeUserID
				MDLI.CreateDateTime,
				MDLI.CreateUserID,
				MDLI.ChangeDateTime,
				MDLI.ChangeUserID,
			(SELECT STUFF((SELECT ',' + LotNo 
			                 FROM STB_MaterialDocLotInfo 
							WHERE LotNo IS NOT NULL 
							  AND MDLI.PackingID = PackingID 
							  FOR XML PATH(''))
						, 1, 1, '')) AS LotList
				------------------------------
		FROM
				STB_MaterialDocLotInfo MDLI
				-- 2018-09-11 JGH 수정
				--INNER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)
					ON	MLI.MaterialLotNo = MDLI.MaterialLotNo
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = MDLI.MaterialCode
				LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
					ON	ML.MaterialLocationCode = MDLI.MaterialLocationCode
				LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
					ON	MT.MaterialTypeCode = MM.MaterialTypeCode
				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					ON	PG.ProductGroupCode = MM.ProductGroupCode
		WHERE
				MDLI.MaterialDocDetailNo = @MaterialDocDetailNo AND
				MDLI.MaterialCode = @MaterialCode
				
		ORDER BY
				MLI.GRDate
	END ELSE BEGIN
		DECLARE @Stock TABLE
		(
			ROW INT IDENTITY(1,1),
			MaterialLotNo VARCHAR(20),
			AvailQty NUMERIC(20,5),
			PickingQty NUMERIC(20,5)
		)
		INSERT INTO @Stock
		SELECT
				MLI.MaterialLotNo,
				MLI.CurrentQty - MLI.PickingQty,
				0
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
		WHERE
				MLI.MaterialWarehouseCode = @MaterialWarehouseCode AND
				MLI.MaterialCode = @MaterialCode AND
				MLI.CurrentQty IS NOT NULL AND
				MLI.CurrentQty > 0
		ORDER BY
				MLI.GRDate


		DECLARE @Row INT,
				@Count INT,
				@MaterialLotNo VARCHAR(20),
				@AvailQty NUMERIC(20,5)

		SELECT
				@Row = 1,
				@Count = COUNT(*)
		FROM
				@Stock

		WHILE @Row <= @Count BEGIN
			SELECT
					@AvailQty = S.AvailQty
			FROM
					@Stock S
			WHERE
					S.ROW = @Row

			IF @AvailQty >= @PlanQty BEGIN
				UPDATE
						@Stock
				SET
						PickingQty = @PlanQty
				WHERE
						ROW = @Row

				SET @PlanQty = 0
			END ELSE BEGIN
				UPDATE
						@Stock
				SET
						PickingQty = @AvailQty
				WHERE
						ROW = @Row

				SET @PlanQty = @PlanQty - @AvailQty
			END

			IF @PlanQty = 0 BEGIN
				BREAK
			END
			SET @Row = @Row + 1
		END

		SELECT			
				@MaterialDocNo AS MaterialDocNo,
				@MaterialDocDetailNo AS MaterialDocDetailNo,
				MLI.MaterialLotNo,
				MLI.LotID,
				MLI.GRDate,			
				MLI.MaterialCode,
				MM.MaterialName,
				MM.MaterialSpec,
				MM.MaterialTypeCode,
				MT.MaterialTypeName,
				MM.ProductGroupCode,
				PG.ProductGroupName,
				S.AvailQty,
				CASE 
					WHEN S.PickingQty > 0 THEN CASE WHEN MSAI.IsUseBarcode = 1 THEN MLI.CurrentQty ELSE S.PickingQty END 
					ELSE S.PickingQty
				END AS StockQty,
				MLI.MaterialStockAttribute,
				MLI.StockAttrib1,
				MLI.StockAttrib2,
				MLI.StockAttrib3,
				MLI.MaterialLocationCode,
				ML.MaterialLocationName,
				MLI.PackingID,			
				CONVERT(BIT,0) AS IsChecked,
				MLI.CreateDateTime,
				MLI.CreateUserID,
				MLI.ChangeDateTime,
				MLI.ChangeUserID,
			(SELECT STUFF((SELECT ',' + LotNo 
			                 FROM STB_MaterialDocLotInfo 
							WHERE LotNo IS NOT NULL 
							  AND MLI.PackingID = PackingID 
							  FOR XML PATH(''))
						, 1, 1, '')) AS LotList
		FROM
				@Stock S
				INNER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)
					ON	MLI.MaterialLotNo = S.MaterialLotNo
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = MLI.MaterialCode
				LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
					ON	ML.MaterialLocationCode = MLI.MaterialLocationCode
				LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
					ON	MT.MaterialTypeCode = MM.MaterialTypeCode
				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					ON	PG.ProductGroupCode = MM.ProductGroupCode
				LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)
					ON MSAI.MaterialCode = MLI.MaterialCode
		WHERE
				@IsAutoPicking = 1
		ORDER BY
				MLI.GRDate

	END
END