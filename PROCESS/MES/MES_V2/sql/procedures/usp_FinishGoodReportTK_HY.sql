CREATE PROCEDURE [dbo].[usp_FinishGoodReportTK_HY]
	@pFromDate date = NULL,
	@pToDate date = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF 1=0 BEGIN SET FMTONLY OFF END;

	DECLARE @daten date = DATEADD(day, -1, @pFromDate);

	-- 1. BẢNG TẠM SẢN LƯỢNG KHO HƯNG YÊN (HY) - KHÔNG JOIN STB_SetInfo (0.1s)
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
		FROM Stb_InventoryProductLiquidation FIM WITH (NOLOCK) 
		WHERE FIM.WorkCenterCode = 'VVT_HY'
	) A6 ON a.PublicCode = A6.MaterialCode
	WHERE (a.Flag = 1 OR a.Flag IS NULL)
	GROUP BY a.PublicCode, a.PartNo;

	-- 2. BẢNG TẠM TUỔI TỒN KHO HƯNG YÊN (HY) - CHỈ QUÉT HÀNG TỒN THỰC TẾ (0.05s)
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

	SELECT h.*, COALESCE(g.QtyOver3M, 0) AS QtyOver3M, COALESCE(g.QtyOver6M, 0) AS QtyOver6M, COALESCE(g.QtyOver1Y, 0) AS QtyOver1Y
	INTO #HY
	FROM #HY_Base h
	LEFT JOIN #HY_Aging g ON h.PublicCode = g.PublicCode AND h.PartNo = g.PartNo;

	CREATE CLUSTERED INDEX IX_HY_Code ON #HY(PublicCode, PartNo);

	-- 3. TRUY VẤN KẾT HỢP DỮ LIỆU CỘNG GỘP KHỚP 100% FILE EXCEL
	SELECT 
		FinalReport.PublicCode,
		FinalReport.PartNo,
		'PCS' AS materialunit,
		FinalReport.Model,
		FinalReport.TonDauKy,
		COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS UnitPrice,
		FinalReport.NhapTrongKy,
		FinalReport.XuatBan,
		FinalReport.XuatSanXuat,
		FinalReport.XuatTieuHuy,
		FinalReport.XuatTraLai,
		FinalReport.XuatKhac,
		FinalReport.TonCuoiKy AS TonCuoiKy,

		-- CỘT TỔNG TIỀN HƯNG YÊN (TỒN CUỐI KỲ HY * ĐƠN GIÁ)
		CAST(FinalReport.TonCuoiKy * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS TotalAmount,

		-- CÁC CỘT TUỔI TỒN KHO HƯNG YÊN (TÍNH THEO NGÀY TẠO MÃ LOT)
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
				h.PublicCode, 
				h.PartNo,
				M.Model,
				h.MaterialCode,
				h.openninginventory,
				h.NhapDauKy, h.XuatBanDauKy, h.XuatSanXuatDauKy, h.XuatTieuHuyDauKy, h.XuatTraLaiDauKy, h.XuatKhacDauKy,
				h.NhapDauKy1, h.XuatBanDauKy1, h.XuatSanXuatDauKy1, h.XuatTieuHuyDauKy1, h.XuatTraLaiDauKy1, h.XuatKhacDauKy1,
				h.QtyInput, h.XuatBan, h.XuatSanXuat, h.XuatTieuHuy, h.XuatTraLai, h.XuatKhac,
				h.QtyOver3M, h.QtyOver6M, h.QtyOver1Y
			FROM #HY h
			CROSS APPLY (
				SELECT CASE
					WHEN h.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN h.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN h.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN h.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN h.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', h.PartNo) > 0 AND CHARINDEX(')', h.PartNo) > 0
					THEN SUBSTRING(
							h.PartNo,
							LEN(h.PartNo) - CHARINDEX('(', REVERSE(h.PartNo)) + 2,
							LEN(h.PartNo) - CHARINDEX(')', REVERSE(h.PartNo)) + 1
							- (LEN(h.PartNo) - CHARINDEX('(', REVERSE(h.PartNo)) + 2)
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

	DROP TABLE #HY_Base;
	DROP TABLE #HY_Aging;
	DROP TABLE #HY;

END
