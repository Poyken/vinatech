-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_MaterialMaster_popup_C561
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE	@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	
	SELECT
					MM.MaterialCode,
					MM.MaterialName,
					MM.MaterialNameL,
					MM.MaterialTypeCode,
					MT.MaterialTypeName,
					MM.ProductGroupCode,
					PG.ProductGroupName,
					MM.MaterialSpec,
					MM.MaterialUnit
			FROM
					STB_MaterialMaster MM WITH(NOLOCK)					
					INNER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode  = MT.MaterialTypeCode					
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)		ON MM.ProductGroupCode = PG.ProductGroupCode					
					LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)		ON MBI.ModelCode          = MM.MaterialCode
			WHERE 1=1
			  AND		MM.MaterialCode LIKE @MaterialCode 
				AND			ISNULL(MM.IsClosed, CONVERT(BIT, 0)) = 0



END
