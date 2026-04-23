-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-10-06
-- Description:	Huỷ tách số lượng
-- =============================================
CREATE PROCEDURE usp_DivideAndPrintPackagingLabelsInventory_Cancel 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pPackingID NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here

		DELETE FROM STB_DividePackaging
		WHERE ParentPackingID = @pPackingID;


END
