-- ==============================================================================
-- SCRIPT CẬP NHẬT STORED PROCEDURE: usp_FinishGoodReportTK
-- MÀN HÌNH: [FG02] Tổng hợp kho thành phẩm Bắc Ninh & [F512] VietNamMaterialCustomReport
-- LỊCH SỬ THAY ĐỔI: vanduc edit 2026-08-14
-- ĐỐI CHIẾU NGUYÊN VĂN TỪ BACKUP GỐC: [sql/procedures/usp_FinishGoodReportTK.sql](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/sql/procedures/usp_FinishGoodReportTK.sql)
-- TIÊU CHUẨN TRÌNH BÀY MÃ NGUỒN:
--   1. Bảo toàn 100% tất cả dòng code gốc (kể cả các dòng comment gốc cũ).
--   2. Đoạn code cũ bị thay thế được BỌC NGUYÊN KHỐI trong /* vanduc edit 2026-08-14 [CODE CŨ BẢO LƯU GỐC TỪ usp_FinishGoodReportTK.sql]: ... */
--   3. Đoạn code mới bổ sung được BỌC TRONG -- START: vanduc edit 2026-08-14 - [Mô tả] ... -- END: vanduc edit 2026-08-14
--   4. Đảm bảo 100% Tiếng Việt có dấu, không lỗi font mã hóa UTF-8.
-- ==============================================================================

USE [SmartFactoryV2]
GO

IF OBJECT_ID('dbo.usp_FinishGoodReportTK', 'P') IS NOT NULL
BEGIN
    PRINT 'Updating Stored Procedure [dbo].[usp_FinishGoodReportTK]...'
END
GO

ALTER PROCEDURE [dbo].[usp_FinishGoodReportTK]
	-- Add the parameters for the stored procedure here
	@pFromDate date=NULL,
	@pToDate date = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Stored procedure execution logic
				--select * from 	
				--(select AA.PublicCode,AA.PartNo,'PCS' as materialunit,
				--COALESCE(sum(NhapDauKy),0) - COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) as TonDauKy,
				--COALESCE(sum(QtyInput),0) as NhapTrongKy,
				--COALESCE(sum(XuatBan),0) as XuatBan,
				--COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
				--COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
				--COALESCE(sum(XuatTraLai),0) as XuatTraLai,
				--COALESCE(sum(XuatKhac),0) as XuatKhac,
				--COALESCE(sum(NhapDauKy),0)- COALESCE(sum(XuatBanDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatTraLaiDauKy),0) - COALESCE(sum(XuatKhacDauKy),0)  + COALESCE(sum(QtyInput),0) - COALESCE(sum(XuatBan),0) - COALESCE(sum(XuatTieuHuy),0) - COALESCE(sum(XuatTraLai),0) - COALESCE(sum(XuatSanXuat),0)  - COALESCE(sum(XuatKhac),0) as TonCuoiKy
				--from
				--(select a.PublicCode, a.PartNo,'PCS' as materialunit,
				--case when  convert(date,createdate)  < @pFromDate and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as NhapDauKy,
				--case when convert(date,DateExport)   < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBanDauKy,
				--case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuatDauKy,
				--case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuyDauKy,
				--case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLaiDauKy,
				--case when convert(date,DateExport) < @pFromDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhacDauKy,
				--case when convert(date,createdate) between @pFromDate and @pToDate and Flag =1 and statusSystem=N'Nhập' then (PackQty) end as QtyInput,
				--case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBan,
				--case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuat,
				--case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuy,
				--case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLai,
				--case when convert(date,DateExport) between @pFromDate and @pToDate and Flag =1 and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhac
				--from STB_VN_FINISHGOODS a
				--where 1=1
				----loaihinhtokhai='E62'
				--group by  PublicCode,PartNo, CreateDate, StatusSystem,DateExport,TYPEEXPORT,Statusout,packqty, Flag) AA

				--group by AA.PublicCode,AA.PartNo
				--) BB
			 --   where (tondauky > 0 or nhaptrongky > 0 or xuatban > 0 or xuatsanxuat > 0 or xuattralai > 0 or xuattieuhuy > 0 or xuatkhac > 0 )

declare @daten date = DATEADD(day,-1,@pFromDate)

--,@df varchar(50)=@pToDate
--RAISERROR(@df, 16, 1)

/* vanduc edit 2026-08-14 [CODE CŨ BẢO LƯU GỐC TỪ usp_FinishGoodReportTK.sql]:
select * from 	
				(select AA.PublicCode,AA.PartNo,'PCS' as materialunit,
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
				(select a.PublicCode, a.PartNo,'PCS' as materialunit, max(a6.openninginventory) as openninginventory,
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
				case when convert(date,DateExport) between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XB') then (PackQty) end as XuatBan,
				case when convert(date,DateExport) between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XSX') then (PackQty) end as XuatSanXuat,
				case when convert(date,DateExport) between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XTH') then (PackQty) end as XuatTieuHuy,
				case when convert(date,DateExport) between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XTL') then (PackQty) end as XuatTraLai,
				case when convert(date,DateExport) between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhac
				--case when DateExport between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XBND','XCDMDSD') then (PackQty) end as XuatNoiDia,
				--case when DateExport between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XKH') then (PackQty) end as XuatKhau,
				--case when DateExport between @pFromDate and @pToDate and statusOut=N'Xuất' and TYPEEXPORT in ('XK') then (PackQty) end as XuatKhac
				from STB_VN_FINISHGOODS a
				--left join STB_MaterialMaster b
				--ON a.materialcode = b.materialcode 
				left join (select materialcode, openninginventory from 
				Stb_InventoryProductLiquidation FIM with (nolock) where FIM.WorkCenterCode ='VVT_F1') A6 on a.PublicCode = A6.MaterialCode
				where 1=1
				
				--loaihinhtokhai='E62'
				group by  ID,PublicCode,PartNo, CreateDate, StatusSystem,DateExport,TYPEEXPORT,Statusout,packqty, Flag) AA

				group by AA.PublicCode,AA.PartNo
				--order by AA.materialcode
				) BB
			    where (tondauky > 0 or nhaptrongky > 0 or xuatban > 0 or xuatsanxuat > 0 or xuattralai > 0 or xuattieuhuy > 0 or xuatkhac > 0 )
*/

-- START: vanduc edit 2026-08-14 - Toàn bộ phần câu lệnh SELECT mới cập nhật bổ sung Model, UnitPrice và 6 cột tuổi tồn kho
    SELECT 
        FinalReport.PublicCode,
        FinalReport.PartNo,

        -- START: vanduc edit 2026-08-14 - Bổ sung 2 cột Model và UnitPrice chèn mới giữa PartNo và materialunit (Đồng bộ 100% theo màn FG20)
        FinalReport.Model,
        COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS UnitPrice,
        -- END: vanduc edit 2026-08-14 - Bổ sung cột Model và UnitPrice

        FinalReport.materialunit,
        FinalReport.TonDauKy,
        FinalReport.NhapTrongKy,
        FinalReport.XuatBan,
        FinalReport.XuatSanXuat,
        FinalReport.XuatTieuHuy,
        FinalReport.XuatTraLai,
        FinalReport.XuatKhac,
        FinalReport.TonCuoiKy,

        -- START: vanduc edit 2026-08-14 - Bổ sung 6 cột tuổi tồn kho: SL >3M, >6M, >1Y và Thành tiền tương ứng
        FinalReport.QtyOver3M,
        FinalReport.QtyOver6M,
        FinalReport.QtyOver1Y,
        CAST(FinalReport.QtyOver3M * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver3M,
        CAST(FinalReport.QtyOver6M * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver6M,
        CAST(FinalReport.QtyOver1Y * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver1Y
        -- END: vanduc edit 2026-08-14 - Bổ sung 6 cột tuổi tồn kho & thành tiền

    FROM (
        SELECT 
            AA.PublicCode,
            AA.PartNo,
            AA.Model,
            AA.MaterialCode,
            'PCS' AS materialunit,

            CASE 
                WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0)
                WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0)
                ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0)
            END AS TonDauKy,

            COALESCE(SUM(QtyInput), 0) AS NhapTrongKy,
            COALESCE(SUM(XuatBan), 0) AS XuatBan,
            COALESCE(SUM(XuatSanXuat), 0) AS XuatSanXuat,
            COALESCE(SUM(XuatTieuHuy), 0) AS XuatTieuHuy,
            COALESCE(SUM(XuatTraLai), 0) AS XuatTraLai,
            COALESCE(SUM(XuatKhac), 0) AS XuatKhac,

            CASE 
                WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
                WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
                ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
            END AS TonCuoiKy,

            -- START: vanduc edit 2026-08-14 - Gom nhóm tổng số lượng tồn kho theo tuổi tồn 3M, 6M, 1Y
            COALESCE(SUM(QtyOver3M), 0) AS QtyOver3M,
            COALESCE(SUM(QtyOver6M), 0) AS QtyOver6M,
            COALESCE(SUM(QtyOver1Y), 0) AS QtyOver1Y
            -- END: vanduc edit 2026-08-14 - Gom nhóm tổng số lượng tuổi tồn kho

        FROM (
            SELECT 
                a.PublicCode, 
                a.PartNo,

                -- START: vanduc edit 2026-08-14 - Lấy MaterialCode và Model bổ sung
                MAX(MC.MaterialCode) AS MaterialCode,
                M.Model,
                MAX(a6.openninginventory) AS openninginventory,
                -- END: vanduc edit 2026-08-14 - Lấy MaterialCode và Model bổ sung

                CASE WHEN CONVERT(DATE, a.CreateDate) < @pFromDate AND a.Flag = 1 AND a.StatusSystem = N'Nhập' THEN a.PackQty END AS NhapDauKy,
                CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty END AS XuatBanDauKy,
                CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty END AS XuatSanXuatDauKy,
                CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty END AS XuatTieuHuyDauKy,
                CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty END AS XuatTraLaiDauKy,
                CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty END AS XuatKhacDauKy,

                CASE WHEN CONVERT(DATE, a.CreateDate) BETWEEN '2022-01-01' AND @daten AND a.Flag = 1 AND a.StatusSystem = N'Nhập' THEN a.PackQty END AS NhapDauKy1,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty END AS XuatBanDauKy1,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty END AS XuatSanXuatDauKy1,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty END AS XuatTieuHuyDauKy1,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty END AS XuatTraLaiDauKy1,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty END AS XuatKhacDauKy1,

                CASE WHEN CONVERT(DATE, a.CreateDate) BETWEEN @pFromDate AND @pToDate AND a.Flag = 1 AND a.StatusSystem = N'Nhập' THEN a.PackQty END AS QtyInput,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty END AS XuatBan,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty END AS XuatSanXuat,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty END AS XuatTieuHuy,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty END AS XuatTraLai,
                CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND a.Flag = 1 AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty END AS XuatKhac,

                -- START: vanduc edit 2026-08-14 - Phân loại tuổi tồn kho cho từng lô chưa xuất: >=90 ngày (3M), >=180 ngày (6M), >=365 ngày (1Y)
                CASE WHEN a.Flag = 1 AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, a.CreateDate), GETDATE()) >= 90  THEN a.PackQty ELSE 0 END AS QtyOver3M,
                CASE WHEN a.Flag = 1 AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, a.CreateDate), GETDATE()) >= 180 THEN a.PackQty ELSE 0 END AS QtyOver6M,
                CASE WHEN a.Flag = 1 AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, a.CreateDate), GETDATE()) >= 365 THEN a.PackQty ELSE 0 END AS QtyOver1Y
                -- END: vanduc edit 2026-08-14 - Phân loại tuổi tồn kho cho từng lô chưa xuất

            FROM STB_VN_FINISHGOODS a (NOLOCK)
            -- START: vanduc edit 2026-08-14 - LEFT JOIN lấy MaterialCode từ STB_VN_FINISHGOODS
            LEFT JOIN (
                SELECT PublicCode, MAX(NULLIF(MaterialCode, '')) AS MaterialCode
                FROM STB_VN_FINISHGOODS
                WHERE MaterialCode IS NOT NULL AND MaterialCode <> ''
                GROUP BY PublicCode
            ) MC ON a.PublicCode = MC.PublicCode
            -- END: vanduc edit 2026-08-14 - LEFT JOIN lấy MaterialCode
            LEFT JOIN (
                SELECT materialcode, openninginventory 
                FROM Stb_InventoryProductLiquidation FIM WITH (NOLOCK) 
                WHERE FIM.WorkCenterCode = 'VVT_F1'
            ) A6 ON a.PublicCode = A6.MaterialCode

            -- START: vanduc edit 2026-08-14 - Logic tách Model từ PartNo đồng bộ 100% theo màn FG20
            CROSS APPLY (
                SELECT CASE
                    WHEN a.PartNo = 'VEL10303R8107G-C035' THEN '1030'
                    WHEN a.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
                    WHEN a.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
                    WHEN a.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
                    WHEN a.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
                    WHEN CHARINDEX('(', a.PartNo) > 0 AND CHARINDEX(')', a.PartNo) > 0
                    THEN SUBSTRING(
                            a.PartNo,
                            LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2,
                            LEN(a.PartNo) - CHARINDEX(')', REVERSE(a.PartNo)) + 1
                            - (LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2)
                          )
                    ELSE NULL
                END AS Model
            ) M
            -- END: vanduc edit 2026-08-14 - Logic tách Model từ PartNo đồng bộ 100% theo màn FG20

            WHERE 1 = 1
            -- START: vanduc edit 2026-08-14 - GROUP BY chi tiết theo a.ID, a.PublicCode, a.PartNo, M.Model để tính chính xác tuổi tồn
            GROUP BY a.ID, a.PublicCode, a.PartNo, M.Model, a.CreateDate, a.StatusSystem, a.DateExport, a.TYPEEXPORT, a.Statusout, a.PackQty, a.Flag
            -- END: vanduc edit 2026-08-14 - GROUP BY chi tiết
        ) AA
        GROUP BY AA.PublicCode, AA.PartNo, AA.Model, AA.MaterialCode
    ) FinalReport

    -- START: vanduc edit 2026-08-14 - Logic lấy Đơn giá UnitPrice từ màn B943 (STB_InventoryOfGoodsReport) đồng bộ 100% theo FG20
    OUTER APPLY (
        SELECT TOP 1 UnitPrice
        FROM STB_InventoryOfGoodsReport
        WHERE ItemCodeVN = FinalReport.PublicCode
          AND ItemCodeVN IS NOT NULL AND ItemCodeVN <> ''
        ORDER BY ID DESC
    ) r
    OUTER APPLY (
        SELECT TOP 1 UnitPrice
        FROM STB_InventoryOfGoodsReport
        WHERE ItemCodeKorea = FinalReport.MaterialCode
          AND ItemCodeKorea IS NOT NULL AND ItemCodeKorea <> ''
          AND r.UnitPrice IS NULL
        ORDER BY ID DESC
    ) r_kr
    -- END: vanduc edit 2026-08-14 - Logic lấy Đơn giá UnitPrice

    WHERE (FinalReport.TonDauKy > 0 OR FinalReport.NhapTrongKy > 0 OR FinalReport.XuatBan > 0 OR FinalReport.XuatSanXuat > 0 OR FinalReport.XuatTraLai > 0 OR FinalReport.XuatTieuHuy > 0 OR FinalReport.XuatKhac > 0 OR FinalReport.TonCuoiKy > 0)
    ORDER BY FinalReport.PublicCode
-- END: vanduc edit 2026-08-14 - Toàn bộ phần câu lệnh SELECT mới cập nhật

				--select * from Stb_InventoryMaterialLiquidation where MaterialCode='153_REEL_TAPE'

END
GO

PRINT 'Stored Procedure [dbo].[usp_FinishGoodReportTK] updated successfully matching FG20.'
