-- ========================================
-- SCRIPT 2: THÊM 7 MÃ LỖI MỚI VÀO B530 BG
-- Bảng: STB_DefectInfo
-- Màn hình: B530 — Nhà máy BG
-- Ngày: 2026-06-04
-- Tác giả: vanduc
-- ========================================
-- HƯỚNG DẪN: Chạy từng bước trên SSMS
-- Bước 1: Kiểm tra mã chưa tồn tại → Bước 2: INSERT trong TRAN → Bước 3: Verify → COMMIT/ROLLBACK

-- =====================
-- BƯỚC 1: KIỂM TRA MÃ CHƯA TỒN TẠI
-- =====================
SELECT DefectCode, BasicDefectName FROM STB_DefectInfo
WHERE DefectCode IN (
    'V-22_BM_BG',   -- Winding: Xocha đen đầu đáy
    'V-23_DV_BG',   -- Rubber: Dập vỡ Tancha pan
    'V-23_RD_BG',   -- Rubber: Rách đáy xocha
    'V-23_XZ3_BG',  -- Riveting: Thiếu thừa vòng đệm
    'V-24_NE6_BG',  -- Curling: NG thừa thiếu cân nặng
    'V-24_NE7_BG',  -- Curling: Xước chân tancha
    'V-24_NE8_BG'   -- Curling: Lỗi mẻ miệng curling
);
-- KỲ VỌNG: 0 rows (chưa tồn tại)

-- =====================
-- BƯỚC 2: INSERT (TRONG TRANSACTION)
-- =====================
BEGIN TRAN;

-- 1. Winding - Xocha đen đầu đáy (V-22_BG)
INSERT INTO STB_DefectInfo (DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, DisplayIndex, IsRealDefect, IsUsed, DirectlyUnder, WorkCenterCode, DefectEnglishName, CreateDateTime, CreateUserID)
VALUES ('V-22_BM_BG', N'Winding_Xocha đen đầu đáy', N'The product has black marks on the top and bottom', 'V-22_BG', 70020, 0, 1, 'Production_Defect', 'VVT_F2', 'Winding_Xocha black marks top bottom', GETDATE(), 'vanduc');

-- 2. Rubber - Dập vỡ Tancha pan (V-23_BG)
INSERT INTO STB_DefectInfo (DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, DisplayIndex, IsRealDefect, IsUsed, DirectlyUnder, WorkCenterCode, DefectEnglishName, CreateDateTime, CreateUserID)
VALUES ('V-23_DV_BG', N'Rubber/riveting_Dập vỡ Tancha pan', N'ATL bent or broke when stamped', 'V-23_BG', 50040, 0, 1, 'Production_Defect', 'VVT_F2', 'Rubber/riveting_ATL bent or broke when stamped', GETDATE(), 'vanduc');

-- 3. Rubber - Rách đáy xocha khi đưa vào vỏ nhôm (V-23_BG)
INSERT INTO STB_DefectInfo (DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, DisplayIndex, IsRealDefect, IsUsed, DirectlyUnder, WorkCenterCode, DefectEnglishName, CreateDateTime, CreateUserID)
VALUES ('V-23_RD_BG', N'Rubber/riveting_Rách đáy xocha khi đưa vào vỏ nhôm', N'The bottom of the xocha (paper tear) when inserted into the aluminum casing', 'V-23_BG', 50041, 0, 1, 'Production_Defect', 'VVT_F2', 'Rubber/riveting_Xocha bottom paper tear', GETDATE(), 'vanduc');

-- 4. Riveting - Thiếu thừa vòng đệm (V-23_BG) — thay thế V-23_XZ2_BG cũ
INSERT INTO STB_DefectInfo (DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, DisplayIndex, IsRealDefect, IsUsed, DirectlyUnder, WorkCenterCode, DefectEnglishName, CreateDateTime, CreateUserID)
VALUES ('V-23_XZ3_BG', N'Riveting_Thiếu thừa vòng đệm', N'Insufficient or excessive gasket', 'V-23_BG', 50042, 0, 1, 'Production_Defect', 'VVT_F2', 'Riveting_Insufficient or excessive gasket', GETDATE(), 'vanduc');

-- 5. Curling - NG thừa thiếu cân nặng (V-24_BG)
INSERT INTO STB_DefectInfo (DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, DisplayIndex, IsRealDefect, IsUsed, DirectlyUnder, WorkCenterCode, DefectEnglishName, CreateDateTime, CreateUserID)
VALUES ('V-24_NE6_BG', N'Curling_NG thừa thiếu cân nặng', N'Overweight or underweight', 'V-24_BG', 5020, 0, 1, 'Production_Defect', 'VVT_F2', 'Curling_Overweight or underweight', GETDATE(), 'vanduc');

-- 6. Curling - Xước chân tancha (V-24_BG)
INSERT INTO STB_DefectInfo (DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, DisplayIndex, IsRealDefect, IsUsed, DirectlyUnder, WorkCenterCode, DefectEnglishName, CreateDateTime, CreateUserID)
VALUES ('V-24_NE7_BG', N'Curling_Xước chân tancha', N'Lead terminal is Scrash', 'V-24_BG', 5021, 0, 1, 'Production_Defect', 'VVT_F2', 'Curling_Lead terminal scrash', GETDATE(), 'vanduc');

-- 7. Curling - Lỗi mẻ miệng curling (V-24_BG)
INSERT INTO STB_DefectInfo (DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, DisplayIndex, IsRealDefect, IsUsed, DirectlyUnder, WorkCenterCode, DefectEnglishName, CreateDateTime, CreateUserID)
VALUES ('V-24_NE8_BG', N'Curling_Lỗi mẻ miệng curling', N'Deformation around the mouth of the product', 'V-24_BG', 5022, 0, 1, 'Production_Defect', 'VVT_F2', 'Curling_Deformation around mouth', GETDATE(), 'vanduc');

SELECT @@ROWCOUNT AS RowsInserted;
-- KỲ VỌNG: 1 (row cuối), tổng 7 inserts

-- =====================
-- BƯỚC 3: VERIFY TRƯỚC KHI COMMIT
-- =====================
SELECT DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, IsUsed, WorkCenterCode
FROM STB_DefectInfo
WHERE DefectCode IN (
    'V-22_BM_BG', 'V-23_DV_BG', 'V-23_RD_BG', 'V-23_XZ3_BG',
    'V-24_NE6_BG', 'V-24_NE7_BG', 'V-24_NE8_BG'
);
-- KỲ VỌNG: 7 rows, tất cả IsUsed = 1

-- Nếu đúng → chạy dòng này:
-- COMMIT TRAN;

-- Nếu sai → chạy dòng này:
-- ROLLBACK TRAN;
