-- Procedure: usp_GetPopupGrids






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-18
-- Browsable : false
-- Description:	Get PopupGrid List
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetPopupGrids]
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			PG.*
	FROM
			STB_PopupGrid PG WITH(NOLOCK)
END







GO

