-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-06-03
-- Description:	Lấy kiểu xuất
-- =============================================
CREATE PROCEDURE usp_TypeExport_TypeCode
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TypeCode,TypeName from STB_TypeExport_HN
END
