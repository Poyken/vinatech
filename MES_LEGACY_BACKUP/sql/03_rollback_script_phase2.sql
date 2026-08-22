-- ==============================================================================
-- 03_rollback_script_phase2.sql — Khôi Phục Dữ Liệu Phase 2 Về Nguyên Trạng Từ Backup
-- ==============================================================================
BEGIN TRAN;
BEGIN TRY
    UPDATE SPT
    SET SPT.EmpNo = BK.EmpNo,
        SPT.EmpChange = BK.EmpChange,
        SPT.PrintTime = BK.PrintTime,
        SPT.PackQty = BK.PackQty
    FROM dbo.STB_SavePackingTime_VVT SPT
    INNER JOIN dbo.BK_20260821_PHASE2_STB_SavePackingTime_VVT BK
        ON SPT.id = BK.id;

    COMMIT TRAN;
    PRINT 'ROLLBACK PHASE 2 HOAN TAT THANH CONG!';
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI ROLLBACK PHASE 2: %s', 16, 1, @ErrMsg);
END CATCH;
