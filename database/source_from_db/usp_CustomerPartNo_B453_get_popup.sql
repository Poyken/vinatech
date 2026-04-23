-- =============================================
-- Author:		DinhManh
-- Create date: 2025-03-11
-- Description:	Popup CustomerPartNo select on B453
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerPartNo_B453_get_popup]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  '4E113227' as CustomerPartNo, 'WEC3R0156QG' as MPN union all
	SELECT  '4E113266' as CustomerPartNo, 'WEC3R0256QG' as MPN
		

END
