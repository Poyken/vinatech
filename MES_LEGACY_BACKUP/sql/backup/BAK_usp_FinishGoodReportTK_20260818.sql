-- ==============================================================================
-- FILE BACKUP NGUYÊN BẢN: usp_FinishGoodReportTK (Bắc Ninh)
-- NGÀY BACKUP: 2026-08-18
-- GHI CHÚ: Bản sao lưu gốc bảo tồn 100% mã nguồn trước khi cập nhật tính năng
--          tuổi tồn kho Hưng Yên & Ngày Tạo Lot.
-- ==============================================================================

USE [SmartFactoryV2]
GO

IF OBJECT_ID('dbo.usp_FinishGoodReportTK', 'P') IS NOT NULL
BEGIN
    PRINT 'Restoring Stored Procedure [dbo].[usp_FinishGoodReportTK] from backup...'
END
GO

ALTER PROCEDURE [dbo].[usp_FinishGoodReportTK]
	@pFromDate date=NULL,
	@pToDate date = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @daten date = DATEADD(day,-1,@pFromDate)

	SELECT * FROM 	
	(
		SELECT AA.PublicCode, AA.PartNo, 'PCS' AS materialunit,
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
		END AS TonCuoiKy

		FROM
		(
			SELECT a.PublicCode, a.PartNo, 'PCS' AS materialunit, MAX(a6.openninginventory) AS openninginventory,
			CASE WHEN CONVERT(date, createdate) < @pFromDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy,
			CASE WHEN CONVERT(date, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy,
			CASE WHEN CONVERT(date, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy,
			CASE WHEN CONVERT(date, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy,
			CASE WHEN CONVERT(date, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy,
			CASE WHEN CONVERT(date, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy,

			CASE WHEN CONVERT(date, createdate) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy1,
			CASE WHEN CONVERT(date, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy1,
			CASE WHEN CONVERT(date, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy1,
			CASE WHEN CONVERT(date, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy1,
			CASE WHEN CONVERT(date, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy1,
			CASE WHEN CONVERT(date, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy1,

			CASE WHEN CONVERT(date, createdate) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS QtyInput,
			CASE WHEN CONVERT(date, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBan,
			CASE WHEN CONVERT(date, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuat,
			CASE WHEN CONVERT(date, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuy,
			CASE WHEN CONVERT(date, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLai,
			CASE WHEN CONVERT(date, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhac

			FROM STB_VN_FINISHGOODS a
			LEFT JOIN (
				SELECT materialcode, openninginventory 
				FROM Stb_InventoryProductLiquidation FIM WITH (NOLOCK) 
				WHERE FIM.WorkCenterCode = 'VVT_F1'
			) A6 ON a.PublicCode = A6.MaterialCode
			WHERE 1=1
			GROUP BY ID, PublicCode, PartNo, CreateDate, StatusSystem, DateExport, TYPEEXPORT, Statusout, packqty, Flag
		) AA
		GROUP BY AA.PublicCode, AA.PartNo
	) BB
	WHERE (tondauky > 0 OR nhaptrongky > 0 OR xuatban > 0 OR xuatsanxuat > 0 OR xuattralai > 0 OR xuattieuhuy > 0 OR xuatkhac > 0)

END
GO

PRINT 'Restored [dbo].[usp_FinishGoodReportTK] from backup successfully.'
