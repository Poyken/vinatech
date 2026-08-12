-- ==============================================================================
-- SCRIPT CẬP NHẬT STORED PROCEDURE: usp_FinishGoodReportTK
-- MÀN HÌNH: [FG02] Tổng hợp kho thành phẩm Bắc Ninh
-- THAM CHIẾU 100% ĐỒNG BỘ THEO MÀN [FG20] (usp_FinishGoodAllFactoryReport):
--   - Model: Tách từ PartNo bằng CROSS APPLY (parse dấu ngoặc đơn hoặc mapping đặc biệt)
--   - Đơn giá (UnitPrice): Lấy từ bảng STB_InventoryOfGoodsReport (màn B943) join qua ItemCodeVN (PublicCode) và fallback ItemCodeKorea (MaterialCode)
-- BỔ SUNG ĐẦY ĐỦ 8 CỘT THEO YÊU CẦU:
--   1. Model (Cột Model tách từ PartNo như FG20)
--   2. UnitPrice (Đơn giá như FG20)
--   3. QtyOver3M (Tồn > 3 tháng)
--   4. QtyOver6M (Tồn > 6 tháng)
--   5. QtyOver1Y (Tồn > 1 năm)
--   6. AmountOver3M (Tổng tiền tồn > 3 tháng = QtyOver3M * UnitPrice)
--   7. AmountOver6M (Tổng tiền tồn > 6 tháng = QtyOver6M * UnitPrice)
--   8. AmountOver1Y (Tổng tiền tồn > 1 năm = QtyOver1Y * UnitPrice)
-- ==============================================================================

USE [SmartFactoryV2]
GO

IF OBJECT_ID('dbo.usp_FinishGoodReportTK', 'P') IS NOT NULL
BEGIN
    PRINT 'Updating Stored Procedure [dbo].[usp_FinishGoodReportTK]...'
END
GO

ALTER PROCEDURE [dbo].[usp_FinishGoodReportTK]
    @pFromDate DATE = NULL,
    @pToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @daten DATE = DATEADD(DAY, -1, @pFromDate)

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
        FinalReport.TonCuoiKy,

        -- 8 CỘT BỔ SUNG ĐỒNG BỘ VỚI FG20 VÀ TUỔI HÀNG
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

            -- Tính tồn kho quá 3M, 6M, 1Y từ các lô tồn thực tế (chưa xuất)
            COALESCE(SUM(QtyOver3M), 0) AS QtyOver3M,
            COALESCE(SUM(QtyOver6M), 0) AS QtyOver6M,
            COALESCE(SUM(QtyOver1Y), 0) AS QtyOver1Y

        FROM (
            SELECT 
                a.PublicCode, 
                a.PartNo,
                MAX(MC.MaterialCode) AS MaterialCode,
                M.Model,
                MAX(a6.openninginventory) AS openninginventory,

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

                -- Phân loại tuổi tồn kho cho các lô hàng hiện tại chưa xuất (tính từ CreateDate)
                CASE WHEN a.Flag = 1 AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, a.CreateDate), GETDATE()) >= 90  THEN a.PackQty ELSE 0 END AS QtyOver3M,
                CASE WHEN a.Flag = 1 AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, a.CreateDate), GETDATE()) >= 180 THEN a.PackQty ELSE 0 END AS QtyOver6M,
                CASE WHEN a.Flag = 1 AND a.StatusSystem = N'Nhập' AND (a.Statusout IS NULL OR a.Statusout <> N'Xuất') AND DATEDIFF(DAY, CONVERT(DATE, a.CreateDate), GETDATE()) >= 365 THEN a.PackQty ELSE 0 END AS QtyOver1Y

            FROM STB_VN_FINISHGOODS_BG a (NOLOCK)
            LEFT JOIN (
                SELECT PublicCode, MAX(NULLIF(MaterialCode, '')) AS MaterialCode
                FROM STB_VN_FINISHGOODS_BG
                WHERE MaterialCode IS NOT NULL AND MaterialCode <> ''
                GROUP BY PublicCode
            ) MC ON a.PublicCode = MC.PublicCode
            LEFT JOIN (
                SELECT materialcode, openninginventory 
                FROM Stb_InventoryProductLiquidation FIM WITH (NOLOCK) 
                WHERE FIM.WorkCenterCode = 'VVT_F1'
            ) A6 ON a.PublicCode = A6.MaterialCode
            CROSS APPLY (
                -- LOGIC MODEL ĐỒNG BỘ 100% THEO FG20 (usp_FinishGoodAllFactoryReport)
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
            GROUP BY a.ID, a.PublicCode, a.PartNo, M.Model, a.CreateDate, a.StatusSystem, a.DateExport, a.TYPEEXPORT, a.Statusout, a.PackQty, a.Flag
        ) AA
        GROUP BY AA.PublicCode, AA.PartNo, AA.Model, AA.MaterialCode
    ) FinalReport
    -- LOGIC ĐƠN GIÁ ĐỒNG BỘ 100% THEO FG20 (LẤY TỪ MÀN B943 STB_InventoryOfGoodsReport)
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
    ORDER BY FinalReport.PublicCode
END
GO

PRINT 'Stored Procedure [dbo].[usp_FinishGoodReportTK] updated successfully matching FG20.'
