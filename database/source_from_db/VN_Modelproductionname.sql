create PROC [dbo].[VN_Modelproductionname]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
--@pMaterialCode VARCHAR(50) = NULL,
--@pMaterialName NVARCHAR(100) = NULL
AS
BEGIN

SET NOCOUNT ON;
		
		--DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode,
		--		@MaterialName NVARCHAR(100) = CASE WHEN ISNULL(@pMaterialName,'') = '' THEN '%' ELSE @pMaterialName END
		--SELECT 
		--		DISTINCT  MM.MaterialCode,
		--				  MM.MaterialName 
	 --   FROM 
		--				  STB_MaterialMaster MM WITH(NOLOCK)

	 --   WHERE
		--			      MM.MaterialCode = @pMaterialCode AND
		--				  (
		--						MM.MaterialName IS NULL OR
		--						MM.MaterialName = '' OR
		--						MM.MaterialName LIKE @MaterialName
		--				  ) 
						 

		SELECT
				 DISTINCT  MM.MaterialCode,
						   MM.MaterialName 
		FROM

				STB_MaterialMaster MM WITH(NOLOCK)



END
