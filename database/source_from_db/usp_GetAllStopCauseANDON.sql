-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 20258-10-15
-- Description:	Lấy ra dánh sách các nguyên nhân dừng lỗi
-- =============================================
CREATE PROCEDURE usp_GetAllStopCauseANDON
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT StopCauseName FROM  StopCause WHERE IsActive=1
END
