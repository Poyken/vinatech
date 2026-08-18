-- ==============================================================================
-- SCRIPT CẬP NHẬT STORED PROCEDURE: usp_FinishGoodAllFactoryReport
-- MÀN HÌNH: [FG02] Tổng hợp kho thành phẩm - Tab Tổng Hợp (BN, BG, HY)
-- LỊCH SỬ NÂNG CẤP: 2026-08-18 - Tích hợp Hưng Yên, Tổng tồn BN-HY, Tổng tiền BN-BG, Tuổi tồn theo Lot
-- TÁC GIẢ: Antigravity AI Agent
-- ==============================================================================

USE [SmartFactoryV2]
GO

IF OBJECT_ID('dbo.usp_FinishGoodAllFactoryReport', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[usp_FinishGoodAllFactoryReport]
END
GO

CREATE PROCEDURE [dbo].[usp_FinishGoodAllFactoryReport] 
	@pFromDate date = NULL,
	@pToDate date = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @daten date = DATEADD(day, -1, @pFromDate);

SELECT 
	FinalReport.PublicCode, 
	FinalReport.PartNo, 
	FinalReport.Model, 
	FinalReport.MaterialCode, 
	FinalReport.materialunit,
	COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS UnitPrice,

	-- 1. SỐ LIỆU BẮC NINH (BN)
	FinalReport.TonDauKy_BN,
	FinalReport.NhapTrongKy_BN,
	FinalReport.XuatBan_BN,
	FinalReport.XuatSanXuat_BN,
	FinalReport.TonCuoiKy_BN,

	-- 2. SỐ LIỆU BẮC GIANG (BG)
	FinalReport.TonDauKy_BG,
	FinalReport.NhapTrongKy_BG,
	FinalReport.XuatBan_BG,
	FinalReport.XuatSanXuat_BG,
	FinalReport.TonCuoiKy_BG,

	-- 3. SỐ LIỆU HƯNG YÊN (HY)
	FinalReport.TonDauKy_HY,
	FinalReport.NhapTrongKy_HY,
	FinalReport.XuatBan_HY,
	FinalReport.XuatSanXuat_HY,
	FinalReport.TonCuoiKy_HY,

	-- 4. KHỐI TỔNG HỢP & LIÊN KẾT NHÀ MÁY
	(FinalReport.TonCuoiKy_BN + FinalReport.TonCuoiKy_HY) AS TotalQty_BN_HY,
	CAST((FinalReport.TonCuoiKy_BN + FinalReport.TonCuoiKy_BG) * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS TotalAmount_BN_BG,

	-- 5. TUỔI TỒN KHO HƯNG YÊN
	FinalReport.QtyOver3M_HY,
	FinalReport.QtyOver6M_HY,
	FinalReport.QtyOver1Y_HY,
	CAST(FinalReport.QtyOver3M_HY * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver3M_HY,
	CAST(FinalReport.QtyOver6M_HY * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver6M_HY,
	CAST(FinalReport.QtyOver1Y_HY * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS AmountOver1Y_HY,

	-- 6. TUỔI TỒN KHO TỔNG CỘNG 3 NHÀ MÁY (BN + BG + HY)
	(FinalReport.QtyOver3M_BN + FinalReport.QtyOver3M_BG + FinalReport.QtyOver3M_HY) AS TotalQtyOver3M,
	(FinalReport.QtyOver6M_BN + FinalReport.QtyOver6M_BG + FinalReport.QtyOver6M_HY) AS TotalQtyOver6M,
	(FinalReport.QtyOver1Y_BN + FinalReport.QtyOver1Y_BG + FinalReport.QtyOver1Y_HY) AS TotalQtyOver1Y,
	CAST((FinalReport.QtyOver3M_BN + FinalReport.QtyOver3M_BG + FinalReport.QtyOver3M_HY) * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS TotalAmountOver3M,
	CAST((FinalReport.QtyOver6M_BN + FinalReport.QtyOver6M_BG + FinalReport.QtyOver6M_HY) * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS TotalAmountOver6M,
	CAST((FinalReport.QtyOver1Y_BN + FinalReport.QtyOver1Y_BG + FinalReport.QtyOver1Y_HY) * COALESCE(r.UnitPrice, r_kr.UnitPrice, 0) AS DECIMAL(18, 2)) AS TotalAmountOver1Y

FROM (
	SELECT 
		Master.PublicCode,
		Master.PartNo,
		Master.Model,
		Master.MaterialCode,
		'PCS' AS materialunit,

		-- BN
		COALESCE(bn.TonDauKy, 0)    AS TonDauKy_BN,
		COALESCE(bn.NhapTrongKy, 0) AS NhapTrongKy_BN,
		COALESCE(bn.XuatBan, 0)     AS XuatBan_BN,
		COALESCE(bn.XuatSanXuat, 0) AS XuatSanXuat_BN,
		COALESCE(bn.TonCuoiKy, 0)   AS TonCuoiKy_BN,
		COALESCE(bn.QtyOver3M, 0)   AS QtyOver3M_BN,
		COALESCE(bn.QtyOver6M, 0)   AS QtyOver6M_BN,
		COALESCE(bn.QtyOver1Y, 0)   AS QtyOver1Y_BN,

		-- BG
		COALESCE(bg.TonDauKy, 0)    AS TonDauKy_BG,
		COALESCE(bg.NhapTrongKy, 0) AS NhapTrongKy_BG,
		COALESCE(bg.XuatBan, 0)     AS XuatBan_BG,
		COALESCE(bg.XuatSanXuat, 0) AS XuatSanXuat_BG,
		COALESCE(bg.TonCuoiKy, 0)   AS TonCuoiKy_BG,
		COALESCE(bg.QtyOver3M, 0)   AS QtyOver3M_BG,
		COALESCE(bg.QtyOver6M, 0)   AS QtyOver6M_BG,
		COALESCE(bg.QtyOver1Y, 0)   AS QtyOver1Y_BG,

		-- HY
		COALESCE(hy.TonDauKy, 0)    AS TonDauKy_HY,
		COALESCE(hy.NhapTrongKy, 0) AS NhapTrongKy_HY,
		COALESCE(hy.XuatBan, 0)     AS XuatBan_HY,
		COALESCE(hy.XuatSanXuat, 0) AS XuatSanXuat_HY,
		COALESCE(hy.TonCuoiKy, 0)   AS TonCuoiKy_HY,
		COALESCE(hy.QtyOver3M, 0)   AS QtyOver3M_HY,
		COALESCE(hy.QtyOver6M, 0)   AS QtyOver6M_HY,
		COALESCE(hy.QtyOver1Y, 0)   AS QtyOver1Y_HY

	FROM (
		SELECT PublicCode, PartNo, MAX(Model) AS Model, MAX(MaterialCode) AS MaterialCode
		FROM (
			SELECT a.PublicCode, a.PartNo, M.Model, a.MaterialCode
			FROM STB_VN_FINISHGOODS a (NOLOCK)
			CROSS APPLY (
				SELECT CASE
					WHEN a.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN a.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN a.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN a.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN a.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', a.PartNo) > 0 AND CHARINDEX(')', a.PartNo) > 0
					THEN SUBSTRING(a.PartNo, LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2, LEN(a.PartNo) - CHARINDEX(')', REVERSE(a.PartNo)) + 1 - (LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2))
					ELSE NULL
				END AS Model
			) M
			WHERE a.Flag = 1

			UNION

			SELECT a.PublicCode, a.PartNo, M.Model, a.MaterialCode
			FROM STB_VN_FINISHGOODS_BG a (NOLOCK)
			CROSS APPLY (
				SELECT CASE
					WHEN a.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN a.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN a.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN a.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN a.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', a.PartNo) > 0 AND CHARINDEX(')', a.PartNo) > 0
					THEN SUBSTRING(a.PartNo, LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2, LEN(a.PartNo) - CHARINDEX(')', REVERSE(a.PartNo)) + 1 - (LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2))
					ELSE NULL
				END AS Model
			) M
			WHERE a.Flag = 1

			UNION

			SELECT a.PublicCode, a.PartNo, M.Model, a.MaterialCode
			FROM STB_VN_FINISHGOODS_HY a (NOLOCK)
			CROSS APPLY (
				SELECT CASE
					WHEN a.PartNo = 'VEL10303R8107G-C035' THEN '1030'
					WHEN a.PartNo = 'VEL13353R8257G(1335)' THEN '1335'
					WHEN a.PartNo = 'VEL13253R8157G-WC(70)(1325)' THEN '1325'
					WHEN a.PartNo = 'WEC3R0705QD(0830-taping)' THEN '0830'
					WHEN a.PartNo = 'WEC3R0335QG(0820-CY)TAPING' THEN '0820'
					WHEN CHARINDEX('(', a.PartNo) > 0 AND CHARINDEX(')', a.PartNo) > 0
					THEN SUBSTRING(a.PartNo, LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2, LEN(a.PartNo) - CHARINDEX(')', REVERSE(a.PartNo)) + 1 - (LEN(a.PartNo) - CHARINDEX('(', REVERSE(a.PartNo)) + 2))
					ELSE NULL
				END AS Model
			) M
			WHERE a.Flag = 1
		) MList
		GROUP BY PublicCode, PartNo
	) Master

	-- BẮC NINH (BN)
	LEFT JOIN (
		SELECT AA.PublicCode, AA.PartNo,
			CASE 
				WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0)
				WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0)
				ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0)
			END AS TonDauKy,
			COALESCE(SUM(QtyInput), 0)    AS NhapTrongKy,
			COALESCE(SUM(XuatBan), 0)     AS XuatBan,
			COALESCE(SUM(XuatSanXuat), 0) AS XuatSanXuat,
			CASE 
				WHEN @pFromDate = '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				WHEN @pFromDate > '2022-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
			END AS TonCuoiKy,
			COALESCE(SUM(QtyOver3M), 0) AS QtyOver3M,
			COALESCE(SUM(QtyOver6M), 0) AS QtyOver6M,
			COALESCE(SUM(QtyOver1Y), 0) AS QtyOver1Y
		FROM (
			SELECT a.PublicCode, a.PartNo, MAX(a6.openninginventory) AS openninginventory,
				CASE WHEN CONVERT(DATE, createdate) < @pFromDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy,
				CASE WHEN CONVERT(DATE, createdate) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2022-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy1,
				CASE WHEN CONVERT(DATE, createdate) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS QtyInput,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBan,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuat,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuy,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLai,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhac,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 90  THEN PackQty ELSE 0 END AS QtyOver3M,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 180 THEN PackQty ELSE 0 END AS QtyOver6M,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 365 THEN PackQty ELSE 0 END AS QtyOver1Y
			FROM STB_VN_FINISHGOODS a (NOLOCK)
			LEFT JOIN STB_SetInfo si (NOLOCK) ON a.LotNo = si.Barcode
			LEFT JOIN (SELECT materialcode, openninginventory FROM Stb_InventoryProductLiquidation WITH (NOLOCK) WHERE WorkCenterCode = 'VVT_F1') A6 ON a.PublicCode = A6.MaterialCode
			WHERE Flag = 1
			GROUP BY a.ID, a.PublicCode, a.PartNo, a.CreateDate, a.StatusSystem, a.DateExport, a.TYPEEXPORT, a.Statusout, a.PackQty, a.Flag, si.InputJobDate, a.LotNo
		) AA
		GROUP BY AA.PublicCode, AA.PartNo
	) bn ON Master.PublicCode = bn.PublicCode AND Master.PartNo = bn.PartNo

	-- BẮC GIANG (BG)
	LEFT JOIN (
		SELECT AA.PublicCode, AA.PartNo,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0)
				ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0)
			END AS TonDauKy,
			COALESCE(SUM(QtyInput), 0)    AS NhapTrongKy,
			COALESCE(SUM(XuatBan), 0)     AS XuatBan,
			COALESCE(SUM(XuatSanXuat), 0) AS XuatSanXuat,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
			END AS TonCuoiKy,
			COALESCE(SUM(QtyOver3M), 0) AS QtyOver3M,
			COALESCE(SUM(QtyOver6M), 0) AS QtyOver6M,
			COALESCE(SUM(QtyOver1Y), 0) AS QtyOver1Y
		FROM (
			SELECT a.PublicCode, a.PartNo, MAX(a6.openninginventory) AS openninginventory,
				CASE WHEN CONVERT(DATE, createdate) < @pFromDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy,
				CASE WHEN CONVERT(DATE, createdate) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy1,
				CASE WHEN CONVERT(DATE, createdate) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS QtyInput,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBan,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuat,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuy,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLai,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhac,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 90  THEN PackQty ELSE 0 END AS QtyOver3M,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 180 THEN PackQty ELSE 0 END AS QtyOver6M,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 365 THEN PackQty ELSE 0 END AS QtyOver1Y
			FROM STB_VN_FINISHGOODS_BG a (NOLOCK)
			LEFT JOIN STB_SetInfo si (NOLOCK) ON a.LotNo = si.Barcode
			LEFT JOIN (SELECT materialcode, openninginventory FROM Stb_InventoryProductLiquidation WITH (NOLOCK) WHERE WorkCenterCode = 'VVT_F2') A6 ON a.PublicCode = A6.MaterialCode
			WHERE Flag = 1
			GROUP BY a.ID, a.PublicCode, a.PartNo, a.CreateDate, a.StatusSystem, a.DateExport, a.TYPEEXPORT, a.Statusout, a.PackQty, a.Flag, si.InputJobDate, a.LotNo
		) AA
		GROUP BY AA.PublicCode, AA.PartNo
	) bg ON Master.PublicCode = bg.PublicCode AND Master.PartNo = bg.PartNo

	-- HƯNG YÊN (HY)
	LEFT JOIN (
		SELECT AA.PublicCode, AA.PartNo,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0)
				ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0)
			END AS TonDauKy,
			COALESCE(SUM(QtyInput), 0)    AS NhapTrongKy,
			COALESCE(SUM(XuatBan), 0)     AS XuatBan,
			COALESCE(SUM(XuatSanXuat), 0) AS XuatSanXuat,
			CASE 
				WHEN @pFromDate = '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				WHEN @pFromDate > '2025-01-01' THEN COALESCE(MAX(openninginventory), 0) + COALESCE(SUM(NhapDauKy1), 0) - COALESCE(SUM(XuatBanDauKy1), 0) - COALESCE(SUM(XuatSanXuatDauKy1), 0) - COALESCE(SUM(XuatTieuHuyDauKy1), 0) - COALESCE(SUM(XuatTraLaiDauKy1), 0) - COALESCE(SUM(XuatKhacDauKy1), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
				ELSE COALESCE(SUM(NhapDauKy), 0) - COALESCE(SUM(XuatBanDauKy), 0) - COALESCE(SUM(XuatSanXuatDauKy), 0) - COALESCE(SUM(XuatTieuHuyDauKy), 0) - COALESCE(SUM(XuatTraLaiDauKy), 0) - COALESCE(SUM(XuatKhacDauKy), 0) + COALESCE(SUM(QtyInput), 0) - COALESCE(SUM(XuatBan), 0) - COALESCE(SUM(XuatTieuHuy), 0) - COALESCE(SUM(XuatTraLai), 0) - COALESCE(SUM(XuatSanXuat), 0) - COALESCE(SUM(XuatKhac), 0)
			END AS TonCuoiKy,
			COALESCE(SUM(QtyOver3M), 0) AS QtyOver3M,
			COALESCE(SUM(QtyOver6M), 0) AS QtyOver6M,
			COALESCE(SUM(QtyOver1Y), 0) AS QtyOver1Y
		FROM (
			SELECT a.PublicCode, a.PartNo, MAX(a6.openninginventory) AS openninginventory,
				CASE WHEN CONVERT(DATE, createdate) < @pFromDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy,
				CASE WHEN CONVERT(DATE, DateExport) < @pFromDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy,
				CASE WHEN CONVERT(DATE, createdate) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS NhapDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBanDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuatDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuyDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLaiDauKy1,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN '2025-01-01' AND @daten AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhacDauKy1,
				CASE WHEN CONVERT(DATE, createdate) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusSystem = N'Nhập' THEN PackQty END AS QtyInput,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XB') THEN PackQty END AS XuatBan,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XSX') THEN PackQty END AS XuatSanXuat,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTH') THEN PackQty END AS XuatTieuHuy,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XTL') THEN PackQty END AS XuatTraLai,
				CASE WHEN CONVERT(DATE, DateExport) BETWEEN @pFromDate AND @pToDate AND Flag = 1 AND statusOut = N'Xuất' AND TYPEEXPORT IN ('XK') THEN PackQty END AS XuatKhac,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 90  THEN PackQty ELSE 0 END AS QtyOver3M,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 180 THEN PackQty ELSE 0 END AS QtyOver6M,
				CASE WHEN Flag = 1 AND statusSystem = N'Nhập' AND (statusOut IS NULL OR statusOut <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, COALESCE(si.InputJobDate, CASE WHEN ISDATE(dbo.fnPharseLotNo(a.LotNo, 'D')) = 1 THEN CONVERT(DATE, dbo.fnPharseLotNo(a.LotNo, 'D')) ELSE NULL END, a.CreateDate)), GETDATE()) >= 365 THEN PackQty ELSE 0 END AS QtyOver1Y
			FROM STB_VN_FINISHGOODS_HY a (NOLOCK)
			LEFT JOIN STB_SetInfo si (NOLOCK) ON a.LotNo = si.Barcode
			LEFT JOIN (SELECT materialcode, openninginventory FROM Stb_InventoryProductLiquidation WITH (NOLOCK) WHERE WorkCenterCode = 'VVT_HY') A6 ON a.PublicCode = A6.MaterialCode
			WHERE Flag = 1
			GROUP BY a.ID, a.PublicCode, a.PartNo, a.CreateDate, a.StatusSystem, a.DateExport, a.TYPEEXPORT, a.Statusout, a.PackQty, a.Flag, si.InputJobDate, a.LotNo
		) AA
		GROUP BY AA.PublicCode, AA.PartNo
	) hy ON Master.PublicCode = hy.PublicCode AND Master.PartNo = hy.PartNo
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
GO

PRINT 'Stored Procedure [dbo].[usp_FinishGoodAllFactoryReport] deployed successfully.'