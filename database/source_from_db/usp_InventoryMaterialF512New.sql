-- =============================================
-- Author:		Mr.Duy
-- Create date:exec usp_InventoryMaterialF512New '2024-09-19'
-- Description:	Tính chênh lệch giữa số lượng nvl đã sử dụng và số lượng nvl đã xuất
-- =============================================
CREATE PROCEDURE [dbo].[usp_InventoryMaterialF512New]
		@pDate varchar(50) = NULL
AS
BEGIN
SET NOCOUNT ON;
	
	declare @outFromDateExportNVL varchar(50),@outToDateExportNVL varchar(30),@outFromDateTotalQtyProduct varchar(30),@outToDateTotalQtyProduct varchar(30)
	exec usp_VN_OutGetDateSearch @pDate,@outFromDateExportNVL OUTPUT,@outToDateExportNVL OUTPUT,@outFromDateTotalQtyProduct OUTPUT,@outToDateTotalQtyProduct OUTPUT

	declare @DateFromBaophe datetime = @outFromDateTotalQtyProduct,@DateToBaophe datetime =@outToDateTotalQtyProduct -- convert lại ngày để tìm kiếm trong báo phế
	declare @month int = Month(@pDate) , @year int = Year(@pDate) -- lấy ra tháng và năm để tìm kiếm trong kỳ trước đó


	declare @pStart datetime,@pEnd datetime
	set @pStart = convert(varchar(7), dateadd(month,-1,@pDate) , 120 ) +'-25'
	set @pEnd = convert(varchar(7), dateadd(month,0,@pDate) , 120 )+'-24'
	;with
				 
						RawView0 as ( -- lấy danh sách các barcode đã thực hiện ở công đoạn tổng số hàng đưa vào và số hàng lỗi
	 						select  c.PONo,b.CreateUserID,c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
							sum(b.ProdQty) as ProdQty,sum(a.DefectQty) as DefectQty,
							max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
							from  STB_SetInfo c with(nolock) 
							 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
							 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
							 where 1=1
							--and c.Barcode in ('VVOM013R010555','VVOM083R020503','VVOM013R010531','VVOM023R010514')
							 --and c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) 
							 --and  b.WorkCenterCode = @WorkCenterCode 
							 AND b.ProdDateTime>=@outFromDateTotalQtyProduct  
							 and b.ProdDateTime<@outToDateTotalQtyProduct
							 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker',/*'electrode_worker',*/'dryroom_worker' )
							-- and RouteCode in ('V-22','V-22_BG','MV-01','MV-01_BG','V-01','V-01_BG') --chỉ lấy hàng khi cho vào V-22 lấy số lượng chưa bị NG
							 group by c.PONo,b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.ProdQty,a.DefectQty,a.DefectCode--,b.CreateDateTime

					),
					RawView as ( -- Tổng hợp lại các barcode ở trên gộp lại để tính tổng lỗi theo từng công đoạn
	 						select  PONo,CreateUserID,Barcode,RouteCode, FindRouteCode,
							ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01,
							max(ProdQty) as ProdQty, 
							sum(DefectQty) as DefectQty ,
							max(ProdDateTime) as ProdDateTime, 
							max(CreateDateTime) as CreateDateTime
							from  RawView0	
							where 
							1=1
							--and InputLineCode='VVC-01'  
							--and  SUBSTRING (Barcode, 1, 1) !='M' 
							 group by PONo,CreateUserID,Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01 --,a.DefectCode--,b.CreateDateTime
					)
					
					,
					GroupRawViewByLine as -- lấy số lượng hàng sản xuất theo line
					(
					select MaterialCode,InputLineCode,RouteCode, SUM(ProdQty) as ProdQty, 	ISNULL(sum(DefectQty),0) as DefectQty  from RawView  
					group by MaterialCode,RouteCode,InputLineCode
					),
					GroupRawViewRouteCode as --Lấy tổng số lượng hàng sản xuất theo công đoạn
					(
					select MaterialCode,RouteCode, SUM(ProdQty) as ProdQty, 	ISNULL(sum(DefectQty),0) as DefectQty  from RawView   
					group by MaterialCode,RouteCode
					)
					,
					GetLineProduction as  --lấy ra line đang sản xuất con hàng
					(
					select distinct MaterialCode, InputLineCode from GroupRawViewByLine
					)
					,
				
					selectall as ( --Lấy được ra Inputlinecode và MaterialCode  để link sang boom nhân ra số lượng nvl đã sử dụng
					select RouteCode ,MaterialCode ,ISNULL(max(ProdQty),0) as ProdQty,ISNULL(sum(DefectQty),0) as DefectQty 
					from GroupRawViewRouteCode r
					group by MaterialCode,RouteCode
					),
					selectversion as ( -- xác định xem Bomversion đang được sử dụng là bao nhiêu
					select  BomVersion , BomUnit,sa.MaterialCode,sa.RouteCode ,ProdQty,DefectQty  from STB_BomHeader BH
					left outer join selectall sa on Bh.MaterialCode = sa.MaterialCode
					where 
					 IsUsed=1 and BH.MaterialCode=sa.MaterialCode and BomVersion='99'--order by BomVersion desc 
					 ),
					 BomCTE AS --Tính toán số lượng nvl đã sử dụng
							(
								SELECT					
										CONVERT(VARCHAR,ROW_NUMBER() OVER(ORDER BY BD.MaterialCode)) AS Id,
										--CONVERT(VARCHAR,NULL) AS ParentId,
										BD.MaterialCode,
										case when MM.ProductGroupCode in ('SLITTING-ROLL') then
										coalesce(
										b5.ChildMaterialCode,
										b4.ChildMaterialCode,
										b3.ChildMaterialCode,
										b2.MaterialCode,
										BD.MaterialCode
										) else '' end as MaterialCode1,
										BD.BomVersion, 
										coalesce(
											b5.ChildMaterialCode,
											b4.ChildMaterialCode,
											b3.ChildMaterialCode,
											b2.ChildMaterialCode,
											BD.ChildMaterialCode
											) as ChildMaterialCode,

										BD.ChildBomVersion,
										
										BD.RouteCode,
										--MM.MaterialName,
										coalesce(MMM.MaterialName,MM.MaterialName)  as MaterialName,
										isnull(coalesce(
											b5.BomUnit,
											b4.BomUnit,
											b3.BomUnit,
											b2.BomUnit,
											BD.BomUnit
											),MMM.MaterialUnit) as BomUnit,
										sv.BomUnit AS ParentBomHeaderUnit,
										--sv.InputLineCode,
										(
											SELECT
													BH.BomUnit
											FROM
													STB_BomHeader BH
											WHERE
													BH.MaterialCode = BD.ChildMaterialCode AND
													BH.BomVersion = BD.ChildBomVersion
										) AS BomHeaderUnit,
										coalesce(MMM.MaterialUnit,MM.MaterialUnit) as MaterialUnit,
									
										--BD.UsedQty,
										--CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty)) AS ParentBomHeaderUnitUsedQty,	
										sv.ProdQty as TotalProdQty ,
										CONVERT(NUMERIC(10,5),isnull(BD.UsedQty,1)) as UsedQty1,
										CONVERT(NUMERIC(10,5),isnull(b2.UsedQty,1)) as UsedQty2,
										CONVERT(NUMERIC(10,5),isnull(b3.UsedQty,1)) as UsedQty3,
										CONVERT(NUMERIC(10,5),isnull(b4.UsedQty,1)) as UsedQty4,
										CONVERT(NUMERIC(10,5),isnull(b5.UsedQty,1)) as UsedQty5,
							
											CONVERT(NUMERIC(20,15),
										CONVERT(NUMERIC(10,5),isnull(BD.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b2.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b3.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b4.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b5.UsedQty,1)))	
										*sv.ProdQty
										as TotalNvlTToQty,
										
-- exec usp_UseMaterialAndInventoryF512 '2024-09-16'
											(sv.ProdQty - sv.DefectQty) as TotalOK ,
										CONVERT(NUMERIC(20,15),
										CONVERT(NUMERIC(10,5),isnull(BD.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b2.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b3.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b4.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b5.UsedQty,1)))	
										*(sv.ProdQty - sv.DefectQty) as TotalNvlTToOK,
										
										sv.DefectQty as TotalDefect,

										CONVERT(NUMERIC(20,15),
										CONVERT(NUMERIC(10,5),isnull(BD.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b2.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b3.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b4.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b5.UsedQty,1)))	
										*sv.DefectQty
										 as TotalNvlTToDefect,
										MM.ProductGroupCode
								FROM
										STB_BomDetail BD
										left outer join stb_BomDetail b2  on b2.MaterialCode=BD.ChildMaterialCode and b2.MaterialCode<>b2.ChildMaterialCode  and  (b2.BomVersion='99' )
										left outer join stb_BomDetail b3  on b3.MaterialCode=b2.ChildMaterialCode and b3.MaterialCode<>b3.ChildMaterialCode  and  (b3.BomVersion='99' )
										left outer join STB_BomDetail b4  on b4.MaterialCode=b3.ChildMaterialCode and b4.MaterialCode<>b4.ChildMaterialCode  and  (b4.BomVersion='99' )
										left outer join STB_BomDetail b5  on b5.MaterialCode=b4.ChildMaterialCode and b5.MaterialCode<>b5.ChildMaterialCode  and  (b5.BomVersion='99' )
							
										INNER JOIN STB_MaterialMaster MM
											ON	MM.MaterialCode = BD.ChildMaterialCode
										INNER JOIN STB_MaterialMaster MMM
											ON	MMM.MaterialCode = coalesce(
									
											b5.ChildMaterialCode,
											b4.ChildMaterialCode,
											b3.ChildMaterialCode,
											b2.ChildMaterialCode,
											BD.ChildMaterialCode)

										inner join selectversion sv on BD.MaterialCode = sv.MaterialCode 
								WHERE
										BD.MaterialCode = sv.MaterialCode AND
										BD.BomVersion = sv.BomVersion
										/* phần này là trừ nvl đã làm từ 1 con hàng khác cho hàng module
										and coalesce(
											BD.ChildBomVersion,
											b2.ChildBomVersion,
											b3.ChildBomVersion,
											b4.ChildBomVersion,
											b5.ChildBomVersion
											) != '99'*/
										AND sv.RouteCode like '%'+BD.RouteCode+'%' -- do sv.RouteCode V-24_Bg nên trong BD.RouteCode chỉ có V-24.. thì cần sử dụng like thay vì so sánh =
					 )

				 select * from BomCTE-- where ChildMaterialCode = 'GBHB00-034'

				-- exec  usp_InventoryMaterialF512New '2024-09-19'
  
END
