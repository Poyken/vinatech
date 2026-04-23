-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_MaterialTypeCodeHaNamGoods_popup
AS
BEGIN
	SET NOCOUNT ON;


	SELECT
			MT.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL
	FROM
			STB_MaterialType MT WITH(NOLOCK)
	WHERE
			MT.IsUsed = 0 
	
END
