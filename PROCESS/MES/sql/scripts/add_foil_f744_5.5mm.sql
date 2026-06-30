-- SCRIPT THÊM MÃ FOIL CHO MÀN HÌNH F744
-- Dành cho user chạy trên SSMS (Mặc định bọc ROLLBACK TRAN để kiểm tra trước)

BEGIN TRAN;

-- 1. Thêm mã foil U199-58.8VFS 5.5mm (mã 10199058855) vào danh mục vật tư STB_MaterialMaster nếu chưa có
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = '10199058855')
BEGIN
    INSERT INTO STB_MaterialMaster (
        MaterialCode, MaterialName, MaterialTypeCode, ProductGroupCode, MaterialUnit,
        IsDelegate, IsInternalProd, IsProdPlan, IsPurchase, IsOrder, IsUseFlush, IsUseBackFlush, IsClosed, IsRequireOqc,
        MMExtInt01, CreateDateTime, CreateUserID
    )
    VALUES (
        '10199058855', N'ANODE FOIL U199 58.8VFS 5.5mm', 'ROH', 'ANODE-FOIL', 'M2',
        0, 0, 0, 1, 1, 0, 0, 1, 0,
        36, GETDATE(), 'vanduc'
    );
    PRINT 'Inserted 10199058855 into STB_MaterialMaster';
END
ELSE
BEGIN
    PRINT '10199058855 already exists in STB_MaterialMaster';
END

-- 2. Thêm thuộc tính tồn kho (F110) cho mã 10199058855 nếu chưa có
IF NOT EXISTS (SELECT 1 FROM STB_MaterialStockAttributeInfo WHERE MaterialCode = '10199058855')
BEGIN
    INSERT INTO STB_MaterialStockAttributeInfo (
        MaterialCode, IsUseBarcode, IsLotUse, IsVendorLotUse, IsUseVendorBarcode, IsLifetimeUse, IsFIFO, SaftyStock, CreateDateTime, CreateUserID
    )
    VALUES (
        '10199058855', 1, 1, 0, 0, 0, 1, 0, GETDATE(), 'vanduc'
    );
    PRINT 'Inserted 10199058855 into STB_MaterialStockAttributeInfo';
END
ELSE
BEGIN
    PRINT '10199058855 already exists in STB_MaterialStockAttributeInfo';
END

-- 3. Thêm cấu hình chiều rộng Slitting 5.5mm (F744) cho U199-58.8VFS (10199058855) nếu chưa có
IF NOT EXISTS (SELECT 1 FROM STB_WidthSlitting WHERE MaterialCode = '10199058855')
BEGIN
    INSERT INTO STB_WidthSlitting (
        MaterialCode, Width, MaterialUnit, IsUsed, CreateDateTime, CreateUserID
    )
    VALUES (
        '10199058855', 5.5000000000, 'M2', 1, GETDATE(), 'vanduc'
    );
    PRINT 'Inserted 10199058855 into STB_WidthSlitting';
END
ELSE
BEGIN
    PRINT '10199058855 already exists in STB_WidthSlitting';
END

-- 4. Thêm cấu hình chiều rộng Slitting 5.5mm (F744) cho U140-162VFS (10140162055) nếu chưa có
IF NOT EXISTS (SELECT 1 FROM STB_WidthSlitting WHERE MaterialCode = '10140162055')
BEGIN
    INSERT INTO STB_WidthSlitting (
        MaterialCode, Width, MaterialUnit, IsUsed, CreateDateTime, CreateUserID
    )
    VALUES (
        '10140162055', 5.5000000000, 'M2', 1, GETDATE(), 'vanduc'
    );
    PRINT 'Inserted 10140162055 into STB_WidthSlitting';
END
ELSE
BEGIN
    PRINT '10140162055 already exists in STB_WidthSlitting';
END

-- Hãy chạy COMMIT hoặc ROLLBACK tùy thuộc kết quả kiểm tra
-- COMMIT TRAN; -- Uncomment dòng này khi bạn sẵn sàng áp dụng thay đổi vào Database
ROLLBACK TRAN; -- Mặc định rollback để chạy thử an toàn
