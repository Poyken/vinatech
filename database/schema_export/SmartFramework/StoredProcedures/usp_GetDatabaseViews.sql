-- Procedure: usp_GetDatabaseViews

-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-05-02
-- Browsable : false
-- Description:	Get Database Views
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDatabaseViews]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
			V.TABLE_NAME AS ViewName,
			OBJECT_DEFINITION(OBJECT_ID(V.TABLE_NAME)) AS VIEW_DEFINITION
	FROM  
			INFORMATION_SCHEMA.VIEWS V
	ORDER BY
			TABLE_NAME
END







GO

