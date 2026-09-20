-- ==============================================================================
-- HOTFIX SCRIPT: B725_Backup_And_Delete_Inventory_Records
-- Date: 2026-09-02
-- Target Database: SmartFactoryV2
-- Screen: [B723 / B725] Kiểm kê cuối tháng / Hạng mục kiểm kê
-- Target Table: STB_VN_ITEM_CHECK
-- Backup Table: BAK_STB_VN_ITEM_CHECK_20260902_B725
-- Purpose: Backup và Xóa 15 dòng dữ liệu kiểm kê Điện cực Bắc Ninh (ElectrodeBN) nhập ngày 2026-09-02 (ID 47788 - 47802)
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- ==============================================================================
-- 1. [BACKUP] TẠO BẢNG BACKUP DỮ LIỆU TRƯỚC KHI XÓA
-- ==============================================================================
PRINT N'--- [1. TẠO BẢNG BACKUP] ---';

-- Nếu bảng backup đã tồn tại thì xóa trước khi tạo mới
IF OBJECT_ID(N'BAK_STB_VN_ITEM_CHECK_20260902_B725', N'U') IS NOT NULL
BEGIN
    DROP TABLE BAK_STB_VN_ITEM_CHECK_20260902_B725;
END

-- Sao lưu toàn bộ 15 dòng dữ liệu cần xóa vào bảng backup
SELECT *
INTO BAK_STB_VN_ITEM_CHECK_20260902_B725
FROM STB_VN_ITEM_CHECK WITH(NOLOCK)
WHERE ID BETWEEN 47788 AND 47802;

PRINT N'-> Đã sao lưu dữ liệu vào bảng BAK_STB_VN_ITEM_CHECK_20260902_B725: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng.';

-- ==============================================================================
-- 2. [BEFORE] SELECT KHẢO SÁT 15 DÒNG CẦN XÓA
-- ==============================================================================
PRINT N'--- [2. KHẢO SÁT DỮ LIỆU CẦN XÓA] ---';
SELECT 
    ID, DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, CODENAME, INPUT, QTY, CreateDateTime, CreateUserID
FROM STB_VN_ITEM_CHECK WITH(NOLOCK)
WHERE ID BETWEEN 47788 AND 47802
ORDER BY ID ASC;

-- ==============================================================================
-- 3. [EXECUTION] XÓA DỮ LIỆU THEO DẢI ID 47788 - 47802
-- ==============================================================================
PRINT N'--- [3. TIẾN HÀNH XÓA DỮ LIỆU] ---';
DELETE FROM STB_VN_ITEM_CHECK
WHERE ID BETWEEN 47788 AND 47802;

PRINT N'-> Số dòng đã xóa từ STB_VN_ITEM_CHECK: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng.';

-- ==============================================================================
-- 4. [AFTER] KIỂM TRA LẠI SỐ DÒNG CÒN LẠI TRONG BẢNG GỐC (Kỳ vọng: 0 dòng)
-- ==============================================================================
PRINT N'--- [4. KIỂM TRA LẠI BẢNG GỐC SAU KHI XÓA] ---';
SELECT 
    ID, DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, CODENAME, INPUT, QTY, CreateDateTime, CreateUserID
FROM STB_VN_ITEM_CHECK WITH(NOLOCK)
WHERE ID BETWEEN 47788 AND 47802;

-- ==============================================================================
-- 5. [VERIFY BACKUP] KIỂM TRA LẠI BẢNG BACKUP
-- ==============================================================================
PRINT N'--- [5. KIỂM TRA DỮ LIỆU TRONG BẢNG BACKUP] ---';
SELECT 
    ID, DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, CODENAME, INPUT, QTY, CreateDateTime, CreateUserID
FROM BAK_STB_VN_ITEM_CHECK_20260902_B725 WITH(NOLOCK)
ORDER BY ID ASC;

-- ==============================================================================
-- 6. [CONTROL] COMMIT TRANSACTION ĐỂ LƯU THAY ĐỔI LÊN DATABASE
-- ==============================================================================
-- ROLLBACK TRANSACTION;
COMMIT TRANSACTION;
GO


