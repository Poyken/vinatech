-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_RawMaterialInputHistory_get_V1]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pLotNo NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @LotNo NVARCHAR(50) = @pLotNo

    SELECT
		Barcode as LotNo ,
		RawMaterialBarcode,
		ProductGroupCode,
		CreatedDate as CreateDateTime

	from STB_InputMaterialHistory WITH(NOLOCK)
	where Barcode = @pLotNo

	ORDER BY CreatedDate asc


END
