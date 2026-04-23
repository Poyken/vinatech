
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 공통
-- Description:	거래처정보 조회
-- Modified:
-- =============================================
-- EXEC usp_CustomerInfo_get '','','하남',''

CREATE PROCEDURE [dbo].[usp_CustomerInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCustomerName NVARCHAR(50) = NULL,
						@pIsOnlyVendor BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CustomerName NVARCHAR(50) = CASE WHEN ISNULL(@pCustomerName,'') = '' THEN '%' ELSE @pCustomerName END
	DECLARE @IsOnlyVendor BIT = ISNULL(@pIsOnlyVendor,0)
    
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
			CI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MW.MaterialWarehouseNameL,
			CI.CIExtText01,
			CI.CIExtText02,
			CI.CIExtText03,
			CI.CreateDateTime,
			CI.CreateUserID,
			CI.ChangeDateTime,
			CI.ChangeUserID
	FROM
			STB_CustomerInfo CI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)				ON	MW.MaterialWarehouseCode = CI.MaterialWarehouseCode 
	WHERE 1=1
	 --AND 	(CI.CustomerName LIKE '%' @CustomerName '%') 
	 AND 	(CI.CustomerName LIKE '%' + @CustomerName + '%')                           -- kilee추가 (2019-11-21)
    ORDER BY CI.CustomerCode

END
