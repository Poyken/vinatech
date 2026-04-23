-- =============================================
-- Author:		Mr.duy
-- Create date: 2024-12-23
-- Description:	Lấy danh sách phân chia loại lỗi các màn hình B682, B782
-- =============================================
CREATE PROCEDURE usp_TypeErrorGroupOfFactory_grid
	@pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select TypeErrorCode,TypeErrorNameVI,TypeErrorNameEN from [STB_TypeErrorGroupOfFactory]
END
