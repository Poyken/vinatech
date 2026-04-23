-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-05
-- Description:	Import Special Sparepart
-- =============================================
CREATE PROCEDURE usp_VN_ImportSpecialSparePart_get
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

		'' AS SparePartCode,
		'' AS SparePartName,
		1 AS IOQty,
		'' AS WorkCenterCode
END
