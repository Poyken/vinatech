-- =============================================
-- Author:		Nguyễn Hải Triều(Dev)
-- Create date: 2026-01-22
-- Description:	Lấy ra CellLine theo mã nhà máy
-- =============================================
CREATE PROCEDURE usp_GetInfoCellLIneByWorkCenterCode 
	-- Add the parameters for the stored procedure here
	@pWorkCenterCode VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT LineCode,LineName from STB_LineInfo where WorkCenterCode=@pWorkCenterCode
END
