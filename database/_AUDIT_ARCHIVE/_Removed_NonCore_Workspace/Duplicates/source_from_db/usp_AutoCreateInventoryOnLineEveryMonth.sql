-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-05-09
-- Description:	Tự động chạy vào đầu tháng để lấy tồn trên line của tháng đó cho các line chưa bao gồm điện cực mới trong kho nvl quản lý
-- ============================================= exec usp_AutoCreateInventoryOnLineEveryMonth '2024-09-01'
CREATE PROCEDURE [dbo].[usp_AutoCreateInventoryOnLineEveryMonth]
	@pDate date = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	set ansi_warnings off
	-- convert ngày tháng do pDate truyền vào
declare @outFromDateExportNVL varchar(50),@outToDateExportNVL varchar(30),@outFromDateTotalQtyProduct varchar(30),@outToDateTotalQtyProduct varchar(30), @month int,@year int
exec usp_VN_OutGetDateCreate @pDate,@outFromDateExportNVL OUTPUT,@outToDateExportNVL OUTPUT,@outFromDateTotalQtyProduct OUTPUT,@outToDateTotalQtyProduct OUTPUT,@month,@year


declare @DateFromBaophe datetime = @outFromDateTotalQtyProduct,@DateToBaophe datetime =@outToDateTotalQtyProduct -- convert lại ngày để tìm kiếm trong báo phế
declare @monthadd int = Month(@pDate) , @yearadd int = Year(@pDate) -- lấy ra tháng và năm để tìm kiếm trong kỳ trước đó

declare @pStart datetime,@pEnd datetime
set @pStart = convert(varchar(7), dateadd(month,-2,@pDate) , 120 ) +'-25'
set @pEnd = convert(varchar(7), dateadd(month,-1,@pDate) , 120 )+'-24'


declare @kiemtra int
select  @kiemtra = COUNT(*) from Stb_InventoryUpLine where Months = @monthadd and Years=@yearadd 



if(@kiemtra = 0)
begin
;with
					tondauky as( --Tồn đầu kỳ lấy ở màn hình B723 do kiểm kê cuối tháng
						
						--Đây là lấy từ bảng tồn thực tế
					select Codeline as InputLineCode,Nameline,sum(Qty) as InventoryNvl,Typeinput,input as MaterialName,Unit as BomUnit,Codename as ChildMaterialCode from STB_VN_ITEM_CHECK      WHERE
								 CreateDateTime BETWEEN  @pStart AND @pEnd
					 group by Codeline,Nameline,Typeinput,input,Unit,Codename

					 --đây là lấy từ bảng tự động
					 --select * from Stb_InventoryUpLine where Months = @month and Years=@year
					),
					baophenvl as( --nvl được báo phế chỉ lấy mục nào đã là "báo phế"
					select Model,Item,UNIT,sum(Weights) as Weights,LINENAME,MaLotNguyenLieu,MaLotCapThu,WORKCENTERCODE from STB_VN_PRODUCTION_ERROR  
					WHERE
					1=1
					and StatusError=N'Báo phế'	--And LINENAME='VVC-02' and MaLotNguyenLieu='GBNKSP-057'
					and 	((@DateFromBaophe IS NULL) OR CONVERT(DATE,createdatetime) >= @DateFromBaophe)
											AND
							((@DateToBaophe IS NULL) OR CONVERT(DATE,createdatetime) <= @DateToBaophe)
					group by  Model,Item,UNIT,LINENAME,MaLotNguyenLieu,MaLotCapThu,WORKCENTERCODE
					)
					--select * from baophenvl
					,
					table1  as ( -- Lấy danh sách đã xuất nvl ra ngoài sx 
							select  WarehouseInOutCode,PRO.MaterialWarehouseInOutHistNo,PRO.CompanyCode,PRO.WorkCenterCode,PRO.SourceMaterialWarehouseCode,PRO.TargetMaterialWarehouseCode,
							case when WarehouseInOutCode='O' and TargetMaterialWarehouseCode in('ROUTE_VN_WH','ROUTE_BG_WH') then 'Xuat kho'
								 when WarehouseInOutCode='I' and SourceMaterialWarehouseCode in('ROUTE_VN_WH','ROUTE_BG_WH')  and TargetMaterialWarehouseCode in('ROH_VN_WH','ROH_BG_WH') then 'Nhap lai tu sx'
							end as Tinhtrang,
							PRO.LotID,PRO.LineCode,
							
							--isnull(MLI.MaterialCode,si.MaterialCode) as MaterialCode
							--kiểm tra có bắt đầu bằng CR không. kiểm tra có dấu (-) trong chuỗi không
							case
							when  isnull(MLI.MaterialCode,si.MaterialCode) like 'CR%' and  CHARINDEX('-', isnull(MLI.MaterialCode,si.MaterialCode)) > 0  
								then
									-- xóa chuỗi sau dấu (-) nếu tìm thấy và đổi kí tự đầu tiên thành S
								   STUFF(SUBSTRING(isnull(MLI.MaterialCode,si.MaterialCode), 1, CHARINDEX('-', isnull(MLI.MaterialCode,si.MaterialCode))-1), 1, 1, 'S')  
								else
								isnull(MLI.MaterialCode,si.MaterialCode) 

							end  as MaterialCode
							,isnull(MLI.CurrentQty,PRO.ExportSlitingLength) as CurrentQty

							 from STB_MaterialWarehouseInOutHist PRO
							left join STB_MaterialLotInfo MLI on PRO.LotID = MLI.LotID
							left join STB_ElectrodeSlittingResult esr on PRO.LotID = esr.Barcode
							left join STB_SetInfo si on esr.ElectrodeLotNumber = si.Barcode
							where 
							 1=1
							 AND PRO.CreateDateTime >=@outFromDateExportNVL  and PRO.CreateDateTime<=@outToDateExportNVL
							 AND PRO.CompanyCode = 'VVT' 
						/*
							select WarehouseInOutCode,PRO.MaterialWarehouseInOutHistNo,PRO.CompanyCode,PRO.WorkCenterCode,PRO.SourceMaterialWarehouseCode,PRO.TargetMaterialWarehouseCode,
							case when WarehouseInOutCode='O' and TargetMaterialWarehouseCode in('ROUTE_VN_WH','ROUTE_BG_WH') then 'Xuat kho'
								 when WarehouseInOutCode='I' and SourceMaterialWarehouseCode in('ROUTE_VN_WH','ROUTE_BG_WH')  and TargetMaterialWarehouseCode in('ROH_VN_WH','ROH_BG_WH') then 'Nhap lai tu sx'
							end as Tinhtrang,
							PRO.LotID,PRO.LineCode,MLI.MaterialCode,MLI.CurrentQty
							 from STB_MaterialWarehouseInOutHist PRO
							inner join STB_MaterialLotInfo MLI on PRO.LotID = MLI.LotID
							 where 
							 1=1
							 AND PRO.CreateDateTime >=@outFromDateExportNVL  and PRO.CreateDateTime<=@outToDateExportNVL
							 AND PRO.CompanyCode = 'VVT' 

							 */

							 --and PRO.LineCode  not in ('R-KR','XCDMDSD','XTH','XK','KVHD','XCDMDSD','XTH','R-KR','XK')
							--and PRO.LineCode = 'VVC-01'
							--and MLI.MaterialCode = 'GBAKAC-060'
							 --and PRO.WarehouseInOutCode='O'
							 --and TargetMaterialWarehouseCode <> '%HOLDING%'
							  --and PRO.TargetMaterialWarehouseCode in('ROUTE_VN_WH','ROUTE_BG_WH','ROH_VN_WH','ROH_BG_WH')
						),
						 table2 as -- tính tổng số nvl đã xuất ra sx theo từng line và từng mã nl
						(
							select WarehouseInOutCode,Tinhtrang,CompanyCode,WorkCenterCode,SourceMaterialWarehouseCode,TargetMaterialWarehouseCode,
							LineCode,MaterialCode,SUM(CurrentQty) as CurrentQty
							from table1
							group by WarehouseInOutCode,Tinhtrang,CompanyCode,WorkCenterCode,SourceMaterialWarehouseCode,TargetMaterialWarehouseCode,
							LineCode,MaterialCode
						),
						table3 as ( -- chia ra số lượng nhập và xuất kho
 						select *,
						case when Tinhtrang='Nhap lai tu sx' then isnull(CurrentQty,0) end as Nhaplaitusx,
						case when Tinhtrang='Xuat kho' then isnull(CurrentQty,0) end as Tongsoluongxuat
						from table2 where Tinhtrang is not null
						),
						importedproduction as (
						--nhập lại từ sản xuất ở màn hình  F610
						 select MaterialCode,SUM(PickingAssignQty) as PickingAssignQty,Line  from STB_MaterialDocDetail where
						 	 1=1
							 AND CreateDateTime >=@outFromDateExportNVL  and CreateDateTime<=@outToDateExportNVL
							 and Line is not null
							  Group by MaterialCode,Line
						)
						--select * from table3
						, 
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
							and  SUBSTRING (Barcode, 1, 1) !='M' 
							 group by PONo,CreateUserID,Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01 --,a.DefectCode--,b.CreateDateTime
					)
					--select * from RawView
					--select MaterialCode,InputLineCode, SUM(ProdQty) asProdQty  from RawView   where InputLineCode='VVBGC-01' and MaterialCode='ECVT27-350'
					--group by MaterialCode,InputLineCode
					,
					-- Lấy được ra Inputlinecode và materialCode  để link sang boom nhân ra số lượng nvl đã sử dụng
					/*
					select @Pono=PONo,@Barcode = Barcode ,@MaterialCode= MaterialCode,@InputlineCode=InputlineCode ,@TotalQtyOneProductInLine= max(ProdQty),@TotalNG= sum(DefectQty) from RawView r
					where Exists (select * from STB_ProdRouteHist where ControlNo=r.ControlNo and RouteCode in ('V-27','V-27_BG')) -- kiểm tra xem có tồn tại công đoạn V-27 không nếu có mới tính là hàng đã hoàn thành
					group by PONo,Barcode,MaterialCode,InputLineCode
					*/

					selectall as( --Lấy được ra Inputlinecode và MaterialCode  để link sang boom nhân ra số lượng nvl đã sử dụng
					select PONo,Barcode,RouteCode ,MaterialCode,InputlineCode ,ISNULL(max(ProdQty),0) as ProdQty,ISNULL(sum(DefectQty),0) as DefectQty from RawView r
					--where Exists (select * from STB_ProdRouteHist where ControlNo=r.ControlNo and RouteCode in ('V-27','V-27_BG')) -- kiểm tra xem có tồn tại công đoạn V-27 không nếu có mới tính là hàng đã hoàn thành
					group by PONo,Barcode,MaterialCode,InputLineCode,RouteCode
					),
					selectversion as ( -- xác định xem Bomversion đang được sử dụng là bao nhiêu
					select  BomVersion , BomUnit, PONo,Barcode ,sa.MaterialCode,sa.RouteCode,InputlineCode ,ProdQty,DefectQty  from STB_BomHeader BH
					left outer join selectall sa on Bh.MaterialCode = sa.MaterialCode
					where 
					 IsUsed=1 and BH.MaterialCode=sa.MaterialCode and BomVersion='99'--order by BomVersion desc 
					 )
					 , BomCTE AS --Tính toán số lượng nvl đã sử dụng
							(
								SELECT					
										CONVERT(VARCHAR,ROW_NUMBER() OVER(ORDER BY BD.MaterialCode)) AS Id,
										CONVERT(VARCHAR,NULL) AS ParentId,
										BD.MaterialCode, 
										BD.BomVersion, 
										BD.ChildMaterialCode, 
										BD.ChildBomVersion,
										MaterialName,
										isnull(BD.BomUnit,MaterialUnit) as BomUnit,
										sv.BomUnit AS ParentBomHeaderUnit,
										sv.InputLineCode,
										(
											SELECT
													BH.BomUnit
											FROM
													STB_BomHeader BH
											WHERE
													BH.MaterialCode = BD.ChildMaterialCode AND
													BH.BomVersion = BD.ChildBomVersion
										) AS BomHeaderUnit,
										MM.MaterialUnit,
										BD.UsedQty,
										CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty)) AS ParentBomHeaderUnitUsedQty,					
										CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty * sv.ProdQty)) AS ParentBomHeaderUnitTotalQty,
										CONVERT(NUMERIC(38,19), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, MM.MaterialUnit,SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty))) AS MaterialUnitUsedQty,
										CONVERT(NUMERIC(20,5), SmartFramework.dbo.fnConvertUnit(BD.BomUnit, MM.MaterialUnit,SmartFramework.dbo.fnConvertUnit(BD.BomUnit, sv.BomUnit,BD.UsedQty * sv.ProdQty))) AS MaterialUnitTotalQty,
										CONVERT(NUMERIC(20,5),BD.UsedQty * sv.ProdQty) as TotalNvlTToQty,
										BD.RouteCode,
										BD.IsOptionItem,
										CONVERT(BIT, 1) AS IsUseOption,
										CASE 
											WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1
											ELSE 0
										END AS IsParentUseProduction,
										CASE 
											WHEN ISNULL(MM.IsProdPlan,0) = 1 OR ISNULL(MM.IsPurchase,0) = 1 THEN  1
											ELSE 0
										END AS IsUseProduction,
										MM.IsPurchase,
										MM.IsOrder,
										MM.IsProdPlan,
										ISNULL(MM.RequestGrDay,0) AS RequestGrDay,
										ISNULL(MM.RequestGrDay,0) AS TotalGrDay
								FROM
										STB_BomDetail BD
										INNER JOIN STB_MaterialMaster MM
											ON	MM.MaterialCode = BD.ChildMaterialCode
										inner join selectversion sv on BD.MaterialCode = sv.MaterialCode 
								WHERE
										BD.MaterialCode = sv.MaterialCode AND
										BD.BomVersion = sv.BomVersion
										AND sv.RouteCode like '%'+BD.RouteCode+'%' -- do sv.RouteCode V-24_Bg nên trong BD.RouteCode chỉ có V-24.. thì cần sử dụng like thay vì so sánh =
		
							)
							,ket as( -- tổng số lượng nvl gộp theo nhiều điều kiện group by
						 select InputLineCode,MaterialName,BomVersion,ChildMaterialCode,BomUnit,MaterialUnit,UsedQty,ParentBomHeaderUnitUsedQty,SUM(ParentBomHeaderUnitTotalQty) as ParentBomHeaderUnitTotalQty,
						   MaterialUnitUsedQty, SUM(MaterialUnitTotalQty) as MaterialUnitTotalQty,
	   						 SUM(TotalNvlTToQty) as TotalNvlTToQty
						   from BomCTE
						   group by InputLineCode,MaterialName,BomVersion,ChildMaterialCode,BomUnit,MaterialUnit,UsedQty,ParentBomHeaderUnitUsedQty,
						   MaterialUnitUsedQty
						   ),
						   totalQty as ( -- tổng số lượng nvl đã dùng cho hàng theo nhiều điều kiện group by
								select InputLineCode,MaterialName,BomVersion,BomUnit/*,UsedQty*/,ChildMaterialCode , SUM(MaterialUnitTotalQty) as MaterialUnitTotalQty,SUM(TotalNvlTToQty) as TotalNvlTToQty from ket 
								group by InputLineCode,MaterialName,BomVersion,BomUnit,ChildMaterialCode--,UsedQty
						   ),
						  total1 as (
							SELECT k.InputLineCode,k.MaterialName,k.ChildMaterialCode 
							--,isnull(max(tdk.InventoryNvl),0) as InventoryNvl
							,isnull(max(Tongsoluongxuat),0) as TongsoluongxuatTrongThang
							,isnull(max(Nhaplaitusx),0) as NhaplaitusxtrongThang
							,isnull(max(ip.PickingAssignQty),0) as NhaplaitusxtrongThang1
							,isnull(max(k.TotalNvlTToQty),0) as TotalNvlTToQty 
							,isnull(max(bp.Weights),0) as baophe,
						   --(COALESCE(max(tdk.InventoryNvl),0) + COALESCE(max(Tongsoluongxuat),0) - COALESCE(max(Nhaplaitusx),0)- COALESCE(max(ip.PickingAssignQty),0) -COALESCE(max(k.TotalNvlTToQty),0) - COALESCE(max(bp.Weights),0))	as tontrenline,
						   
						   k.BomUnit
						   FROM totalQty k left outer join table3 tb3
						   on tb3.LineCode = k.InputLineCode and k.ChildMaterialCode = tb3.MaterialCode
						   left outer join importedproduction ip on ip.MaterialCode =  k.ChildMaterialCode and ip.Line = k.InputLineCode
						   --left outer join tondauky tdk on tdk.InputLineCode = k.InputLineCode and k.ChildMaterialCode = tdk.ChildMaterialCode
						   left outer join baophenvl bp on k.InputLineCode = bp.LINENAME and k.ChildMaterialCode = bp.MaLotNguyenLieu
						   where
						   1=1
						   --and k.InputLineCode='VVC-01' 
						   --and ChildMaterialCode='GBAKAC-039' 
						   group by k.InputLineCode,k.MaterialName,k.ChildMaterialCode,  k.BomUnit
						   --order by k.ChildMaterialCode desc
						   ),
						   total2 as(
						   select isnull(tdk.InputLineCode,tt1.InputLineCode) as InputLineCode,isnull(tdk.MaterialName,tt1.MaterialName) as MaterialName,isnull(tdk.ChildMaterialCode,tt1.ChildMaterialCode) as ChildMaterialCode
						   ,isnull(max(tdk.InventoryNvl),0) as InventoryNvl
						   ,isnull(max(TongsoluongxuatTrongThang),0) as TongsoluongxuatTrongThang
							,isnull(max(NhaplaitusxtrongThang),0) as NhaplaitusxtrongThang
							,isnull(max(NhaplaitusxtrongThang1),0) as NhaplaitusxtrongThang1
							,isnull(max(TotalNvlTToQty),0) as TotalNvlTToQty 
							,isnull(max(baophe),0) as baophe
							,(COALESCE(max(tdk.InventoryNvl),0) + COALESCE(max(TongsoluongxuatTrongThang),0) - COALESCE(max(NhaplaitusxtrongThang),0)- COALESCE(max(NhaplaitusxtrongThang1),0) -COALESCE(max(TotalNvlTToQty),0) - COALESCE(max(baophe),0))	as tontrenline
							, isnull(tt1.BomUnit,tdk.BomUnit) as BomUnit
							from total1 tt1
						   full join tondauky tdk on tdk.InputLineCode = tt1.InputLineCode and tt1.ChildMaterialCode = tdk.ChildMaterialCode
						    where
						   1=1
						   group by tdk.InputLineCode,tdk.MaterialName,tt1.InputLineCode,tt1.MaterialName,tdk.ChildMaterialCode,tt1.ChildMaterialCode,tt1.BomUnit,tdk.BomUnit
						 --  order by ChildMaterialCode desc
						   )

						   select * from total2 order by InputLineCode desc
						   /*
						   insert into Stb_InventoryUpLine(InputLineCode,MaterialName,ChildMaterialCode,BomUnit,InventoryNvl, Months, Years,CreateDate,WorkCenterCode)
						   	SELECT k.InputLineCode,k.MaterialName,k.ChildMaterialCode, k.BomUnit,
							CONVERT(NUMERIC(20,5),(COALESCE(max(tdk.InventoryNvl),0) + COALESCE(max(Tongsoluongxuat),0) - COALESCE(max(Nhaplaitusx),0) -COALESCE(max(k.TotalNvlTToQty),0) - COALESCE(max(bp.Weights),0)))
						  ,@monthadd,@yearadd,GETDATE(),k.WorkCenterCode
						   FROM totalQty k left outer join table3 tb3
						   on tb3.LineCode = k.InputLineCode and k.ChildMaterialCode = tb3.MaterialCode
						   left outer join tondauky tdk on tdk.InputLineCode = k.InputLineCode and k.ChildMaterialCode = tdk.ChildMaterialCode
						   left outer join baophenvl bp on k.InputLineCode = bp.LINENAME and k.ChildMaterialCode = bp.MaLotNguyenLieu
						   where
						   1=1
						   --and tdk.InputLineCode='VVC-12' 
						   --and ChildMaterialCode='GBAKAC-039' 
						   group by k.InputLineCode,k.MaterialName,k.ChildMaterialCode,  k.BomUnit,k.WorkCenterCode
						   order by ChildMaterialCode desc
						   */

	end
	else
	begin
		RAISERROR('Đã tồn tại dữ liệu ! .....',16,1)
	end
END
