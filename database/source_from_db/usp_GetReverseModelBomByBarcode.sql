-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2026-04-23
-- Browsable : true
-- Group : 공통관리
-- Description:	BOM 역전개
---- =============================================
CREATE PROCEDURE [dbo].[usp_GetReverseModelBomByBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pRawMaterialBarcode VARCHAR(50) = NULL
AS
BEGIN
	Declare @RawMaterialBarcode VARCHAR(50) = @pRawMaterialBarcode

	DECLARE @MaterialCode VARCHAR(50)
		   ,@BomVersion VARCHAR(20) = ''
		   ,@ProcessUserID VARCHAR(20)
		   ,@MaxBomVersion VARCHAR(20)

	SELECT @MaterialCode = MaterialCode 
	  FROM STB_MaterialDocLotInfo
	 WHERE LotID = @RawMaterialBarcode

   -- ParentMaterialCode
   SELECT @MaxBomVersion = MAX(BD.BomVersion)
     FROM STB_BOMDetail BD
	 LEFT OUTER JOIN STB_MaterialMaster MM
	   ON MM.MaterialCode = BD.MaterialCode
	 LEFT OUTER JOIN STB_BOMHeader BH
	   ON BH.BomVersion = BD.BomVersion
	  AND BH.MaterialCode = BD.MaterialCode
	WHERE BD.ChildMaterialCode = @MaterialCode
	  AND MM.MaterialTypeCode = 'FERT'
	  AND BH.BomHeaderDesc LIKE '%GW BOM Approval%'

 --  -- Bloom's BOM approval by G/W's Maxium version
 --  SELECT
	--		BH.BomVersion
	--FROM
	--		STB_BomHeader BH WITH(NOLOCK)
	--WHERE
	--		BH.MaterialCode = @MaterialCode AND
	--		BH.IsUsed = 1


	DECLARE @BomCTE TABLE (
			BomSeq INT IDENTITY(1,1),
			ParentBomSeq INT,
			Levels INT,
			KeyValue VARCHAR(500),
			ParentKeyValue VARCHAR(500),
			ChildMaterialCode VARCHAR(50), 
			ChildBomVersion VARCHAR(20),
			MaterialCode VARCHAR(50),
			BomVersion VARCHAR(20),
					
			UnitQty NUMERIC(20,5),
			UnitTotalQty NUMERIC(20,5),
			TotalQty NUMERIC(20,5),
					
			BasicCostPrice NUMERIC(20,4) DEFAULT 0,
			TotalCostPrice NUMERIC(20,4) DEFAULT 0,
			AccCostPrice NUMERIC(20,4) DEFAULT 0,

			IsOptionItem BIT,
			IsUseOption BIT
		)		


		;WITH BomCTE (Levels, KeyValue, ParentKeyValue, ChildMaterialCode, ChildBomVersion, MaterialCode, BomVersion, UnitQty, UnitTotalQty, TotalQty, IsOptionItem, IsUseOption)
		AS
		(
			SELECT
					0 AS Levels, 
					CONVERT(VARCHAR(50),NEWID()) AS KeyValue,
					CONVERT(VARCHAR(50), NULL) AS ParentKeyValue,
					CONVERT(VARCHAR(50), NULL) AS ChildMaterialCode, 
					CONVERT(VARCHAR(20), NULL) AS ChildBomVersion, 
					MaterialCode, 
					BomVersion,
						
					CONVERT(NUMERIC(20,5), 1) AS UnitQty,
					CONVERT(NUMERIC(20,5), 1) AS UnitTotalQty,
					CONVERT(NUMERIC(20,5), 1) AS TotalQty,
					CONVERT(BIT, 0) AS IsOptionItem,
					CONVERT(BIT, 1) AS IsUseOption
			FROM
					(
						SELECT
								MM.MaterialCode AS MaterialCode,
								@BomVersion AS BomVersion
						FROM
								STB_MaterialMaster MM WITH(NOLOCK)
						WHERE
								MaterialCode = @MaterialCode 								
					) BD
			UNION ALL
			SELECT
					Levels+1 AS Levels, 
					CONVERT(VARCHAR(50),NEWID()) AS KeyValue,
					CTE.KeyValue AS ParentKeyValue,
					BD.ChildMaterialCode, 
					BD.ChildBomVersion, 
					BD.MaterialCode, 
					BD.BomVersion,
						
					CONVERT(NUMERIC(20,5), BD.UsedQty) AS UnitQty,
					CONVERT(NUMERIC(20,5), BD.UsedQty * CTE.UnitTotalQty) AS UnitTotalQty,
					CONVERT(NUMERIC(20,5), BD.UsedQty * CTE.TotalQty) AS TotalQty,
					BD.IsOptionItem,
					CONVERT(BIT, 1) AS IsUseOption
			FROM
					STB_BomDetail BD WITH(NOLOCK)
					, BomCTE CTE
			WHERE
					(BD.ChildMaterialCode = CTE.MaterialCode) AND (BD.ChildBomVersion = CTE.BomVersion)
		)
		INSERT INTO @BomCTE (Levels, KeyValue, ParentKeyValue, MaterialCode, BomVersion, ChildMaterialCode, ChildBomVersion, UnitQty, UnitTotalQty, TotalQty, IsOptionItem, IsUseOption)
		SELECT 
				Levels,
				KeyValue,
				ParentKeyValue,
				MaterialCode,
				BomVersion,
				ChildMaterialCode,
				ChildBomVersion,
				UnitQty,
				UnitTotalQty,
				TotalQty,
				IsOptionItem,
				IsUseOption
		FROM 
				BomCTE
					
		UPDATE @BomCTE 
		SET
				ParentBomSeq = (SELECT BomSeq FROM (SELECT BomSeq, ParentKeyValue AS ParentKeyValue2, KeyValue AS KeyValue2 FROM @BomCTE) BCTE WHERE BCTE.KeyValue2 = ParentKeyValue)
				--BasicCostPrice = ISNULL((SELECT BasicCostPrice FROM STB_MaterialMaster MM WITH (NOLOCK) WHERE MM.MaterialCode = ChildMaterialCode), 0),
				--TotalCostPrice = ISNULL(UnitTotalQty,0) * ISNULL((SELECT BasicCostPrice FROM STB_MaterialMaster MM WITH (NOLOCK) WHERE MM.MaterialCode = ChildMaterialCode),0)


		SELECT 
				REPLACE(SPACE(A.Levels),' ', '.') + CONVERT(VARCHAR, ISNULL(A.Levels,0)+1) AS LevelString,
				BomSeq, 
				ParentBomSeq, 
				A.MaterialCode, 
				BomVersion, 
				ChildMaterialCode, 
				ChildBomVersion,
				MM.AltMaterialCode,
				MM.MaterialName,
				MM.MaterialSpec,
				MM.MaterialTypeCode,
				MT.MaterialTypeName,
				MT.BasicMaterialType,
				MM.ProductGroupCode, 
				PG.ProductGroupName,
				ISNULL(MM.IsDelegate,CONVERT(BIT, 0)) AS IsDelegate,
				MM.MaterialSource,
				MM.MaterialThickness,
				RouteCode,
				MM.MaterialUnit,
				UnitQty,
				UnitTotalQty,
				TotalQty,
				IsOptionItem,
				IsUseOption,
				IsDelegate,
				MM.IsUseBackFlush,
				MM.IsInternalProd,
				MM.IsProdPlan,
				MM.IsPurchase,
				MM.IsOrder,
				MaterialSource,
				MaterialThickness,
				A.BasicCostPrice,
				TotalCostPrice
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
					ON (MM.MaterialCode = A.MaterialCode)
				LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)
					ON (MT.MaterialTypeCode = MM.MaterialTypeCode)
				LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)
					ON (PG.ProductGroupCode = MM.ProductGroupCode)	
			   WHERE BomVersion IN (@BomVersion, @MaxBomVersion)

END
