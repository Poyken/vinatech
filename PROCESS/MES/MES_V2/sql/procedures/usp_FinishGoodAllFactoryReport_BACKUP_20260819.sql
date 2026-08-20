ALTER PROCEDURE [dbo].[usp_FinishGoodAllFactoryReport] 
	@pFromDate date = NULL,
	@pToDate date = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @daten date = DATEADD(day, -1, @pFromDate);

	-- =========================================================================
	-- 1. BẢNG TẠM SẢN LƯỢNG KHO BẮC NINH (BN) - KHÔNG JOIN STB_SetInfo
	-- =========================================================================
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

		SUM(CASE WHEN CONVERT(DATE, a.CreateDate) BETWEEN '2022-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' THEN a.PackQty ELSE 0 END) AS NhapDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty ELSE 0 END) AS XuatBanDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty ELSE 0 END) AS XuatSanXuatDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty ELSE 0 END) AS XuatTieuHuyDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty ELSE 0 END) AS XuatTraLaiDauKy1,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN '2022-01-01' AND @daten AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty ELSE 0 END) AS XuatKhacDauKy1,

		SUM(CASE WHEN CONVERT(DATE, a.CreateDate) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' THEN a.PackQty ELSE 0 END) AS QtyInput,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XB') THEN a.PackQty ELSE 0 END) AS XuatBan,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XSX') THEN a.PackQty ELSE 0 END) AS XuatSanXuat,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTH') THEN a.PackQty ELSE 0 END) AS XuatTieuHuy,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XTL') THEN a.PackQty ELSE 0 END) AS XuatTraLai,
		SUM(CASE WHEN CONVERT(DATE, a.DateExport) BETWEEN @pFromDate AND @pToDate AND (a.Flag = 1 OR a.Flag IS NULL) AND a.Statusout = N'Xuất' AND a.TYPEEXPORT IN ('XK') THEN a.PackQty ELSE 0 END) AS XuatKhac
	INTO #BN_Base
	FROM STB_VN_FINISHGOODS a (NOLOCK)
	LEFT JOIN (
		SELECT materialcode, openninginventory 
		FROM Stb_InventoryProductLiquidation WITH (NOLOCK) 
		WHERE WorkCenterCode = 'VVT_F1'
	) A6 ON a.PublicCode = A6.MaterialCode
	WHERE (a.Flag = 1 OR a.Flag IS NULL)
	GROUP BY a.PublicCode, a.PartNo;

	-- Tuổi tồn kho BN: Chỉ quét các Lot tồn thực tế (~7,300 dòng)
	SELECT 
		a.PublicCode, a.PartNo,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 90  THEN a.PackQty ELSE 0 END) AS QtyOver3M,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 180 THEN a.PackQty ELSE 0 END) AS QtyOver6M,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 365 THEN a.PackQty ELSE 0 END) AS QtyOver1Y
	INTO #BN_Aging
	FROM STB_VN_FINISHGOODS a (NOLOCK)
	LEFT JOIN STB_SetInfo si (NOLOCK) ON a.LotNo = si.Barcode
	WHERE (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất')
	GROUP BY a.PublicCode, a.PartNo;

	SELECT b.*, COALESCE(g.QtyOver3M, 0) AS QtyOver3M, COALESCE(g.QtyOver6M, 0) AS QtyOver6M, COALESCE(g.QtyOver1Y, 0) AS QtyOver1Y
	INTO #BN
	FROM #BN_Base b
	LEFT JOIN #BN_Aging g ON b.PublicCode = g.PublicCode AND b.PartNo = g.PartNo;

	CREATE CLUSTERED INDEX IX_BN ON #BN(PublicCode, PartNo);

	-- =========================================================================
	-- 2. BẢNG TẠM SẢN LƯỢNG KHO BẮC GIANG (BG) - KHÔNG JOIN STB_SetInfo
	-- =========================================================================
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
		FROM Stb_InventoryProductLiquidation WITH (NOLOCK) 
		WHERE WorkCenterCode = 'VVT_BG'
	) A6 ON a.PublicCode = A6.MaterialCode
	WHERE (a.Flag = 1 OR a.Flag IS NULL)
	GROUP BY a.PublicCode, a.PartNo;

	-- Tuổi tồn kho BG: Chỉ quét các Lot tồn thực tế (~500 dòng)
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

	CREATE CLUSTERED INDEX IX_BG ON #BG(PublicCode, PartNo);

	-- =========================================================================
	-- 3. BẢNG TẠM SẢN LƯỢNG KHO HƯNG YÊN (HY) - KHÔNG JOIN STB_SetInfo
	-- =========================================================================
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
	INTO #HY_Base
	FROM (
		SELECT PublicCode, PartNo, MaterialCode, CreateDate, DateExport, StatusSystem, Statusout, TYPEEXPORT, PackQty, LotNo, Flag FROM STB_VN_FINISHGOODS_HY (NOLOCK)
		UNION ALL
		SELECT PublicCode, PartNo, MaterialCode, CreateDate, DateExport, StatusSystem, Statusout, TYPEEXPORT, PackQty, LotNo, Flag FROM STB_VN_FINISHGOODS_HY_NEW (NOLOCK)
	) a
	LEFT JOIN (
		SELECT materialcode, openninginventory 
		FROM Stb_InventoryProductLiquidation WITH (NOLOCK) 
		WHERE WorkCenterCode = 'VVT_HY'
	) A6 ON a.PublicCode = A6.MaterialCode
	WHERE (a.Flag = 1 OR a.Flag IS NULL)
	GROUP BY a.PublicCode, a.PartNo;

	-- Tuổi tồn kho HY: Chỉ quét các Lot tồn thực tế (~1,100 dòng)
	SELECT 
		a.PublicCode, a.PartNo,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 90  THEN a.PackQty ELSE 0 END) AS QtyOver3M,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 180 THEN a.PackQty ELSE 0 END) AS QtyOver6M,
		SUM(CASE WHEN DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 365 THEN a.PackQty ELSE 0 END) AS QtyOver1Y
	INTO #HY_Aging
	FROM (
		SELECT PublicCode, PartNo, MaterialCode, CreateDate, DateExport, StatusSystem, Statusout, TYPEEXPORT, PackQty, LotNo, Flag FROM STB_VN_FINISHGOODS_HY (NOLOCK)
		UNION ALL
		SELECT PublicCode, PartNo, MaterialCode, CreateDate, DateExport, StatusSystem, Statusout, TYPEEXPORT, PackQty, LotNo, Flag FROM STB_VN_FINISHGOODS_HY_NEW (NOLOCK)
	) a
	LEFT JOIN STB_SetInfo si (NOLOCK) ON a.LotNo = si.Barcode
	WHERE (a.Flag = 1 OR a.Flag IS NULL) AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất')
	GROUP BY a.PublicCode, a.PartNo;

	SELECT b.*, COALESCE(g.QtyOver3M, 0) AS QtyOver3M, COALESCE(g.QtyOver6M, 0) AS QtyOver6M, COALESCE(g.QtyOver1Y, 0) AS QtyOver1Y
	INTO #HY
	FROM #HY_Base b
	LEFT JOIN #HY_Aging g ON b.PublicCode = g.PublicCode AND b.PartNo = g.PartNo;

	CREATE CLUSTERED INDEX IX_HY ON #HY(PublicCode, PartNo);

	-- =========================================================================
	-- 4. KẾT HỢP DỮ LIỆU TỔNG HỢP VÀ ĐƠN GIÁ (B943) - KHỚP 100% GRID FG20
	-- =========================================================================
	SELECT 
		Master.PublicCode, 
		Master.PartNo, 
		Master.Model, 
		Master.MaterialCode, 
		'PCS' AS materialunit,

		-- TỒN ĐẦU KỲ TỔNG CỘNG (BN + BG + HY)
		(COALESCE(bn.TonDauKy, 0) + COALESCE(bg.TonDauKy, 0) + COALESCE(hy.TonDauKy, 0)) AS TonDauKy,

		-- NHẬP TRONG KỲ TỔNG CỘNG (BN + BG + HY)
		(COALESCE(bn.NhapTrongKy, 0) + COALESCE(bg.NhapTrongKy, 0) + COALESCE(hy.NhapTrongKy, 0)) AS NhapTrongKy,

		-- XUẤT BÁN TỔNG CỘNG (BN + BG + HY)
		(COALESCE(bn.XuatBan, 0) + COALESCE(bg.XuatBan, 0) + COALESCE(hy.XuatBan, 0)) AS XuatBan,

		-- XUẤT SẢN XUẤT TỔNG CỘNG (BN + BG + HY)
		(COALESCE(bn.XuatSanXuat, 0) + COALESCE(bg.XuatSanXuat, 0) + COALESCE(hy.XuatSanXuat, 0)) AS XuatSanXuat,

		-- CÁC CỘT XUẤT PHỤ
		(COALESCE(bn.XuatTieuHuy, 0) + COALESCE(bg.XuatTieuHuy, 0) + COALESCE(hy.XuatTieuHuy, 0)) AS XuatTieuHuy,
		(COALESCE(bn.XuatTraLai, 0) + COALESCE(bg.XuatTraLai, 0) + COALESCE(hy.XuatTraLai, 0)) AS XuatTraLai,
		(COALESCE(bn.XuatKhac, 0) + COALESCE(bg.XuatKhac, 0) + COALESCE(hy.XuatKhac, 0)) AS XuatKhac,

		-- TỒN CUỐI KỲ TỔNG CỘNG (BN + BG + HY)
		(COALESCE(bn.TonCuoiKy, 0) + COALESCE(bg.TonCuoiKy, 0) + COALESCE(hy.TonCuoiKy, 0)) AS TonCuoiKy,

		-- TỒN TRÊN 1 NĂM TỔNG CỘNG
		(COALESCE(bn.QtyOver1Y, 0) + COALESCE(bg.QtyOver1Y, 0) + COALESCE(hy.QtyOver1Y, 0)) AS TonTren1Nam,

		-- ĐƠN GIÁ B943
		COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DonGia,

		-- GIÁ TIỀN TỒN CUỐI KỲ (TỒN CUỐI KỲ * ĐƠN GIÁ)
		CAST((COALESCE(bn.TonCuoiKy, 0) + COALESCE(bg.TonCuoiKy, 0) + COALESCE(hy.TonCuoiKy, 0)) * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS GiaTienTonCuoiKy,

		-- GIÁ TIỀN TỒN TRÊN 1 NĂM (TỒN > 1 NĂM * ĐƠN GIÁ)
		CAST((COALESCE(bn.QtyOver1Y, 0) + COALESCE(bg.QtyOver1Y, 0) + COALESCE(hy.QtyOver1Y, 0)) * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS GiaTienTon1Nam

	FROM (
		SELECT PublicCode, PartNo, MAX(Model) AS Model, MAX(MaterialCode) AS MaterialCode
		FROM (
			SELECT b.PublicCode, b.PartNo, M.Model, b.MaterialCode
			FROM #BN b
			CROSS APPLY (
				SELECT CASE
					WHEN b.PartNo LIKE '%(60mm)1840%' OR b.PartNo LIKE '%(60mm)(1840)%' THEN '1840'
					WHEN b.PartNo LIKE '%-3PLA%' THEN '1025'
					WHEN b.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN b.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN b.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN b.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN b.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', b.PartNo) > 0 AND CHARINDEX(')', b.PartNo) > 0
					THEN SUBSTRING(b.PartNo, LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2, LEN(b.PartNo) - CHARINDEX(')', REVERSE(b.PartNo)) + 1 - (LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2))
					ELSE NULL
				END AS Model
			) M

			UNION

			SELECT b.PublicCode, b.PartNo, M.Model, b.MaterialCode
			FROM #BG b
			CROSS APPLY (
				SELECT CASE
					WHEN b.PartNo LIKE '%(60mm)1840%' OR b.PartNo LIKE '%(60mm)(1840)%' THEN '1840'
					WHEN b.PartNo LIKE '%-3PLA%' THEN '1025'
					WHEN b.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN b.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN b.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN b.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN b.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', b.PartNo) > 0 AND CHARINDEX(')', b.PartNo) > 0
					THEN SUBSTRING(b.PartNo, LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2, LEN(b.PartNo) - CHARINDEX(')', REVERSE(b.PartNo)) + 1 - (LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2))
					ELSE NULL
				END AS Model
			) M

			UNION

			SELECT b.PublicCode, b.PartNo, M.Model, b.MaterialCode
			FROM #HY b
			CROSS APPLY (
				SELECT CASE
					WHEN b.PartNo LIKE '%(60mm)1840%' OR b.PartNo LIKE '%(60mm)(1840)%' THEN '1840'
					WHEN b.PartNo LIKE '%-3PLA%' THEN '1025'
					WHEN b.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN b.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN b.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN b.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN b.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', b.PartNo) > 0 AND CHARINDEX(')', b.PartNo) > 0
					THEN SUBSTRING(b.PartNo, LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2, LEN(b.PartNo) - CHARINDEX(')', REVERSE(b.PartNo)) + 1 - (LEN(b.PartNo) - CHARINDEX('(', REVERSE(b.PartNo)) + 2))
					ELSE NULL
				END AS Model
			) M
		) MasterList
		GROUP BY PublicCode, PartNo
	) Master

	-- BẮC NINH (BN)
	LEFT JOIN (
		SELECT PublicCode, PartNo,
			CASE 
				WHEN @pFromDate = '2022-01-01' THEN COALESCE(openninginventory, 0)
				WHEN @pFromDate > '2022-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(NhapDauKy1, 0) - COALESCE(XuatBanDauKy1, 0) - COALESCE(XuatSanXuatDauKy1, 0) - COALESCE(XuatTieuHuyDauKy1, 0) - COALESCE(XuatTraLaiDauKy1, 0) - COALESCE(XuatKhacDauKy1, 0)
				ELSE COALESCE(NhapDauKy, 0) - COALESCE(XuatBanDauKy, 0) - COALESCE(XuatSanXuatDauKy, 0) - COALESCE(XuatTieuHuyDauKy, 0) - COALESCE(XuatTraLaiDauKy, 0) - COALESCE(XuatKhacDauKy, 0)
			END AS TonDauKy,
			COALESCE(QtyInput, 0)    AS NhapTrongKy,
			COALESCE(XuatBan, 0)     AS XuatBan,
			COALESCE(XuatSanXuat, 0) AS XuatSanXuat,
			COALESCE(XuatTieuHuy, 0) AS XuatTieuHuy,
			COALESCE(XuatTraLai, 0)  AS XuatTraLai,
			COALESCE(XuatKhac, 0)    AS XuatKhac,
			CASE 
				WHEN @pFromDate = '2022-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
				WHEN @pFromDate > '2022-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(NhapDauKy1, 0) - COALESCE(XuatBanDauKy1, 0) - COALESCE(XuatSanXuatDauKy1, 0) - COALESCE(XuatTieuHuyDauKy1, 0) - COALESCE(XuatTraLaiDauKy1, 0) - COALESCE(XuatKhacDauKy1, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
				ELSE COALESCE(NhapDauKy, 0) - COALESCE(XuatBanDauKy, 0) - COALESCE(XuatSanXuatDauKy, 0) - COALESCE(XuatTieuHuyDauKy, 0) - COALESCE(XuatTraLaiDauKy, 0) - COALESCE(XuatKhacDauKy, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
			END AS TonCuoiKy,
			QtyOver1Y
		FROM #BN
	) bn ON Master.PublicCode = bn.PublicCode AND Master.PartNo = bn.PartNo

	-- BẮC GIANG (BG)
	LEFT JOIN (
		SELECT PublicCode, PartNo,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(openninginventory, 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(NhapDauKy1, 0) - COALESCE(XuatBanDauKy1, 0) - COALESCE(XuatSanXuatDauKy1, 0) - COALESCE(XuatTieuHuyDauKy1, 0) - COALESCE(XuatTraLaiDauKy1, 0) - COALESCE(XuatKhacDauKy1, 0)
				ELSE COALESCE(NhapDauKy, 0) - COALESCE(XuatBanDauKy, 0) - COALESCE(XuatSanXuatDauKy, 0) - COALESCE(XuatTieuHuyDauKy, 0) - COALESCE(XuatTraLaiDauKy, 0) - COALESCE(XuatKhacDauKy, 0)
			END AS TonDauKy,
			COALESCE(QtyInput, 0)    AS NhapTrongKy,
			COALESCE(XuatBan, 0)     AS XuatBan,
			COALESCE(XuatSanXuat, 0) AS XuatSanXuat,
			COALESCE(XuatTieuHuy, 0) AS XuatTieuHuy,
			COALESCE(XuatTraLai, 0)  AS XuatTraLai,
			COALESCE(XuatKhac, 0)    AS XuatKhac,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(NhapDauKy1, 0) - COALESCE(XuatBanDauKy1, 0) - COALESCE(XuatSanXuatDauKy1, 0) - COALESCE(XuatTieuHuyDauKy1, 0) - COALESCE(XuatTraLaiDauKy1, 0) - COALESCE(XuatKhacDauKy1, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
				ELSE COALESCE(NhapDauKy, 0) - COALESCE(XuatBanDauKy, 0) - COALESCE(XuatSanXuatDauKy, 0) - COALESCE(XuatTieuHuyDauKy, 0) - COALESCE(XuatTraLaiDauKy, 0) - COALESCE(XuatKhacDauKy, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
			END AS TonCuoiKy,
			QtyOver1Y
		FROM #BG
	) bg ON Master.PublicCode = bg.PublicCode AND Master.PartNo = bg.PartNo

	-- HƯNG YÊN (HY)
	LEFT JOIN (
		SELECT PublicCode, PartNo,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(openninginventory, 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(NhapDauKy1, 0) - COALESCE(XuatBanDauKy1, 0) - COALESCE(XuatSanXuatDauKy1, 0) - COALESCE(XuatTieuHuyDauKy1, 0) - COALESCE(XuatTraLaiDauKy1, 0) - COALESCE(XuatKhacDauKy1, 0)
				ELSE COALESCE(NhapDauKy, 0) - COALESCE(XuatBanDauKy, 0) - COALESCE(XuatSanXuatDauKy, 0) - COALESCE(XuatTieuHuyDauKy, 0) - COALESCE(XuatTraLaiDauKy, 0) - COALESCE(XuatKhacDauKy, 0)
			END AS TonDauKy,
			COALESCE(QtyInput, 0)    AS NhapTrongKy,
			COALESCE(XuatBan, 0)     AS XuatBan,
			COALESCE(XuatSanXuat, 0) AS XuatSanXuat,
			COALESCE(XuatTieuHuy, 0) AS XuatTieuHuy,
			COALESCE(XuatTraLai, 0)  AS XuatTraLai,
			COALESCE(XuatKhac, 0)    AS XuatKhac,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(openninginventory, 0) + COALESCE(NhapDauKy1, 0) - COALESCE(XuatBanDauKy1, 0) - COALESCE(XuatSanXuatDauKy1, 0) - COALESCE(XuatTieuHuyDauKy1, 0) - COALESCE(XuatTraLaiDauKy1, 0) - COALESCE(XuatKhacDauKy1, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
				ELSE COALESCE(NhapDauKy, 0) - COALESCE(XuatBanDauKy, 0) - COALESCE(XuatSanXuatDauKy, 0) - COALESCE(XuatTieuHuyDauKy, 0) - COALESCE(XuatTraLaiDauKy, 0) - COALESCE(XuatKhacDauKy, 0) + COALESCE(QtyInput, 0) - COALESCE(XuatBan, 0) - COALESCE(XuatTieuHuy, 0) - COALESCE(XuatTraLai, 0) - COALESCE(XuatSanXuat, 0) - COALESCE(XuatKhac, 0)
			END AS TonCuoiKy,
			QtyOver1Y
		FROM #HY
	) hy ON Master.PublicCode = hy.PublicCode AND Master.PartNo = hy.PartNo

	-- Đơn giá từ màn B943
	OUTER APPLY (
		SELECT TOP 1 UnitPrice
		FROM STB_InventoryOfGoodsReport
		WHERE ItemCodeVN = Master.PublicCode
		  AND ItemCodeVN IS NOT NULL AND ItemCodeVN <> ''
		ORDER BY ID DESC
	) r
	OUTER APPLY (
		SELECT TOP 1 UnitPrice
		FROM STB_InventoryOfGoodsReport
		WHERE ItemCodeKorea = Master.MaterialCode
		  AND ItemCodeKorea IS NOT NULL AND ItemCodeKorea <> ''
		  AND r.UnitPrice IS NULL
		ORDER BY ID DESC
	) r_kr

	WHERE (
		(COALESCE(bn.TonDauKy, 0) + COALESCE(bg.TonDauKy, 0) + COALESCE(hy.TonDauKy, 0)) > 0 OR 
		(COALESCE(bn.NhapTrongKy, 0) + COALESCE(bg.NhapTrongKy, 0) + COALESCE(hy.NhapTrongKy, 0)) > 0 OR 
		(COALESCE(bn.XuatBan, 0) + COALESCE(bg.XuatBan, 0) + COALESCE(hy.XuatBan, 0)) > 0 OR 
		(COALESCE(bn.TonCuoiKy, 0) + COALESCE(bg.TonCuoiKy, 0) + COALESCE(hy.TonCuoiKy, 0)) > 0
	)
	ORDER BY Master.PublicCode;

	DROP TABLE #BN_Base;
	DROP TABLE #BN_Aging;
	DROP TABLE #BN;
	DROP TABLE #BG_Base;
	DROP TABLE #BG_Aging;
	DROP TABLE #BG;
	DROP TABLE #HY_Base;
	DROP TABLE #HY_Aging;
	DROP TABLE #HY;

END