

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-27
-- Browsable : true
-- Group : 자재관리
-- Description: 발주서 생성을 위한 미발주 MRP 를 조회합니다.
-- Modified:   usp_DayMaterialOrder_get '','','VVT','VVT_F1','2024-11-01','2024-11-30','','','2024110100202' 
-- Modified:   usp_DayMaterialOrder_get  '2024110100202' 
 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayMaterialOrderAndAdditional_get]
			
AS
BEGIN
	SET NOCOUNT ON;
	

	select 
		PONo, 
		DayPlanNo, 
		ChildMaterialCode,
		MaterialName, 
		LineCode, 
		SoLuongKeHoachNgay, 
		UsedQtyDay,
		NVLngay, 
		PlanShiftCode,
		Plandate, 
		'' as IsAdditional, 
		WorkCenterCode,
		QtyByPO,
		OrderDesc
	
	 
	 


	from STB_DayMaterialOrder  where 1=0



END


 