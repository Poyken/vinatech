-- =============================================
-- TEST chặn NVL Module cho RDMD00-266
-- Chạy SAU KHI deploy script chính (COMMIT)
-- =============================================

-- Test 1: ModuleWire scan đúng → PASS
PRINT '=== TEST 1: Wire scan đúng (WRHI00-007) ==='
EXEC usp_Vietnam_RawMaterialInputHist_uid
    @pProcessUserID = 'test_ducnv',
    @pProcessLanguage = 'vi',
    @pBarcode = 'MVVQO186R030632',       -- lot sản phẩm RDMD00-266 thật
    @pProductGroupCode = 'ModuleWire',
    @pRawMaterialBarcode = 'ml20260213000112',  -- lot WRHI00-007 thật
    @pMaterialCode = 'WRHI00-007'
GO

-- Test 2: ModuleWire gõ tay → BLOCK
PRINT '=== TEST 2: Wire gõ tay "40" → phải BLOCK ==='
BEGIN TRY
    EXEC usp_Vietnam_RawMaterialInputHist_uid
        @pProcessUserID = 'test_ducnv',
        @pProcessLanguage = 'vi',
        @pBarcode = 'MVVQO186R030632',
        @pProductGroupCode = 'ModuleWire',
        @pRawMaterialBarcode = '40',
        @pMaterialCode = 'WRHI00-007'
    PRINT 'FAIL — không bị chặn!'
END TRY
BEGIN CATCH
    PRINT 'OK — Bị chặn: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 3: ModuleChip gõ "0" → PASS (bỏ qua giá trị 0)
PRINT '=== TEST 3: Chip nhập "0" → phải PASS ==='
EXEC usp_Vietnam_RawMaterialInputHist_uid
    @pProcessUserID = 'test_ducnv',
    @pProcessLanguage = 'vi',
    @pBarcode = 'MVVQO186R030632',
    @pProductGroupCode = 'ModuleChip',
    @pRawMaterialBarcode = '0',
    @pMaterialCode = 'VRE-009'
GO

-- Test 4: ModulePCB gõ "dm" → BLOCK
PRINT '=== TEST 4: PCB gõ "dm" → phải BLOCK ==='
BEGIN TRY
    EXEC usp_Vietnam_RawMaterialInputHist_uid
        @pProcessUserID = 'test_ducnv',
        @pProcessLanguage = 'vi',
        @pBarcode = 'MVVQO186R030632',
        @pProductGroupCode = 'ModulePCB',
        @pRawMaterialBarcode = 'dm',
        @pMaterialCode = 'PBDM00-004'
    PRINT 'FAIL — không bị chặn!'
END TRY
BEGIN CATCH
    PRINT 'OK — Bị chặn: ' + ERROR_MESSAGE()
END CATCH
GO

-- Test 5: Model khác (không phải RDMD00-266) → PASS (không ảnh hưởng)
PRINT '=== TEST 5: Model khác → phải PASS (không chặn) ==='
EXEC usp_Vietnam_RawMaterialInputHist_uid
    @pProcessUserID = 'test_ducnv',
    @pProcessLanguage = 'vi',
    @pBarcode = 'MVVQM283R060610',       -- lot model khác
    @pProductGroupCode = 'ModuleWire',
    @pRawMaterialBarcode = '40',
    @pMaterialCode = 'WRHI00-007'
GO
