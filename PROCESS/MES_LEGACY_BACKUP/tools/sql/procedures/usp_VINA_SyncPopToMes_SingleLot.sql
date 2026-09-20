-- =====================================================================================
-- Stored Procedure: [dbo].[usp_VINA_SyncPopToMes_SingleLot]
-- Description     : Đồng bộ tức thì (<0.05s) dữ liệu từng Lot sang MES (STB_ProdRouteHist).
--                   HỖ TRỢ 2 CHẾ ĐỘ:
--                   1. Chỉ định @pRouteCode: Chỉ đồng bộ đúng 1 công đoạn đó.
--                   2. Bỏ trống @pRouteCode (NULL): Tự động quét toàn bộ các công đoạn đã
--                      hoàn thành (IsDone=1) của Lot trên Kiosk POP.
--                   NGUYÊN TẮC AN TOÀN (Idempotent):
--                   - Công đoạn ĐÃ CÓ trong MES ➔ TỰ ĐỘNG BỎ QUA (Skip), không nhân đôi.
--                   - Công đoạn CHƯA CÓ trong MES ➔ Chốt bù sinh số Serial chuẩn qua usp_DoCreateSerial.
--                   - Công đoạn CHƯA XONG trên POP (IsDone=0) ➔ Tự động bỏ qua.
--                   - BẮT BUỘC nhập mã người thực hiện (@pProcessUserID), không để mặc định.
-- Author          : Vinatech IT MES / vanduc
-- Updated Date    : 2026-09-21
-- =====================================================================================

CREATE   PROCEDURE [dbo].[usp_VINA_SyncPopToMes_SingleLot]
    @pBarcode       VARCHAR(50),
    @pRouteCode     VARCHAR(20) = NULL,
    @pProcessUserID VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- 1. Kiểm tra tham số bắt buộc
    IF ISNULL(@pBarcode, '') = ''
    BEGIN
        RAISERROR(N'Lỗi: Mã Barcode (@pBarcode) không được để trống!', 16, 1);
        RETURN -1;
    END

    IF ISNULL(@pProcessUserID, '') = ''
    BEGIN
        RAISERROR(N'Lỗi: Vui lòng nhập mã người thực hiện (@pProcessUserID), không được để trống!', 16, 1);
        RETURN -1;
    END

    -- 2. Kiểm tra Lot tồn tại trong STB_SetInfo
    DECLARE @ControlNo      VARCHAR(20);
    DECLARE @PONo           VARCHAR(20);
    DECLARE @MaterialCode   VARCHAR(30);

    SELECT 
        @ControlNo      = ControlNo,
        @PONo           = PONo,
        @MaterialCode   = MaterialCode
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
    WHERE Barcode = @pBarcode;

    IF @ControlNo IS NULL
    BEGIN
        RAISERROR(N'Lỗi: Không tìm thấy thông tin Barcode %s trong STB_SetInfo!', 16, 1, @pBarcode);
        RETURN -2;
    END

    -- 3. Xác định Master Data dùng chung: WorkCenterCode & BomVersion
    DECLARE @WorkCenterCode VARCHAR(20);
    SELECT TOP 1 @WorkCenterCode = WorkCenterCode
    FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = @ControlNo AND ISNULL(WorkCenterCode, '') <> '';

    IF @WorkCenterCode IS NULL
    BEGIN
        SELECT TOP 1 @WorkCenterCode = WorkCenterCode
        FROM SmartFactoryV2.dbo.STB_DayProdPlan WITH(NOLOCK)
        WHERE DayPlanNo = (SELECT TOP 1 DayPlanNo FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) WHERE Barcode = @pBarcode);
    END

    IF @WorkCenterCode IS NULL SET @WorkCenterCode = 'VVT_F5';

    DECLARE @BomVersion VARCHAR(20);
    SELECT TOP 1 @BomVersion = BomVersion 
    FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = @ControlNo AND ISNULL(BomVersion, '') <> '';

    IF @BomVersion IS NULL SET @BomVersion = '2001';

    -- 4. Bảng tạm chứa danh sách công đoạn cần quét từ MongoToMesPerformance
    IF OBJECT_ID('tempdb..#RoutesToProcess') IS NOT NULL DROP TABLE #RoutesToProcess;
    CREATE TABLE #RoutesToProcess (
        ID              INT IDENTITY(1,1) PRIMARY KEY,
        RouteCode       VARCHAR(20),
        DayPlanNo       VARCHAR(20),
        LineCode        VARCHAR(20),
        MachineCode     VARCHAR(50),
        WorkerCode      VARCHAR(20),
        ProdQty         DECIMAL(18,5),
        ProdDateTime    DATETIME,
        IsDone          BIT,
        AlreadyInMes    BIT DEFAULT 0
    );

    INSERT INTO #RoutesToProcess (RouteCode, DayPlanNo, LineCode, MachineCode, WorkerCode, ProdQty, ProdDateTime, IsDone, AlreadyInMes)
    SELECT 
        MMP.RouteCode,
        MMP.DayPlanNo,
        MMP.LineCode,
        COALESCE(
            NULLIF(LTRIM(RTRIM(MMP.MachineCode)), ''),
            (SELECT TOP 1 EM.EQUIPMENT_ID 
             FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING EM WITH(NOLOCK) 
             WHERE EM.DAY_PLAN_NO = MMP.DayPlanNo AND EM.ROUTE_CODE = MMP.RouteCode AND EM.MAPPING_STATUS = 'ACTIVE'),
            (SELECT TOP 1 DP.MachineCode 
             FROM SmartFactoryV2.dbo.STB_DayProdPlan DP WITH(NOLOCK) 
             WHERE DP.DayPlanNo = MMP.DayPlanNo AND ISNULL(DP.MachineCode, '') <> ''),
            NULL
        ) AS MachineCode,
        MMP.CreateUserId,
        CAST(MMP.TotalProdQty AS DECIMAL(18,5)),
        ISNULL(MMP.InsertDateTime, MMP.ModifyDateTime) AS ProdDateTime,
        MMP.IsDone,
        CASE WHEN EXISTS (
            SELECT 1 FROM SmartFactoryV2.dbo.STB_ProdRouteHist PRH WITH(NOLOCK)
            WHERE PRH.ControlNo = @ControlNo AND PRH.RouteCode = MMP.RouteCode
        ) THEN 1 ELSE 0 END AS AlreadyInMes
    FROM SmartFactoryV2.dbo.MongoToMesPerformance MMP WITH(NOLOCK)
    WHERE MMP.Barcode = @pBarcode
      AND (ISNULL(@pRouteCode, '') = '' OR MMP.RouteCode = @pRouteCode);

    IF NOT EXISTS (SELECT 1 FROM #RoutesToProcess)
    BEGIN
        IF ISNULL(@pRouteCode, '') <> ''
            RAISERROR(N'Lỗi: Không tìm thấy công đoạn %s của Barcode %s trên MongoToMesPerformance!', 16, 1, @pRouteCode, @pBarcode);
        ELSE
            RAISERROR(N'Lỗi: Không tìm thấy bất kỳ công đoạn nào của Barcode %s trên MongoToMesPerformance!', 16, 1, @pBarcode);
        RETURN -3;
    END

    -- 5. Bảng tạm lưu trữ kết quả xử lý
    IF OBJECT_ID('tempdb..#SyncResults') IS NOT NULL DROP TABLE #SyncResults;
    CREATE TABLE #SyncResults (
        ProdRouteHistNo VARCHAR(20),
        ControlNo       VARCHAR(20),
        Barcode         VARCHAR(50),
        MaterialCode    VARCHAR(30),
        RouteCode       VARCHAR(20),
        LineCode        VARCHAR(20),
        MachineCode     VARCHAR(50),
        ProdQty         DECIMAL(18,5),
        ProdDateTime    DATETIME,
        JobDate         VARCHAR(10),
        ShiftCode       VARCHAR(10),
        CreateUserID    VARCHAR(20),
        SyncStatus      NVARCHAR(150)
    );

    -- 6. Duyệt từng công đoạn và xử lý an toàn
    DECLARE @CurID             INT = 1;
    DECLARE @MaxID             INT = (SELECT MAX(ID) FROM #RoutesToProcess);
    DECLARE @CurRouteCode      VARCHAR(20);
    DECLARE @CurDayPlanNo      VARCHAR(20);
    DECLARE @CurLineCode       VARCHAR(20);
    DECLARE @CurMachineCode    VARCHAR(50);
    DECLARE @CurWorkerCode     VARCHAR(20);
    DECLARE @CurProdQty        DECIMAL(18,5);
    DECLARE @CurProdDateTime   DATETIME;
    DECLARE @CurIsDone         BIT;
    DECLARE @CurAlreadyInMes   BIT;

    WHILE @CurID <= @MaxID
    BEGIN
        SELECT 
            @CurRouteCode      = RouteCode,
            @CurDayPlanNo      = DayPlanNo,
            @CurLineCode       = LineCode,
            @CurMachineCode    = MachineCode,
            @CurWorkerCode     = WorkerCode,
            @CurProdQty        = ProdQty,
            @CurProdDateTime   = ProdDateTime,
            @CurIsDone         = IsDone,
            @CurAlreadyInMes   = AlreadyInMes
        FROM #RoutesToProcess
        WHERE ID = @CurID;

        -- Trường hợp 1: Công đoạn chưa hoàn thành trên Kiosk (IsDone = 0)
        IF @CurIsDone <> 1
        BEGIN
            INSERT INTO #SyncResults (ControlNo, Barcode, MaterialCode, RouteCode, LineCode, MachineCode, ProdQty, ProdDateTime, CreateUserID, SyncStatus)
            VALUES (@ControlNo, @pBarcode, @MaterialCode, @CurRouteCode, @CurLineCode, @CurMachineCode, @CurProdQty, @CurProdDateTime, @pProcessUserID, 
                    N'Bỏ qua (Chưa hoàn thành trên POP Kiosk - IsDone=0)');
        END
        -- Trường hợp 2: Công đoạn đã có sẵn trong MES ➔ BỎ QUA ĐỂ CHỐNG TRÙNG LẶP
        ELSE IF @CurAlreadyInMes = 1
        BEGIN
            INSERT INTO #SyncResults (ProdRouteHistNo, ControlNo, Barcode, MaterialCode, RouteCode, LineCode, MachineCode, ProdQty, ProdDateTime, JobDate, ShiftCode, CreateUserID, SyncStatus)
            SELECT TOP 1
                PRH.ProdRouteHistNo, @ControlNo, @pBarcode, @MaterialCode, @CurRouteCode, PRH.LineCode, PRH.MachineCode, PRH.ProdQty, PRH.ProdDateTime, PRH.JobDate, PRH.ShiftCode, PRH.CreateUserID,
                N'Đã tồn tại trong MES (Bỏ qua để tránh nhân đôi sản lượng)'
            FROM SmartFactoryV2.dbo.STB_ProdRouteHist PRH WITH(NOLOCK)
            WHERE PRH.ControlNo = @ControlNo AND PRH.RouteCode = @CurRouteCode;
        END
        -- Trường hợp 3: Đã xong trên POP (IsDone=1) và CHƯA CÓ trong MES ➔ THỰC HIỆN ĐỒNG BỘ BÙ
        ELSE
        BEGIN
            -- Tính chu kỳ ca cắt lúc 10:00:00 sáng dựa trên thời điểm sản xuất gốc
            DECLARE @JobDate VARCHAR(10) = CASE 
                WHEN CAST(@CurProdDateTime AS TIME) >= '10:00:00' THEN CONVERT(VARCHAR(10), @CurProdDateTime, 120)
                ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, @CurProdDateTime), 120)
            END;

            DECLARE @ShiftCode VARCHAR(10) = CASE 
                WHEN CAST(@CurProdDateTime AS TIME) >= '10:00:00' AND CAST(@CurProdDateTime AS TIME) < '20:30:00' THEN '1'
                ELSE '2'
            END;

            BEGIN TRANSACTION;
            BEGIN TRY
                DECLARE @NewHistNo VARCHAR(20);
                EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist', @NewHistNo OUTPUT;

                INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHist (
                    ProdRouteHistNo, CompanyCode, WorkCenterCode, PONo, DayPlanNo,
                    ControlNo, MaterialCode, BomVersion, JobDate, ShiftCode, TimeCode,
                    LineCode, RouteCode, WorkerCode, MachineCode, ProdQty,
                    ProdDateTime, CreateDateTime, CreateUserID, CompleteRoute
                )
                VALUES (
                    @NewHistNo, 'VVT', @WorkCenterCode, @PONo, @CurDayPlanNo,
                    @ControlNo, @MaterialCode, @BomVersion, @JobDate, @ShiftCode, '*',
                    @CurLineCode, @CurRouteCode, @CurWorkerCode, @CurMachineCode, @CurProdQty,
                    @CurProdDateTime, GETDATE(), @pProcessUserID, '1'
                );

                -- Cập nhật trạng thái công đoạn hiện tại trên STB_SetInfo
                UPDATE SmartFactoryV2.dbo.STB_SetInfo
                SET CurrentRouteCode = @CurRouteCode,
                    ChangeDateTime = GETDATE(),
                    ChangeUserID = @pProcessUserID
                WHERE ControlNo = @ControlNo;

                UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
                SET IsTransferred  = 1,
                    ModifyDateTime = GETDATE()
                WHERE Barcode = @pBarcode 
                  AND RouteCode = @CurRouteCode;

                COMMIT TRANSACTION;

                INSERT INTO #SyncResults (ProdRouteHistNo, ControlNo, Barcode, MaterialCode, RouteCode, LineCode, MachineCode, ProdQty, ProdDateTime, JobDate, ShiftCode, CreateUserID, SyncStatus)
                VALUES (@NewHistNo, @ControlNo, @pBarcode, @MaterialCode, @CurRouteCode, @CurLineCode, @CurMachineCode, @CurProdQty, @CurProdDateTime, @JobDate, @ShiftCode, @pProcessUserID,
                        N'Đồng bộ thành công sang MES');
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                INSERT INTO #SyncResults (ControlNo, Barcode, MaterialCode, RouteCode, LineCode, MachineCode, ProdQty, ProdDateTime, CreateUserID, SyncStatus)
                VALUES (@ControlNo, @pBarcode, @MaterialCode, @CurRouteCode, @CurLineCode, @CurMachineCode, @CurProdQty, @CurProdDateTime, @pProcessUserID,
                        N'Lỗi: ' + ERROR_MESSAGE());
            END CATCH;
        END

        SET @CurID = @CurID + 1;
    END;

    -- 7. Trả bảng tổng kết tất cả các công đoạn đã kiểm tra
    SELECT 
        ProdRouteHistNo,
        ControlNo,
        Barcode,
        MaterialCode,
        RouteCode,
        LineCode,
        MachineCode,
        ProdQty,
        ProdDateTime,
        JobDate,
        ShiftCode,
        CreateUserID,
        SyncStatus
    FROM #SyncResults
    ORDER BY RouteCode ASC;

    DROP TABLE #RoutesToProcess;
    DROP TABLE #SyncResults;
END;