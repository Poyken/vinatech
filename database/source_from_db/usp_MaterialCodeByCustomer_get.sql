-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-05-06
-- Description:	Lâyts dữ liệu in tem của nhà cung cấp
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialCodeByCustomer_get]
		@pProcessUserID VARCHAR(20),
	    @pProcessLanguage VARCHAR(20),
		@pCustomerCode varchar(20) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END

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

		   WHERE CustomerCode LIKE @CustomerCode

		   End


