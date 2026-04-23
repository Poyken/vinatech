-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-10-20
-- Description:	Popup Part number for Jabil Mexico
-- =============================================
CREATE PROCEDURE [dbo].[usp_JabilMexicoLotQty_popup_get]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT '1400' AS Quantity UNION ALL
	SELECT '700' AS Quantity UNION ALL
	SELECT '100' AS Quantity 
	 
END
