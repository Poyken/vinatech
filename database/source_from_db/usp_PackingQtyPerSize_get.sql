-- =============================================
-- Author:		DinhManh
-- Create date: 2025-01-10
-- Description:	Config PackQty per Size
-- =============================================
CREATE PROCEDURE [dbo].[usp_PackingQtyPerSize_get] 
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProdSize VARCHAR(10) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProdSize VARCHAR(10) = CASE WHEN ISNULL(@pProdSize,'') = '' THEN '%' ELSE @pProdSize END

    -- Insert statements for procedure here
	SELECT 
		PQPS.IDX,
		PQPS.ProdSize,
		PQPS.PackingQty,
		PQPS.CreateDateTime,
		PQPS.CreateUserID,
		PQPS.ChangeDateTime,
		PQPS.ChangeUserID,
		PQPS.IsUsed

	FROM
		STB_PackingQtyPerSize PQPS WITH(NOLOCK)

	WHERE 
		PQPS.ProdSize LIKE @ProdSize
		
END
