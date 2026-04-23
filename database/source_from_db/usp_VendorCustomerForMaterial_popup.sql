

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-01-13
-- Browsable : true
-- Group : 팝업
-- Description:	거래처정보(공급사인 거래처) 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VendorCustomerForMaterial_popup]
	@pMaterialCode VARCHAR(50) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode

	SELECT
			MVM.CustomerCode,
			CI.CustomerName
	FROM
			STB_MaterialVendorMapping MVM WITH(NOLOCK)
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON CI.CustomerCode = MVM.CustomerCode
	WHERE
			MVM.MaterialCode = @MaterialCode
END
