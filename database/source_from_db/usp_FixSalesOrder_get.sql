-- =============================================
-- Author: kilee
-- Create date: 2019-01-10
-- Group : 영업관리 > 고정오더조회 > 고정오더조회 (Tab1)
-- Description:	FixSalesOrderItem (Tab1) 조회합니다.

		--사업장코드 : 기본값(사용자)
		--수주일자(From~To)
		--납품요청일자(From~To)
		--거래선코드
		--오더유형
-- =============================================


CREATE PROCEDURE [dbo].[usp_FixSalesOrder_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pFromOrderDate DATE = NULL,
	@pToOrderDate DATE = NULL,
	@pFromDeliveryDate DATE = NULL,
	@pToDeliveryDate DATE = NULL,
	@pCustomerCode VARCHAR(20) = NULL,
	@pOrderType VARCHAR(20) = NULL,
	@pIncludeCancel VARCHAR(1) = NULL,
	@pFromFixDate DATE = NULL,
	@pToFixDate DATE = NULL

WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
			
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END,
			@FromOrderDate DATE = CASE WHEN @pFromOrderDate IS NULL THEN (SELECT MIN(OrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE OrderDate IS NOT NULL) ELSE @pFromOrderDate END,
			@ToOrderDate DATE = CASE WHEN @pToOrderDate IS NULL THEN (SELECT MAX(OrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE OrderDate IS NOT NULL) ELSE @pToOrderDate END,
			@FromDeliveryDate DATE = CASE WHEN @pFromDeliveryDate IS NULL THEN (SELECT MIN(RequestDeliveryDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE RequestDeliveryDate IS NOT NULL) ELSE @pFromDeliveryDate END,
			@ToDeliveryDate DATE   = CASE WHEN @pToDeliveryDate   IS NULL THEN (SELECT MAX(RequestDeliveryDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE RequestDeliveryDate IS NOT NULL) ELSE @pToDeliveryDate END,			
			@CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END,
			@OrderType VARCHAR(20) = CASE WHEN ISNULL(@pOrderType,'') = '' THEN '*' ELSE @pOrderType END,			
			@IncludeCancel VARCHAR(1) = CASE WHEN ISNULL(@pIncludeCancel,'') = '' THEN 'Y' ELSE @pIncludeCancel END,
			@FromFixDate DATE = CASE WHEN @pFromFixDate IS NULL THEN (SELECT MIN(FixOrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE FixOrderDate IS NOT NULL) ELSE @pFromFixDate END,
			@ToFixDate   DATE = CASE WHEN @pToFixDate   IS NULL THEN (SELECT MAX(FixOrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE FixOrderDate IS NOT NULL) ELSE @pToFixDate   END
			
			


	SELECT
			SO.SalesOrderNo AS OldSalesOrderNo,
			SO.SalesOrderNo,
			SO.CompanyCode,
			COM.CompanyName,
			COM.CompanyNameL,
			COM.CompanyDesc,
			COM.CompanyDescL,
			SO.OrderType,
			SO.CustomerCode,
			CUS.CustomerName,
			CUS.CustomerNameL,
			CUS.IsCustomer,
			CUS.IsVendor,
			CUS.IsSourcing,
			CUS.BusinessCondition,
			CUS.BusinessType,
			CUS.BusinessNo,
			CUS.ZipCode,
			CUS.AddressText,
			CUS.CeoName,
			CUS.TelNo,
			CUS.FaxNo,
			CUS.ContactName1,
			CUS.ContactTel1,
			CUS.ContactName2,
			CUS.ContactTel2,
			CUS.ContactName3,
			CUS.ContactTel3,
			CUS.OrderToName,
			CUS.OrderToTel,
			CUS.OrderToEmail,
			CUS.CustomerDesc,
			CUS.CIExtText01,
			CUS.CIExtText02,
			CUS.CIExtText03,
			SO.OrderDate,
			SO.IsFixedOrder,
			SO.RequestDeliveryDate,
			SO.DeliveryDay,
			SO.DestInfomation,
			SO.IsCancel,
			SO.CancelText,
			SO.AmountPrice,
			SO.SOExtText01,
			SO.SOExtText02,
			SO.SOExtText03,
			SO.SOExtText04,
			SO.SOExtText05,
			SO.CreateDateTime,
			SO.CreateUserID,
			SO.ChangeDateTime,
			SO.ChangeUserID,
			SO.FixOrderDate
	FROM
			STB_SalesOrder SO WITH(NOLOCK)
			LEFT OUTER JOIN STB_CustomerInfo CUS WITH(NOLOCK)			ON SO.CustomerCode = CUS.CustomerCode
			LEFT OUTER JOIN STB_CompanyInfo  COM WITH(NOLOCK)			ON SO.CompanyCode  = COM.CompanyCode
	WHERE 1=1
		AND	((@CompanyCode = '*') OR (SO.CompanyCode = @CompanyCode)) 
		AND	((@CustomerCode = '*') OR (SO.CustomerCode = @CustomerCode)) 
		--AND	(SO.OrderDate IS NULL OR (SO.OrderDate BETWEEN @FromOrderDate AND @ToOrderDate) AND (SO.RequestDeliveryDate IS NULL OR (SO.RequestDeliveryDate BETWEEN @FromDeliveryDate AND @ToDeliveryDate))) 

		AND	SO.OrderDate BETWEEN  @FromOrderDate AND @ToOrderDate
		AND ((@OrderType = '*') OR (SO.OrderType = @OrderType)) 
		AND ((@IncludeCancel = 'Y') OR (SO.IsCancel = 0))		
		AND	SO.FIXOrderDate BETWEEN @FromFixDate AND @ToFixDate
		AND SO.IsFlxedCheck = '1'        -- 고정오더인것만

END
