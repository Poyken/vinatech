-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-12
-- Description:	Tính số lượng cần sử dụng của poil và giấy đối với các mã hàng được thêm vào hệ thống
-- =============================================
-- exec usp_MaterialSlittingQtyPlanInMonths '2025-02-10'
CREATE PROCEDURE [dbo].[usp_MaterialSlittingQtyPlanInMonths]
	@pDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @monthdate varchar(20)=MONTH(@pDate)
	declare @yeardate varchar(20)=Year(@pDate)


	--raiserror(@dateConver,16,1)
	;with getMaterialSlittingQtyPlanInMonths as
	(
	select MaterialCode,Qty,Yearr,Months from STB_MaterialSlittingQtyPlanInMonths where Months=@monthdate and yearr=@yeardate
	),
	getQtyForBom as
	(
		 SELECT
				GMSQ.MaterialCode,
				BD.BomVersion,
				BD.ChildMaterialCode,
				BD.ChildBomVersion,
				MM.MaterialName,
				MM1.MaterialName as PMaterialName,
				MM.ProductGroupCode,
				BD.BomUnit,
				BD.UsedQty as UsedQty,			
				RI.IsUsed,
				GMSQ.Qty,
				(GMSQ.Qty * BD.UsedQty) as TotalUserQtyMaterial,
				GMSQ.Yearr,
				GMSQ.Months
		FROM
				getMaterialSlittingQtyPlanInMonths GMSQ WITH(NOLOCK) 
				LEFT OUTER JOIN STB_BomDetail BD WITH(NOLOCK)						 ON BD.MaterialCode = GMSQ.MaterialCode
				LEFT OUTER JOIN STB_MaterialMaster MM1 WITH(NOLOCK)					 ON BD.MaterialCode = MM1.MaterialCode
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)					 ON BD.ChildMaterialCode = MM.MaterialCode --AND MM.ProductGroupCode in ('ANODE-FOIL','CATHODE-FOIL','CON-PAPER')
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)						 ON RI.RouteCode = BD.RouteCode

				
		WHERE 
				(BD.BomVersion = '99' OR BD.BomVersion IS NULL)
				AND MM.ProductGroupCode IN ('ANODE-FOIL', 'CATHODE-FOIL', 'CON-PAPER') OR MM.ProductGroupCode IS NULL  -- chỉ lấy số lượng của 3 loại
				AND ((BD.ChildMaterialCode <> null and MM.MaterialName is not null) or (BD.ChildMaterialCode is null and MM.MaterialName is  null)) -- nếu mà có mã nguyên liệu thì phải có  tên nguyên liệu không thì ngược lại để lọc các nguyên liệu chưa được thêm vào A230 ra ngoài
				--and RI.IsUsed=1

		
		)
		select MaterialCode,PMaterialName,ChildMaterialCode,MaterialName,Qty, CONVERT(VARCHAR(20), UsedQty) as UsedQty,TotalUserQtyMaterial,BomUnit from getQtyForBom
	

END
