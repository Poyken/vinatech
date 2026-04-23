CREATE PROCEDURE [dbo].[usp_material_popup]
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	
	SELECT
			CI.MaterialCode,
			CI.MaterialName,
			CI.ProductGroupCode,
			CI.MaterialUnit
	FROM
			STB_MaterialMaster CI WITH(NOLOCK)
	WHERE
			IsClosed = 0
    ORDER BY 
			CI.MaterialCode

END