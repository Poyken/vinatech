
-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-18
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 조회(입고대상발주전표만 조회)
-- Modified:
/***********************************************/
--	2016-09-01 Kim Han Young(hykim@awoo.co.kr)
--		납품예정일자(PlanGrDate) 조회로 변경
/***********************************************/
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialOrderForGR_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pCustomerCode VARCHAR(20) = NULL,
	@pFromPlanGrDate DATE = NULL,
	@pToPlanGrDate DATE = NULL,
	@pMaterialOrderType VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END
	DECLARE @FromPlanGrDate DATE = @pFromPlanGrDate
    DECLARE @ToPlanGrDate DATE = @pToPlanGrDate
	DECLARE @MaterialOrderType VARCHAR(20) = CASE WHEN ISNULL(@pMaterialOrderType,'') = '' THEN '*' ELSE @pMaterialOrderType END
	  

    ;
	WITH OrderItem AS
	(
		SELECT
				DISTINCT
				MO.MaterialOrderNo
		FROM
				STB_MaterialOrder MO
				INNER JOIN STB_MaterialOrderItem MOI
					ON	MOI.MaterialOrderNo = MO.MaterialOrderNo
		WHERE
				((@CompanyCode = '*') OR (MO.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (MO.WorkCenterCode = @WorkCenterCode)) AND
				((@CustomerCode = '*') OR (MO.CustomerCode = @CustomerCode)) AND				
				((@MaterialOrderType = '*') OR (MO.MaterialOrderType = @MaterialOrderType)) AND
				(MO.IsFinished = 0) AND
				(MO.IsAllCancel = 0) AND
				((MO.OrderStatus NOT IN ('REQUEST', 'FINISH'))) AND
				((@FromPlanGrDate IS NULL) OR (@FromPlanGrDate <= MOI.PlanGrDate)) AND 
				((@ToPlanGrDate IS NULL) OR (MOI.PlanGrDate <= @ToPlanGrDate))
	)
	SELECT
	        MO.MaterialOrderNo AS OldMaterialOrderNo,
	        MO.MaterialOrderNo,
	        
	        CASE MO.MaterialOrderType
				WHEN 'PURCHASE' THEN 'GR_NORMAL'
				WHEN 'PRODUCTION' THEN 'GR_EXT_PROD_W_BOM'
			END AS MaterialDocTypeCode,
			CASE MO.MaterialOrderType
				WHEN 'PURCHASE' THEN '구매입고'
				WHEN 'PRODUCTION' THEN '외주생산입고'
			END AS MaterialDocTypeName,
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

			CMW.MaterialWarehouseCode AS CustomerMaterialWarehouseCode,
	        CMW.MaterialWarehouseName AS CustomerMaterialWarehouseName,
	        
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
			OrderItem OI
	        INNER JOIN STB_MaterialOrder MO WITH(NOLOCK)				ON	MO.MaterialOrderNo = OI.MaterialOrderNo
	        LEFT OUTER JOIN STB_MaterialWareHouse MW WITH(NOLOCK)				ON MO.MaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)				ON MO.CustomerCode = CI.CustomerCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON MO.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo C WITH(NOLOCK)				ON MO.CompanyCode = C.CompanyCode
			LEFT OUTER JOIN dbo.VW_MaterialOrderType MOT WITH(NOLOCK)				ON (MOT.MaterialOrderType = MO.MaterialOrderType)	 
			LEFT OUTER JOIN STB_MaterialWarehouse CMW WITH(NOLOCK)				ON	CMW.MaterialWarehouseCode = CI.MaterialWarehouseCode       

END
