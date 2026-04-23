-- =============================================
-- Author:		DinhManh
-- Create date: 2025-03-11
-- Description:	popup for B453
-- =============================================
CREATE PROCEDURE usp_PacketQty_B453_get_popup 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT '700 PCS / 7 Packets' as PacketQty union all
	SELECT '1200 PCS / 6 Packets' as PacketQty
END
