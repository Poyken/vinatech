-- ============================================================
-- BƯỚC 3: ĐĂNG KÍ MÀN HÌNH T4029 VÀ GÁN STORED PROCEDURE
-- Database: SmartFramework
-- ============================================================

USE SmartFramework;
GO

-- 1. Đăng kí màn hình vào STB_ScreenInfo
IF NOT EXISTS (SELECT 1 FROM STB_ScreenInfo WHERE Name = 'T4029')
BEGIN
    INSERT INTO STB_ScreenInfo (
        Name, ParentName, Caption, IsFolder, IsDialog, 
        ShowInMenu, CreateDateTime, CreateUserID, SystemCode
    )
    VALUES (
        'T4029', 
        'ROOT', -- Có thể đổi thành 'S' hoặc 'DucTest' tùy ý
        '^Sorting Error Data (T4029)^', 
        0, 0, 1, 
        GETDATE(), 'Antigravity', NULL
    );
    PRINT 'Đã đăng kí màn hình T4029';
END
ELSE
BEGIN
    UPDATE STB_ScreenInfo 
    SET Caption = '^Sorting Error Data (T4029)^', ParentName = 'ROOT'
    WHERE Name = 'T4029';
    PRINT 'Đã cập nhật thông tin màn hình T4029';
END

-- 2. Gán Stored Procedure vào STB_ScreenObjects
-- Xóa cũ nếu có để gán lại cho sạch
DELETE FROM STB_ScreenObjects WHERE ScreenName = 'T4029';

-- Gán SP Search (Lấy dữ liệu)
INSERT INTO STB_ScreenObjects (ScreenName, ObjectName, ObjectType, Description)
VALUES ('T4029', 'usp_VVT_SortingErrorData_get', 'SearchFunction', 'Lấy dữ liệu Sorting Error Data');

-- Gán SP Execute (Lưu/Xóa dữ liệu)
INSERT INTO STB_ScreenObjects (ScreenName, ObjectName, ObjectType, Description)
VALUES ('T4029', 'usp_VVT_SortingErrorData_iud', 'ExecuteFunction', 'Lưu/Xóa dữ liệu Sorting Error Data');

PRINT 'Đã gán Stored Procedure cho màn hình T4029 thành công!';
GO
