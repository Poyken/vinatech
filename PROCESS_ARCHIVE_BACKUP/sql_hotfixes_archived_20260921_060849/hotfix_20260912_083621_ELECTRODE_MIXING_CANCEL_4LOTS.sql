-- ==============================================================================
-- HOTFIX SCRIPT: ELECTRODE_MIXING_CANCEL_4LOTS
-- Date: 2026-09-12 08:36:21
-- Target Database: SmartFactoryV2
-- Screen: [B470] / [B552] / electrode.weighing
-- Lots: VVQR1120001E49, VVQR1120001E48, VVQR1120001E44, VVQR1120001E45
-- Reason: Xoa cac me can dien cuc thua (Mixing) do khong dung den theo yeu cau san xuat
-- Pre-flight check: STB_ElectrodeCoatingInfo = 0 (Chua trang Coating)
-- Reference: KB_09 [B552] #3 & KB_05_01 8.10
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [XOA BUOC CAN MIXING] Xoa du lieu cac buoc can tam cua 4 Lot dien cuc thua
DELETE FROM STB_ElectrodeMixStepInfo
WHERE ElectrodeLotNumber IN ('VVQR1120001E49', 'VVQR1120001E48', 'VVQR1120001E44', 'VVQR1120001E45');

-- 2. [PHONG NGUA DU THUA] Xoa thong tin me tron neu co phat sinh
DELETE FROM STB_ElectrodeMixInfo
WHERE ElectrodeLotNumber IN ('VVQR1120001E49', 'VVQR1120001E48', 'VVQR1120001E44', 'VVQR1120001E45');

-- 3. [PHONG NGUA DU THUA] Xoa ma Barcode SetInfo neu co
DELETE FROM STB_SetInfo
WHERE Barcode IN ('VVQR1120001E49', 'VVQR1120001E48', 'VVQR1120001E44', 'VVQR1120001E45');

COMMIT TRANSACTION;
GO
