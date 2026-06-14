-- ========================================
-- SCRIPT 1: DISABLE 28 MÃ LỖI DƯ THỪA/TRÙNG LẶP
-- Bảng: STB_DefectInfo
-- Màn hình: B530 — Nhà máy BG
-- Ngày: 2026-06-04
-- Tác giả: vinaadmin
-- ========================================
-- HƯỚNG DẪN: Chạy từng bước trên SSMS
-- Bước 1: SELECT kiểm tra → Bước 2: UPDATE trong TRAN → Bước 3: Verify → COMMIT/ROLLBACK

-- =====================
-- BƯỚC 1: SELECT KIỂM TRA TRƯỚC
-- =====================
SELECT DefectCode, BasicDefectName, DefectGroupCode, IsUsed
FROM STB_DefectInfo
WHERE DefectCode IN (
    -- Winding (V-22_BG): 4 mã
    'V-22_CC_BG', 'V-22_X12_BG', 'V-22_Z03_BG', 'V-22_Z04_BG',
    -- Rubber/Riveting (V-23_BG): 8 mã
    'V-23_02_BG', 'V-23_2DR_BG', 'V-23_NE1_BG', 'V-23_NE2_BG',
    'V-23_QQ_BG', 'V-23_XZ2_BG', 'V-23_X12_BG', 'V-24_2RY_BG',
    -- Curling (V-24_BG): 6 mã
    'V-24_NE4_BG', 'V-24_22CT_BG', 'V-24_2CT_BG', 'V-24_2DR_BG',
    'V-24_5VV_BG', 'V-24_NE22_BG',
    -- Sleeving (V-25_BG): 4 mã
    'V-25_01_BG', 'V-25_2CT_BG', 'V-25_X03_BG', 'V-25_X12_BG',
    -- Ngoại quan (V-27_BG): 6 mã
    'V-27_ZC_BG', 'V-27_ZD_BG', 'V-27_4GV_BG',
    'V-27_5VI_BG', 'V-27_XP1_BG', 'V-27_RELY_BG'
)
ORDER BY DefectGroupCode, DefectCode;
-- KỲ VỌNG: 28 rows, tất cả IsUsed = 1

-- =====================
-- BƯỚC 2: UPDATE (TRONG TRANSACTION)
-- =====================
BEGIN TRAN;

UPDATE STB_DefectInfo
SET IsUsed = 0,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE DefectCode IN (
    'V-22_CC_BG', 'V-22_X12_BG', 'V-22_Z03_BG', 'V-22_Z04_BG',
    'V-23_02_BG', 'V-23_2DR_BG', 'V-23_NE1_BG', 'V-23_NE2_BG',
    'V-23_QQ_BG', 'V-23_XZ2_BG', 'V-23_X12_BG', 'V-24_2RY_BG',
    'V-24_NE4_BG', 'V-24_22CT_BG', 'V-24_2CT_BG', 'V-24_2DR_BG',
    'V-24_5VV_BG', 'V-24_NE22_BG',
    'V-25_01_BG', 'V-25_2CT_BG', 'V-25_X03_BG', 'V-25_X12_BG',
    'V-27_ZC_BG', 'V-27_ZD_BG', 'V-27_4GV_BG',
    'V-27_5VI_BG', 'V-27_XP1_BG', 'V-27_RELY_BG'
);

SELECT @@ROWCOUNT AS RowsUpdated;
-- KỲ VỌNG: 28

-- =====================
-- BƯỚC 3: VERIFY TRƯỚC KHI COMMIT
-- =====================
SELECT DefectCode, BasicDefectName, IsUsed
FROM STB_DefectInfo
WHERE DefectCode IN (
    'V-22_CC_BG', 'V-22_X12_BG', 'V-22_Z03_BG', 'V-22_Z04_BG',
    'V-23_02_BG', 'V-23_2DR_BG', 'V-23_NE1_BG', 'V-23_NE2_BG',
    'V-23_QQ_BG', 'V-23_XZ2_BG', 'V-23_X12_BG', 'V-24_2RY_BG',
    'V-24_NE4_BG', 'V-24_22CT_BG', 'V-24_2CT_BG', 'V-24_2DR_BG',
    'V-24_5VV_BG', 'V-24_NE22_BG',
    'V-25_01_BG', 'V-25_2CT_BG', 'V-25_X03_BG', 'V-25_X12_BG',
    'V-27_ZC_BG', 'V-27_ZD_BG', 'V-27_4GV_BG',
    'V-27_5VI_BG', 'V-27_XP1_BG', 'V-27_RELY_BG'
);
-- KỲ VỌNG: Tất cả IsUsed = 0

-- Nếu đúng → chạy dòng này:
-- COMMIT TRAN;

-- Nếu sai → chạy dòng này:
-- ROLLBACK TRAN;
