-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-09-16
-- Description:	Tính nvl sử dụng và tồn của F512. Đây là của hàng cell riêng
-- =============================================
-- exec usp_UseMaterialAndInventoryF512 '2024-01-11'
CREATE PROCEDURE [dbo].[usp_UseMaterialAndInventoryF512]
	@pDate date = NULL
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

	/*
			Biến cho lấy dữ liệu đã nhập kho thành phẩm hay chưa 

	*/

	declare @daten date = DATEADD(day,-1,@outFromDateTotalQtyProduct),
		@pFromDate date=@outFromDateTotalQtyProduct,
	@pToDate date = @outToDateTotalQtyProduct

	--End
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
					totalNG as ( --tính tổng số hàng Ng từ công đoạn 25 trở lên
					select MaterialCode,isnull(sum(DefectQty),0) as TotalNGDefectQty from selectversion where (RouteCode>'V-25' or RouteCode>='V-25_BG')
					group by MaterialCode
					),
					totalOK as ( --tính tổng số hàng OK của ngoại quan(để tính hàng thành phẩm và bán thành phẩm)
					select MaterialCode,isnull(ProdQty,0) as TotalOKProdQty from selectversion where RouteCode in ('V-27','V-27_BG')
					)
					,
					 BomCTE AS --Tính toán số lượng nvl đã sử dụng
							(
								SELECT					
										CONVERT(VARCHAR,ROW_NUMBER() OVER(ORDER BY BD.MaterialCode)) AS Id,
										--CONVERT(VARCHAR,NULL) AS ParentId,
										BD.MaterialCode,
											--MM.MaterialName,
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
										
										sv.RouteCode,
										MM2.MaterialName as MaterialName1,
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
										sv.ProdQty as TotalProdQty , -- Số lượng hàng đầu vào qua các công đoạn
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
										as TotalNvlTToQty, --Tổng số nvl cần dùng khi qua công đoạn
										
-- exec usp_UseMaterialAndInventoryF512 '2024-09-16'
											(sv.ProdQty - sv.DefectQty) as TotalOK , -- Số hàng ok để tính nvl
										CONVERT(NUMERIC(20,15),
										CONVERT(NUMERIC(10,5),isnull(BD.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b2.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b3.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b4.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b5.UsedQty,1)))	
										*(sv.ProdQty - sv.DefectQty) as TotalNvlTToOK, -- Số nvl cần dùng để làm hàng ok
										
										sv.DefectQty as TotalDefect, -- Số hàng NG để tính nvl

										CONVERT(NUMERIC(20,15),
										CONVERT(NUMERIC(10,5),isnull(BD.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b2.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b3.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b4.UsedQty,1))
										*CONVERT(NUMERIC(10,5),isnull(b5.UsedQty,1)))	
										*sv.DefectQty
										 as TotalNvlTToDefect, --Số nvl cần dùng để làm hàng NG
										MM.ProductGroupCode,
										isnull(TNG.TotalNGDefectQty,0) as TotalNGDefectQty -- Số hàng bị NG sau khi qua công đoạn 25
								FROM
										STB_BomDetail BD
										left outer join stb_BomDetail b2  on b2.MaterialCode=BD.ChildMaterialCode and b2.MaterialCode<>b2.ChildMaterialCode  and  (b2.BomVersion='99' )
										left outer join stb_BomDetail b3  on b3.MaterialCode=b2.ChildMaterialCode and b3.MaterialCode<>b3.ChildMaterialCode  and  (b3.BomVersion='99' )
										left outer join STB_BomDetail b4  on b4.MaterialCode=b3.ChildMaterialCode and b4.MaterialCode<>b4.ChildMaterialCode  and  (b4.BomVersion='99' )
										left outer join STB_BomDetail b5  on b5.MaterialCode=b4.ChildMaterialCode and b5.MaterialCode<>b5.ChildMaterialCode  and  (b5.BomVersion='99' )
										INNER JOIN STB_MaterialMaster MM2
											ON	MM2.MaterialCode = BD.MaterialCode

										INNER JOIN STB_MaterialMaster MM
											ON	MM.MaterialCode = BD.ChildMaterialCode
										INNER JOIN STB_MaterialMaster MMM
											ON	MMM.MaterialCode = coalesce(
									
											b5.ChildMaterialCode,
											b4.ChildMaterialCode,
											b3.ChildMaterialCode,
											b2.ChildMaterialCode,
											BD.ChildMaterialCode)

										right join selectversion sv on BD.MaterialCode = sv.MaterialCode 
										left join totalNG TNG on Tng.MaterialCode = BD.MaterialCode
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
										AND ( /*BD.RouteCode is null or*/ sv.RouteCode like '%'+BD.RouteCode+'%' )-- do sv.RouteCode V-24_Bg nên trong BD.RouteCode chỉ có V-24.. thì cần sử dụng like thay vì so sánh =
					 ),
					 getProductImportExportFinshGods as (
						 select * from 	
							(select AA.PublicCode,AA.MaterialCode,AA.PartNo,'PCS' as materialunit,
							case  when @pFromDate = '2022-01-01' then COALESCE(max(openninginventory),0)
								 when  @pFromDate > '2022-01-01'  then COALESCE(max(openninginventory),0) + COALESCE(sum(NhapDauKy1),0) - COALESCE(sum(XuatBanDauKy1),0) - COALESCE(sum(XuatSanXuatDauKy1),0) - COALESCE(sum(XuatTieuHuyDauKy1),0) - COALESCE(sum(XuatTraLaiDauKy1),0) - COALESCE(sum(XuatKhacDauKy1),0) 
								 else COALESCE(sum(NhapDauKy),0) - COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) end
								 as TonDauKy,
							
							
							--COALESCE(sum(NhapDauKy),0) - COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) as TonDauKy,
							COALESCE(sum(QtyInput),0) as NhapTrongKy,
							COALESCE(sum(XuatBan),0) as XuatBan,
							COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
							COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
							COALESCE(sum(XuatTraLai),0) as XuatTraLai,
							COALESCE(sum(XuatKhac),0) as XuatKhac,
							case  when @pFromDate = '2022-01-01' then COALESCE(max(openninginventory),0) + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0)
								 when  @pFromDate > '2022-01-01'  then COALESCE(max(openninginventory),0) + COALESCE(sum(NhapDauKy1),0) - COALESCE(sum(XuatBanDauKy1),0) - COALESCE(sum(XuatSanXuatDauKy1),0) - COALESCE(sum(XuatTieuHuyDauKy1),0) - COALESCE(sum(XuatTraLaiDauKy1),0) - COALESCE(sum(XuatKhacDauKy1),0) + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0)
								 else COALESCE(sum(NhapDauKy),0) - COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0)
								 end
								 as TonCuoiKy

							--COALESCE(sum(NhapDauKy),0)- COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0)  + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0) as TonCuoiKy
							from
							(select a.PublicCode,a.MaterialCode, a.PartNo,'PCS' as materialunit, max(a6.openninginventory) as openninginventory,
							case when  convert(date,createdate)  < @pFromDate and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as NhapDauKy,
							case when convert(date,DateExport)   < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBanDauKy,
							case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuatDauKy,
							case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuyDauKy,
							case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLaiDauKy,
							case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhacDauKy,
							case when convert(date,createdate)  between '2022-01-01' and @daten and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as NhapDauKy1,
							case when convert(date,DateExport)  between '2022-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBanDauKy1,
							case when convert(date,DateExport)  between '2022-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuatDauKy1,
							case when convert(date,DateExport)  between '2022-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuyDauKy1,
							case when convert(date,DateExport)  between '2022-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLaiDauKy1,
							case when convert(date,DateExport)  between '2022-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhacDauKy1,

							--case when DateExport < @pFromDate  and statusOut=N'Xuất' and TYPEEXPORT in ('XBND','XCDMDSD') then (PackQty) end as XuatNoiDiaDauKy,
							--case when DateExport < @pFromDate and statusOut=N'Xuất' and TYPEEXPORT in ('XKH') then (PackQty) end as XuatKhauDauKy,
							--case when DateExport < @pFromDate and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end  as XuatKhacDauKy,
							case when convert(date,createdate) between @pFromDate and @pToDate and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as QtyInput,
							case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBan,
							case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuat,
							case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuy,
							case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLai,
							case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhac
							--case when DateExport between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XBND','XCDMDSD') then (PackQty) end as XuatNoiDia,
							--case when DateExport between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XKH') then (PackQty) end as XuatKhau,
							--case when DateExport between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhac
							from STB_VN_FINISHGOODS a
							--left join STB_MaterialMaster b
							--ON a.materialcode = b.materialcode 
							left join (select materialcode, openninginventory from Stb_InventoryProductLiquidation FIM with (nolock))
							A6 on a.PublicCode = A6.MaterialCode
							where 1=1
							--loaihinhtokhai='E62'
							group by  ID,PublicCode,a.MaterialCode,PartNo, CreateDate, StatusSystem,DateExport,TYPEEXPORT,Statusout,packqty, Flag) AA

							group by AA.PublicCode,AA.MaterialCode,AA.PartNo
							--order by AA.materialcode
							) BB
							where (tondauky > 0 or nhaptrongky > 0 or xuatban > 0 or xuatsanxuat > 0 or xuattralai > 0 or xuattieuhuy > 0 or xuatkhac > 0 )

					 ),
					 getBOMandProductImportExportFinshGods as (
					  select BCTE.*,GPIEF.PublicCode,GPIEF.TonDauKy,GPIEF.NhapTrongKy,GPIEF.XuatBan,GPIEF.XuatSanXuat,GPIEF.XuatTieuHuy,
					  GPIEF.XuatTraLai/*,GPIEF.XuatNoiDia,GPIEF.XuatKhau*/,GPIEF.XuatKhac,GPIEF.TonCuoiKy
					  from BomCTE BCTE
					  inner join getProductImportExportFinshGods GPIEF on BCTE.MaterialCode = GPIEF.MaterialCode
					 )
				 -- select * from RawView where materialcode='ECVT30-215'
				  select * from getBOMandProductImportExportFinshGods --where materialcode='ECVT30-215'

				-- exec  usp_InventoryMaterialF512New '2024-11-11'
		--	select * from STB_VN_FINISHGOODS where MaterialCode='ECVT30-270'
		-- exec usp_UseMaterialAndInventoryF512 '2024-10-10'
  
END
