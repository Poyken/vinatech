-- Procedure: usp_DoSaveScreenSnapshot






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Save Screen Snapshot
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveScreenSnapshot]
	@pProcessLanguage VARCHAR(20),
	@pName VARCHAR(50),
	@pVersion INT,
	@pSnapshot VARBINARY(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	
	UPDATE STB_ScreenLayoutInfo
	SET
			Snapshot = @pSnapshot
	WHERE
			Name = @pName AND
			Version = @pVersion
			
END







GO

