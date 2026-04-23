
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : [F123] 자재관리 > 발주정보 TAB
-- Description:	자재발주전표 조회
-- Modified: 2019-06-18 SQL 줄바꿈 정리 (kilee)
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialOrder_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pCustomerCode VARCHAR(20) = NULL,
    @pFromOrderDate DATE = NULL,
    @pToOrderDate DATE = NULL,
	@pMaterialOrderType VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20)     = CASE WHEN ISNULL(@pCompanyCode,'') = ''       THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20)  = CASE WHEN ISNULL(@pWorkCenterCode,'') = ''    THEN '*' ELSE @pWorkCenterCode END
    DECLARE @CustomerCode VARCHAR(20)     = CASE WHEN ISNULL(@pCustomerCode,'') = ''       THEN '*' ELSE @pCustomerCode END
    DECLARE @FromOrderDate DATE               = CASE WHEN ISNULL(@pFromOrderDate,'') = ''      THEN GETDATE() ELSE @pFromOrderDate END
    DECLARE @ToOrderDate DATE				   = CASE WHEN ISNULL(@pToOrderDate,'') = ''         THEN GETDATE() ELSE @pToOrderDate END
	DECLARE @MaterialOrderType VARCHAR(20) = CASE WHEN ISNULL(@pMaterialOrderType,'') = '' THEN '*' ELSE @pMaterialOrderType END
	  
    -- [1]
	SELECT
	        MO.MaterialOrderNo AS OldMaterialOrderNo,
	        MO.MaterialOrderNo,	        
	        
	        MO.CompanyCode,
	        C.CompanyName,
	        C.CompanyNameL,
	        C.CompanyDesc,
	        C.CompanyDescL,
	        
	        MO.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        WCI.WorkCenterDesc,
	        WCI.WorkCenterDescL,
	        
	        
	        MO.MOCreateType,
			MO.MaterialOrderType,
			MOT.MaterialOrderTypeName,
	        
	        MO.CustomerCode,
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
	        CI.OrderToTel,
	        CI.OrderToEmail,
	        CI.CustomerDesc,
	        
	        MO.OrderFromUserID,
	        MO.OrderToName,
	        
	        MO.MaterialWarehouseCode,
	        MW.MaterialWarehouseName,
	        MW.MaterialWarehouseNameL,
	        MW.MaterialWarehouseDesc,
	        MW.MaterialWarehouseDescL,
	        MW.WHExtText01,
	        MW.WHExtText02,
	        MW.WHExtText03,
	        MW.WHExtText04,
	        MW.WHExtText05,
	        
	        
	        MO.OrderDate,
	        MO.DeliveryPlanDate,
	        MO.TotalItemQty,
	        MO.TotalOrderPrice,
	        MO.OrderStatus,
	        MO.IsAllCancel,
	        MO.AllCencelUserID,
	        MO.IsFinished,
	        MO.FinishedUserID,
	        MO.MOExtText01,
	        MO.MOExtText02,
	        MO.MOExtText03,
	        MO.MOExtText04,
	        MO.MOExtText05,
	        MO.CreateDateTime,
	        MO.CreateUserID,
	        MO.ChangeDateTime,
	        MO.ChangeUserID
	FROM
	        STB_MaterialOrder MO WITH(NOLOCK)                                                                                                                                          -- 자재발주 Table ( STB_MaterialOrder )
	        LEFT OUTER JOIN STB_MaterialWareHouse MW WITH(NOLOCK)			ON MO.MaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)				    ON MO.CustomerCode = CI.CustomerCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON MO.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo C WITH(NOLOCK)				        ON MO.CompanyCode = C.CompanyCode
			LEFT OUTER JOIN dbo.VW_MaterialOrderType MOT WITH(NOLOCK)		ON (MOT.MaterialOrderType = MO.MaterialOrderType)
	WHERE 1=1
	    AND ((@CompanyCode = '*') OR (MO.CompanyCode = @CompanyCode)) 
		AND ((@WorkCenterCode = '*') OR (MO.WorkCenterCode = @WorkCenterCode)) 
		AND ((@CustomerCode = '*') OR (MO.CustomerCode = @CustomerCode)) 
		AND ((MO.OrderDate >= @FromOrderDate) 
		AND (MO.OrderDate <= @ToOrderDate)) 
		--AND ((MO.MOCreateType = 'MANUAL')) 
		AND ((@MaterialOrderType = '*') OR (MO.MaterialOrderType = @MaterialOrderType))

END
