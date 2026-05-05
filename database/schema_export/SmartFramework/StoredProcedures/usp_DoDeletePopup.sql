-- Procedure: usp_DoDeletePopup






-- =============================================
-- Author:		Kim Han Young
-- Browsable: false
-- Create date: 2016-01-18
-- Description:	Delete Popup Grid
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeletePopup]
	@pName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	--RAISERROR('Can`t delete Global Popup',16,1)
	--RETURN

    DELETE FROM STB_PopupGrid
    WHERE Name = @pName
END







GO

