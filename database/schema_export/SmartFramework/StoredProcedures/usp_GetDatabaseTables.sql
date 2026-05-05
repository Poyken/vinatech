-- Procedure: usp_GetDatabaseTables

-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get Database Tables
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDatabaseTables]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
			TABLE_NAME AS TableName
	FROM  
			INFORMATION_SCHEMA.TABLES
	WHERE 
			TABLE_TYPE = 'BASE TABLE'
	ORDER BY
			TABLE_NAME
END







GO

