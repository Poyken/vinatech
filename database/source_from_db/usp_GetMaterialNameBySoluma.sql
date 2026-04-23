-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-29
-- Description:	Lấy mã NVl thành phẩm của khách hàng solum
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialNameBySoluma]
	-- Add the parameters for the stored procedure here
	@pCustomerCode varchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SolumCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END
    -- Insert statements for procedure here
	  select 
		   ID,
		   CustomerCode	 ,
		   MaterialCode,
		   MaterialCodeCustomer	,
		   ShortMaterialCode,
		   CreateDateTime,
		   CreateUserID	,
		   ChangeDateTime,
		   ChangeUserID

		   from STB_MaterialCodeByCustomer

		   WHERE CustomerCode=@SolumCode
END
