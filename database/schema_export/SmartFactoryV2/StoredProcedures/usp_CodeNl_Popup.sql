-- Procedure: usp_CodeNl_Popup
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_CodeNl_Popup
@pLoaiHang NVARCHAR(50) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT WS.CODENVL,WS.NAMESNVL FROM
   STB_VN_B598 WS WHERE LOAIHANG=@pLoaiHang
END

GO

