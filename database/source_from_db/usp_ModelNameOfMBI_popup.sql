-- =============================================
-- Author:		<DinhManh>
-- Create date: <2025-01-14>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_ModelNameOfMBI_popup
	-- Add the parameters for the stored procedure here
	@pModelName VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ModelName VARCHAR(10) = CASE WHEN ISNULL(@pModelName,'') = '' THEN '%' ELSE @pModelName END

    -- Insert statements for procedure here
	SELECT DISTINCT	
		ModelName


	FROM
		STB_ModelBasicInfo MBI WITH(NOLOCK)

	WHERE
		ModelName LIKE @ModelName
END
