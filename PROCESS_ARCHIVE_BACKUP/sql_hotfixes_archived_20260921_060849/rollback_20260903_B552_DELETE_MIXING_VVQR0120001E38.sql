-- ==============================================================================
-- ROLLBACK SCRIPT: B552_DELETE_MIXING_VVQR0120001E38
-- Date: 2026-09-03
-- Target Database: SmartFactoryV2
-- Purpose: Khôi phục lại toàn bộ dữ liệu Mixing của Lot VVQR0120001E38 nếu cần
-- Source: Snapshot tools/backups/preflight_20260903_084718_...
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. Khôi phục STB_SetInfo
IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = 'VVQR0120001E38')
BEGIN
    INSERT INTO STB_SetInfo (
        ControlNo, PONo, DayPlanNo, MaterialCode, SetSeq, IsLineInput, IsLoss, IsDefect,
        Barcode, DefectQty, IsProdFinish, IsOutboundFinalInspection, IsFinalInspection,
        GradeCode, ProdQty, SIExtText01, CreateDateTime, CreateUserID
    ) VALUES (
        '20260901000245', '260818000005', '2026090100015', 'CREHCO85', 1, 0, 0, 0,
        'VVQR0120001E38', 0, 0, 0, 0,
        'A', 1.0, '', '2026-09-01 22:16:59', 'eai'
    );
END

-- 2. Khôi phục STB_ElectrodeMixInfo
IF NOT EXISTS (SELECT 1 FROM STB_ElectrodeMixInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = 'VVQR0120001E38')
BEGIN
    INSERT INTO STB_ElectrodeMixInfo (
        ElectrodeLotNumber, ViscosityResult, CreateDateTime
    ) VALUES (
        'VVQR0120001E38', 'NG', '2026-09-01 23:32:30.910'
    );
END

-- 3. Khôi phục STB_ElectrodeMixStepInfo (10 bước cân)
IF NOT EXISTS (SELECT 1 FROM STB_ElectrodeMixStepInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = 'VVQR0120001E38')
BEGIN
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode, InputQty1, InputQty2, MaterialLotNumber, CreateDateTime, CreateUserID
    ) VALUES 
    ('VVQR0120001E38', 'D', 1, 'GAHCCA-001', 30.11000, 0.00000, 'ML20260623000313', '2026-09-01 23:32:30.910', 'eai'),
    ('VVQR0120001E38', 'D', 2, 'GAHCCA-001', 30.11000, 0.00000, 'ML20260623000313', '2026-09-01 23:32:40.597', 'eai'),
    ('VVQR0120001E38', 'D', 3, 'GATCCC-001', 4.18200, 0.00000, 'ML20260605000012', '2026-09-01 23:40:18.790', 'eai'),
    ('VVQR0120001E38', 'D', 4, 'GAADCB-001', 0.26000, 0.00000, 'ML20260616000749', '2026-09-01 23:42:40.910', 'eai'),
    ('VVQR0120001E38', 'G', 1, 'GADACB-001', 33.41000, 0.00000, 'ML20260717000123', '2026-09-01 23:36:42.180', 'eai'),
    ('VVQR0120001E38', 'G', 2, 'GADACB-001', 33.41000, 0.00000, 'ML20260717000123', '2026-09-01 23:36:50.040', 'eai'),
    ('VVQR0120001E38', 'G', 3, 'WTRN01-001', 23.06800, 0.00000, 'VJJWTRN01-001#01', '2026-09-01 23:43:30.140', 'eai'),
    ('VVQR0120001E38', 'K', 1, 'WTRN01-001', 9.03400, 0.00000, 'VJJWTRN01-001#01', '2026-09-01 23:45:44.220', 'eai'),
    ('VVQR0120001E38', 'S', 1, 'WTRN01-001', 10.03000, 0.00000, 'VJJWTRN01-001#01', '2026-09-02 00:06:35.340', 'eai'),
    ('VVQR0120001E38', 'S', 2, 'GAZOCB-001', 7.79800, 0.00000, 'ML20260707000189', '2026-09-02 00:07:56.550', 'eai');
END

COMMIT TRANSACTION;
GO
