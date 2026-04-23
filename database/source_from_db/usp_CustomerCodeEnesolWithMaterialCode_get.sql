-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-05-07
-- Description:	get customer with materialcode for Ha nam
-- =============================================
CREATE PROCEDURE usp_CustomerCodeEnesolWithMaterialCode_get
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pCustomerCode varchar(20) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END

	SELECT 
							ID,
							CustomerCode,
							MaterialCodeCustomer,
							MaterialCode,	
							ShortMaterialCode

	FROM 
		 STB_MaterialCodeByCustomer

	WHERE 
		CustomerCode LIKE @CustomerCode
END
