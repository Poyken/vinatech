-- View: VW_ProdSnRule



CREATE VIEW [dbo].[VW_ProdSnRule]
AS
	--SELECT
	--		'자사규칙' AS ProdSnType
	--UNION ALL
	--SELECT
	--		'SANTEC' AS ProdSnType
	--UNION ALL
	--SELECT
	--		'AMERICAN DYNAMICS' AS ProdSnType

	SELECT
			'Own Rules' AS ProdSnType
	UNION ALL
	SELECT
			'SANTEC' AS ProdSnType
	UNION ALL
	SELECT
			'AMERICAN DYNAMICS' AS ProdSnType
		



GO

