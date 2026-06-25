-- =============================================
-- Hotfix ID: 05_FIX_RETURNS_FG_IQC_VALIDATION
-- Target Object: usp_DoValidateMaterialDocBarcodeForReturn
-- Author: vanduc
-- Date: 2026-06-10
-- Description: Bỏ qua kiểm tra IQC đối với thành phẩm (FERT) hoặc bán thành phẩm (HALB) 
--              khi làm thủ tục trả hàng, chỉ bắt buộc check IQC đối với NVL nhập mua (ROH).
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;

PRINT 'Starting Hotfix: 05_FIX_RETURNS_FG_IQC_VALIDATION...';

-- 1. Sửa đổi stored procedure
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoValidateMaterialDocBarcodeForReturn')
BEGIN
    EXEC('
    ALTER PROCEDURE [dbo].[usp_DoValidateMaterialDocBarcodeForReturn]
        @pProcessUserID VARCHAR(20),
        @pProcessLanguage VARCHAR(20),
        @pMaterialDocDetailNo VARCHAR(20) = NULL,
        @pBarcode VARCHAR(50) = NULL
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
                @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
                @MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo,			
                @Barcode VARCHAR(50) = @pBarcode,
                @MaterialCode VARCHAR(50),
                @MaterialIqcNo VARCHAR(20),
                @MaterialDocNo VARCHAR(20),
                @MaterialDocType VARCHAR(20),
                @MaterialDocTypeCode VARCHAR(20),
                @CustomerCode VARCHAR(20),
                @DocStatus VARCHAR(20),
                @InspectionType VARCHAR(20),
                @DecisionResult VARCHAR(1),
                @IsRequireQC BIT,
                @MaterialTypeCode VARCHAR(20) -- Thêm biến phân loại vật tư

        SELECT
                @MaterialDocNo = MDI.MaterialDocNo,
                @MaterialDocType = MDI.MaterialDocType,
                @MaterialDocTypeCode = MDI.MaterialDocTypeCode,
                @DocStatus = MDI.DocStatus,
                @MaterialIqcNo = MDD.MaterialIqcNo,
                @CustomerCode = MDI.SourceCustomerCode,
                @MaterialCode  = MDD.MaterialCode,
                @IsRequireQC = MDT.IsRequireQC
        FROM
                STB_MaterialDocDetail MDD WITH(NOLOCK)
                INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)
                    ON	MDI.MaterialDocNo = MDD.MaterialDocNo
                INNER JOIN STB_MaterialDocType MDT WITH(NOLOCK)
                    ON	MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode
        WHERE
                MDD.MaterialDocDetailNo = @MaterialDocDetailNo

        -- Lấy loại vật tư để phân biệt NVL nhập mua (ROH) và Thành phẩm/Bán thành phẩm (FERT/HALB)
        SELECT @MaterialTypeCode = MaterialTypeCode 
          FROM STB_MaterialMaster WITH(NOLOCK) 
         WHERE MaterialCode = @MaterialCode

        IF @MaterialDocType = ''GR'' BEGIN
            IF @DocStatus <> ''ARRIVAL'' BEGIN
                EXEC usp_RaiseLocalizedError	@ProcessLanguage,
                                                ''입하처리가 되지 않았습니다.''
                RETURN
            END

            -- FIX: Chỉ thực hiện check IQC nếu là Nguyên vật liệu mua ngoài (ROH). 
            -- Đối với Thành phẩm (FERT) hoặc Bán thành phẩm (HALB), bỏ qua check IQC.
            IF @IsRequireQC = 1 AND @MaterialTypeCode = ''ROH'' BEGIN
                SELECT
                        @InspectionType = MVM.InspectionType
                FROM
                        STB_MaterialVendorMapping MVM WITH(NOLOCK)
                WHERE
                        MVM.MaterialCode = @MaterialCode AND
                        MVM.CustomerCode = @CustomerCode
                
                IF @InspectionType <> ''NONE'' AND ISNULL(@MaterialIqcNo,'''') = '''' BEGIN
                    EXEC usp_RaiseLocalizedError	@ProcessLanguage,
                                                    ''수입검사의뢰 정보를 찾을 수 없습니다.''
                    RETURN
                END

                SELECT
                        @DecisionResult = MQI.DecisionResult
                FROM
                        STB_MaterialQcInfo MQI WITH(NOLOCK)
                WHERE
                        MQI.MaterialQcNo = @MaterialIqcNo

                IF @DecisionResult <> ''P'' BEGIN
                    EXEC usp_RaiseLocalizedError	@ProcessLanguage,
                                                    ''수입검사 합격처리가 되지 않았습니다.''
                    RETURN
                END
            END
        END

        SELECT
                @MaterialDocNo AS MaterialDocNo,
                @MaterialDocDetailNo AS MaterialDocDetailNo,
                MLI.MaterialLotNo,
                MLI.LotID,
                MLI.MaterialCode,
                MM.MaterialName,
                MM.MaterialTypeCode,
                MT.MaterialTypeName,
                MM.ProductGroupCode,
                PG.ProductGroupName,
                MLI.MaterialStockAttribute,
                MLI.StockAttrib1,
                MLI.StockAttrib2,
                MLI.StockAttrib3,			
                MLI.CurrentQty AS RequestQty,
                MLI.LotNo,
                MLI.LotAttr01,
                MLI.LotAttr02,
                MLI.LotAttr03,
                MLI.LotAttr04,
                MLI.LotAttr05,
                MLI.LotAttr06,
                MLI.LotAttr07,
                MLI.LotAttr08,
                MLI.LotAttr09,
                MLI.LotAttr10
        FROM
                STB_MaterialLotSnapshot MLI WITH(NOLOCK)
                LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
                    ON	MM.MaterialCode = MLI.MaterialCode
                LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
                    ON	MT.MaterialTypeCode = MM.MaterialTypeCode
                LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
                    ON	PG.ProductGroupCode = MM.ProductGroupCode
        WHERE
                MLI.LotID = @Barcode
    END
    ');
    PRINT 'Procedure usp_DoValidateMaterialDocBarcodeForReturn altered successfully.';
END
ELSE
BEGIN
    PRINT 'Error: Procedure usp_DoValidateMaterialDocBarcodeForReturn not found!';
END

-- 2. Chạy thử nghiệm Simulation Test
-- Tạo dữ liệu test
DECLARE @TestDocNo VARCHAR(20) = 'TEST_RET_DOC_01'
DECLARE @TestDetailNo VARCHAR(20) = 'TEST_RET_DET_01'
DECLARE @TestBarcode VARCHAR(20) = 'TEST_RET_BAR_01'

-- Đăng ký loại tài liệu nhập kho GR cần QC
IF NOT EXISTS (SELECT 1 FROM STB_MaterialDocType WHERE MaterialDocTypeCode = 'TEST_RT_TYPE')
    INSERT INTO STB_MaterialDocType (MaterialDocTypeCode, IsRequireQC) VALUES ('TEST_RT_TYPE', 1);

-- Phiếu nhập kho GR
IF NOT EXISTS (SELECT 1 FROM STB_MaterialDocInfo WHERE MaterialDocNo = @TestDocNo)
    INSERT INTO STB_MaterialDocInfo (MaterialDocNo, MaterialDocType, MaterialDocTypeCode, DocStatus, SourceCustomerCode)
    VALUES (@TestDocNo, 'GR', 'TEST_RT_TYPE', 'ARRIVAL', 'CUST_TEST');

-- Snapshot Lot test
IF NOT EXISTS (SELECT 1 FROM STB_MaterialLotSnapshot WHERE LotID = @TestBarcode)
    INSERT INTO STB_MaterialLotSnapshot (LotID, MaterialLotNo, MaterialCode, CurrentQty)
    VALUES (@TestBarcode, 'TEST_LOT_01', 'TEST_FERT_CODE', 100);

-- Test Case 1: Thử với Thành phẩm (MaterialTypeCode = 'FERT') -> Kỳ vọng thành công không ném lỗi IQC
-- Đăng ký mã thành phẩm
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = 'TEST_FERT_CODE')
    INSERT INTO STB_MaterialMaster (MaterialCode, MaterialName, MaterialTypeCode) VALUES ('TEST_FERT_CODE', 'Test Finished Goods', 'FERT');

IF NOT EXISTS (SELECT 1 FROM STB_MaterialDocDetail WHERE MaterialDocDetailNo = @TestDetailNo)
    INSERT INTO STB_MaterialDocDetail (MaterialDocDetailNo, MaterialDocNo, MaterialCode, MaterialIqcNo)
    VALUES (@TestDetailNo, @TestDocNo, 'TEST_FERT_CODE', NULL); -- Không có phiếu IQC

BEGIN TRY
    PRINT 'Test case 1: Finished Goods (FERT) return - Expecting success without IQC check...';
    EXEC usp_DoValidateMaterialDocBarcodeForReturn 'vinaadmin', 'vi-VN', @TestDetailNo, @TestBarcode;
    PRINT 'Test case 1: PASSED.';
END TRY
BEGIN CATCH
    PRINT 'Test case 1: FAILED. Error: ' + ERROR_MESSAGE();
END CATCH;

-- Test Case 2: Thử với Nguyên vật liệu (MaterialTypeCode = 'ROH') -> Kỳ vọng bị chặn vì không có IQC
-- Đăng ký mã NVL
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = 'TEST_ROH_CODE')
    INSERT INTO STB_MaterialMaster (MaterialCode, MaterialName, MaterialTypeCode) VALUES ('TEST_ROH_CODE', 'Test Raw Material', 'ROH');

-- Cập nhật chi tiết phiếu nhập sang ROH
UPDATE STB_MaterialDocDetail SET MaterialCode = 'TEST_ROH_CODE', MaterialIqcNo = NULL WHERE MaterialDocDetailNo = @TestDetailNo;
UPDATE STB_MaterialLotSnapshot SET MaterialCode = 'TEST_ROH_CODE' WHERE LotID = @TestBarcode;

-- Mapping nhà cung cấp yêu cầu kiểm tra
IF NOT EXISTS (SELECT 1 FROM STB_MaterialVendorMapping WHERE MaterialCode = 'TEST_ROH_CODE' AND CustomerCode = 'CUST_TEST')
    INSERT INTO STB_MaterialVendorMapping (MaterialCode, CustomerCode, InspectionType) VALUES ('TEST_ROH_CODE', 'CUST_TEST', 'NORMAL');

BEGIN TRY
    PRINT 'Test case 2: Raw Material (ROH) return without IQC - Expecting failure...';
    EXEC usp_DoValidateMaterialDocBarcodeForReturn 'vinaadmin', 'vi-VN', @TestDetailNo, @TestBarcode;
    PRINT 'Test case 2: FAILED! (Did not block missing IQC)';
END TRY
BEGIN CATCH
    PRINT 'Test case 2: PASSED. Expected error caught: ' + ERROR_MESSAGE();
END CATCH;

-- Dọn dẹp dữ liệu test
DELETE FROM STB_MaterialDocType WHERE MaterialDocTypeCode = 'TEST_RT_TYPE';
DELETE FROM STB_MaterialDocInfo WHERE MaterialDocNo = @TestDocNo;
DELETE FROM STB_MaterialDocDetail WHERE MaterialDocDetailNo = @TestDetailNo;
DELETE FROM STB_MaterialLotSnapshot WHERE LotID = @TestBarcode;
DELETE FROM STB_MaterialMaster WHERE MaterialCode IN ('TEST_FERT_CODE', 'TEST_ROH_CODE');
DELETE FROM STB_MaterialVendorMapping WHERE MaterialCode = 'TEST_ROH_CODE' AND CustomerCode = 'CUST_TEST';

-- 3. Hủy bỏ thay đổi để an toàn
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
