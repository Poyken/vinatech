-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-25
-- Description:	Lấy danh sách nguyên vật liệu đang được sử dụng với lot nhập vào.
-- =============================================
CREATE PROCEDURE usp_getListMaterialInBomForLotID_popup
	@pLotID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select BD.ChildMaterialCode,BD.BomUnit,MM.MaterialName from stb_Bomdetail BD
	left join STB_MaterialMaster MM on BD.ChildMaterialCode = MM.MaterialCode
	 where BD.MaterialCode=(select MaterialCode from stb_setinfo where barcode=@pLotID) and BD.BomVersion='99' 
	
END
