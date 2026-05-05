-- Procedure: usp_DoDeleteScreen






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Delete Screen
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteScreen]
	@pName VARCHAR(50),
	@pProcessUserID VARCHAR(20),
	@pDeleteFromDatabase BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @pDeleteFromDatabase = 1 BEGIN
		DELETE FROM STB_ScreenInfo
		WHERE
				Name = @pName
				
		DELETE FROM STB_ScreenInfo
		WHERE
				Name IN (SELECT Name FROM DBO.fnGetChildScreens(@pName))
	END ELSE BEGIN
		UPDATE STB_ScreenInfo
		SET
				IsDelete = 1,
				DeleteDateTime = GETDATE(),
				DeleteUserID = @pProcessUserID
		WHERE
				Name = @pName
				
		UPDATE STB_ScreenInfo
		SET
				IsDelete = 1,
				DeleteDateTime = GETDATE(),
				DeleteUserID = @pProcessUserID
		WHERE
				Name IN (SELECT Name FROM DBO.fnGetChildScreens(@pName))
	END
END







GO

