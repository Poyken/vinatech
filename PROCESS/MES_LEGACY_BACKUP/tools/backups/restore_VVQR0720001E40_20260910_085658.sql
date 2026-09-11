USE SmartFactoryV2;
GO

-- RESTORE SCRIPT FOR LOT: VVQR0720001E40
-- Backup Date: 2026-09-10 08:57:03
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Restore STB_ElectrodeMixStepInfo
    DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'VVQR0720001E40';
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'D', 1, 'GAKCCA-002',
        9.15400, 0.00000, 'ML20260725001004', '09/07/2026 20:28:41', '09/07/2026 20:28:41',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'G', 1, 'GADACB-001',
        17.19000, 0.00000, 'ML20260717000123', '09/08/2026 00:04:26', '09/08/2026 00:04:26',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'G', 2, 'GAZOCB-001',
        1.32400, 0.00000, 'ML20260707000157', '09/08/2026 00:07:49', '09/08/2026 00:07:49',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'D', 2, 'GAPOCA-006',
        6.00000, 0.00000, 'ML20260812000060', '09/07/2026 20:29:29', '09/07/2026 20:29:29',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'D', 3, 'GATCCC-001',
        1.32400, 0.00000, 'ML20260605000012', '09/07/2026 20:36:29', '09/07/2026 20:36:29',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'G', 3, 'GADPCB-002',
        0.86400, 0.00000, 'ML20260701000133', '09/08/2026 00:10:10', '09/08/2026 00:10:10',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'G', 4, 'VJJWTRN01-001',
        6.99600, 0.00000, 'VJJWTRN01-001#01', '09/08/2026 00:12:50', '09/08/2026 00:12:50',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQR0720001E40', 'D', 4, 'VJJGAADCB-001',
        0.06600, 0.00000, 'ML20260616000749', '09/07/2026 20:39:48', '09/07/2026 20:39:48',
        GETDATE(), N'RESTORE_USER'
    );
    COMMIT TRANSACTION;
    PRINT '==> [RESTORE SUCCESS] Da phuc hoi thanh cong du lieu ve trang thai goc!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@Err, 16, 1);
END CATCH;
GO