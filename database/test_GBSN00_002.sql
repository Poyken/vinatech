-- ============================================================================
-- Regression: parse vendor lot — Material GBSN00-002, LotNo 12SR03-4628
-- Kỳ vọng tài liệu workspace: ngày 2024-06-28 (chỉ kiểm tra phần DATE).
-- DB: SmartFactoryV2. Chạy sau khi đã kết nối đúng database.
-- Tham chiếu: KB_02 (F330 đặc tính 10), DataFlow (fn_VVT_getdatebyVendorLot).
-- ============================================================================

DECLARE @MaterialCode NVARCHAR(100) = N'GBSN00-002';
DECLARE @LotNo NVARCHAR(200) = N'12SR03-4628';

IF OBJECT_ID(N'dbo.fn_VVT_getdatebyVendorLot', N'FN') IS NOT NULL
    SELECT
        N'dbo.fn_VVT_getdatebyVendorLot' AS FunctionUsed,
        dbo.fn_VVT_getdatebyVendorLot(@MaterialCode, @LotNo) AS ParsedValue,
        CAST(dbo.fn_VVT_getdatebyVendorLot(@MaterialCode, @LotNo) AS DATE) AS ParsedDate;
ELSE IF OBJECT_ID(N'dbo.fn_VVT_getdatebyVendorLot_MergeCode', N'FN') IS NOT NULL
    SELECT
        N'dbo.fn_VVT_getdatebyVendorLot_MergeCode' AS FunctionUsed,
        dbo.fn_VVT_getdatebyVendorLot_MergeCode(@MaterialCode, @LotNo) AS ParsedValue,
        CAST(dbo.fn_VVT_getdatebyVendorLot_MergeCode(@MaterialCode, @LotNo) AS DATE) AS ParsedDate;
ELSE
    SELECT
        CAST(NULL AS NVARCHAR(128)) AS FunctionUsed,
        CAST(NULL AS DATETIME) AS ParsedValue,
        CAST(NULL AS DATE) AS ParsedDate,
        N'Chưa thấy function — export: SELECT OBJECT_DEFINITION(OBJECT_ID(''dbo.fn_VVT_getdatebyVendorLot''));' AS Hint;

-- Expected ParsedDate = 2024-06-28 (xác nhận lại trên server thật).
