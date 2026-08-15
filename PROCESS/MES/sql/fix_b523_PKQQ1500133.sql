-- ====================================================================
-- SCRIPT FIX DỨT ĐIỂM NGUYÊN NHÂN GỐC LỖI IN TEM B523 (STB_VIETNAM_BARCODEWEIGHT)
-- Database: SmartFactoryV2
-- File: sql/fix_b523_PKQQ1500133.sql
-- ====================================================================
USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Nạp cân nặng vào STB_VIETNAM_BARCODEWEIGHT (Khắc phục nguyên nhân gốc gây ra FormatName lỗi)
    IF NOT EXISTS (SELECT 1 FROM STB_VIETNAM_BARCODEWEIGHT WHERE BARCODE = 'VVQQ143R850605')
    BEGIN
        INSERT INTO STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, CREATEDATETIME)
        VALUES ('VVQQ143R850605', 25.5, GETDATE());
    END;

    IF NOT EXISTS (SELECT 1 FROM STB_VIETNAM_BARCODEWEIGHT WHERE BARCODE = 'VVPN263R850606')
    BEGIN
        INSERT INTO STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, CREATEDATETIME)
        VALUES ('VVPN263R850606', 25.5, GETDATE());
    END;

    -- 2. Nạp bản ghi cân kho cho Mã MỚI VVQQ143R850605 (Nếu chưa có)
    IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS WHERE PackingID = 'PKQQ1500133' AND LotNo = 'VVQQ143R850605')
    BEGIN
        INSERT INTO STB_VN_FINISHGOODS (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
        VALUES ('FGVN_BN' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '-', ''), 'PKQQ1500133', 'VVQQ143R850605', 'LIVT38-018', 'VEL08253R8506G-B034', 2800, 'vvtworker_BG', CONVERT(VARCHAR(10), GETDATE(), 110), 'VEL08253R8506G-B034', GETDATE());
    END;

    -- 3. Nạp bản ghi cân kho cho Mã CŨ VVPN263R850606 (Nếu chưa có)
    IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS WHERE PackingID = 'PKQQ1500133' AND LotNo = 'VVPN263R850606')
    BEGIN
        INSERT INTO STB_VN_FINISHGOODS (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
        VALUES ('FGVN_BN' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '-', '') + 'A', 'PKQQ1500133', 'VVPN263R850606', 'LIVT38-018', 'VEL08253R8506G-B034', 2800, 'vvtworker_BG', CONVERT(VARCHAR(10), GETDATE(), 110), 'VEL08253R8506G-B034', GETDATE());
    END;

    -- 4. Nạp bản ghi kho Bắc Giang tương ứng cho cả 2 mã
    IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG WHERE PackingID = 'PKQQ1500133' AND LotNo = 'VVQQ143R850605')
    BEGIN
        INSERT INTO STB_VN_FINISHGOODS_BG (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
        VALUES ('FGVN_BG' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '-', ''), 'PKQQ1500133', 'VVQQ143R850605', 'LIVT38-018', 'VEL08253R8506G-B034', 2800, 'vvtworker_BG', CONVERT(VARCHAR(10), GETDATE(), 110), 'VEL08253R8506G-B034', GETDATE());
    END;

    IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG WHERE PackingID = 'PKQQ1500133' AND LotNo = 'VVPN263R850606')
    BEGIN
        INSERT INTO STB_VN_FINISHGOODS_BG (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
        VALUES ('FGVN_BG' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '-', '') + 'A', 'PKQQ1500133', 'VVPN263R850606', 'LIVT38-018', 'VEL08253R8506G-B034', 2800, 'vvtworker_BG', CONVERT(VARCHAR(10), GETDATE(), 110), 'VEL08253R8506G-B034', GETDATE());
    END;

    -- 5. Giữ nguyên OldBarcode = VVPN263R850606 để gõ mã cũ VVPN... vẫn tìm ra lô hàng
    UPDATE STB_LotChangeMaterialHistory SET OldBarcode = 'VVPN263R850606' WHERE NewBarcode = 'VVQQ143R850605';
    UPDATE STB_MaterialLotInfo SET LotNo = 'VVQQ143R850605' WHERE PackingID = 'PKQQ1500133';

    -- 6. Đặt cờ cho phép in tem trong STB_PackingLabelPrintHist
    UPDATE STB_PackingLabelPrintHist SET IsPrintAllow = 1, PrintCount = 0 WHERE PackingID = 'PKQQ1500133';

    COMMIT TRANSACTION;
    PRINT N'SUCCESS: Đã khôi phục OldBarcode = VVPN263R850606 để ô search gõ mã cũ hay mã mới đều nạp lô hàng!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'LỖI: ' + ERROR_MESSAGE();
END CATCH;
GO
