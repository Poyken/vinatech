

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-27
-- Browsable : true
-- Group : 자재관리
-- Description: 발주서 생성을 위한 미발주 MRP 를 조회합니다.
-- Modified:   usp_DayMaterialOrder_get '','','VVT','VVT_F1','2024-11-01','2024-11-30','','','2024110100202' 
-- Modified:   usp_DayMaterialOrder_get  '2024110100202' 
 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayMaterialOrder_get]
	@pDayPlanNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @DayPlanNo VARCHAR(30) =@pDayPlanNo   
    

;with Ha as (
					
						select DPP.PoNo,DPP.DayPlanNo,SUM( DPP.PlanQty) as soluongkehoachngay, PO.PlanQty as soluongPO,DPP.PlanShiftCode,DPP.Plandate,DPP.linecode,DPP.WorkCenterCode
						from  STB_DayProdPlan DPP
							left join STB_ProductionOrderInfo PO  WITH(NOLOCK) ON	DPP.PONo = PO.PONo
							Group by DPP.DayPlanNo,PO.PlanQty,DPP.PoNo,DPP.Plandate,DPP.linecode,DPP.WorkCenterCode,DPP.PlanShiftCode
			

), okbaby as (
			 select 
				ha.PONo, 
				ha.DayPlanNo, 
				POB.ChildMaterialCode,
				MM.MaterialName,
				ha.LineCode,
				ha.SoLuongKehoachNgay,
				ha.PlanShiftCode,
				POB.UsedQty as UsedQtyDay ,
				POB.UsedQty * ha.soluongkehoachngay  as NVLngay,
				ha.Plandate,
				'' as IsAdditional,
				ha.WorkCenterCode,
				POB.UsedQty * ha.soluongkehoachngay  as QtyByPO
			from Ha ha
			
			left join STB_ProductionOrderBom POB  WITH(NOLOCK) ON	ha.PONo = POB.PONo
		 	left Join stb_MaterialMaster  MM WITH(NOLOCK) ON   POB.ChildMaterialCode =MM.MaterialCode
					--where ha.DayPlanNo = '2024111900012'  --- tìm kiếm theo kế hoạch ngày
							where POB.PoNo is not null

)select * from okbaby  where  DayPlanNo like @DayPlanNo

		 
		
END