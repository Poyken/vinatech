-- View: VW_CommandType



CREATE VIEW [dbo].[VW_CommandType]
AS
	SELECT 'Report' AS CommandType
	UNION ALL
	SELECT 'Doc' AS CommandType
	UNION ALL
	SELECT 'Zebra' AS CommandType
	UNION ALL
	SELECT 'IPL' AS CommandType

GO

