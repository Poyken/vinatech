-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-06-26
-- Description: lấy ra danh sách khách hàng
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCustomer_Popup]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT CustomerCode,MaterialCode  from STB_MaterialCodeByCustomer
END
