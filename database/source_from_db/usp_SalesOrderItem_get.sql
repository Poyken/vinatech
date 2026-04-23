-- =============================================
-- Author:		Joo Su Hong
-- Create date: 2016-01-14
-- Group : 영업관리
-- Description:	SalesOrderItem 조회합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesOrderItem_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pSalesOrderNo VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
			
	DECLARE
			@SalesOrderNo VARCHAR(20) = CASE WHEN ISNULL(@pSalesOrderNo,'') = '' THEN '*' ELSE @pSalesOrderNo END

	SELECT
			SOI.SOISequence AS OldSOISequence,
			SOI.SOISequence,
			SO.CustomerCode,
			CI.CustomerName,
			--자재수불관리에서 영업오더상세를 선택할 때 사용
			SOI.SOISequence AS OrderDetailNo,
			SOI.SalesOrderNo AS OldSalesOrderNo,
			SOI.SalesOrderNo,
			SOI.ModelCode,
			SOI.BomVersion,
			--(
			--	SELECT
			--			TOP 1
			--			BH.RouteCode
			--	FROM
			--			STB_BomHeader BH WITH(NOLOCK)
			--	WHERE
			--			BH.MaterialCode = SOI.ModelCode AND 
			--			ISNULL(BH.IsBasic,0) = 1
			--) AS RouteCode, 삼화는 BomVersion을 미사용
			MM.MaterialName AS ModelName,
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
			MBI.MBIExtText03,
			MBI.MBIExtText04,
			MBI.MBIExtText05,
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
			SOI.OrderQty,
			SOI.FixedQty,
			SOI.GIPlanQty,		-- 출고예정수량
			SOI.GIFixQty,		-- 출고확정수량
			SOI.FixedQty - SOI.GIPlanQty - SOI.GIFixQty AS GIRemainQty, -- 출고잔량
			CONVERT(INT, SOI.FixedQty - ISNULL(SOI.StockReservationQty, 0) - ISNULL(SOI.ProdPlanQty,0)) AS RemainPlanQty,
			CONVERT(INT, SOI.FixedQty - ISNULL(SOI.StockReservationQty, 0) - ISNULL(SOI.ProdPlanQty,0)) AS RequestQty,
			SOI.ProdPlanQty,
			SOI.IsMainAssemblePlan,
			SOI.IsOutboundInspection,
			SOI.StockReservationQty,
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
			SOI.ChangeUserID
	FROM
			STB_SalesOrderItem SOI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SalesOrder SO WITH(NOLOCK)
				ON	SO.SalesOrderNo = SOI.SalesOrderNo
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON	CI.CustomerCode = SO.CustomerCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON SOI.ModelCode = MBI.ModelCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
				ON (MM.MaterialCode = SOI.ModelCode)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MBI.ProductGroupCode = PG.ProductGroupCode
	WHERE
			((SOI.SalesOrderNo = @SalesOrderNo))
END
