-- Procedure: usp_DoRunQuery

-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-15
-- Browsable : false
-- Description:	Run Query
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRunQuery]
	
	@pQuery NVARCHAR(MAX),
	@pProcessUserID VARCHAR(20) = NULL,
	@pLanguage VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	EXEC(@pQuery)
END








GO

