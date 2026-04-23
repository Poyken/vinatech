-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-25
-- Description:	Lấy ra mã hàng của lotID thay đổi nguyên liệu Hà Nam
-- =============================================
CREATE PROCEDURE usp_getMaterialCodeByLotID
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pLotID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select top 1 materialcode from STB_SetInfo where Barcode=@pLotID
END
