-- =============================================
-- Author:		Mr.Duy 
-- Create date: 2025-02-20
-- Description:	Lấy các mã thành phẩm trong BOM tương ứng với mã nguyên liệu được chọn
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetListProductBomByChildMaterialCode_Popup]
	@pChildMaterialCode VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		select BD.MaterialCode,MM.MaterialName from STB_BomDetail BD
		left outer join STb_materialmaster MM on BD.MaterialCode = MM.Materialcode
		 where ChildMaterialCode=@pChildMaterialCode 
		 and BD.BomVersion='99'

END
