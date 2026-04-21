-- ============================================================
-- BƯỚC 3: CẤU HÌNH NAIS SCREEN (SmartFramework DB)
-- Đăng ký màn hình SRT_D00 vào hệ thống NAIS
-- ============================================================

USE SmartFramework;
GO

-- Kiểm tra và đăng ký Serial Number Rule cho bảng mới
IF NOT EXISTS (
    SELECT 1 FROM dbo.STB_SerialRule WHERE TableName = 'STB_VVT_SortingErrorData'
)
BEGIN
    INSERT INTO dbo.STB_SerialRule (TableName, SerialColumnName, PrefixData, SerialLen, IsAutoKey, IsLoopIUD, UseYN)
    VALUES ('STB_VVT_SortingErrorData', 'SortingErrorNo', 'SRT', 17, 1, 0, 'Y');
    PRINT 'Đã đăng ký Serial Rule cho STB_VVT_SortingErrorData.';
END
ELSE
    PRINT 'Serial Rule đã tồn tại.';
GO

-- ============================================================
-- BƯỚC 4: KIỂM TRA KẾT QUẢ TOÀN BỘ
-- Chạy trên SmartFactoryV2
-- ============================================================

USE SmartFactoryV2;
GO

-- 4.1 Kiểm tra bảng tồn tại
SELECT 
    'TABLE EXISTS' AS CheckType,
    name AS ObjectName, 
    create_date
FROM sys.tables 
WHERE name = 'STB_VVT_SortingErrorData';

-- 4.2 Kiểm tra 2 SP tồn tại
SELECT 
    'SP EXISTS' AS CheckType,
    name AS ObjectName,
    create_date,
    modify_date
FROM sys.procedures 
WHERE name IN ('usp_VVT_SortingErrorData_get', 'usp_VVT_SortingErrorData_iud');

-- 4.3 Test gọi SP Search (với kết quả rỗng vì chưa có data)
EXEC usp_VVT_SortingErrorData_get
    @pProcessUserID   = 'vinaadmin',
    @pProcessLanguage = 'VI',
    @pProcessViewName = 'SortingData',
    @pSortingDateFrom = '2026-01-01',
    @pSortingDateTo   = '2026-12-31',
    @pMaterialType    = NULL,
    @pFactoryName     = NULL,
    @pMaterialCode    = NULL;

-- 4.4 Test insert 1 dòng mẫu (AL Case)
BEGIN TRAN;

    DECLARE @testNo VARCHAR(20) = 'SRT_TEST_001';
    INSERT INTO STB_VVT_SortingErrorData (
        SortingErrorNo, SortingDate, Shift, PersonName, VendorCode, FactoryName,
        MaterialCode, LotNo, MaterialType, QtyCheck, QtyOK,
        ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALLoiKhacOther,
        CreateDateTime, CreateUserID
    )
    VALUES (
        @testNo, '2026-04-21', 'A', N'Nguyễn Thị Test', 'TNS', N'Bắc Ninh',
        '3505', 'LOT-TEST-001', 'ALCASE', 2430, 2400,
        5, 3, 2, 1, 1,
        GETDATE(), 'vinaadmin'
    );

    -- Kiểm tra dòng vừa insert
    SELECT SortingErrorNo, SortingDate, Shift, PersonName, MaterialType,
           QtyCheck, QtyOK, ALBuiDust, ALMoDent,
           (ALBuiDust + ALMoDent + ALMepDeform + ALXuocScratch + ALLoiKhacOther) AS TotalDefect
    FROM STB_VVT_SortingErrorData 
    WHERE SortingErrorNo = @testNo;

ROLLBACK; -- Rollback dòng test, không lưu vào DB thật
PRINT 'Test INSERT thành công! (Đã ROLLBACK - không lưu vào DB)';
GO
