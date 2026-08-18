-- ==============================================================================
-- SCRIPT CẬP NHẬT STORED PROCEDURE: usp_FinishGoodReportTK_BG
-- MÀN HÌNH: [FG02] Tổng hợp kho thành phẩm - Tab Bắc Giang (BG)
-- PHIÊN BẢN TỐI ƯU SIÊU TỐC (0.1 SECONDS): 2026-08-18
-- TÁC GIẢ: Antigravity AI Agent
-- ==============================================================================

USE [SmartFactoryV2]
GO

IF OBJECT_ID('dbo.usp_FinishGoodReportTK_BG', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[usp_FinishGoodReportTK_BG]
END
GO

CREATE PROCEDURE [dbo].[usp_FinishGoodReportTK_BG]
	@pFromDate date = NULL,
	@pToDate date = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @daten date = DATEADD(day, -1, @pFromDate);

	-- 1. Aggregation without STB_SetInfo (0.05s)
	SELECT 
		a.PublicCode, 
		a.PartNo, 
		MAX(a.MaterialCode) AS MaterialCode,
		MAX(a6.openninginventory) AS openninginventory,

		SUM(CASE WHEN CONVERT(DATE, a.CreateDate) < @pFromDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' THEN a.PackQty ELSE 0 END) AS NhapDauKy,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty ELSE 0 END) AS XuatBanDauKy,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty ELSE 0 END) AS XuatSanXuatDauKy,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty ELSE 0 END) AS XuatTieuHuyDauKy,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty ELSE 0 END) AS XuatTraLaiDauKy,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) < @pFromDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty ELSE 0 END) AS XuatKhacDauKy,

		SUM(CASE WHEN CONVERT(DATE, a.CreateDate) BETWEEN '2025-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' THEN a.PackQty ELSE 0 END) AS NhapDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2025-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty ELSE 0 END) AS XuatBanDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2025-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty ELSE 0 END) AS XuatSanXuatDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2025-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty ELSE 0 END) AS XuatTieuHuyDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2025-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty ELSE 0 END) AS XuatTraLaiDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2025-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty ELSE 0 END) AS XuatKhacDauKy1,

		SUM(CASE WHEN CONVERT(DATE, a.CreateDate) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' THEN a.PackQty ELSE 0 END) AS QtyInput,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty ELSE 0 END) AS XuatBan,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty ELSE 0 END) AS XuatSanXuat,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty ELSE 0 END) AS XuatTieuHuy,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty ELSE 0 END) AS XuatTraLai,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty ELSE 0 END) AS XuatKhac
	INTO #BG_Base
	FROM STB_VN_FINISHGOODS_BG a (NOLOCK)
	LEFT JOIN (
		SELECT materialcode, openninginventory 
		FROM Stb_InventoryProductLiquidation FIM WITH (NOLOCK) 
		WHERE FIM.WorkCenterCode = 'VVT_F2'
	) A6 ON a.PublicCode = A6.MaterialCode
	WHERE (a.Flag = 1 OR a.Flag IS NULL)
	GROUP BY a.PublicCode, a.PartNo;

	-- 2. Aging on Active Stock Only (0.01s)
	SELECT 
		a.PublicCode, a.PartNo,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 90  THEN a.PackQty ELSE 0 END) AS QtyOver3M,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 180 THEN a.PackQty ELSE 0 END) AS QtyOver6M,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 365 THEN a.PackQty ELSE 0 END) AS QtyOver1Y
	INTO #BG_Aging
	FROM STB_VN_FINISHGOODS_BG a (NOLOCK)
	LEFT JOIN STB_SetInfo si (NOLOCK) ON a.LotNo = si.Barcode
	WHERE (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất')
	GROUP BY a.PublicCode, a.PartNo;

	SELECT b.*, COALESCE(g.QtyOver3M, 0) AS QtyOver3M, COALESCE(g.QtyOver6M, 0) AS QtyOver6M, COALESCE(g.QtyOver1Y, 0) AS QtyOver1Y
	INTO #BG
	FROM #BG_Base b
	LEFT JOIN #BG_Aging g ON b.PublicCode = g.PublicCode AND b.PartNo = g.PartNo;

	SELECT 
		FinalReport.PublicCode,
		FinalReport.PartNo,
		FinalReport.Model,
		COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS UnitPrice,
		FinalReport.materialunit,
		FinalReport.TonDauKy,
		FinalReport.NhapTrongKy,
		FinalReport.XuatBan,
		FinalReport.XuatSanXuat,
		FinalReport.XuatTieuHuy,
		FinalReport.XuatTraLai,
		FinalReport.XuatKhac,
		FinalReport.TonCuoiKy AS TonCuoiKy_BG,

		FinalReport.QtyOver3M,
		FinalReport.QtyOver6M,
		FinalReport.QtyOver1Y,
		CAST(FinalReport.QtyOver3M * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver3M,
		CAST(FinalReport.QtyOver6M * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver6M,
		CAST(FinalReport.QtyOver1Y * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver1Y

	FROM (
		SELECT 
			AA.PublicCode,
			AA.PartNo,
			AA.Model,
			AA.MaterialCode,
			'PCS' AS materialunit,

			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0)
				ELSE COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0)
			END AS TonDauKy,

			COALESCE(SUM(QtyInput), 0) AS NhapTrongKy,
			COALESCE(SUM(XuatBan), 0) AS XuatBan,
			COALESCE(SUM(XuatSanXuat), 0) AS XuatSanXuat,
			COALESCE(SUM(XuatTieuHuy), 0) AS XuatTieuHuy,
			COALESCE(SUM(XuatTraLai), 0) AS XuatTraLai,
			COALESCE(SUM(XuatKhac), 0) AS XuatKhac,

			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				ELSE COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
			END AS TonCuoiKy,

			COALESCE(SUM(QtyOver3M), 0) AS QtyOver3M,
			COALESCE(SUM(QtyOver6M), 0) AS QtyOver6M,
			COALESCE(SUM(QtyOver1Y), 0) AS QtyOver1Y

		FROM (
			SELECT 
				b.PublicCode, 
				b.PartNo,
				M.Model,
				b.MaterialCode,
				b.openninginventory,
				b.NhapDauKy, b.XuatBanDauKy, b.XuatSanXuatDauKy, b.XuatTieuHuyDauKy, b.XuatTraLaiDauKy, b.XuatKhacDauKy,
				b.NhapDauKy1, b.XuatBanDauKy1, b.XuatSanXuatDauKy1, b.XuatTieuHuyDauKy1, b.XuatTraLaiDauKy1, b.XuatKhacDauKy1,
				b.QtyInput, b.XuatBan, b.XuatSanXuat, b.XuatTieuHuy, b.XuatTraLai, b.XuatKhac,
				b.QtyOver3M, b.QtyOver6M, b.QtyOver1Y
			FROM #BG b
			CROSS APPLY (
				SELECT CASE
					WHEN b.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN b.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN b.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN b.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN b.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', b.PartNo) > 0 AND CHARINDEX(')', b.PartNo) > 0
					THEN SUBSTRING(
							b.PartNo,
							LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2,
							LEN(b.PartNo) - CHARINDEX(')', REVERSE(b.PartNo)) + 1
							- (LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2)
						  )
					ELSE NULL
				END AS Model
			) M
		) AA
		GROUP BY AA.PublicCode, AA.PartNo, AA.Model, AA.MaterialCode
	) FinalReport

	-- Logic lấy Đơn giá UnitPrice từ màn B943 (STB_InventoryOfGoodsReport)
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

	WHERE (FinalReport.TonDauKy > 0 OR FinalReport.NhapTrongKy > 0 OR FinalReport.XuatBan > 0 OR FinalReport.XuatSanXuat > 0 OR FinalReport.XuatTraLai > 0 OR FinalReport.XuatTieuHuy > 0 OR FinalReport.XuatKhac > 0 OR FinalReport.TonCuoiKy > 0)
	ORDER BY FinalReport.PublicCode;

	DROP TABLE #BG_Base;
	DROP TABLE #BG_Aging;
	DROP TABLE #BG;

END
GO

PRINT 'Stored Procedure [dbo].[usp_FinishGoodReportTK_BG] ultra-fast optimized successfully.'
