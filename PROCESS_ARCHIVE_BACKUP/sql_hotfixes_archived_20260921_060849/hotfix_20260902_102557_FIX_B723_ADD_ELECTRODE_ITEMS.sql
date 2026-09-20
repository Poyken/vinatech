-- ==============================================================================
-- HOTFIX SCRIPT: FIX_B723_ADD_ELECTRODE_ITEMS
-- Date: 2026-09-02
-- Target Database: SmartFactoryV2
-- Screen: [B723] Hạng mục kiểm kê (CheckItems)
-- Table: STB_VN_ITEM_CHECK
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- ==============================================================================
-- 1. [BEFORE] KHẢO SÁT HIỆN TRẠNG CÁC BẢN GHI 0820-LOW VÀ CÁC MÃ LIÊN QUAN
-- ==============================================================================
PRINT N'--- [1. HIỆN TRẠNG TRƯỚC KHI XỬ LÝ] ---';
SELECT 
    ID, DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, CODENAME, INPUT, UNIT 
FROM STB_VN_ITEM_CHECK WITH(NOLOCK)
WHERE INPUT LIKE N'%0820-low%' OR CODENAME IN (N'SRFYL85', N'SREBL85L', N'CREYO85B', N'SRFYN85L', N'SREBO85L', N'CRECO85A', N'CREBK85L', N'CRFBO83', N'CRNCM85-001');

-- ==============================================================================
-- 2. [EXECUTION - PHẦN 1] CẬP NHẬT SỬA LỖI ĐỘ DÀY MODEL 0820-LOW
-- SREBO85 (200) -> SREBL85L (120)
-- SRFYO85 (180) -> SRFYL85 (120)
-- ==============================================================================
PRINT N'--- [2. TIẾN HÀNH SỬA ĐỘ DÀY MODEL 0820-LOW] ---';

-- Sửa Cuộn Dương (+)
UPDATE STB_VN_ITEM_CHECK
SET 
    CODENAME = N'SREBL85L',
    INPUT = N'BY85 120(A301) (độ rộng 13.7 -0820-low)(+)',
    ChangeDateTime = GETDATE(),
    ChangeUserID = N'ADMIN'
WHERE 
    CODENAME = N'SREBO85' 
    AND INPUT LIKE N'%0820-low%(+)%';

-- Sửa Cuộn Âm (-)
UPDATE STB_VN_ITEM_CHECK
SET 
    CODENAME = N'SRFYL85',
    INPUT = N'YP 85 120(A301)(độ rộng 13.7 -0820-low)(-)',
    ChangeDateTime = GETDATE(),
    ChangeUserID = N'ADMIN'
WHERE 
    CODENAME = N'SRFYO85' 
    AND INPUT LIKE N'%0820-low%(-)%';

-- ==============================================================================
-- 3. [EXECUTION - PHẦN 2] BỔ SUNG CÁC MÃ ĐIỆN CỰC MỚI VÀO BẢNG HẠNG MỤC KIỂM KÊ
-- Áp dụng cho Chuyền: ElectrodeBN (Điện cực Bắc Ninh) & VVC-ELECTRODE-LINE (Điện cực VN)
-- ==============================================================================
PRINT N'--- [3. TIẾN HÀNH BỔ SUNG DANH SÁCH MÃ MỚI] ---';

-- Bảng tạm chứa danh sách mã cần thêm
DECLARE @NewItems TABLE (
    CODENAME NVARCHAR(50),
    INPUT NVARCHAR(500),
    UNIT NVARCHAR(20)
);

INSERT INTO @NewItems (CODENAME, INPUT, UNIT) VALUES
(N'SRFYL85',     N'YP 85 120(A301)(độ rộng 13.7 -0820-low)(-)',            N'M'),
(N'SREBL85L',    N'BY85 120(A301) (độ rộng 13.7 -0820-low)(+)',            N'M'),
(N'CREYO85B',    N'Coating-Roll Etching -YP 85 200(A-401D) (+)',            N'M'),
(N'SRFYN85L',    N'YP 180 (Độ rộng 23.7 -1030-10F LOW) cuộn âm',           N'M'),
(N'SREBO85L',    N'BY 85 200 (Độ rộng 23.7 -1030-10F LOW) cuộn dương',      N'M'),
(N'CRECO85A',    N'Coating - Roll Etching - CY85 200 (+) A301',             N'M'),
(N'CREBK85L',    N'Điện cực BY 116 (A301) Cuộn Dương',                      N'M'),
(N'CRFBO83',     N'Điện cực BA21E-200 Cuộn âm',                             N'M'),
(N'CRNCM85-001', N'Coatingroll-NCM 85 (VPC) (+)',                           N'M');

-- 3.1 Bổ sung cho Chuyền ElectrodeBN (Điện cực Bắc Ninh)
INSERT INTO STB_VN_ITEM_CHECK (
    DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, REMARK, CODENAME, INPUT, UNIT, CreateDateTime, CreateUserID
)
SELECT 
    N'SẢN XUẤT', N'ElectrodeBN', N'Điện cực Bắc Ninh', N'Điện cực Việt Nam', N'NVL', N'', n.CODENAME, n.INPUT, n.UNIT, GETDATE(), N'ADMIN'
FROM @NewItems n
WHERE NOT EXISTS (
    SELECT 1 FROM STB_VN_ITEM_CHECK c WITH(NOLOCK)
    WHERE c.CODELINE = N'ElectrodeBN' AND c.CODENAME = n.CODENAME AND c.INPUT = n.INPUT
);

-- 3.2 Bổ sung cho Chuyền VVC-ELECTRODE-LINE (Line điện cực Việt Nam)
INSERT INTO STB_VN_ITEM_CHECK (
    DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, REMARK, CODENAME, INPUT, UNIT, CreateDateTime, CreateUserID
)
SELECT 
    N'SẢN XUẤT', N'VVC-ELECTRODE-LINE', N'베트남 전극라인 Line điện cực Việt Nam', N'Điện cực Việt Nam', N'NVL', N'', n.CODENAME, n.INPUT, n.UNIT, GETDATE(), N'ADMIN'
FROM @NewItems n
WHERE NOT EXISTS (
    SELECT 1 FROM STB_VN_ITEM_CHECK c WITH(NOLOCK)
    WHERE c.CODELINE = N'VVC-ELECTRODE-LINE' AND c.CODENAME = n.CODENAME AND c.INPUT = n.INPUT
);

-- ==============================================================================
-- 4. [AFTER] KIỂM TRA LẠI DỮ LIỆU SAU KHI XỬ LÝ
-- ==============================================================================
PRINT N'--- [4. KIỂM TRA LẠI KẾT QUẢ SAU XỬ LÝ] ---';
SELECT 
    ID, DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, CODENAME, INPUT, UNIT 
FROM STB_VN_ITEM_CHECK WITH(NOLOCK)
WHERE CODENAME IN (N'SRFYL85', N'SREBL85L', N'CREYO85B', N'SRFYN85L', N'SREBO85L', N'CRECO85A', N'CREBK85L', N'CRFBO83', N'CRNCM85-001')
ORDER BY ID DESC;

-- ==============================================================================
-- 5. [CONTROL] COMMIT TRANSACTION ĐỂ LƯU THAY ĐỔI VÀO CSDL
-- ==============================================================================
-- ROLLBACK TRANSACTION;
COMMIT TRANSACTION;
GO

