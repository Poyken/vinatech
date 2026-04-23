-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-27
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_Vietnam_KindOfPackingQtyWarehouse_A419_popup
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT				N'THÙNG_NGOÀI' as KindOfPacking

	UNION ALL SELECT	N'Thùng_Trong'
	UNION ALL SELECT	N'TÚI_BÓNG'
END
