-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-14
-- Description:	Popup location for QC audit
-- =============================================
CREATE PROCEDURE usp_VN_ShowAllFinishGoodMES_forQCAudit_FGLocation_popup
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		N'Bắc Ninh' as FGLocation
	UNION ALL
	SELECT 
		N'Bắc Giang' as FGLocation
END
