

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-01-13
-- Browsable : true
-- Group : 팝업
-- Description:	거래처정보(공급사인 거래처) 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VendorCustomerInfo_popup]
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
			CI.IsVendor = 1 AND
			(CI.CustomerCode NOT LIKE 'V%' or CustomerCode = 'VVT_F2') -- update 2026-01-28
	ORDER BY 
			CI.CustomerCode

	
END
