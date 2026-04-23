-- =============================================
-- Author: Jackaroe
-- Create date: 2022-08-24
-- Browsable : true
-- Group : 공통관리
-- Description:	BOM 정전개 내역 중 품목코드 리스트
-- =============================================
CREATE PROCEDURE usp_GetNormalModelBomListOutput
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL,
	@pBomVersion VARCHAR(20) = NULL,
	@pReleaseQty NUMERIC(20,4) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @BomVersion VARCHAR(20) = CASE WHEN ISNULL(@pBomVersion,'') = '' THEN '' ELSE @pBomVersion END
	DECLARE @ReleaseQty NUMERIC(20,4) = ISNULL(@pReleaseQty, 1)

			
	DECLARE @BomCTE TABLE (
			BomSeq INT IDENTITY(1,1),
			ParentBomSeq INT,
			Levels INT,
			KeyValue VARCHAR(500),
			ParentKeyValue VARCHAR(500),
			MaterialCode VARCHAR(50), 
			BomVersion VARCHAR(20),
			BomUnit VARCHAR(10),
			ChildMaterialCode VARCHAR(50),
			ChildBomVersion VARCHAR(20),
			ChildBomUnit VARCHAR(10),
			UnitQty NUMERIC(20,5),
			UnitTotalQty NUMERIC(20,5),
			TotalQty NUMERIC(20,5),
					
			BasicCostPrice NUMERIC(20,4) DEFAULT 0,
			TotalCostPrice NUMERIC(20,4) DEFAULT 0,
			AccCostPrice NUMERIC(20,4) DEFAULT 0,

			IsOptionItem BIT,
			IsUseOption BIT
		)
	
			
		;WITH BomCTE (Levels, KeyValue, ParentKeyValue, MaterialCode, BomVersion, BomUnit, ChildMaterialCode, ChildBomVersion, ChildBomUnit, UnitQty, UnitTotalQty, TotalQty, IsOptionItem, IsUseOption)
		AS
		(
			SELECT
					0 AS Levels, 
					CONVERT(VARCHAR(50),NEWID()) AS KeyValue,
					CONVERT(VARCHAR(50), NULL) AS ParentKeyValue,
					CONVERT(VARCHAR(50), NULL) AS MaterialCode, 
					CONVERT(VARCHAR(20), NULL) AS BomVersion, 
					CONVERT(VARCHAR(10), NULL) AS BomUnit,
					ChildMaterialCode, 
					ChildBomVersion,
					ChildBomUnit,
					CONVERT(NUMERIC(20,5), 1) AS UnitQty,
					CONVERT(NUMERIC(20,5), 1) AS UnitTotalQty,
					CONVERT(NUMERIC(20,5), @ReleaseQty) AS TotalQty,
					CONVERT(BIT, 0) AS IsOptionItem,
					CONVERT(BIT, 1) AS IsUseOption
			FROM
					(
						SELECT
								BH.*,
								BH.MaterialCode AS ChildMaterialCode,
								BH.BomVersion AS ChildBomVersion,
								BH.BomUnit AS ChildBomUnit
						FROM
								STB_BomHeader BH WITH(NOLOCK)
						WHERE
								MaterialCode = @ModelCode AND
								BomVersion = @BomVersion									
					) BH
			UNION ALL
			SELECT
					Levels+1 AS Levels, 
					CONVERT(VARCHAR(50),NEWID()) AS KeyValue,
					CTE.KeyValue AS ParentKeyValue,
					BD.MaterialCode, 
					BD.BomVersion, 
					BD.HeaderBomUnit AS BomUnit,
					BD.ChildMaterialCode, 
					BD.ChildBomVersion,
					BD.BomUnit AS ChildBomUnit,
					/*
					--CONVERT(NUMERIC(20,5), BD.UsedQty) AS UnitQty,
					--CONVERT(NUMERIC(20,5), BD.UsedQty * CTE.UnitTotalQty) AS UnitTotalQty,
					--CONVERT(NUMERIC(20,5), BD.UsedQty * CTE.TotalQty) AS TotalQty,
					*/
					
					CASE
						WHEN CTE.BomUnit <> BD.BomUnit THEN 
							CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, CTE.BomUnit, BD.UsedQty))
						ELSE CONVERT(NUMERIC(20,5), BD.UsedQty)
					END AS UnitQty,
					CASE
						WHEN CTE.BomUnit <> BD.BomUnit THEN 
							CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, CTE.BomUnit, BD.UsedQty * CTE.UnitTotalQty))
						ELSE CONVERT(NUMERIC(20,5), BD.UsedQty * CTE.UnitTotalQty)
					END AS UnitTotalQty,
					CASE
						WHEN CTE.BomUnit <> BD.BomUnit THEN 
							CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, CTE.BomUnit, BD.UsedQty * CTE.TotalQty))
						ELSE CONVERT(NUMERIC(20,5), BD.UsedQty * CTE.TotalQty)
					END AS TotalQty,
					

					BD.IsOptionItem,
					CONVERT(BIT, 1) AS IsUseOption
			FROM
					VW_BomDetailWithHeaderBomUnit BD
					--(
					--	SELECT
					--			BD.*,
					--			BH.BomUnit AS HeaderBomUnit
					--	FROM
					--			STB_BomDetail BD WITH(NOLOCK)
					--			LEFT OUTER JOIN STB_BomHeader BH WITH (NOLOCK)
					--				ON (BH.MaterialCode = BD.ChildMaterialCode AND BH.BomVersion = BD.ChildBomVersion)
					--) BD
					--STB_BomDetail BD WITH(NOLOCK)
					--LEFT OUTER JOIN STB_BomHeader BH WITH (NOLOCK)
					--	ON (BH.MaterialCode = BD.ChildMaterialCode AND BH.BomVersion = BD.ChildBomVersion)
					, BomCTE CTE
			WHERE
					(BD.MaterialCode = CTE.ChildMaterialCode) AND (BD.BomVersion = CTE.ChildBomVersion)
		)			
			
		INSERT INTO @BomCTE 
			(	Levels, 
				KeyValue, 
				ParentKeyValue, 
				MaterialCode, 
				BomVersion, 
				BomUnit,
				ChildMaterialCode, 
				ChildBomVersion, 
				ChildBomUnit,
				UnitQty, 
				UnitTotalQty, 
				TotalQty, 
				IsOptionItem, 
				IsUseOption
			)
		SELECT 
				Levels,
				KeyValue,
				ParentKeyValue,
				MaterialCode,
				BomVersion,
				BomUnit,
				ChildMaterialCode,
				ChildBomVersion,
				ChildBomUnit,
				UnitQty,
				UnitTotalQty,
				TotalQty,
				IsOptionItem,
				IsUseOption
		FROM 
				BomCTE
					
		UPDATE @BomCTE 
		SET
				ParentBomSeq = (SELECT BomSeq FROM (SELECT BomSeq, ParentKeyValue AS ParentKeyValue2, KeyValue AS KeyValue2 FROM @BomCTE) BCTE WHERE BCTE.KeyValue2 = ParentKeyValue),
				BasicCostPrice = ISNULL((SELECT BasicCostPrice FROM STB_MaterialMaster MM WITH (NOLOCK) WHERE MM.MaterialCode = ChildMaterialCode), 0),
				TotalCostPrice = ISNULL(UnitTotalQty,0) * ISNULL((SELECT BasicCostPrice FROM STB_MaterialMaster MM WITH (NOLOCK) WHERE MM.MaterialCode = ChildMaterialCode),0)


		SELECT  MM.MaterialCode
		FROM
				(
					SELECT 
							BCTE.Levels,
							BCTE.BomSeq, 
							BCTE.ParentBomSeq, 
							BCTE.MaterialCode, 
							BCTE.BomVersion, 
							BCTE.ChildMaterialCode, 
							BCTE.ChildBomVersion, 
							BD.RouteCode,
							--BD.BomUnit,
							BCTE.ChildBomUnit,
							BCTE.UnitQty,
							BCTE.UnitTotalQty,
							BCTE.TotalQty,
							BCTE.IsOptionItem,
							BCTE.IsUseOption,
							BCTE.BasicCostPrice,
							BCTE.TotalCostPrice,
							BCTE.AccCostPrice,
							GETDATE() AS CreateDateTime,
							@ProcessUserID AS CreateUserID
					FROM 
							@BomCTE	BCTE
							LEFT OUTER JOIN STB_BomDetail BD WITH (NOLOCK)
								ON (BD.MaterialCode = BCTE.MaterialCode AND BD.BomVersion = BCTE.BomVersion AND BD.ChildMaterialCode = BCTE.ChildMaterialCode AND BD.ChildBomVersion = BCTE.ChildBomVersion)
				) A
				LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
					ON (MM.MaterialCode = A.ChildMaterialCode)
				LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)
					ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
				LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)
					ON (PG.ProductGroupCode = MM.ProductGroupCode)

		
		


END