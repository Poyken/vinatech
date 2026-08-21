-- ==============================================================================
-- 03_rollback_script.sql — Script Khôi Phục Dữ Liệu Về Nguyên Trạng Từ Backup
-- ==============================================================================
BEGIN TRAN;
BEGIN TRY
    -- 1. Rollback STB_ProdRouteHist
    UPDATE PRH
    SET PRH.JobDate = BK.JobDate,
        PRH.ProdDateTime = BK.ProdDateTime,
        PRH.ChangeDateTime = BK.ChangeDateTime,
        PRH.ChangeUserID = BK.ChangeUserID
    FROM dbo.STB_ProdRouteHist PRH
    INNER JOIN dbo.BK_20260821_HY_STB_ProdRouteHist BK 
        ON PRH.ControlNo = BK.ControlNo AND PRH.RouteCode = BK.RouteCode;

    -- 2. Rollback STB_SavePackingTime_VVT
    UPDATE SPT
    SET SPT.PrintTime = BK.PrintTime,
        SPT.EmpNo = BK.EmpNo,
        SPT.EmpChange = BK.EmpChange,
        SPT.PackQty = BK.PackQty
    FROM dbo.STB_SavePackingTime_VVT SPT
    INNER JOIN dbo.BK_20260821_HY_STB_SavePackingTime_VVT BK
        ON SPT.id = BK.id;

    COMMIT TRAN;
    PRINT 'ROLLBACK DU LIEU VE BAN SNAPSHOT HOAN TAT THANH CONG!';
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI ROLLBACK: %s', 16, 1, @ErrMsg);
END CATCH;
