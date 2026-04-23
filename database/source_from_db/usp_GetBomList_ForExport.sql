-- =============================================
-- Author:		Park Jong Seob
-- Create date: 2016-12-08
-- Browsable : true
-- Group : 공통관리
-- Description:	BOM Export
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBomList_ForExport]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL,
	@pBomVersion VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @BomVersion VARCHAR(20) = CASE WHEN ISNULL(@pBomVersion,'') = '' THEN '' ELSE @pBomVersion END

			
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
			RouteCode VARCHAR(20),					
			UnitQty NUMERIC(20,5),
			BasicCostPrice NUMERIC(20,4) DEFAULT 0,
			TotalCostPrice NUMERIC(20,4) DEFAULT 0,
			AccCostPrice NUMERIC(20,4) DEFAULT 0,

			IsOptionItem BIT,
			IsUseOption BIT
		)
	
			
		;WITH BomCTE (Levels, KeyValue, ParentKeyValue, MaterialCode, BomVersion, BomUnit, ChildMaterialCode, ChildBomVersion, ChildBomUnit, RouteCode, UnitQty, IsOptionItem, IsUseOption)
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
					CONVERT(VARCHAR(20), NULL) AS RouteCode,
					CONVERT(NUMERIC(20,5), 1) AS UnitQty,
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
					CTE.ChildMaterialCode AS MaterialCode, 
					CTE.ChildBomVersion AS BomVersion, 
					BD.HeaderBomUnit AS BomUnit,
					BD.ChildMaterialCode, 
					BD.ChildBomVersion,
					BD.BomUnit AS ChildBomUnit,
					BD.RouteCode AS RouteCode,
					CONVERT(NUMERIC(20,5), BD.UsedQty) AS UnitQty,
					BD.IsOptionItem,
					CONVERT(BIT, 1) AS IsUseOption
			FROM
					--STB_BomDetail BD WITH(NOLOCK)
					VW_BomDetailWithHeaderBomUnit BD WITH(NOLOCK)
					, BomCTE CTE
			WHERE
					(BD.MaterialCode = CTE.ChildMaterialCode) AND (BD.BomVersion = CTE.ChildBomVersion)
		)			

		
			
		INSERT INTO @BomCTE (Levels, KeyValue, ParentKeyValue, MaterialCode, BomVersion, BomUnit, ChildMaterialCode, ChildBomVersion, ChildBomUnit, RouteCode, UnitQty, IsOptionItem, IsUseOption)
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
				RouteCode,
				UnitQty,
				IsOptionItem,
				IsUseOption
		FROM 
				BomCTE
					
		UPDATE @BomCTE 
		SET
				ParentBomSeq = (SELECT BomSeq FROM (SELECT BomSeq, ParentKeyValue AS ParentKeyValue2, KeyValue AS KeyValue2 FROM @BomCTE) BCTE WHERE BCTE.KeyValue2 = ParentKeyValue)


		SELECT 
				--REPLACE(SPACE(A.Levels),' ', '.') + CONVERT(VARCHAR, ISNULL(A.Levels,0)+1) AS LevelString,
				--BomSeq, 
				--ParentBomSeq, 
				DISTINCT
				A.Levels,
				A.MaterialCode, 
				A.BomVersion, 
				BH.BomUnit AS BomUnit,
				A.ChildMaterialCode, 
				A.ChildBomVersion,
				A.ChildBomUnit,
				A.RouteCode,
				MM.AltMaterialCode,
				MM.MaterialName,
				MM.MaterialSpec,
				MM.MaterialUnit,
				UnitQty
		FROM
				(
					SELECT 
							BCTE.Levels,
							BCTE.BomSeq, 
							BCTE.ParentBomSeq, 
							BCTE.MaterialCode, 
							BCTE.BomVersion, 
							BCTE.BomUnit,
							BCTE.ChildMaterialCode, 
							BCTE.ChildBomVersion, 
							BCTE.ChildBomUnit,
							BD.RouteCode,
							BCTE.UnitQty,
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
				LEFT OUTER JOIN STB_BomHeader BH WITH (NOLOCK)
					ON (BH.MaterialCode = A.MaterialCode AND BH.BomVersion = A.BomVersion)
		WHERE
				A.Levels > 0
		ORDER BY
				A.Levels,
				A.MaterialCode,
				A.ChildMaterialCode

		
		


END
