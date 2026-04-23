CREATE PROC [dbo].[usp_ProcedureContentsSearch] @text NVARCHAR(100)
AS
BEGIN
	SELECT OBJECT_NAME(object_id) AS ProcedureName
		  ,OBJECT_DEFINITION(object_id) AS Contents
	  FROM sys.procedures 
	 WHERE OBJECT_DEFINITION(object_id) LIKE '%' + @text + '%'
END