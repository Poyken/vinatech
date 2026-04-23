

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-01-13
-- Browsable : true
-- Group : 팝업
-- Description:	거래처정보(공급사인 거래처) 팝업
-- Modified:
-- =============================================
create PROCEDURE [dbo].[usp_VVT_VendorCustomerInfo_popup]
	@pMaterialCode VARCHAR(50) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	SELECT
			CI.CustomerCode,
			CI.CustomerName
	FROM
			STB_CustomerInfo CI WITH(NOLOCK)
	WHERE
			CI.IsUsed = 1 AND
			CI.IsVendor = 1 
			
	ORDER BY 
			CI.CustomerCode
END
