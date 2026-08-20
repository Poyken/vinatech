
CREATE PROC [dbo].[usp_VN_ShowAllFinishGoodMES_HY]
/*
    Mục đích : Tra cứu hàng thành phẩm kho HY
    Tham số  :
        @pFromdateinput / @pTodateinput  — khoảng ngày NHẬP kho (dùng khi @TypeInput = N'Nhập')
        @TypeInput                        — N'Nhập' | N'Xuất' | NULL/'' (lấy tất cả)
        @pFromdateExp   / @pTodateExp    — khoảng ngày XUẤT kho (dùng khi @TypeInput = N'Xuất')

    Ví dụ:
        EXEC dbo.usp_VN_ShowAllFinishGoodMES_HY '2026-06-01','2026-06-18', N'Nhập', NULL, NULL
        EXEC dbo.usp_VN_ShowAllFinishGoodMES_HY NULL, NULL, N'Xuất', '2026-06-01','2026-06-18'
        EXEC dbo.usp_VN_ShowAllFinishGoodMES_HY NULL, NULL, NULL, NULL, NULL
*/
    @pFromdateinput DATE        = NULL,
    @pTodateinput   DATE        = NULL,
    @TypeInput      NVARCHAR(50)= NULL,
    @pFromdateExp   DATE        = NULL,
    @pTodateExp     DATE        = NULL
AS
BEGIN
    SET NOCOUNT ON

    IF OBJECT_ID('tempdb..#T1') IS NOT NULL DROP TABLE #T1
    IF OBJECT_ID('tempdb..#T2') IS NOT NULL DROP TABLE #T2

    DECLARE @FromDate    DATE         = @pFromdateinput
    DECLARE @ToDate      DATE         = @pTodateinput
    DECLARE @FromDateExp DATE         = @pFromdateExp
    DECLARE @ToDateExp   DATE         = @pTodateExp
    DECLARE @Input       NVARCHAR(50) = @TypeInput

    -- Nhập kho — lọc theo ngày nhập (CreateDate)
    IF @Input = N'Nhập'
    BEGIN
        SELECT
            T1.CUSTOMERNAME,
            T1.TRANSPORT,
            T1.ID,
            T1.SoPhieuNhapKho,
            T1.SoPhieuXuatKho,
            T1.SoInVoice,
            T1.SoToKhaiHaiQuan,
            T1.IDCODE,
            REPLACE(T1.PublicCode, ' ', '')         AS PublicCode,
            T1.Country,
            T1.PackingID,
            T1.LotNo,
            T1.MaterialCode,
            T1.MaterialName,
            T1.ProductionSize,
            T1.PackQty,
            T1.EmpNo,
            T1.CreatDatePacked                      AS PackedDate,
            RIGHT(T1.CreatDatePacked, 8)            AS TimePacked,
            REPLACE(T1.PartNo, ' ', '')             AS PartNo,
            T1.TypeProduction,
            T1.StatusSystem,
            T1.Statusout,
            T1.CreateDate                           AS CreateDateIn,
            RIGHT(T1.CreateDate, 8)                 AS TimeIn,
            T1.USERID                               AS PersonIn,
            T1.PersonExport,
            T1.DateExport                           AS DateExports,
            RIGHT(T1.DateExport, 8)                 AS TimeOute,
            T1.CreateDateChange                     AS CreateDateOut,
            RIGHT(T1.CreateDateChange, 8)           AS TimeOuts,
            T1.USERIDChange                         AS PersonOut,
            T1.Descrption,
            T1.Levels,
            T1.LevelsOut,
            T1.INPUTFROM,
            T1.LOCATIONS,
            T1.TYPEEXPORT,
            -- Phân loại xuất bán/ nội bộ
            CASE
                WHEN T1.Country IN (
                    N'Mỹ (America)', N'Trung Quốc (China)', N'Pháp (France)',
                    N'Đài loan (Taiwan)', N'Hàn Quốc (Korea)', N'Tây Ban Nha (Spain)',
                    N'Nga (Russia)', N'Bỉ (Belgium)', N'Hongkong', N'Ấn Độ (India)',
                    N'Anh Quốc (English)', N'Thái Lan (Thalan)', N'Đức (Germany)',
                    N'Special IND(Italy)', N'SATCO(Sweden)', N'Singapore',
                    N'Hà lan (Netherlands)', N'Poland(Phần Lan)', N'Israel',
                    N'SLOVENIA', N'South Africa', N'Shanghai', N'Finland', N'Broad Band'
                ) THEN N'Xuất Bán'
                WHEN T1.Country IN (
                    N'QA', N'Module', N'Đóng gói (Packing)', N'Sản Xuất (Production)'
                ) THEN N'Nội Bộ'
                ELSE T1.Country
            END                                     AS Contrys,
            -- Đơn giá thành tiền từ bảng giá
            ISNULL(pl.UnitPrice, 0)                 AS Prices,
            ISNULL(T1.PackQty * pl.UnitPrice, 0)    AS Price,
            -- Kiểm tra PartNo
            (
                SELECT COUNT(*)
                FROM dbo.fn_VVT_PartnoModel_HY()
                WHERE partno = T1.PartNo
                  AND modelname = T1.MaterialName
            )                                       AS CheckPartno,
            -- Hàng tồn quá 365 ngày
            CASE
                WHEN DATEDIFF(day, ISNULL(si.InputJobDate, GETDATE()-366), GETDATE()) > 365
                THEN 1 ELSE 0
            END                                     AS BackLog_Inventory
        INTO #T1
        FROM dbo.STB_VN_FINISHGOODS_HY_NEW T1 WITH(NOLOCK)
        LEFT JOIN dbo.STB_SetInfo          si WITH(NOLOCK)
               ON T1.LotNo = si.Barcode
        LEFT JOIN dbo.STB_PriceList_HY     pl
               ON REPLACE(T1.PublicCode, ' ', '') = pl.PublicCode
        WHERE ISNULL(T1.Flag, 1) = 1

        SELECT *
        FROM #T1
        WHERE ( @FromDate IS NULL OR CONVERT(DATE, CreateDateIn) >= @FromDate )
          AND ( @ToDate   IS NULL OR CONVERT(DATE, CreateDateIn) <= @ToDate   )
        ORDER BY CreateDateIn DESC

        DROP TABLE #T1
        RETURN
    END

    -- Xuất kho 
    IF @Input = N'Xuất'
    BEGIN
        SELECT
            T1.ID,
            T1.CUSTOMERNAME,
            T1.TRANSPORT,
            T1.SoPhieuNhapKho,
            T1.SoPhieuXuatKho,
            T1.SoInVoice,
            T1.SoToKhaiHaiQuan,
            T1.IDCODE,
            REPLACE(T1.PublicCode, ' ', '')         AS PublicCode,
            T1.Country,
            T1.PackingID,
            T1.LotNo,
            T1.MaterialCode,
            T1.MaterialName,
            T1.ProductionSize,
            T1.PackQty,
            T1.EmpNo,
            T1.CreatDatePacked                      AS PackedDate,
            RIGHT(T1.CreatDatePacked, 8)            AS TimePacked,
            REPLACE(T1.PartNo, ' ', '')             AS PartNo,
            T1.TypeProduction,
            T1.StatusSystem,
            T1.Statusout,
            T1.CreateDate                           AS CreateDateIn,
            RIGHT(T1.CreateDate, 8)                 AS TimeIn,
            T1.USERID                               AS PersonIn,
            T1.PersonExport,
            T1.DateExport                           AS DateExports,
            RIGHT(T1.DateExport, 8)                 AS TimeOute,
            T1.CreateDateChange                     AS CreateDateOut,
            RIGHT(T1.CreateDateChange, 8)           AS TimeOuts,
            T1.USERIDChange                         AS PersonOut,
            T1.Descrption,
            T1.Levels,
            T1.LevelsOut,
            T1.INPUTFROM,
            T1.LOCATIONS,
            T1.TYPEEXPORT,
            CASE
                WHEN T1.Country IN (
                    N'Mỹ (America)', N'Trung Quốc (China)', N'Pháp (France)',
                    N'Đài loan (Taiwan)', N'Hàn Quốc (Korea)', N'Tây Ban Nha (Spain)',
                    N'Nga (Russia)', N'Bỉ (Belgium)', N'Hongkong', N'Ấn Độ (India)',
                    N'Anh Quốc (English)', N'Thái Lan (Thalan)', N'Đức (Germany)',
                    N'Special IND(Italy)', N'SATCO(Sweden)', N'Singapore',
                    N'Hà lan (Netherlands)', N'Poland(Phần Lan)', N'Israel',
                    N'SLOVENIA', N'South Africa', N'Shanghai', N'Finland', N'Broad Band'
                ) THEN N'Xuất Bán'
                WHEN T1.Country IN (
                    N'QA', N'Module', N'Đóng gói (Packing)', N'Sản Xuất (Production)'
                ) THEN N'Nội Bộ'
                ELSE T1.Country
            END                                     AS Contrys,
            ISNULL(pl.UnitPrice, 0)                 AS Prices,
            ISNULL(T1.PackQty * pl.UnitPrice, 0)    AS Price,
            (
                SELECT COUNT(*)
                FROM dbo.fn_VVT_PartnoModel_HY()
                WHERE partno = T1.PartNo
                  AND modelname = T1.MaterialName
            )                                       AS CheckPartno,
            CASE
                WHEN DATEDIFF(day, ISNULL(si.InputJobDate, GETDATE()-366), GETDATE()) > 365
                THEN 1 ELSE 0
            END                                     AS BackLog_Inventory
        INTO #T2
        FROM dbo.STB_VN_FINISHGOODS_HY_NEW T1 WITH(NOLOCK)
        LEFT JOIN dbo.STB_SetInfo          si WITH(NOLOCK)
               ON T1.LotNo = si.Barcode
        LEFT JOIN dbo.STB_PriceList_HY     pl
               ON REPLACE(T1.PublicCode, ' ', '') = pl.PublicCode
        WHERE ISNULL(T1.Flag, 1) = 1
          AND T1.DateExport IS NOT NULL

        SELECT *
        FROM #T2
        WHERE ( @FromDateExp IS NULL OR CONVERT(DATE, DateExports) >= @FromDateExp )
          AND ( @ToDateExp   IS NULL OR CONVERT(DATE, DateExports) <= @ToDateExp   )
        ORDER BY DateExports DESC

        DROP TABLE #T2
        RETURN
    END

    --Tất cả — không filter ngày
    SELECT
        T1.ID,
        T1.CUSTOMERNAME,
        T1.TRANSPORT,
        T1.SoPhieuNhapKho,
        T1.SoPhieuXuatKho,
        T1.SoInVoice,
        T1.SoToKhaiHaiQuan,
        T1.IDCODE,
        REPLACE(T1.PublicCode, ' ', '')         AS PublicCode,
        T1.Country,
        T1.PackingID,
        T1.LotNo,
        T1.MaterialCode,
        T1.MaterialName,
        T1.ProductionSize,
        T1.PackQty,
        T1.EmpNo,
        T1.CreatDatePacked                      AS PackedDate,
        RIGHT(T1.CreatDatePacked, 8)            AS TimePacked,
        REPLACE(T1.PartNo, ' ', '')             AS PartNo,
        T1.TypeProduction,
        T1.StatusSystem,
        T1.Statusout,
        T1.CreateDate                           AS CreateDateIn,
        RIGHT(T1.CreateDate, 8)                 AS TimeIn,
        T1.USERID                               AS PersonIn,
        T1.PersonExport,
        T1.DateExport                           AS DateExports,
        RIGHT(T1.DateExport, 8)                 AS TimeOute,
        T1.CreateDateChange                     AS CreateDateOut,
        RIGHT(T1.CreateDateChange, 8)           AS TimeOuts,
        T1.USERIDChange                         AS PersonOut,
        T1.Descrption,
        T1.Levels,
        T1.LevelsOut,
        T1.INPUTFROM,
        T1.LOCATIONS,
        T1.TYPEEXPORT,
        CASE
            WHEN T1.Country IN (
                N'Mỹ (America)', N'Trung Quốc (China)', N'Pháp (France)',
                N'Đài loan (Taiwan)', N'Hàn Quốc (Korea)', N'Tây Ban Nha (Spain)',
                N'Nga (Russia)', N'Bỉ (Belgium)', N'Hongkong', N'Ấn Độ (India)',
                N'Anh Quốc (English)', N'Thái Lan (Thalan)', N'Đức (Germany)',
                N'Special IND(Italy)', N'SATCO(Sweden)', N'Singapore',
                N'Hà lan (Netherlands)', N'Poland(Phần Lan)', N'Israel',
                N'SLOVENIA', N'South Africa', N'Shanghai', N'Finland', N'Broad Band'
            ) THEN N'Xuất Bán'
            WHEN T1.Country IN (
                N'QA', N'Module', N'Đóng gói (Packing)', N'Sản Xuất (Production)'
            ) THEN N'Nội Bộ'
            ELSE T1.Country
        END                                     AS Contrys,
        ISNULL(pl.UnitPrice, 0)                 AS Prices,
        ISNULL(T1.PackQty * pl.UnitPrice, 0)    AS Price,
        (
            SELECT COUNT(*)
            FROM dbo.fn_VVT_PartnoModel_HY()
            WHERE partno = T1.PartNo
              AND modelname = T1.MaterialName
        )                                       AS CheckPartno,
        CASE
            WHEN DATEDIFF(day, ISNULL(si.InputJobDate, GETDATE()-366), GETDATE()) > 365
            THEN 1 ELSE 0
        END                                     AS BackLog_Inventory
    FROM dbo.STB_VN_FINISHGOODS_HY_NEW T1 WITH(NOLOCK)
    LEFT JOIN dbo.STB_SetInfo          si WITH(NOLOCK)
           ON T1.LotNo = si.Barcode
    LEFT JOIN dbo.STB_PriceList_HY     pl
           ON REPLACE(T1.PublicCode, ' ', '') = pl.PublicCode
    WHERE ISNULL(T1.Flag, 1) = 1

END
