-- Procedure: usp_GetScreenLayoutVersionList






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Group: System
-- Create date: 2016-02-11
-- Description:	Get Screen Layout Version List
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetScreenLayoutVersionList]
	@pName VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Name VARCHAR(50) = @pName

    SELECT
			SLI.Name,
			SLI.Version,
			SLI.Description,
			SLI.CreateDateTime,
			SLI.CreateUserID,
			SLI.ChangeDateTime,
			SLI.ChangeUserID
    FROM
			STB_ScreenLayoutInfo SLI WITH(NOLOCK)
	WHERE
			SLI.Name = @Name
	ORDER BY
			SLI.Version DESC
END







GO

