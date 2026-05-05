-- Procedure: usp_DoAddFavoriteMenu






-- =============================================
-- Author:		Kim Han Young
-- Browsable : false
-- Create date: 2015-01-20
-- Description:	Add Favorite Menu
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddFavoriteMenu]
	@pProcessUserID VARCHAR(20),
	@pName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    MERGE STB_FavoriteMenu AS T
    USING ( SELECT @pProcessUserID AS UserID, @pName AS Name ) AS S
    ON (T.UserID = S.UserID AND T.Name = S.Name )
    WHEN MATCHED THEN
		UPDATE SET UserID = S.UserID,
				   Name = S.Name
	WHEN NOT MATCHED THEN
		INSERT (UserID,Name) VALUES (S.UserID, S.Name);
END







GO

