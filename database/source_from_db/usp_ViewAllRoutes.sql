-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-27
-- Description: Lấy ra tất cả các công đoạn
-- =============================================
CREATE PROCEDURE usp_ViewAllRoutes
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT RouteId,Code, RouteName FROM Routes;
END
