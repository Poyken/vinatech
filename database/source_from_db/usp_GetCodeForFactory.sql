-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-03-19
-- Description:	Dũ liệu code cho cả hai nhà máy
-- =============================================
CREATE PROCEDURE usp_GetCodeForFactory 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM STB_ItemCode
END
