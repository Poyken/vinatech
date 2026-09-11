USE SmartFactoryV2;
GO

-- RESTORE SCRIPT FOR LOT: VVQQ2520001E79
-- Backup Date: 2026-09-11 08:34:45
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Restore STB_ElectrodeMixStepInfo
    DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'VVQQ2520001E79';
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'COAT', 1, 'GAJCFO-002',
        615.00000, 0.00000, 'ML20260708000024', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'D', 1, 'GAHCCA-001',
        30.30000, 0.00000, 'ML20260623000314', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'K', 1, 'WTRN01-001',
        9.09000, 0.00000, '', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'S', 1, 'WTRN01-001',
        10.10000, 0.00000, '', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'G', 1, 'GADACB-001',
        34.01700, 0.00000, 'ML20260717000104', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'G', 2, 'GADACB-001',
        33.43200, 0.00000, 'ML20260717000114', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'S', 2, 'GAZOCB-001',
        7.87000, 0.00000, 'ML20260707000106', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'D', 2, 'GAHCCA-001',
        30.30000, 0.00000, 'ML20260623000314', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'D', 3, 'GATCCC-001',
        4.22200, 0.00000, 'ML20260605000009', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'S', 3, 'GADPCB-002',
        1.72000, 0.00000, 'ML20260701000112', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'G', 3, 'WTRN01-001',
        23.23000, 0.00000, '', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'S', 4, 'WTRN01-001',
        14.14000, 0.00000, '', '', '',
        GETDATE(), N'RESTORE_USER'
    );
    INSERT INTO STB_ElectrodeMixStepInfo (
        ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode,
        InputQty1, InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime,
        CreateDateTime, CreateUserID
    ) VALUES (
        'VVQQ2520001E79', 'D', 4, 'GAADCB-001',
        0.26300, 0.00000, 'ML20260616000749', '', '',
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