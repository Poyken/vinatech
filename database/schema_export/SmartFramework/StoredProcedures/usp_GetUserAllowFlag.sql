-- Procedure: usp_GetUserAllowFlag






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2015-01-19
-- Description:	Get User Allow Flag
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetUserAllowFlag]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	'Allow' AS Flag
	UNION
	SELECT  'Deny' AS Flag
	UNION
	SELECT	'Request' AS Flag
END







GO

