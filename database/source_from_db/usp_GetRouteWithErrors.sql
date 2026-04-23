-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-27
-- Description:	lấy ra tên lỗi theo từng công đoạn
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteWithErrors] 
	-- Add the parameters for the stored procedure here
	 @RouteId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT r.Code, r.RouteName,
           e.ErrorName
    FROM Routes r
    LEFT JOIN Errors e ON r.RouteId = e.RouteId
    WHERE r.RouteId = @RouteId
END
