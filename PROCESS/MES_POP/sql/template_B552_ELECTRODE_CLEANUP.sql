-- ==============================================================================
-- TEMPLATE: B552 XOA ME TRON / CUON DIEN CUC (ELECTRODE MIXING / SLITTING)
-- Thay the: {{ELECTRODE_LOT_NUMBER}}, {{SEQ_START}}, {{SEQ_END}}
-- Mode: MIXING (xoa me tron) hoac SLITTING (xoa cuon cat)
-- Tham chieu: KB_09 § B552, KB_05_01 § 8.10
-- ==============================================================================
-- HUONG DAN: 
--   1. Thay tat ca {{ELECTRODE_LOT_NUMBER}} bang ma Lot dien cuc thuc te
--   2. Neu la MIXING: Chay Block A (xoa MixStep + MixInfo + SetInfo)
--   3. Neu la SLITTING: Chay Block B (xoa SlittingResult theo Seq range)
--   4. Luon ROLLBACK truoc, chi COMMIT khi chac chan
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- ===================== BLOCK A: XOA ME TRON (MIXING) ========================
-- Chi chay block nay khi can xoa me tron dien cuc
-- Dieu kien: STB_ElectrodeCoatingInfo PHAI = 0 (chua trang phu Coating)

-- A0. [PRE-CHECK] Kiem tra Coating da chay chua (PHAI = 0 moi duoc xoa)
SELECT COUNT(*) AS CoatingCount 
FROM STB_ElectrodeCoatingInfo WITH(NOLOCK) 
WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';

-- A1. [BEFORE] Khao sat hien trang
SELECT ElectrodeLotNumber, Seq, StepName, InputQty, CreateDateTime 
FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) 
WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';

SELECT ElectrodeLotNumber, MixQty, CreateDateTime 
FROM STB_ElectrodeMixInfo WITH(NOLOCK) 
WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';

-- A2. [EXECUTION] Xoa chi tiet buoc can
DELETE FROM STB_ElectrodeMixStepInfo 
WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';

-- A3. [EXECUTION] Xoa header me tron
DELETE FROM STB_ElectrodeMixInfo 
WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';

-- A4. [EXECUTION] Xoa SetInfo (ma khoi tao Lot thung)
DELETE FROM STB_SetInfo 
WHERE Barcode = '{{ELECTRODE_LOT_NUMBER}}';

-- A5. [AFTER] Xac minh = 0 dong
SELECT COUNT(*) AS RemainMixStep FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';
SELECT COUNT(*) AS RemainMixInfo FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';


-- ===================== BLOCK B: XOA CUON CAT (SLITTING) =====================
-- Chi chay block nay khi can xoa ket qua cat dien cuc theo Seq range
-- Thay the: {{SEQ_START}} va {{SEQ_END}}

-- B1. [BEFORE] Khao sat hien trang
-- SELECT ElectrodeLotNumber, Seq, SlittingCode, SlittingWidth, CreateDateTime
-- FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
-- WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}' AND Seq BETWEEN {{SEQ_START}} AND {{SEQ_END}};

-- B2. [AUDIT LOG] Ghi luu vet lich su truoc khi xoa
-- INSERT INTO STB_ElectrodeSlittingResultHist (ElectrodeLotNumber, Seq, Flag, CreateDateTime, CreateUserID)
-- SELECT ElectrodeLotNumber, Seq, 'DELETE', GETDATE(), N'SYSTEM_AI_FIX'
-- FROM STB_ElectrodeSlittingResult WITH(NOLOCK)
-- WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}' AND Seq BETWEEN {{SEQ_START}} AND {{SEQ_END}};

-- B3. [EXECUTION] Xoa cac dong ket qua cat thua
-- DELETE FROM STB_ElectrodeSlittingResult
-- WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}' AND Seq BETWEEN {{SEQ_START}} AND {{SEQ_END}};

-- B4. [AFTER] Kiem tra so dong con lai
-- SELECT COUNT(*) AS RemainSlitting FROM STB_ElectrodeSlittingResult WITH(NOLOCK) WHERE ElectrodeLotNumber = '{{ELECTRODE_LOT_NUMBER}}';


-- [CONTROL] MAC DINH ROLLBACK (CHUYEN SANG COMMIT KHI CHAC CHAN)
ROLLBACK TRANSACTION;
-- COMMIT TRANSACTION;
GO
