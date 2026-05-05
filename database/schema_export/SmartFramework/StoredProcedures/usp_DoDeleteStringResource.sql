-- Procedure: usp_DoDeleteStringResource






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Delete String Resource
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteStringResource]
	@pLanguage VARCHAR(20),
	@pType VARCHAR(20),
	@pName NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE STB_StringResources
	WHERE
			Language = @pLanguage AND
			Type = @pType AND
			Name = @pName
END







GO

