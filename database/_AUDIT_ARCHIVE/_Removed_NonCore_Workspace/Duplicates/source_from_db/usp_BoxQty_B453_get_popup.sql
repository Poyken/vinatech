-- =============================================
-- Author:		DinhManh
-- Create date: 2025-03-11
-- Description:	popup for B453
-- =============================================
CREATE PROCEDURE usp_BoxQty_B453_get_popup 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT '1400 PCS' as BoxQty union all
	SELECT '2400 PCS' as BoxQty
END
