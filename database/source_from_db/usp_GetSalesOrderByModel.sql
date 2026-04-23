
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified: 160128 제품별로 조회하도록 수정
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSalesOrderByModel]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pFromOrderDate DATE = NULL,
	@pToOrderDate DATE = NULL,
	@pFromDeliveryDate DATE = NULL,
	@pToDeliveryDate DATE = NULL,
	@pCustomerCode VARCHAR(20) = NULL,
    @pModelCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
			@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END,
			
			@FromOrderDate DATE = CASE WHEN @pFromOrderDate IS NULL THEN (SELECT MIN(OrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE OrderDate IS NOT NULL) ELSE @pFromOrderDate END,
			@ToOrderDate DATE = CASE WHEN @pToOrderDate IS NULL THEN (SELECT MAX(OrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE OrderDate IS NOT NULL) ELSE @pToOrderDate END,
			@FromDeliveryDate DATE = CASE WHEN @pFromDeliveryDate IS NULL THEN (SELECT MIN(RequestDeliveryDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE RequestDeliveryDate IS NOT NULL) ELSE @pFromDeliveryDate END,
			@ToDeliveryDate DATE = CASE WHEN @pToDeliveryDate IS NULL THEN (SELECT MAX(RequestDeliveryDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE RequestDeliveryDate IS NOT NULL) ELSE @pToDeliveryDate END,
			
			@CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END,
			@ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pModelCode,'') = '' THEN '*' ELSE @pModelCode END


	SELECT
			SOI.SalesOrderNo,
			SOI.ModelCode,
			MBI.MaterialCode AS ModelName,
			--MBI.ModelNameL,
			MBI.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MBI.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL,
			--MBI.ModelPrintName,
			--MBI.BasicModel,
			--MBI.DEFlag,
			--MBI.EanCode,
			--MBI.UpcCode,
			--MBI.ModelColor,
			--MBI.MBIWeight,
			--MBI.MBISizeD,
			--MBI.MBISizeH,
			--MBI.MBISizeW,
			--MBI.IsClosed,
			--MBI.MBIExtText01,
			--MBI.MBIExtText02,
			--MBI.MBIExtText03,
			--MBI.MBIExtText04,
			--MBI.MBIExtText05,
			--MBI.MBIExtText06,
			--MBI.MBIExtText07,
			--MBI.MBIExtText08,
			--MBI.MBIExtText09,
			--MBI.MBIExtText10,
			--MBI.MBIExtInt01,
			--MBI.MBIExtInt02,
			--MBI.MBIExtInt03,
			--MBI.MBIExtInt04,
			--MBI.MBIExtInt05,
			--MBI.MBIExtReal01,
			--MBI.MBIExtReal02,
			--MBI.MBIExtReal03,
			--MBI.MBIExtReal04,
			--MBI.MBIExtReal05,
			--MBI.MBIExtLongText01,
			--MBI.MBIExtLongText02,
			--MBI.MBIExtLongText03,
			--MBI.MBIExtLongText04,
			--MBI.MBIExtLongText05,
			--MBI.MBIExtImage01,
			--MBI.MBIExtImage02,
			--MBI.MBIExtImage03,
			--MBI.MBIExtImage04,
			--MBI.MBIExtImage05,
			SOI.OrderQty,
			SOI.FixedQty,
			SOI.ProdPlanQty,
			SOI.StockReservationQty,
			SOI.UnitPrice,
			SOI.OptionText,
			SOI.FixedQty * SOI.UnitPrice AS SOIPrice,
			SOI.RequestDeliveryDate,
			SOI.DeliveryDate,
			SOI.DestInformation,
			SOI.SOIExtText01,
			SOI.SOIExtText02,
			SOI.SOIExtText03,
			SOI.SOIExtText04,
			SOI.SOIExtText05,
			-- Order Info
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
			-- DateTime			
			SOI.CreateDateTime,
			SOI.CreateUserID,
			SOI.ChangeDateTime,
			SOI.ChangeUserID
	FROM
			STB_SalesOrderItem SOI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MBI WITH(NOLOCK)
				ON SOI.ModelCode = MBI.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MBI.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MBI.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN STB_SalesOrder SO WITH(NOLOCK)
				ON SOI.SalesOrderNo = SO.SalesOrderNo
			LEFT OUTER JOIN STB_CustomerInfo CUS WITH(NOLOCK)
				ON SO.CustomerCode = CUS.CustomerCode
			LEFT OUTER JOIN STB_CompanyInfo COM WITH(NOLOCK)
				ON SO.CompanyCode = COM.CompanyCode
	WHERE
			((@CompanyCode = '*') OR (SO.CompanyCode = @CompanyCode)) AND
			((@CustomerCode = '*') OR (SO.CustomerCode = @CustomerCode)) AND
			(SO.OrderDate IS NULL OR (SO.OrderDate BETWEEN @FromOrderDate AND @ToOrderDate)) AND
			(SO.RequestDeliveryDate IS NULL OR (SO.RequestDeliveryDate BETWEEN @FromDeliveryDate AND @ToDeliveryDate)) AND
			((@ModelCode = '*') OR (SOI.ModelCode = @ModelCode))

END
