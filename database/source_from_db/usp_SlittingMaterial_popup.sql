-- =============================================
-- Author:		DinhManh
-- Create date: 2024-12-24
-- Description:	popup for search on F744
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlittingMaterial_popup] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		MM.MaterialCode,
		MM.MaterialName


	FROM STB_MaterialMaster MM

	WHERE	
			
			ProductGroupCode IN (
				'ANODE-FOIL',
				'CATHODE-FOIL',
				'CON-PAPER'
			)
	



END
