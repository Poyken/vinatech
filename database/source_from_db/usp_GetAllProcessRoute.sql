-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-10-15
-- Description:	Lấy ra tất cả các công đoạn
-- =============================================
CREATE PROCEDURE usp_GetAllProcessRoute 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ProcessCode,ProcessName from Process_BG where IsActive=1
END
