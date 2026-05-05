-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-27
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[usp_Vietnam_FinishGood_BG_get_test]
	-- Add the parameters for the stored procedure here
	    @pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT 
		*
	FROM 
		STB_VN_FINISHGOODS_BG_Test_20251225

END
