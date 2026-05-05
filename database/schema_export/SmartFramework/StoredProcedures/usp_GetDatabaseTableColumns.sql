-- Procedure: usp_GetDatabaseTableColumns

-- =============================================
-- Author:		Kim Han Young
-- Browsable: false
-- Create date: 2014-02-19
-- Description:	Getting columns of table
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDatabaseTableColumns]
	@pTableName VARCHAR(100)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 	COL.Name AS ColumnName,	
			COL.RawDataType,	
			CASE
				WHEN COL.DataType IN ('DATETIME','DATE','INT','BIGINT','BIT') THEN COL.DataType
				ELSE
					CASE
						WHEN COL.Precision <> '0' THEN COL.DataType + '(' + COL.[Precision] + ','+ COL.Scale + ')'
						ELSE COL.DataType + '(' + COL.LENGTH + ')'
					END
			END AS DataType,			
			CONVERT(BIT,1) AS [Param],
			CONVERT(BIT,1) AS [Ins],
			CONVERT(BIT,1) AS [Upt],
			CONVERT(BIT,IsPrimaryKey) AS [Del],
			CONVERT(BIT,COL.[IsNull]) AS [IsNul],
			CONVERT(BIT,IsPrimaryKey) AS [Key]
	FROM	
			(
			SELECT
					COL.column_id AS COL_ID,
					COL.name AS Name,
					COL.column_id AS ID,
					UPPER(TYP.[name]) AS RawDataType,
					CASE TYP.[name]
						WHEN 'CHAR' THEN 'VARCHAR'
						ELSE UPPER(TYP.[name])
					END AS DataType,
					CASE COL.max_length
						WHEN -1 THEN 'MAX'
						ELSE 
								CASE COL.system_type_id
									WHEN 231 THEN CONVERT(VARCHAR,COL.max_length / 2)
									ELSE CONVERT(VARCHAR,COL.max_length)
								END
					END AS LENGTH,
					CONVERT(VARCHAR,COL.precision)  AS [Precision],
					CONVERT(VARCHAR,COL.scale) AS Scale,
					CASE 
        				WHEN ISNULL(ICOL.index_column_id,0) > 0 THEN 1
						ELSE 0
					END IsPrimaryKey,
					CASE COL.is_nullable
						WHEN 0 THEN 0
						ELSE 1
					END AS [IsNull]
			FROM
					sysobjects TBL
					INNER JOIN sys.columns COL
						ON	COL.object_id = TBL.id
					INNER JOIN sys.types TYP
						ON 	COL.user_type_id = TYP.user_type_id
					LEFT OUTER JOIN sys.default_constraints DEF
						ON	COL.object_id = DEF.parent_object_id AND
    						COL.column_id = DEF.parent_column_id
					LEFT OUTER JOIN sys.indexes PK
						ON	PK.object_id = TBL.id AND            	
    						PK.is_primary_key = 1
					LEFT OUTER JOIN sys.index_columns ICOL
						ON	PK.object_id = ICOL.object_id AND
    						PK.index_id = ICOL.index_id AND
							ICOL.column_id = COL.column_id
			WHERE	TBL.Name = @pTableName
			) COL
	ORDER BY
			COL.COL_ID
END







GO

