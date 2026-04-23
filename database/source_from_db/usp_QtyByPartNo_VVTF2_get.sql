-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_QtyByPartNo_VVTF2_get
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pPartNo NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PartNo NVARCHAR(50) = CASE WHEN ISNULL(@pPartNo,'') = '' THEN '%' ELSE @pPartNo END

	select 
		SPQ.ID,
		SPQ.PartNo,
		SPQ.Qty,
		SPQ.IsUsed,
		SPQ.CreateDateTime,
		SPQ.CreateUserID,
		SPQ.ChangeDateTime,
		SPQ.ChangeUserID


		FROM STB_SavePackingQty_VVT_F2 SPQ WITH (NOLOCK)
		WHERE 1 = 1
		AND SPQ.PartNo LIKE @PartNo
END
