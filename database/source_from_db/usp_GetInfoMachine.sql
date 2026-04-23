-- =============================================
-- Author:		Nguyễn Hải Triều (Dev)
-- Create date: 2026-01-22
-- Description:	Lấy ra thông tin máy cần lấy dữ liệu
-- =============================================
CREATE PROCEDURE usp_GetInfoMachine 
	-- Add the parameters for the stored procedure here
	@pWorkCenterCode VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select MachineCode,MachineName from STB_MachineMaster where WorkCenterCode=@pWorkCenterCode
END
