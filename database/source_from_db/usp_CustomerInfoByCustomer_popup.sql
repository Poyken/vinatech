

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-03-09
-- Browsable : true
-- Group : 팝업
-- Description:	거래처정보(고객사) 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerInfoByCustomer_popup]
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			CI.CustomerCode,
			CI.CustomerName,
			CI.CustomerNameL,
			CI.IsCustomer,
			CI.IsVendor,
			CI.IsSourcing,
			CI.BusinessCondition,
			CI.BusinessType,
			CI.BusinessNo,
			CI.ZipCode,
			CI.AddressText,
			CI.CeoName,
			CI.TelNo,
			CI.FaxNo,
			CI.ContactName1,
			CI.ContactTel1,
			CI.ContactName2,
			CI.ContactTel2,
			CI.ContactName3,
			CI.ContactTel3,
			CI.OrderToName,
			CI.OrderToTel,
			CI.OrderToEmail,
			CI.CustomerDesc,
			CI.CIExtText01,
			CI.CIExtText02,
			CI.CIExtText03
	FROM
			STB_CustomerInfo CI WITH(NOLOCK)
	WHERE
			CI.IsUsed = 1
			AND CI.IsCustomer = 1
END

