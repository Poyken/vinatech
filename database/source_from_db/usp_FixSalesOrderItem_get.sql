-- =============================================
-- Author:		kilee
-- Create date: 2019-01-10
-- Group : 영업관리 > 고정오더조회 > 고정오더조회상세
-- Description:	FixSalesOrderItem (Tab2) 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_FixSalesOrderItem_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pSalesOrderNo VARCHAR(20) = NULL,

		
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
				
	DECLARE 
	        @SalesOrderNo VARCHAR(20) = CASE WHEN ISNULL(@pSalesOrderNo,'') = '' THEN '*' ELSE @pSalesOrderNo END,
			@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END,
			@FromOrderDate DATE = CASE WHEN @pFromOrderDate IS NULL THEN (SELECT MIN(OrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE OrderDate IS NOT NULL) ELSE @pFromOrderDate END,
			@ToOrderDate DATE = CASE WHEN @pToOrderDate IS NULL THEN (SELECT MAX(OrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE OrderDate IS NOT NULL) ELSE @pToOrderDate END,
			@FromDeliveryDate DATE = CASE WHEN @pFromDeliveryDate IS NULL THEN (SELECT MIN(RequestDeliveryDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE RequestDeliveryDate IS NOT NULL) ELSE @pFromDeliveryDate END,
			@ToDeliveryDate DATE = CASE WHEN @pToDeliveryDate IS NULL THEN (SELECT MAX(RequestDeliveryDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE RequestDeliveryDate IS NOT NULL) ELSE @pToDeliveryDate END,
			
			@CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END,
			@OrderType VARCHAR(20) = CASE WHEN ISNULL(@pOrderType,'') = '' THEN '*' ELSE @pOrderType END,
			
			@IncludeCancel VARCHAR(1) = CASE WHEN ISNULL(@pIncludeCancel,'') = '' THEN 'Y' ELSE @pIncludeCancel END,
			@FromFixDate DATE = CASE WHEN @pFromFixDate IS NULL THEN (SELECT MIN(FixOrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE FixOrderDate IS NOT NULL) ELSE @pFromFixDate END,
			@ToFixDate   DATE = CASE WHEN @pToFixDate   IS NULL THEN (SELECT MAX(FixOrderDate) FROM STB_SalesOrder WITH(NOLOCK) WHERE FixOrderDate IS NOT NULL) ELSE @pToFixDate   END
			
						

	SELECT
			SOI.SOISequence AS OldSOISequence,
			SOI.SOISequence,
			SO.CustomerCode,
			CI.CustomerName,			
			SOI.SOISequence AS OrderDetailNo,
			SOI.SalesOrderNo AS OldSalesOrderNo,
			SOI.SalesOrderNo,
			--SOI.ModelCode,   -- 기존 소스 백업
			CASE WHEN MM.MaterialTypeCode = 'MDL' THEN MBI.MBIExtText06  ELSE SOI.ModelCode END  AS ModelCode ,			     
			SOI.BomVersion,
			--MM.MaterialName AS ModelName,    -- 기존 소스 백업
			CASE WHEN MM.MaterialTypeCode = 'MDL' THEN (SELECT MM.MATERIALNAME FROM STB_MaterialMaster MM WHERE MM.MATERIALCODE =  MBI.MBIExtText06)  ELSE  MM.MaterialName END  AS ModelName ,			     
			MBI.ModelNameL,
			MM.MaterialCode,
			MM.MaterialName,
			MBI.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MBI.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL,
			MBI.ModelPrintName,
			MBI.BasicModel,
			MBI.DEFlag,
			MBI.EanCode,
			MBI.UpcCode,
			MBI.ModelColor,
			MBI.MBIWeight,
			MBI.MBISizeD,
			MBI.MBISizeH,
			MBI.MBISizeW,
			MBI.IsClosed,
			MBI.MBIExtText01,
			MBI.MBIExtText02,			
			MBI.MBIExtText03 AS 제품종류,
			MBI.MBIExtText04 AS 전압V,
			MBI.MBIExtText05 AS 용량F,			
			MBI.MBIExtText06,
			MBI.MBIExtText07,
			MBI.MBIExtText08,
			MBI.MBIExtText09,
			MBI.MBIExtText10,
			MBI.MBIExtInt01,
			MBI.MBIExtInt02,
			MBI.MBIExtInt03,
			MBI.MBIExtInt04,
			MBI.MBIExtInt05,
			MBI.MBIExtReal01,
			MBI.MBIExtReal02,
			MBI.MBIExtReal03,
			MBI.MBIExtReal04,
			MBI.MBIExtReal05,
			MBI.MBIExtLongText01,
			MBI.MBIExtLongText02,
			MBI.MBIExtLongText03,
			MBI.MBIExtLongText04,
			MBI.MBIExtLongText05,
			MBI.MBIExtImage01,
			MBI.MBIExtImage02,
			MBI.MBIExtImage03,
			MBI.MBIExtImage04,
			MBI.MBIExtImage05,
			SO.OrderDate,
			--SOI.OrderQty,
			CASE WHEN MM.MaterialTypeCode = 'MDL' THEN ISNULL(SOI.OrderQty, 0) * ISNULL(MBI.MBIExtInt01, 0)  ELSE ISNULL(SOI.OrderQty, 0) END  AS OrderQty ,
			ISNULL(SOI.FixedQty, 0),
			ISNULL(SOI.GIPlanQty, 0),		-- 출고예정수량
			ISNULL(SOI.GIFixQty, 0),		-- 출고확정수량
			ISNULL(SOI.FixedQty, 0) - ISNULL(SOI.GIPlanQty, 0) - ISNULL(SOI.GIFixQty, 0) AS GIRemainQty,                       -- 출고잔량
			CONVERT(INT, SOI.FixedQty - ISNULL(SOI.StockReservationQty, 0) - ISNULL(SOI.ProdPlanQty,0)) AS RemainPlanQty,
			CONVERT(INT, SOI.FixedQty - ISNULL(SOI.StockReservationQty, 0) - ISNULL(SOI.ProdPlanQty,0)) AS RequestQty,
			ISNULL(SOI.ProdPlanQty, 0),
			SOI.IsMainAssemblePlan,
			SOI.IsOutboundInspection,
			ISNULL(SOI.StockReservationQty, 0),
			SOI.UnitPrice,
			SOI.OptionText,
			SOI.RequestDeliveryDate,
			SOI.DeliveryDate,
			SOI.DestInformation,
			SOI.SOIExtText01,
			SOI.SOIExtText02,
			SOI.SOIExtText03,
			SOI.SOIExtText04,
			SOI.SOIExtText05,
			SOI.CreateDateTime,
			SOI.CreateUserID,
			SOI.ChangeDateTime,
			SOI.ChangeUserID,
			SO.FixOrderDate,
			MBI.MBISizeH AS 사이즈,
			MBI.MBISizeW AS 직경
	FROM
			STB_SalesOrderItem SOI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SalesOrder     SO WITH(NOLOCK)			ON SO.SalesOrderNo      = SOI.SalesOrderNo
			LEFT OUTER JOIN STB_CustomerInfo   CI WITH(NOLOCK)			ON CI.CustomerCode      = SO.CustomerCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)			ON SOI.ModelCode        = MBI.ModelCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)			ON (MM.MaterialCode     = SOI.ModelCode)
			LEFT OUTER JOIN STB_MaterialType   MT WITH(NOLOCK)			ON MM.MaterialTypeCode  = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup   PG WITH(NOLOCK)			ON MBI.ProductGroupCode = PG.ProductGroupCode
	WHERE 1=1
		AND	((@CompanyCode = '*') OR (SO.CompanyCode = @CompanyCode)) 
		AND	((@CustomerCode = '*') OR (SO.CustomerCode = @CustomerCode)) 
		--AND	SO.OrderDate BETWEEN  @FromOrderDate AND @ToOrderDate
		AND	(SO.OrderDate IS NULL OR (SO.OrderDate BETWEEN @FromOrderDate AND @ToOrderDate) AND (SO.RequestDeliveryDate IS NULL OR (SO.RequestDeliveryDate BETWEEN @FromDeliveryDate AND @ToDeliveryDate))) 
		AND ((@OrderType = '*') OR (SO.OrderType = @OrderType)) 
		AND ((@IncludeCancel = 'Y') OR (SO.IsCancel = 0))				


		AND	SO.FixOrderDate BETWEEN @FromFixDate AND @ToFixDate
		--AND	(SO.FIXOrderDate IS NULL OR (SO.FIXOrderDate BETWEEN '2018-12-31 08:30:00' AND '2019-01-10 08:30:00') AND (SO.FIXOrderDate IS NULL OR (SO.FIXOrderDate BETWEEN '2018-12-31 08:30:00' AND '2019-01-10 08:30:00'))) 
		AND SO.IsFlxedCheck = '1'        -- 고정오더인것만

END



-- SELECT * FROM STB_MaterialMaster WHERE MaterialCode = 'ECPU27-365'

-- SELECT * FROM VW_ModelBasicInfo WHERE MODELCODE = 'ECPU27-365'
-- SELECT MBISizeH FROM STB_ModelBasicInfo WHERE MODELCODE = 'ECPU27-365'

--SELECT A.MBIExtInt01
--     , A.* 
--FROM STB_ModelBasicInfo A WITH(NOLOCK) LEFT OUTER JOIN STB_ModelBasicInfo B  WITH(NOLOCK)	ON A.MODELCODE      = B.MODELCODE
--WHERE 1=1
-- AND A.MaterialTypeCode = 'MDL' 


--select * from STB_SalesOrder