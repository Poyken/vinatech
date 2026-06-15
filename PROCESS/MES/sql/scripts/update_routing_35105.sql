-- =================================================================================
-- Script: Cấu hình quy trình mới cho Model 35105 (Mã hàng: ECVT30-357)
-- Quy trình mới: Aging -> Phân cấp -> Đóng gói -> 7 ngày sau Ngoại quan -> Kiểm tra lại
-- Thực hiện trên database: SmartFactoryV2
-- Lưu ý: Kiểm tra kỹ kết quả SELECT trước khi sửa 'ROLLBACK' thành 'COMMIT'
-- =================================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY
    PRINT '---------------------------------------------------------';
    PRINT '1. KHỞI TẠO ĐỊNH TUYẾN CƠ BẢN MỚI: MainRoutingRubAging_35105';
    PRINT '---------------------------------------------------------';
    
    IF NOT EXISTS (SELECT 1 FROM STB_BasicRoutingInfo WHERE BasicRoutingCode = 'MainRoutingRubAging_35105')
    BEGIN
        INSERT INTO STB_BasicRoutingInfo (BasicRoutingCode, BasicRoutingName, CreateDateTime, CreateUserID)
        VALUES ('MainRoutingRubAging_35105', N'Routing for Model 35105 (Aging->Phan Cap->Dong Goi->Ngoai Quan->Kiem Tra Lai)', GETDATE(), 'vanduc');
        PRINT '-> Đã thêm BasicRoutingInfo: MainRoutingRubAging_35105';
    END
    ELSE
    BEGIN
        PRINT '-> BasicRoutingInfo MainRoutingRubAging_35105 đã tồn tại.';
    END

    -- Xóa các bước cũ nếu chạy lại script
    DELETE FROM STB_BasicRoutingDetail WHERE BasicRoutingCode = 'MainRoutingRubAging_35105';

    -- Chèn 9 bước định tuyến cho cả 2 nhà máy (Bắc Ninh sử dụng V-xx, Bắc Giang sử dụng V-xx_BG)
    INSERT INTO STB_BasicRoutingDetail (BasicRoutingCode, RouteCode, RouteIndex, IsInputRoute, IsOutputRoute, CreateDateTime, CreateUserID)
    VALUES
    ('MainRoutingRubAging_35105', 'V-22', 1, 1, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-22_BG', 1, 1, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-23', 2, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-23_BG', 2, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-24', 3, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-24_BG', 3, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-25', 4, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-25_BG', 4, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-26', 5, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-26_BG', 5, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-29', 6, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-29_BG', 6, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-28', 7, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-28_BG', 7, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-27', 8, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-27_BG', 8, 0, 0, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-34', 9, 0, 1, GETDATE(), 'vanduc'),
    ('MainRoutingRubAging_35105', 'V-34_BG', 9, 0, 1, GETDATE(), 'vanduc');
    PRINT '-> Đã chèn 9 bước định tuyến chi tiết vào STB_BasicRoutingDetail.';

    PRINT '---------------------------------------------------------';
    PRINT '2. CẬP NHẬT MODEL MASTER: ECVT30-357';
    PRINT '---------------------------------------------------------';
    
    UPDATE STB_MaterialMaster
    SET BasicRoutingCode = 'MainRoutingRubAging_35105'
    WHERE MaterialCode = 'ECVT30-357';
    PRINT '-> Đã cập nhật BasicRoutingCode cho model ECVT30-357 trong STB_MaterialMaster.';

    PRINT '---------------------------------------------------------';
    PRINT '3. CẬP NHẬT MAPPING CÔNG ĐOẠN ĐƠN GIÁ: STB_VVT_StagePrices';
    PRINT '---------------------------------------------------------';
    
    UPDATE STB_VVT_StagePrices
    SET RouteV29 = 'V-29', RouteV34 = 'V-34'
    WHERE model = 'ECVT30-357';
    PRINT '-> Đã thiết lập RouteV29 = V-29 và RouteV34 = V-34 trong STB_VVT_StagePrices.';

    PRINT '---------------------------------------------------------';
    PRINT '4. CẬP NHẬT ĐỊNH TUYẾN CÁC PO (PRODUCTION ORDER) ĐANG HOẠT ĐỘNG';
    PRINT '---------------------------------------------------------';
    
    -- 4.1 Cập nhật BasicRoutingCode cho các PO chưa cancel và chưa finish
    UPDATE STB_ProductionOrderInfo
    SET BasicRoutingCode = 'MainRoutingRubAging_35105'
    WHERE MaterialCode = 'ECVT30-357' AND IsCancel = 0 AND IsFinish = 0;
    PRINT '-> Đã cập nhật BasicRoutingCode cho các PO đang hoạt động trong STB_ProductionOrderInfo.';

    -- 4.2 Lấy danh sách PO đang hoạt động
    DECLARE @ActivePOs TABLE (PONo VARCHAR(20));
    INSERT INTO @ActivePOs (PONo)
    SELECT PONo 
    FROM STB_ProductionOrderInfo WITH(NOLOCK)
    WHERE MaterialCode = 'ECVT30-357' AND IsCancel = 0 AND IsFinish = 0;

    -- 4.3 Xóa các bước định tuyến cũ trong STB_ProductionOrderRouting
    DELETE POR
    FROM STB_ProductionOrderRouting POR
    INNER JOIN @ActivePOs AP ON POR.PONo = AP.PONo;
    PRINT '-> Đã xóa định tuyến cũ cho các PO đang hoạt động trong STB_ProductionOrderRouting.';

    -- 4.4 Chèn định tuyến mới phù hợp với WorkCenterCode của từng PO
    INSERT INTO STB_ProductionOrderRouting (PONo, RouteCode, RouteIndex, IsInputRoute, IsOutputRoute, CreateDateTime, CreateUserID)
    SELECT 
        PO.PONo, 
        BRD.RouteCode, 
        BRD.RouteIndex, 
        BRD.IsInputRoute, 
        BRD.IsOutputRoute, 
        GETDATE(), 
        'vanduc'
    FROM STB_ProductionOrderInfo PO WITH(NOLOCK)
    INNER JOIN STB_BasicRoutingDetail BRD WITH(NOLOCK) ON PO.BasicRoutingCode = BRD.BasicRoutingCode
    WHERE PO.MaterialCode = 'ECVT30-357' 
      AND PO.IsCancel = 0 
      AND PO.IsFinish = 0
      AND (
          (PO.WorkCenterCode IN ('VVT_F2', 'VVT_BG', 'VVT_BG1', 'VVT_BG2') AND BRD.RouteCode LIKE '%_BG')
          OR (PO.WorkCenterCode IN ('VNT_F1', 'VNT') AND BRD.RouteCode NOT LIKE '%_BG' AND BRD.RouteCode NOT LIKE '%_HY' AND BRD.RouteCode NOT LIKE '%_HN')
          OR (PO.WorkCenterCode = 'VVT_F3' AND BRD.RouteCode LIKE '%_HN')
      );
    PRINT '-> Đã chèn định tuyến mới tương ứng cho các PO đang hoạt động.';

    -- ---------------------------------------------------------------------------------
    -- PHẦN SELECT ĐỂ KIỂM TRA LẠI (VERIFICATION CHECKS)
    -- ---------------------------------------------------------------------------------
    PRINT '---------------------------------------------------------';
    PRINT '5. ĐỐI SOÁT DỮ LIỆU SAU THAO TÁC';
    PRINT '---------------------------------------------------------';

    -- Check 1: Xem BasicRoutingCode của MaterialMaster
    SELECT MaterialCode, BasicRoutingCode AS MM_BasicRoutingCode 
    FROM STB_MaterialMaster 
    WHERE MaterialCode = 'ECVT30-357';

    -- Check 2: Xem StagePrices mapping
    SELECT model, RouteV29, PriceV29, RouteV34, PriceV34 
    FROM STB_VVT_StagePrices 
    WHERE model = 'ECVT30-357';

    -- Check 3: Xem định tuyến của một vài PO hoạt động
    SELECT TOP 30 POR.PONo, PO.WorkCenterCode, POR.RouteIndex, POR.RouteCode, POR.IsInputRoute, POR.IsOutputRoute
    FROM STB_ProductionOrderRouting POR
    INNER JOIN STB_ProductionOrderInfo PO ON POR.PONo = PO.PONo
    WHERE PO.MaterialCode = 'ECVT30-357' AND PO.IsCancel = 0 AND PO.IsFinish = 0
    ORDER BY POR.PONo, POR.RouteIndex;

    -- ⚠️ THAY THẾ 'ROLLBACK' THÀNH 'COMMIT' KHI ĐÃ XÁC NHẬN DỮ LIỆU ĐỐI SOÁT OK
    ROLLBACK TRANSACTION;
    -- COMMIT TRANSACTION;
    
    PRINT '-> Đã rollback TRANSACTION thành công (An toàn).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '-> Có lỗi xảy ra. Đã rollback TRANSACTION!';
    THROW;
END CATCH
GO
