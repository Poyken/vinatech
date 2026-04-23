-- =============================================
-- Author:		DinhManh
-- Create date: 2025-01-10
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_PackingQtyPerSize_popup_A418]
	-- Add the parameters for the stored procedure here
	@pProdSize VARCHAR(10) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProdSize VARCHAR(10) = CASE WHEN ISNULL(@pProdSize,'') = '' THEN '%' ELSE @pProdSize END

    -- Insert statements for procedure here
	SELECT DISTINCT
		PQPS.ProdSize
		--PQPS.IDX,
		--PQPS.PackingQty,
		--PQPS.CreateDateTime,
		--PQPS.CreateUserID,
		--PQPS.ChangeDateTime,
		--PQPS.ChangeUserID,
		--PQPS.IsUsed

	FROM
		STB_PackingQtyPerSize PQPS WITH(NOLOCK)

	WHERE 
		PQPS.IsUsed = 1 AND
		PQPS.ProdSize LIKE @ProdSize

	ORDER BY
		PQPS.ProdSize
END
