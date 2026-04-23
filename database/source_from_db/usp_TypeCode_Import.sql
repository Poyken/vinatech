-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-06-25
-- Description:	Láy ra kiểu nhập hàng
-- =============================================
CREATE PROCEDURE usp_TypeCode_Import
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TypeCode,TypeName from STB_TypeImport_HN
END
