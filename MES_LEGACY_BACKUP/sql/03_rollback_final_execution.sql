-- ==============================================================================
-- 03_rollback_final_execution.sql — KHÔI PHỤC DỮ LIỆU NGUYÊN TRẠNG TỪ SNAPSHOT FINAL
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Khôi phục STB_ProdRouteHist theo đúng khóa chính ProdRouteHistNo
    UPDATE PRH
    SET 
        PRH.WorkCenterCode = BK.WorkCenterCode,
        PRH.JobDate        = BK.JobDate,
        PRH.ProdDateTime   = BK.ProdDateTime,
        PRH.ChangeDateTime = BK.ChangeDateTime,
        PRH.ChangeUserID   = BK.ChangeUserID,
        PRH.ShiftCode      = BK.ShiftCode,
        PRH.WorkerCode     = BK.WorkerCode,
        PRH.MachineCode    = BK.MachineCode,
        PRH.ProdQty        = BK.ProdQty,
        PRH.CompleteRoute  = BK.CompleteRoute
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.BK_FINAL_20260821_STB_ProdRouteHist BK WITH (NOLOCK)
        ON PRH.ProdRouteHistNo = BK.ProdRouteHistNo
    WHERE PRH.ProdRouteHistNo IN (SELECT ProdRouteHistNo FROM dbo.BK_FINAL_20260821_STB_ProdRouteHist);

    -- 2. Khôi phục STB_SavePackingTime_VVT theo khóa chính id
    UPDATE SPT
    SET 
        SPT.PrintTime   = BK.PrintTime,
        SPT.EmpNo       = BK.EmpNo,
        SPT.EmpChange   = BK.EmpChange,
        SPT.PackQty     = BK.PackQty,
        SPT.isPrinted   = BK.isPrinted
    FROM dbo.STB_SavePackingTime_VVT SPT WITH (UPDLOCK)
    INNER JOIN dbo.BK_FINAL_20260821_STB_SavePackingTime_VVT BK WITH (NOLOCK)
        ON SPT.id = BK.id
    WHERE SPT.id IN (SELECT id FROM dbo.BK_FINAL_20260821_STB_SavePackingTime_VVT);

    COMMIT TRANSACTION;
    PRINT 'ROLLBACK VE NGUYEN TRANG HOAN TAT THANH CONG!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI ROLLBACK: %s', 16, 1, @ErrMsg);
END CATCH;
