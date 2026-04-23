-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-26
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_ViewDetai_B752_get
	-- Add the parameters for the stored procedure here
			@pGROUPID NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
			  GROUPID,
			  PACKINGID,
			  LOTNO,
			  MATERIALCODE,
			  MATERIALNAME,
			  PACKQTY,
			  PARTNO,
			  PUBLICCODE,
			  TYPEPRODUCTION,
			  PRODUCTIONSIZE,
			  CREATEUSERID,
			  CREATEDATEIN,
			  CREATEDATEOUT,
			  STATUSPRINTER,
			  STATUSOUT,
			  CREATEDATEGROUPID,
			  CUSTOMERS
		FROM STB_VN_FINISHGOOD_OUT_TEMPORARY WITH(NOLOCK)
		WHERE GROUPID = @pGROUPID
END
