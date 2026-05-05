-- Procedure: usp_DoRemoveFavoriteMenu




-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Browsable : false
-- Create date: 2016.07.04
-- Description:	Add Favorite Menu
-- =============================================

CREATE PROCEDURE [dbo].[usp_DoRemoveFavoriteMenu]
	@pProcessUserID VARCHAR(20),
	@pName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM STB_FavoriteMenu
	WHERE
			UserID = @pProcessUserID AND
			Name = @pName
END




GO

