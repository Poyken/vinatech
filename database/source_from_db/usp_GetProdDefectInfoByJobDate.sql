
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-28
-- Browsable : true
-- Group : 품질관리
-- Description:	모델별 실적 및 불량율 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdDefectInfoByJobDate]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	DECLARE @Production TABLE
	(
		ProductGroupCode VARCHAR(20),
		ProductGroupName NVARCHAR(100),
		MaterialCode VARCHAR(50),
		MaterialName NVARCHAR(200),
		JobDate VARCHAR(10),
		OutputQty INT,
		DefectQty INT,
		DefectRate NUMERIC(10,2)
	)

	DECLARE @TypeInfo TABLE
	(
		IDX INT,
		TypeCode VARCHAR(20),
		TypeName VARCHAR(50)
	)

	INSERT INTO @TypeInfo
	SELECT
			1,
			'_DR',
			'Deft. Rate(%)'
	UNION ALL
	SELECT
			2,
			'_DQ',
			'Deft. Qty'
	UNION ALL
	SELECT
			3,
			'_PRD',
			'Prod. Qty'

	;WITH Production AS
	(
		SELECT
				MM.ProductGroupCode,
				PG.ProductGroupName,
				PRS.MaterialCode,
				MM.MaterialName,
				PRS.JobDate,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				CASE
					WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0
					ELSE SUM(PRS.DefectQty) / SUM(PRS.OutputQty) * 100.0
				END AS DefectRate
		FROM
				STB_ProdRouteSummary PRS WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON MM.MaterialCode = PRS.MaterialCode
				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					ON PG.ProductGroupCode = MM.ProductGroupCode
		WHERE
				PRS.LineCode LIKE @LineCode AND
				MM.ProductGroupCode LIKE @ProductGroupCode AND
				PRS.MaterialCode LIKE @MaterialCode AND
				(PRS.JobDate BETWEEN @FromDate AND @ToDate)
		GROUP BY
				MM.ProductGroupCode,
				PG.ProductGroupName,
				PRS.MaterialCode,
				MM.MaterialName,
				PRS.JobDate
	)	
		INSERT INTO @Production
		SELECT
				'',
				'',
				'_Total',
				'Total',
				'Total',
				SUM(OutputQty),
				SUM(DefectQty),
				CASE
					WHEN SUM(OutputQty) > 0 THEN SUM(DefectQty) / SUM(OutputQty) * 100.0
					ELSE 0
				END
		FROM
				Production
		WHERE
				(SELECT COUNT(*) FROM Production) > 0
		UNION ALL
		SELECT
				ProductGroupCode,
				ProductGroupName,
				MaterialCode,
				MaterialName,
				CONVERT(VARCHAR(10),JobDate,120),
				SUM(OutputQty),
				SUM(DefectQty),
				CASE
					WHEN SUM(OutputQty) > 0 THEN SUM(DefectQty) / SUM(OutputQty) * 100.0
					ELSE 0
				END
		FROM
				Production
		GROUP BY
				ProductGroupCode,
				ProductGroupName,
				MaterialCode,
				MaterialName,
				JobDate
		
	SELECT 
			PROD.ProductGroupCode,
			PROD.ProductGroupName,
			PROD.MaterialCode,
			PROD.MaterialName,
			TI.TypeCode,
			TI.TypeName,
			'' AS JobDate,
			'' AS Template
	FROM
			@Production PROD
			CROSS JOIN @TypeInfo TI
	WHERE
			(SELECT COUNT(*) FROM @Production) > 1
	GROUP BY
			PROD.ProductGroupCode,
			PROD.ProductGroupName,
			PROD.MaterialCode,
			PROD.MaterialName,
			TI.TypeCode,
			TI.TypeName,
			TI.IDX
	ORDER BY
			PROD.MaterialCode,
			TI.IDX

	SELECT
			DISTINCT
			'JobDate' AS BandName,
			JobDate,
			'double' AS DataType,
			'Template' AS Template
	FROM
			@Production
	WHERE
			(SELECT COUNT(*) FROM @Production) > 1

	SELECT
			PROD.ProductGroupCode,
			PROD.ProductGroupName,
			PROD.MaterialCode,
			PROD.MaterialName,
			'JobDate' AS BandName,
			PROD.JobDate,
			--PROD.ModelCode + '_' + TI.TypeCode AS TypeCode,
			TI.TypeCode,
			TI.TypeName,
			CASE
				WHEN TI.TypeCode = '_DR' THEN DefectRate
				WHEN TI.TypeCode = '_DQ' THEN DefectQty
				WHEN TI.TypeCode = '_PRD' THEN OutputQty
			END AS OutputQty
	FROM
			@Production PROD 
			CROSS JOIN @TypeInfo TI
	WHERE
			(SELECT COUNT(*) FROM @Production) > 1
	UNION ALL
	SELECT
			'',
			'',
			'_Total',
			'Total',
			'JobDate' AS BandName,
			PROD.JobDate,
			TI.TypeCode,
			TI.TypeName,
			CONVERT(NUMERIC(10,2),CASE
				WHEN TI.TypeCode = '_DR' THEN CASE 
												WHEN SUM(PROD.OutputQty) > 0 THEN SUM(PROD.DefectQty) * 100.0 / SUM(PROD.OutputQty)
												ELSE 0.0
											END				
				WHEN TI.TypeCode = '_DQ' THEN SUM(DefectQty)
				WHEN TI.TypeCode = '_PRD' THEN SUM(OutputQty)
			END) AS OutputQty
	FROM
			@Production PROD
			CROSS JOIN @TypeInfo TI
	WHERE
			(SELECT COUNT(*) FROM @Production) > 1
	GROUP BY
			PROD.JobDate,
			TI.TypeCode,
			TI.TypeName
	UNION ALL
	SELECT
			PROD.ProductGroupCode,
			PROD.ProductGroupName,
			PROD.MaterialCode,
			PROD.MaterialName,
			'JobDate' AS BandName,
			'Total',
			TI.TypeCode,
			TI.TypeName,
			CONVERT(NUMERIC(10,2),CASE
				WHEN TI.TypeCode = '_DR' THEN CASE 
												WHEN SUM(PROD.OutputQty) > 0 THEN SUM(PROD.DefectQty) * 100.0 / SUM(PROD.OutputQty)
												ELSE 0.0
											END				
				WHEN TI.TypeCode = '_DQ' THEN SUM(DefectQty)
				WHEN TI.TypeCode = '_PRD' THEN SUM(OutputQty)
			END) AS OutputQty
	FROM
			@Production PROD
			CROSS JOIN @TypeInfo TI
	GROUP BY
			PROD.ProductGroupCode,
			PROD.ProductGroupName,
			PROD.MaterialCode,
			PROD.MaterialName,
			TI.TypeCode,
			TI.TypeName
	ORDER BY
			TI.TypeName

	--SELECT
	--		'Total' AS ModelCode,
	--		PROD.JobDate,
	--		CASE
	--			WHEN SUM(PROD.OutputQty) > 0 THEN SUM(PROD.DefectQty) * 100.0 / SUM(PROD.OutputQty)
	--			ELSE 0.0
	--		END AS DefectRate
	--FROM
	--		@Production PROD
	--WHERE
	--		PROD.MaterialCode <> '_Total'
	--GROUP BY
	--		PROD.JobDate
END


