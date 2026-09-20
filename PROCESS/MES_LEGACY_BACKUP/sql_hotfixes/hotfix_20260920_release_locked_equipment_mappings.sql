-- ==============================================================================
-- HOTFIX SCRIPT: RELEASE_LOCKED_EQUIPMENT_MAPPINGS
-- Mục đích: Giải phóng 7 máy Hưng Yên (4 Winding, 1 Curling, 2 Sleeving) đang bị kẹt
--           trạng thái ACTIVE từ các Kế hoạch sản xuất cũ trong VINATECH_POP
--           để hiển thị đầy đủ trên POP Kiosk cho Model 35105.
-- Bảng tác động: VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING
-- Người thực hiện: vanduc
-- Ngày lập: 2026-09-20
-- ==============================================================================

USE VINATECH_POP;
GO

BEGIN TRANSACTION;

UPDATE VINA_EQUIPMENT_MAPPING
SET 
    MAPPING_STATUS      = 'RELEASED',
    RELEASED_AT         = GETDATE(),
    RELEASE_REASON      = N'Release cho Model 35105',
    NO_EMP_MODIFYER     = 'vanduc',
    CD_COMPANY_MODIFYER = 'VINA'
WHERE MAPPING_ID IN (
    2298, -- VVMHY143 (Winding C#10-01) - Plan 2026091400057
    2416, -- VVMHY40  (Winding C#2-02)  - Plan 2026091600055
    2239, -- VVMHY130 (Winding C#9-01)  - Plan 2026091400050
    2240, -- VVMHY131 (Winding C#9-02)  - Plan 2026091400050
    2346, -- VVMHY134 (Curling C#9)     - Plan 2026091400051
    2360, -- VVMHY26  (Sleeving C#1)    - Plan 2026091400039
    2352  -- VVMHY148 (Sleeving C#10)   - Plan 2026091400057
)
AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');

-- Kiểm tra số bản ghi tác động
IF @@ROWCOUNT = 7
BEGIN
    COMMIT TRANSACTION;
    PRINT '>> RELEASE THANH CONG 7 MAY BI KET TRANG THAI ACTIVE.';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT '>> SO DONG TAC DONG KHONG DUNG 7, DA ROLLBACK.';
END
GO
