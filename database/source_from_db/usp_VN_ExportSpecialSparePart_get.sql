-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-11
-- Description:	Export Special Sparepart
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_ExportSpecialSparePart_get]
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
		'' AS WorkCenterCode,
		'' AS LineCode,
		'' AS LineName,
		'' AS MachineCode,
		'' AS MachineName
END
