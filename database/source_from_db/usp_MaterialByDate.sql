

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-27
-- Browsable : true
-- Group : 자재관리
-- Description: 발주서 생성을 위한 미발주 MRP 를 조회합니다.
-- Modified: usp_MaterialByDate '','','VVT','VVT_F1','2024-11-01','2024-11-30','','','241023000020' 
-- Modified: usp_MaterialByDate '','','VVT','VVT_F1','2024-11-26','2024-11-26','','','' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialByDate]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pPoNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
		DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
		DECLARE @LineCode VARCHAR(30) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
		DECLARE @FromDate DATE = @pFromDate
		DECLARE @ToDate DATE = @pToDate
		DECLARE @MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END			 
		DECLARE @PoNo VARCHAR(30) = @pPoNo
    

--raiserror (@PoNo,16,1)
IF (@pPoNo IS NULL OR @pPoNo = '')
		begin
				;with ha as (
									 select DPP.PoNo,DPP.DayPlanNo,SUM( DPP.PlanQty) as soluongkehoachngay, PO.PlanQty as tongsoluongPO,DPP.Plandate,DPP.linecode, DPP.MaterialCode, DPP.BomVersion,DPP.WorkCenterCode,DPP.IsOrderMaterial 
															from  STB_DayProdPlan DPP
																left join STB_ProductionOrderInfo PO  WITH(NOLOCK) ON	DPP.PONo = PO.PONo
																where 
																	DPP.PlanDate BETWEEN @FromDate AND @ToDate
																--AND DPP.CompanyCode LIKE @CompanyCode 
																AND DPP.WorkCenterCode LIKE @WorkCenterCode 
																AND DPP.LineCode LIKE @LineCode 
																--AND  DPP.IsOrderMaterial =0
																Group by DPP.DayPlanNo,PO.PlanQty,DPP.PoNo,DPP.Plandate,DPP.linecode,DPP.MaterialCode,DPP.BomVersion,DPP.WorkCenterCode,DPP.IsOrderMaterial 

						)select	
									a.PoNo,
									a.DayPlanNo,
									a.tongsoluongPO,
									a.soluongkehoachngay,
									a.MaterialCode,
									b.MaterialName,
									a.BomVersion, 
									a.linecode,
									a.Plandate,
									a.WorkCenterCode,
									a.IsOrderMaterial 
									from  ha a
							left Join stb_MaterialMaster  b on a.MaterialCode =b.MaterialCode

		end
else 
		begin
					;with ha as (
									 select DPP.PoNo,DPP.DayPlanNo,SUM( DPP.PlanQty) as soluongkehoachngay, PO.PlanQty as tongsoluongPO,DPP.Plandate,DPP.linecode, DPP.MaterialCode, DPP.BomVersion,DPP.WorkCenterCode,DPP.IsOrderMaterial 
															from  STB_DayProdPlan DPP
																left join STB_ProductionOrderInfo PO  WITH(NOLOCK) ON	DPP.PONo = PO.PONo
																where 
																DPP.Pono=@PoNo
																--AND  DPP.IsOrderMaterial =0
																Group by DPP.DayPlanNo,PO.PlanQty,DPP.PoNo,DPP.Plandate,DPP.linecode,DPP.MaterialCode,DPP.BomVersion,DPP.WorkCenterCode,DPP.IsOrderMaterial 

						)select	
									a.PoNo,
									a.DayPlanNo,
									a.tongsoluongPO,
									a.soluongkehoachngay,
									a.MaterialCode,
									b.MaterialName,
									a.BomVersion, 
									a.linecode,
									a.Plandate,
									a.WorkCenterCode,
									a.IsOrderMaterial 
									from  ha a
							left Join stb_MaterialMaster  b on a.MaterialCode =b.MaterialCode
		end






			

END