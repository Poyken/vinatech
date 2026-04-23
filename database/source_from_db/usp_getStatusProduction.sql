-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-21
-- Description:	Lấy ra các trạng thái
-- =============================================
CREATE PROCEDURE [dbo].[usp_getStatusProduction] 
	-- Add the parameters for the stored procedure here
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select * from StatusProduction
END


