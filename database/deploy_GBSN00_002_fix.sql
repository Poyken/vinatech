-- =============================================
-- DEPLOY SCRIPT: Add exception for GBSN00-002 lot 12SR03-4628
-- Author: Antigravity AI Assistant
-- Date: 2026-05-11
-- Purpose: Add specific case to read lot 12SR03-4628 as 2024-06-28
-- =============================================

-- STEP 1: Backup current function (SELECT only)
SELECT 
    OBJECT_DEFINITION(OBJECT_ID('dbo.fn_VVT_getdatebyVendorLot_MergeCode')) AS CurrentFunctionDefinition
WHERE OBJECT_ID('dbo.fn_VVT_getdatebyVendorLot_MergeCode') IS NOT NULL;

-- STEP 2: Test current function with the specific lot
SELECT 
    'BEFORE_UPDATE' AS Status,
    [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GBSN00-002','12SR03-4628','') AS CurrentResult;

-- STEP 3: Apply the change (ALTER FUNCTION)
-- Note: This will replace the entire function with the updated version
-- Please review the complete function definition before executing

-- The actual ALTER statement needs to be executed manually in SSMS
-- after reviewing the complete function definition in fn_VVT_getdatebyVendorLot_MergeCode.sql

-- STEP 4: Verify after update (run this after ALTER)
-- SELECT 
--     'AFTER_UPDATE' AS Status,
--     [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GBSN00-002','12SR03-4628','') AS NewResult;

-- STEP 5: Test other lots to ensure no regression
-- SELECT [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('GBSN00-002','12SR07-5N21','') AS ExistingLotTest;

PRINT '=== DEPLOY INSTRUCTIONS ===';
PRINT '1. Run STEP 1-2 to backup and test current state';
PRINT '2. Open fn_VVT_getdatebyVendorLot_MergeCode.sql in SSMS';
PRINT '3. Execute ALTER FUNCTION to apply changes';
PRINT '4. Run STEP 4-5 to verify deployment';
PRINT '5. Expected result for lot 12SR03-4628: 2024-06-28';
