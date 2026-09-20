-- =====================================================================================
-- Stored Procedure: [dbo].[usp_VINA_SyncPopToMes_SingleLot]
-- Description     : Đồng bộ tức thì (<0.05s) dữ liệu từng Lot/Công đoạn từ POP Kiosk
--                   (bảng MongoToMesPerformance) sang MES (bảng STB_ProdRouteHist).
--                   Tự động sinh số ProdRouteHistNo chuẩn qua usp_DoCreateSerial,
--                   bảo toàn triggers ESM/Line, và chặn chống trùng lặp dữ liệu (Idempotent).
-- Author          : Vinatech IT MES / vanduc
-- Created Date    : 2026-09-21
-- =====================================================================================

CREATE OR ALTER PROCEDURE [dbo].[usp_VINA_SyncPopToMes_SingleLot]
    @pBarcode       VARCHAR(50),
    @pRouteCode     VARCHAR(20),
    @pProcessUserID VARCHAR(20) = 'vanduc'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- 1. Kiểm tra tham số đầu vào
    IF ISNULL(@pBarcode, '') = '' OR ISNULL(@pRouteCode, '') = ''
    BEGIN
        RAISERROR(N'Lỗi: Mã Barcode và RouteCode không được để trống!', 16, 1);
        RETURN -1;
    END

    -- Đảm bảo UserID luôn chuẩn hóa theo người thực hiện
    IF ISNULL(@pProcessUserID, '') = '' SET @pProcessUserID = 'vanduc';

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

    -- 3. Kiểm tra bản ghi hoàn thành trên MongoToMesPerformance
    DECLARE @DayPlanNo      VARCHAR(20);
    DECLARE @LineCode       VARCHAR(20);
    DECLARE @WorkerCode     VARCHAR(20);
    DECLARE @ProdQty        DECIMAL(18,5);
    DECLARE @ModifyDateTime DATETIME;
    DECLARE @IsDone         BIT;

    SELECT 
        @DayPlanNo      = DayPlanNo,
        @LineCode       = LineCode,
        @WorkerCode     = CreateUserId,
        @ProdQty        = CAST(TotalProdQty AS DECIMAL(18,5)),
        @ModifyDateTime = ModifyDateTime,
        @IsDone         = IsDone
    FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
    WHERE Barcode = @pBarcode 
      AND RouteCode = @pRouteCode;

    IF @DayPlanNo IS NULL
    BEGIN
        RAISERROR(N'Lỗi: Không tìm thấy dữ liệu Barcode %s và công đoạn %s trên MongoToMesPerformance!', 16, 1, @pBarcode, @pRouteCode);
        RETURN -3;
    END

    IF @IsDone <> 1
    BEGIN
        RAISERROR(N'Lỗi: Công đoạn %s của Barcode %s chưa hoàn thành trên Kiosk POP (IsDone <> 1)!', 16, 1, @pRouteCode, @pBarcode);
        RETURN -4;
    END

    -- 4. Chống trùng lặp (Idempotency): Kiểm tra đã có trong STB_ProdRouteHist chưa
    IF EXISTS (
        SELECT 1 FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
        WHERE ControlNo = @ControlNo AND RouteCode = @pRouteCode
    )
    BEGIN
        RAISERROR(N'Cảnh báo: Công đoạn %s của Lot %s đã tồn tại trong STB_ProdRouteHist. Thao tác bị hủy để tránh nhân đôi sản lượng!', 16, 1, @pRouteCode, @pBarcode);
        RETURN 0;
    END

    -- 5. Xác định WorkCenterCode, BomVersion, JobDate và ShiftCode theo quy chuẩn MES
    DECLARE @WorkCenterCode VARCHAR(20);
    SELECT TOP 1 @WorkCenterCode = WorkCenterCode
    FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = @ControlNo AND ISNULL(WorkCenterCode, '') <> '';

    IF @WorkCenterCode IS NULL
    BEGIN
        SELECT TOP 1 @WorkCenterCode = WorkCenterCode
        FROM SmartFactoryV2.dbo.STB_DayProdPlan WITH(NOLOCK)
        WHERE DayPlanNo = @DayPlanNo;
    END

    IF @WorkCenterCode IS NULL SET @WorkCenterCode = 'VVT_F5';

    DECLARE @BomVersion VARCHAR(20);
    SELECT TOP 1 @BomVersion = BomVersion 
    FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = @ControlNo AND ISNULL(BomVersion, '') <> '';

    IF @BomVersion IS NULL SET @BomVersion = '2001';

    -- Chu kỳ ca làm việc: Cắt ca lúc 10:00:00 sáng
    DECLARE @JobDate VARCHAR(10) = CASE 
        WHEN CAST(@ModifyDateTime AS TIME) >= '10:00:00' THEN CONVERT(VARCHAR(10), @ModifyDateTime, 120)
        ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, @ModifyDateTime), 120)
    END;

    DECLARE @ShiftCode VARCHAR(10) = CASE 
        WHEN CAST(@ModifyDateTime AS TIME) >= '10:00:00' AND CAST(@ModifyDateTime AS TIME) < '20:30:00' THEN '1'
        ELSE '2'
    END;

    -- 6. Thực thi Transaction sinh Serial và Insert
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @NewHistNo VARCHAR(20);
        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist', @NewHistNo OUTPUT;

        INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHist (
            ProdRouteHistNo, CompanyCode, WorkCenterCode, PONo, DayPlanNo,
            ControlNo, MaterialCode, BomVersion, JobDate, ShiftCode,
            LineCode, RouteCode, WorkerCode, MachineCode, ProdQty,
            ProdDateTime, CreateDateTime, CreateUserID, CompleteRoute
        )
        VALUES (
            @NewHistNo, 'VVT', @WorkCenterCode, @PONo, @DayPlanNo,
            @ControlNo, @MaterialCode, @BomVersion, @JobDate, @ShiftCode,
            @LineCode, @pRouteCode, @WorkerCode, NULL, @ProdQty,
            @ModifyDateTime, GETDATE(), @pProcessUserID, NULL
        );

        -- Cập nhật cờ đã chuyển giao trên MongoToMesPerformance
        UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
        SET IsTransferred  = 1,
            ModifyDateTime = GETDATE()
        WHERE Barcode = @pBarcode 
          AND RouteCode = @pRouteCode;

        COMMIT TRANSACTION;

        -- 7. Trả kết quả về cho người dùng / ứng dụng
        SELECT 
            PRH.ProdRouteHistNo,
            PRH.ControlNo,
            @pBarcode AS Barcode,
            PRH.MaterialCode,
            PRH.RouteCode,
            PRH.LineCode,
            PRH.ProdQty,
            PRH.ProdDateTime,
            PRH.JobDate,
            PRH.ShiftCode,
            PRH.CreateUserID,
            N'Đồng bộ thành công sang MES' AS SyncStatus
        FROM SmartFactoryV2.dbo.STB_ProdRouteHist PRH WITH(NOLOCK)
        WHERE PRH.ProdRouteHistNo = @NewHistNo;

        RETURN 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
