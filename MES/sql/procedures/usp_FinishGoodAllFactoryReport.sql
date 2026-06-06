-- =============================================
-- Author:		Nguyễn Hải Triều(Mr.Dev)
-- Create date: 2026-04-21
-- Description:	Tổng hợp tồn kho thành phẩm cho nhà máy Bắc Ninh và Bắc giang 1
-- exec usp_FinishGoodAllFactoryReport '2026-05-01','2026-05-25'
-- =============================================
-- vanduc 2026-06-05: Thêm 2 cột giá tiền tồn cuối kỳ và giá tiền trên 1 năm dựa trên đơn giá từ màn B943 (join qua mã kế toán ItemCodeVN và fallback ItemCodeKorea)
CREATE PROCEDURE [dbo].[usp_FinishGoodAllFactoryReport] 
	@pFromDate date = NULL,
	@pToDate date = NULL
AS
BEGIN
	SET NOCOUNT ON;
	-- Khai báo ngày tìm kiếm mặc định sẽ là lùi lại 1 ngày
	DECLARE @daten date = DATEADD(day, -1, @pFromDate)

SELECT 
	FinalReport.PublicCode, 
	FinalReport.PartNo, 
	FinalReport.Model, 
	FinalReport.MaterialCode, 
	FinalReport.materialunit,
	FinalReport.TonDauKy,
	FinalReport.NhapTrongKy,
	FinalReport.XuatBan,
	FinalReport.XuatSanXuat,
	FinalReport.XuatTieuHuy,
	FinalReport.XuatTraLai,
	FinalReport.XuatKhac,
	FinalReport.TonCuoiKy,
	FinalReport.TonTren1Nam,
	COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DonGia,
	FinalReport.TonCuoiKy * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS GiaTienTonCuoiKy,
	FinalReport.TonTren1Nam * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS GiaTienTon1Nam
FROM (
	SELECT 
			TotalReport.PublicCode, 
			TotalReport.PartNo, 
			TotalReport.Model, 
			TotalReport.MaterialCode, 
			TotalReport.materialunit,
			SUM(TotalReport.TonDauKy) AS TonDauKy,
			SUM(TotalReport.NhapTrongKy) AS NhapTrongKy,
			SUM(TotalReport.XuatBan) AS XuatBan,
			SUM(TotalReport.XuatSanXuat) AS XuatSanXuat,
			SUM(TotalReport.XuatTieuHuy) AS XuatTieuHuy,
			SUM(TotalReport.XuatTraLai) AS XuatTraLai,
			SUM(TotalReport.XuatKhac) AS XuatKhac,
			SUM(TotalReport.TonCuoiKy) AS TonCuoiKy,
			SUM(TotalReport.TonTren1Nam) AS TonTren1Nam
		FROM 
		(
			SELECT * FROM 	
			(
				SELECT AA.PublicCode, AA.PartNo, AA.Model, AA.MaterialCode, 'PCS' AS materialunit,
				CASE
					WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0)
					WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0)
					ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0)
				END AS TonDauKy,
				COALESCE(SUM(QtyInput), 0)      AS NhapTrongKy,
				COALESCE(SUM(XuatBan), 0)       AS XuatBan,
				COALESCE(SUM(XuatSanXuat), 0)   AS XuatSanXuat,
				COALESCE(SUM(XuatTieuHuy), 0)   AS XuatTieuHuy,
				COALESCE(SUM(XuatTraLai), 0)    AS XuatTraLai,
				COALESCE(SUM(XuatKhac), 0)      AS XuatKhac,
				CASE
					WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatKhac), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				END AS TonCuoiKy,
				CASE 
				WHEN 
					(CASE
						WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai) , 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatKhac), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					END) - COALESCE(SUM(NhapTrongVong1Nam), 0) > 0 
				THEN 
					(CASE
						WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatKhac), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					END) - COALESCE(SUM(NhapTrongVong1Nam), 0)
				ELSE 0 
			END AS TonTren1Nam
				FROM
				(
					SELECT a.PublicCode, a.PartNo,
						   MAX(MC.MaterialCode)      AS MaterialCode,
						   M.Model,
						   'PCS'                     AS materialunit,
						   MAX(A6.openninginventory) AS openninginventory,
						   CASE WHEN CONVERT(date, createdate)  < @pFromDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy,
						   CASE WHEN CONVERT(date, createdate) >= DATEADD(YEAR, -1, GETDATE()) AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapTrongVong1Nam,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB')  THEN PackQty END AS XuatBanDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK')  THEN PackQty END AS XuatKhacDauKy,
						   CASE WHEN CONVERT(date, createdate)  BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB')  THEN PackQty END AS XuatBanDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK')  THEN PackQty END AS XuatKhacDauKy1,
						   CASE WHEN CONVERT(date, createdate)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS QtyInput,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB')  THEN PackQty END AS XuatBan,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuat,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuy,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLai,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK')  THEN PackQty END AS XuatKhac
					FROM STB_VN_FINISHGOODS a
					LEFT JOIN (
						SELECT PublicCode, MAX(NULLIF(MaterialCode, '')) AS MaterialCode
						FROM STB_VN_FINISHGOODS
						WHERE MaterialCode IS NOT NULL AND MaterialCode <> ''
						GROUP BY PublicCode
					) MC ON a.PublicCode = MC.PublicCode
					LEFT JOIN (
						SELECT materialcode, openninginventory
						FROM Stb_InventoryProductLiquidation WITH (NOLOCK) 
						WHERE WorkCenterCode = 'VVT_F1'
					) A6 ON a.PublicCode = A6.MaterialCode
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
					WHERE 1 = 1
					GROUP BY ID, a.PublicCode, a.PartNo, M.Model, CreateDate, StatusSystem, DateExport, TYPEEXPORT, Statusout, PackQty, Flag
				) AA
				GROUP BY AA.PublicCode, AA.PartNo, AA.Model, AA.MaterialCode
			) BB
			WHERE (tondauky > 0 OR nhaptrongky > 0 OR xuatban > 0 OR xuatsanxuat > 0 OR xuattralai > 0 OR xuattieuhuy > 0 OR xuatkhac > 0)

			UNION ALL

			SELECT * FROM 	
			(
				SELECT AA.PublicCode, AA.PartNo, AA.Model, AA.MaterialCode, 'PCS' AS materialunit,
				CASE
					WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0)
					WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0)
					ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0)
				END AS TonDauKy,
				COALESCE(SUM(QtyInput), 0)      AS NhapTrongKy,
				COALESCE(SUM(XuatBan), 0)       AS XuatBan,
				COALESCE(SUM(XuatSanXuat), 0)   AS XuatSanXuat,
				COALESCE(SUM(XuatTieuHuy), 0)   AS XuatTieuHuy,
				COALESCE(SUM(XuatTraLai), 0)    AS XuatTraLai,
				COALESCE(SUM(XuatKhac), 0)      AS XuatKhac,
				CASE
					WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatKhac), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				END AS TonCuoiKy,
				CASE 
				WHEN 
					(CASE
						WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatKhac), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					END) - COALESCE(SUM(NhapTrongVong1Nam), 0) > 0 
				THEN 
					(CASE
						WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
						ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatKhac), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
					END) - COALESCE(SUM(NhapTrongVong1Nam), 0)
				ELSE 0 
			END AS TonTren1Nam
				FROM
				(
					SELECT a.PublicCode, a.PartNo,
						   MAX(MC.MaterialCode)      AS MaterialCode,
						   M.Model,
						   'PCS'                     AS materialunit,
						   MAX(A6.openninginventory) AS openninginventory,
						   CASE WHEN CONVERT(date, createdate)  < @pFromDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy,
						   CASE WHEN CONVERT(date, createdate) >= DATEADD(YEAR, -1, GETDATE()) AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapTrongVong1Nam,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB')  THEN PackQty END AS XuatBanDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy,
						   CASE WHEN CONVERT(date, DateExport)  < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK')  THEN PackQty END AS XuatKhacDauKy,
						   CASE WHEN CONVERT(date, createdate)  BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB')  THEN PackQty END AS XuatBanDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy1,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK')  THEN PackQty END AS XuatKhacDauKy1,
						   CASE WHEN CONVERT(date, createdate)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS QtyInput,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB')  THEN PackQty END AS XuatBan,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuat,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuy,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLai,
						   CASE WHEN CONVERT(date, DateExport)  BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK')  THEN PackQty END AS XuatKhac
					FROM STB_VN_FINISHGOODS_BG a
					LEFT JOIN (
						SELECT PublicCode, MAX(NULLIF(MaterialCode, '')) AS MaterialCode
						FROM STB_VN_FINISHGOODS_BG
						WHERE MaterialCode IS NOT NULL AND MaterialCode <> ''
						GROUP BY PublicCode
					) MC ON a.PublicCode = MC.PublicCode
					LEFT JOIN (
						SELECT materialcode, openninginventory
						FROM Stb_InventoryProductLiquidation WITH (NOLOCK)
						WHERE WorkCenterCode = 'VVT_F2'
					) A6 ON a.PublicCode = A6.MaterialCode
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
					WHERE 1 = 1
					GROUP BY ID, a.PublicCode, a.PartNo, M.Model, CreateDate, StatusSystem, DateExport, TYPEEXPORT, Statusout, PackQty, Flag
				) AA
				GROUP BY AA.PublicCode, AA.PartNo, AA.Model, AA.MaterialCode
			) BB
			WHERE (tondauky > 0 OR nhaptrongky > 0 OR xuatban > 0 OR xuatsanxuat > 0 OR xuattralai > 0 OR xuattieuhuy > 0 OR xuatkhac > 0)
		) AS TotalReport
		GROUP BY 
			TotalReport.PublicCode, 
			TotalReport.PartNo, 
			TotalReport.Model, 
			TotalReport.MaterialCode, 
			TotalReport.materialunit
) AS FinalReport
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
END
