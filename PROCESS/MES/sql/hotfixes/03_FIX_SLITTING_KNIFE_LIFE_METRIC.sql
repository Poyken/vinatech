-- =============================================
-- Hotfix ID: 03_FIX_SLITTING_KNIFE_LIFE_METRIC
-- Target Object: usp_DoCreateSlittingResult
-- Author: vanduc
-- Date: 2026-06-10
-- Description: Đo tuổi thọ dao theo mét cắt (SUM) thay vì đếm số cuộn con (COUNT), 
--              đồng thời gỡ bỏ lọc cứng chi nhánh Bắc Giang để hỗ trợ toàn hệ thống.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;

PRINT 'Starting Hotfix: 03_FIX_SLITTING_KNIFE_LIFE_METRIC...';

-- 1. Sửa đổi stored procedure
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoCreateSlittingResult')
BEGIN
    EXEC('
    ALTER PROCEDURE [dbo].[usp_DoCreateSlittingResult]
        @pProcessUserID VARCHAR(20),
        @pProcessLanguage VARCHAR(20),
        @pElectrodeLotNumber VARCHAR(20) = NULL,
        @pMaterialCode VARCHAR(20) = NULL,
        @pElectrodeThick INT = NULL,
        @pSlittingWidth NUMERIC(20,5) = NULL,
        @pSlittingQty INT = NULL,
        @pGoodQtyLength NUMERIC(20,5) = NULL
    AS
    BEGIN
        Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber
               ,@ElectrodeThick NUMERIC(20,5) = @pElectrodeThick
               ,@SlittingWidth NUMERIC(20,5) = @pSlittingWidth
               ,@SlittingQty INT = @pSlittingQty
               ,@GoodQtyLength NUMERIC(20,5) = @pGoodQtyLength
               ,@SlittingBarcodeSeq INT
               ,@StartNumber INT = 1
               ,@CompanyCode VARCHAR(20) = NULL
               ,@SlittingMatrialCode VARCHAR(20) = @pMaterialCode

        -- Lấy thông tin CompanyCode
        SELECT @CompanyCode = DPP.CompanyCode
          FROM STB_SetInfo SI
          LEFT OUTER JOIN STB_DayProdPlan DPP ON SI.DayPlanNo = DPP.DayPlanNo
         WHERE SI.Barcode = @ElectrodeLotNumber

        DECLARE @MachineCode VARCHAR(30)
        DECLARE @KnifeCheck INT
        DECLARE @KnifeCode VARCHAR(30)
        DECLARE @ProdQtyCheck BIGINT
        DECLARE @StandardQty BIGINT
        DECLARE @SlittingKnifeLotID VARCHAR(30)

        -- Lấy mã máy của Lot hiện tại
        SELECT @MachineCode = MachineCode FROM STB_ElectrodeSlittingInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber

        -- Kiểm tra nếu tồn tại 1 loại dao trong máy hiện tại
        SELECT @KnifeCheck = count(*) FROM STB_VN_SlittingKnifeInUse 
                WHERE UsingStatus = 1 AND MachineCode = @MachineCode

        -- FIX: Thay thế RouteCode = ''V-11_BG'' bằng LIKE ''V-11%'' để hỗ trợ cả Hà Nam/Hưng Yên (ví dụ V-11_HN)
        IF @MachineCode IN (select MachineCode from STB_ProductMachine where RouteCode LIKE ''V-11%'') and @KnifeCheck > 0
            BEGIN
                SELECT @SlittingKnifeLotID = SlittingKnifeLotID,
                        @KnifeCode = SlittingKnifeCode
                        FROM STB_VN_SlittingKnifeInUse 
                        WHERE UsingStatus = 1 AND MachineCode = @MachineCode

                -- FIX: Sử dụng SUM(GoodQtyLength) thay vì COUNT(ProductionQty) để tính chính xác tuổi thọ dao theo mét cắt
                SELECT @ProdQtyCheck = ISNULL(SUM(GoodQtyLength), 0) 
                  FROM STB_ElectrodeSlittingResult 
                 WHERE SlittingKnifeLotID = @SlittingKnifeLotID

                SELECT @StandardQty = StandardQty FROM STB_VN_SlittingKnifeInfo WHERE SlittingKnifeCode = @KnifeCode

                -- Kiểm tra nếu quãng đường cắt thực tế vượt quá tuổi thọ tiêu chuẩn (mét)
                IF(@ProdQtyCheck >= @StandardQty)
                    BEGIN
                        RAISERROR(N''Đã đến giới hạn phải thay dao! Quãng đường cắt: %d m / Tiêu chuẩn: %d m'', 16, 1, @ProdQtyCheck, @StandardQty)
                        RETURN
                    END

                WHILE @StartNumber <= @SlittingQty BEGIN
                    EXEC usp_GetNewSerialNoForBarcode @pProcessUserID, '''', @ElectrodeLotNumber, @SlittingBarcodeSeq OUTPUT

                    INSERT INTO STB_ElectrodeSlittingResult (
                        ElectrodeLotNumber, Seq, ElectrodeThick, SlittingWidth, ProductionQty,
                        GoodQtyLength, CreateDateTime, CreateUserID, SlittingMaterialCode, CompanyCode, WorkCenterCode, SlittingKnifeLotID
                    ) VALUES (
                        @ElectrodeLotNumber, @SlittingBarcodeSeq, @pElectrodeThick, @pSlittingWidth, @GoodQtyLength,
                        @GoodQtyLength, GETDATE(), @pProcessUserID, @SlittingMatrialCode, ''VVT'', ''VVT_F1'', @SlittingKnifeLotID
                    )

                    SET @StartNumber = @StartNumber + 1
                END
            END
        -- FIX: Kiểm tra cho tất cả các máy slitting LIKE ''V-11%'' chứ không riêng gì Bắc Giang
        ELSE IF @MachineCode IN (select MachineCode from STB_ProductMachine where RouteCode LIKE ''V-11%'') and @KnifeCheck = 0
            BEGIN
                RAISERROR(N''Máy hiện tại chưa có dao!'', 16,1)
                RETURN
            END
        ELSE
            BEGIN
                WHILE @StartNumber <= @SlittingQty BEGIN
                    EXEC usp_GetNewSerialNoForBarcode @pProcessUserID, '''', @ElectrodeLotNumber, @SlittingBarcodeSeq OUTPUT

                    INSERT INTO STB_ElectrodeSlittingResult (
                        ElectrodeLotNumber, Seq, ElectrodeThick, SlittingWidth, ProductionQty,
                        GoodQtyLength, CreateDateTime, CreateUserID, SlittingMaterialCode, CompanyCode, WorkCenterCode
                    ) VALUES (
                        @ElectrodeLotNumber, @SlittingBarcodeSeq, @pElectrodeThick, @pSlittingWidth, @GoodQtyLength,
                        @GoodQtyLength, GETDATE(), @pProcessUserID, @SlittingMatrialCode, ''VVT'', ''VVT_F1''
                    )

                    SET @StartNumber = @StartNumber + 1
                END
            END
    END
    ');
    PRINT 'Procedure usp_DoCreateSlittingResult altered successfully.';
END
ELSE
BEGIN
    PRINT 'Error: Procedure usp_DoCreateSlittingResult not found!';
END

-- 2. Chạy thử nghiệm Simulation Test
-- Thiết lập dữ liệu test
DECLARE @TestLot VARCHAR(30) = 'TEST_SLIT_LOT_01'
DECLARE @TestMachine VARCHAR(20) = 'TEST_MCH_01'
DECLARE @TestKnife VARCHAR(20) = 'TEST_KNF_01'
DECLARE @TestKnifeLot VARCHAR(20) = 'TEST_KNF_LOT_01'

IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = @TestLot)
    INSERT INTO STB_SetInfo (Barcode, MaterialCode, CreateDateTime) VALUES (@TestLot, 'ECVT30-333', GETDATE());

IF NOT EXISTS (SELECT 1 FROM STB_ElectrodeSlittingInfo WHERE ElectrodeLotNumber = @TestLot)
    INSERT INTO STB_ElectrodeSlittingInfo (ElectrodeLotNumber, MachineCode) VALUES (@TestLot, @TestMachine);

-- Đăng ký máy slitting giả lập thuộc route V-11_HN (Hà Nam để test gỡ hardcode địa lý)
IF NOT EXISTS (SELECT 1 FROM STB_ProductMachine WHERE MachineCode = @TestMachine AND RouteCode = 'V-11_HN')
    INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode) VALUES (@TestMachine, 'LINE_TEST', 'V-11_HN');

-- Đăng ký dao tiêu chuẩn tuổi thọ 1000m
IF NOT EXISTS (SELECT 1 FROM STB_VN_SlittingKnifeInfo WHERE SlittingKnifeCode = @TestKnife)
    INSERT INTO STB_VN_SlittingKnifeInfo (SlittingKnifeCode, StandardQty, IsUsed) VALUES (@TestKnife, 1000, 1);

-- Gắn dao vào máy
IF NOT EXISTS (SELECT 1 FROM STB_VN_SlittingKnifeInUse WHERE SlittingKnifeLotID = @TestKnifeLot)
    INSERT INTO STB_VN_SlittingKnifeInUse (SlittingKnifeLotID, SlittingKnifeCode, MachineCode, UsingStatus, CreateDateTime)
    VALUES (@TestKnifeLot, @TestKnife, @TestMachine, 1, GETDATE());

-- Trường hợp test 1: Đã cắt 500m (dưới 1000m tiêu chuẩn) -> Kỳ vọng tạo kết quả thành công
DELETE FROM STB_ElectrodeSlittingResult WHERE SlittingKnifeLotID = @TestKnifeLot;
INSERT INTO STB_ElectrodeSlittingResult (ElectrodeLotNumber, Seq, GoodQtyLength, SlittingKnifeLotID, CreateDateTime)
VALUES (@TestLot, 1, 500.0, @TestKnifeLot, GETDATE());

BEGIN TRY
    PRINT 'Test case 1: Expect success (Used 500m < 1000m Standard)...';
    EXEC usp_DoCreateSlittingResult 'vinaadmin', 'vi-VN', @TestLot, 'ECVT30-333', 1, 30.0, 1, 100.0;
    PRINT 'Test case 1: PASSED.';
END TRY
BEGIN CATCH
    PRINT 'Test case 1: FAILED. Error: ' + ERROR_MESSAGE();
END CATCH;

-- Trường hợp test 2: Cắt thêm 600m (Tổng cộng 500 + 100 + 600 = 1200m > 1000m tiêu chuẩn) -> Kỳ vọng chặn và ném lỗi thay dao
INSERT INTO STB_ElectrodeSlittingResult (ElectrodeLotNumber, Seq, GoodQtyLength, SlittingKnifeLotID, CreateDateTime)
VALUES (@TestLot, 2, 600.0, @TestKnifeLot, GETDATE());

BEGIN TRY
    PRINT 'Test case 2: Expect error (Used 1100m > 1000m Standard)...';
    EXEC usp_DoCreateSlittingResult 'vinaadmin', 'vi-VN', @TestLot, 'ECVT30-333', 1, 30.0, 1, 100.0;
    PRINT 'Test case 2: FAILED! (Did not catch error)';
END TRY
BEGIN CATCH
    PRINT 'Test case 2: PASSED. Expected error caught: ' + ERROR_MESSAGE();
END CATCH;

-- Dọn dẹp dữ liệu test
DELETE FROM STB_SetInfo WHERE Barcode = @TestLot;
DELETE FROM STB_ElectrodeSlittingInfo WHERE ElectrodeLotNumber = @TestLot;
DELETE FROM STB_ProductMachine WHERE MachineCode = @TestMachine;
DELETE FROM STB_VN_SlittingKnifeInfo WHERE SlittingKnifeCode = @TestKnife;
DELETE FROM STB_VN_SlittingKnifeInUse WHERE SlittingKnifeLotID = @TestKnifeLot;
DELETE FROM STB_ElectrodeSlittingResult WHERE SlittingKnifeLotID = @TestKnifeLot OR ElectrodeLotNumber = @TestLot;

-- 3. Hủy bỏ thay đổi để an toàn
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
