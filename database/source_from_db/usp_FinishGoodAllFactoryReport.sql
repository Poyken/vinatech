-- =============================================
-- Author:		Nguyễn Hải Triều(Mr.Dev)
-- Create date: 2026-04-21
-- Description:	Tổng hợp tồn kho thành phẩm cho nhà máy Bắc Ninh và Bắc giang 1
-- exec usp_FinishGoodAllFactoryReport '2026-04-01','2026-04-21'
-- =============================================
CREATE PROCEDURE [dbo].[usp_FinishGoodAllFactoryReport] 
	-- Add the parameters for the stored procedure here
	@pFromDate date=NULL,
	@pToDate date = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  declare @daten date = DATEADD(day,-1,@pFromDate)

	-- Nhà máy Bắc Ninh
	select * from 	
				(select AA.PublicCode,AA.PartNo, AA.Model, 'PCS' as materialunit, -- THÊM MODEL Ở ĐÂY
				case  when @pFromDate = '2022-01-01' then COALESCE(max(openninginventory),0)
					 when  @pFromDate > '2022-01-01'  then COALESCE(max(openninginventory),0) + COALESCE(sum(NhapDauKy1),0) - COALESCE(sum(XuatBanDauKy1),0) - COALESCE(sum(XuatSanXuatDauKy1),0) - COALESCE(sum(XuatTieuHuyDauKy1),0) - COALESCE(sum(XuatTraLaiDauKy1),0) - COALESCE(sum(XuatKhacDauKy1),0)  
					 else COALESCE(sum(NhapDauKy),0) - COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) end
					 as TonDauKy,

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
				from
				(select a.PublicCode, a.PartNo, max(A6.Model) as Model, 'PCS' as materialunit, max(a6.openninginventory) as openninginventory, -- LẤY MODEL TỪ A6
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

				case when convert(date,createdate) between @pFromDate and @pToDate and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as QtyInput,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBan,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuat,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuy,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLai,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhac
				from STB_VN_FINISHGOODS a
				left join (select materialcode, openninginventory, Model from  -- THÊM MODEL VÀO SUBQUERY A6
				Stb_InventoryProductLiquidation FIM with (nolock) where FIM.WorkCenterCode ='VVT_F1') A6 on a.PublicCode = A6.MaterialCode
				where 1=1
				group by  ID,PublicCode,PartNo, CreateDate, StatusSystem,DateExport,TYPEEXPORT,Statusout,packqty, Flag) AA
				group by AA.PublicCode,AA.PartNo, AA.Model -- GROUP BY MODEL
				) BB
			    where (tondauky > 0 or nhaptrongky > 0 or xuatban > 0 or xuatsanxuat > 0 or xuattralai > 0 or xuattieuhuy > 0 or xuatkhac > 0 )

				UNION ALL

				-- Nhà máy Bắc Giang
				select * from 	
				(select AA.PublicCode,AA.PartNo, AA.Model, 'PCS' as materialunit, -- THÊM MODEL Ở ĐÂY
				case  when @pFromDate = '2025-01-01' then COALESCE(max(openninginventory),0)
					 when  @pFromDate > '2025-01-01'  then COALESCE(max(openninginventory),0) + COALESCE(sum(NhapDauKy1),0) - COALESCE(sum(XuatBanDauKy1),0) - COALESCE(sum(XuatSanXuatDauKy1),0) - COALESCE(sum(XuatTieuHuyDauKy1),0) - COALESCE(sum(XuatTraLaiDauKy1),0) - COALESCE(sum(XuatKhacDauKy1),0)  
					 else COALESCE(sum(NhapDauKy),0) - COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) end
					 as TonDauKy,

				COALESCE(sum(QtyInput),0) as NhapTrongKy,
				COALESCE(sum(XuatBan),0) as XuatBan,
				COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
				COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
				COALESCE(sum(XuatTraLai),0) as XuatTraLai,
				COALESCE(sum(XuatKhac),0) as XuatKhac,
				case  when @pFromDate = '2025-01-01' then COALESCE(max(openninginventory),0) + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0)
					 when  @pFromDate > '2025-01-01'  then COALESCE(max(openninginventory),0) + COALESCE(sum(NhapDauKy1),0) - COALESCE(sum(XuatBanDauKy1),0) - COALESCE(sum(XuatSanXuatDauKy1),0) - COALESCE(sum(XuatTieuHuyDauKy1),0) - COALESCE(sum(XuatTraLaiDauKy1),0) - COALESCE(sum(XuatKhacDauKy1),0) + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0)
					 else COALESCE(sum(NhapDauKy),0) - COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatKhac),0) + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0)
					 end
					 as TonCuoiKy
				from
				(select a.PublicCode, a.PartNo, max(A6.Model) as Model, 'PCS' as materialunit, max(a6.openninginventory) as openninginventory, -- LẤY MODEL TỪ A6
				case when  convert(date,createdate)  < @pFromDate and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as NhapDauKy,
				case when convert(date,DateExport)   < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBanDauKy,
				case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuatDauKy,
				case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuyDauKy,
				case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLaiDauKy,
				case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhacDauKy,
				case when convert(date,createdate)  between '2025-01-01' and @daten and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as NhapDauKy1,
				case when convert(date,DateExport)  between '2025-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBanDauKy1,
				case when convert(date,DateExport)  between '2025-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuatDauKy1,
				case when convert(date,DateExport)  between '2025-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuyDauKy1,
				case when convert(date,DateExport)  between '2025-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLaiDauKy1,
				case when convert(date,DateExport)  between '2025-01-01' and @daten and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhacDauKy1,

				case when convert(date,createdate) between @pFromDate and @pToDate and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as QtyInput,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBan,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuat,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuy,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLai,
				case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhac
				from STB_VN_FINISHGOODS_BG a
				left join (select materialcode, openninginventory, Model from  -- THÊM MODEL VÀO SUBQUERY A6
				Stb_InventoryProductLiquidation FIM with (nolock) where FIM.WorkCenterCode ='VVT_F2') A6 on a.PublicCode = A6.MaterialCode
				where 1=1
				group by  ID,PublicCode,PartNo, CreateDate, StatusSystem,DateExport,TYPEEXPORT,Statusout,packqty, Flag) AA
				group by AA.PublicCode,AA.PartNo, AA.Model -- GROUP BY MODEL
				) BB
			    where (tondauky > 0 or nhaptrongky > 0 or xuatban > 0 or xuatsanxuat > 0 or xuattralai > 0 or xuattieuhuy > 0 or xuatkhac > 0 )

END


