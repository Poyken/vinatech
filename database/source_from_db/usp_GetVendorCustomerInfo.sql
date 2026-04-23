

-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 공통
-- Description:	거래처 정보(공급사인 거래처)를 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetVendorCustomerInfo]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pCustomerCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	
	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END
			
		
		
	SELECT
			CI.CustomerCode AS OldCustomerCode,
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
			CI.IsUsed,
			CI.CIExtText01,
			CI.CIExtText02,
			CI.CIExtText03,
			CI.CreateDateTime,
			CI.CreateUserID,
			CI.ChangeDateTime,
			CI.ChangeUserID
	FROM
			STB_CustomerInfo CI WITH(NOLOCK)
	WHERE
			((@CustomerCode = '*') OR (CI.CustomerCode = @CustomerCode)) AND
			((CI.IsVendor = 1))

END



--SELECT * FROM STB_CustomerInfo 
--WHERE 1=1
--AND CustomerCode in ('VNT', 'V0142', 'V0005')


--AND  CustomerName LIKE '비나텍%'
